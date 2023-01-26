//
//  ChatElementDataSource.swift
//  kokonats
//
//  Created by iori on 2022/03/06.
//

import UIKit
import Kingfisher

enum ChatElementType: CaseIterable {
    case channel, user
    var cornerRadius: CGFloat {
        switch self {
        case .channel: return 10
        case .user: return 24
        }
    }
    
    var placeholder: String {
        switch self {
        case .channel: return "Enter Room Number"
        case .user:    return "Enter User Name"
        }
    }
    
    var name: String {
        switch self {
        case .channel: return "Room"
        case .user:    return "User"
        }
    }
    
    func fetch(completion: (([ChatElement]) -> ())? = nil) {
        switch self {
        case .channel:
            ChatManager.shared.getAllChannels() { channels in
                completion?(channels.map { ChatChannel(thread: $0) })
            }
            
        case .user:
            ChatManager.shared.getAllDMs { dms in
                completion?(dms.map { ChatUser(thread: $0) })
            }
        }
    }
}

protocol ChatElement {
    var elementType: ChatElementType { get }
    var thread: ChatThreadDocument { get }
    var name: String { get }
    var iconName: String? { get }
    var documentId: String? { get }
    func retrieveIcon(completion: @escaping (UIImage?) -> Void)
}

struct ChatChannel: ChatElement {
    let elementType: ChatElementType = .channel
    let thread: ChatThreadDocument
    var name: String { return thread.name }
    var iconName: String? { return nil }
    var documentId: String? { return thread.id }
    func retrieveIcon(completion: @escaping (UIImage?) -> Void) {
        if let data = thread.icon?.convertPngBase64ToData() {
            completion(UIImage(data: data))
        } else if let source = URL(string: thread.icon ?? "") {
            KingfisherManager.shared.retrieveImage(
                with: source,
                options: nil,
                progressBlock: nil,
                downloadTaskUpdated: nil) { result in
                    switch result {
                    case .success(let imageResult): completion(imageResult.image)
                    case .failure(let error):
                        Logger.debug(error.localizedDescription)
                        completion(nil)
                    }
                }
        } else {
            completion(nil)
        }
    }
}

struct ChatUser: ChatElement {
    let elementType: ChatElementType = .user
    let thread: ChatThreadDocument
    var name: String {
        if let user = thread.membersDetail?.first(where: { $0.id != AppData.shared.currentUser?.id }) {
            return user.userName ?? thread.name
        }
        return thread.name
    }
    var iconName: String? {
        if let user = thread.membersDetail?.first(where: { $0.id != AppData.shared.currentUser?.id }) {
            return "avatar_\(user.picture ?? "1")"
        }
        return nil
    }
    var documentId: String? { return thread.id }
    func retrieveIcon(completion: @escaping (UIImage?) -> Void) {
        completion(UIImage(named: iconName ?? ""))
    }
}

class ChatElementDataSource: NSObject {
    
    let type: ChatElementType
    private var isLoading: Bool = false
    private var canLoadMore: Bool = true // not supported currently.
    private var elems: [ChatElement] = []
    private var filteredElems: [ChatElement] {
        if let word = filterWord, !word.isEmpty {
            return elems.filter { $0.name.localizedStandardContains(word) }
        } else {
            return elems
        }
    }
    private var filterWord: String? = nil
    private var shouldReloadHandler: ActionHandler?
    
    init(type: ChatElementType) {
        self.type = type
        super.init()
    }
    
    func registerCells(_ tableView: UITableView, with updater: ActionHandler?) {
        tableView.register([ChatElementCell.self, LoadingCell.self])
        shouldReloadHandler = updater
        loadMoreIfNeeded()
        canLoadMore = false // no allow more loading
    }
    
    func loadMoreIfNeeded() {
        guard canLoadMore && !isLoading else { return }
        isLoading = true
        type.fetch(completion: { [weak self] list in
            self?.elems.append(contentsOf: list)
            self?.isLoading = false
            self?.shouldReloadHandler?()
        })
    }
    
    func getElement(for indexPath: IndexPath) -> ChatElement? {
        return filteredElems[safe: indexPath.row]
    }
    
    func search(text: String?) {
        filterWord = text
        shouldReloadHandler?()
    }
}

extension ChatElementDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredElems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard filteredElems.count >= indexPath.row else { fatalError("error: " + #function) }
        if filteredElems.count == indexPath.row {
            if let cell = tableView.dequeueReusableCell(withIdentifier: LoadingCell.className) as? LoadingCell {
                loadMoreIfNeeded()
                cell.confiture(isLoading: isLoading)
                return cell
            }
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: ChatElementCell.className) as? ChatElementCell,
           let elem = filteredElems[safe: indexPath.row] {
            cell.configure(element: elem)
            return cell
        }
        fatalError("never comes here.")
    }
}
