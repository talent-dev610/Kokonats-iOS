//
//  ChatMessageDataSource.swift
//  kokonats
//  
//  Created by iori on 2022/03/12
//  
    

import UIKit

protocol ChatMessageDelegate: NSObjectProtocol {
    func didTapIcon(message: ChatMessage)
}

class ChatMessageDataSource: NSObject {
    typealias MessageType = ChatMessageViewController.MessageType
    
    var documentId: String? {
        switch type {
        case .channel(threadId: let id): return id
        case .dm(threadId: let id, member: _): return id ?? createdDocId
        case .support: return createdDocId
        }
    }
    var members: [ChatMember] {
        switch type {
        case .channel(threadId: _), .support: return [] // not supported currently
        case .dm(threadId: _, member: let member): return [member]
        }
    }
    let type: MessageType
    private var createdDocId: String?
    private var userId: Int? { return AppData.shared.currentUser?.id }
    private var isLoading: Bool = false
    private var canLoadMore: Bool = true
    private var messages: [ChatMessage] = []
    private var shouldReloadHandler: ActionHandler?
    private let refreshControl = UIRefreshControl()
    private weak var delegate: ChatMessageDelegate?
    
    init(type: MessageType, delegate: ChatMessageDelegate) {
        self.type = type
        self.delegate = delegate
        super.init()
    }
    
    func registerCells(_ tableView: UITableView, with updater: ActionHandler?) {
        tableView.register([ChatMessageCell.self])
        shouldReloadHandler = updater
        loadMoreIfNeeded()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(self.loadMore), for: .valueChanged)
        tableView.refreshControl = refreshControl
        switch type {
        case .dm(let threadId, let member) where threadId == nil:
            ChatManager.shared.retrieveDMThreadId(partner: member) { [weak self] docId in
                self?.createdDocId = docId
                self?.startListening()
            }
        case .support:
            ChatManager.shared.retrieveSupportThreadId { [weak self] docId in
                self?.createdDocId = docId
                self?.startListening()
            }
        default: break
        }
    }
    
    func getCellHeight(for indexPath: IndexPath) -> CGFloat {
        guard let message = messages[safe: indexPath.row] else { return .zero }
        return ChatMessageCell.calcHeight(body: message.body)
    }
    
    func startListening() {
        guard let documentId = documentId else { return }
        ChatManager.shared.listenMessage(documentId) { [weak self] diffs in
            var shouldReload: Bool = false
            diffs.forEach { (type, message) in
                switch type {
                case .modified, .removed: break // not supported yet.
                case .added:
                    guard let messages = self?.messages else { return }
                    guard !messages.contains(where: { message.id == $0.id }) else {
                        Logger.debug("avoid: " + message.body)
                        return
                    }
                    self?.messages.append(message)
                    shouldReload = true
                }
            }
            if shouldReload {
                self?.shouldReloadHandler?()
            }
        }
    }
    
    func stopListening() {
        ChatManager.shared.unlistenMessage()
    }
    
    func submit(text: String, completion: CompletionHandler? = nil) {
        if let documentId = documentId {
            let hasBeenPosted = messages.contains(where: { $0.author.id == userId })
            ChatManager.shared.submitMessage(to: documentId, message: text, needToAddMe: !hasBeenPosted, completion: completion)
        } else {
            let postProcess: (String?) -> Void = { [weak self] docId in
                guard let docId = docId else {
                    completion?(false)
                    return
                }
                self?.createdDocId = docId
                ChatManager.shared.submitMessage(to: docId, message: text, needToAddMe: true) { success in
                    if success { self?.startListening() }
                    completion?(success)
                }
            }
            
            switch type {
            case .channel(_): completion?(false) // never comes here.
            case .dm(threadId: _, member: let member):
                ChatManager.shared.retrieveOrCreateDMThreadId(partner: member, completion: postProcess)
            case .support:
                ChatManager.shared.retrieveOrCreateSupportThreadIdForMe(completion: postProcess)
            }
        }
    }
    
    func getThreadName(completion: @escaping (String?) -> Void) {
        switch type {
        case .dm(_, let member):
            completion(member.userName)
        case .support:
            completion(nil)
        case .channel(_):
            getThread { completion($0?.name) }
        }
    }
    
    private func getThread(completion: @escaping (ChatThreadDocument?) -> Void) {
        guard let documentId = documentId else {
            completion(nil)
            return
        }
        
        ChatManager.shared.retrieveThread(id: documentId) { doc in
            completion(doc)
        }
    }
    
    private func loadMoreIfNeeded(completion: ActionHandler? = nil) {
        guard let documentId = documentId else { completion?(); return }
        guard canLoadMore && !isLoading else { completion?(); return }
        isLoading = true
        ChatManager.shared.getAllMessages(by: documentId) { [weak self] messages in
            self?.isLoading = false
            self?.canLoadMore = false // TODO: impl?
            self?.messages.removeAll()
            self?.messages.append(contentsOf: messages)
            self?.shouldReloadHandler?()
            completion?()
        }
    }
    
    @objc
    private func loadMore() {
        loadMoreIfNeeded() { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

extension ChatMessageDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard messages.count > indexPath.row else { fatalError("error: " + #function) }
        if let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.className) as? ChatMessageCell,
           let message = messages[safe: indexPath.row] {
            cell.configure(message: message) { [weak self] message in
                self?.delegate?.didTapIcon(message: message)
            }
            return cell
        }
        fatalError("never comes here.")
    }
}
