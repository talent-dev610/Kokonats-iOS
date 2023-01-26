//
//  ChatManager.swift
//  kokonats
//  
//  Created by iori on 2022/03/20
//  


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ChatMember: Codable, Hashable, Equatable {
    let id: Int?
    let picture: String?
    let userName: String?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ChatThreadDocument: Codable {
    // will be the same as ChatMessageDocument
    @DocumentID var id: String?
    
    let type: String
    let name: String
    let tournamentClassId: Int?
    let createdAt: Date?
    let lastSentAt: Date?
    let lastSentAuthorId: Int?
    let icon: String?
    let members: [Int] // Array<uid>
    let membersDetail: [ChatMember]?
}

typealias ChatMessage = ChatMessageDocument.Message
struct ChatMessageDocument: Codable {
    // will be the same as ChatThreadDocument
    @DocumentID var id: String?
    
    let messages: [Message] // collection
    
    struct Message: Codable {
        @DocumentID var id: String?
        
        let body: String
        let sentAt: Date
        let author: ChatMember
    }
}


class ChatManager {
    typealias DidChange = ([(DocumentChangeType, ChatMessage)]) -> Void
    
    static var shared = ChatManager()
    static let CS_ID = 0
    
    private var listener: ListenerRegistration?
    
    enum ChatCollectionName: String {
        case thread = "dev-chatThread"
        case message = "dev-chatMessage"
    }
    enum ChatThreadType: String {
        case channel = "PUBLIC"
        case dm      = "DM"
        case support = "CS"
    }
    
    private init() {}
    
    private func handleResult(snapShot: QuerySnapshot?, error: Error?) -> Result<QuerySnapshot, Error> {
        if let error = error {
            Logger.debug(#function + ": " + error.localizedDescription)
            return .failure(error)
        }
        if let snapShot = snapShot {
            return .success(snapShot)
        }
        return .failure(NSError(domain: "Never comes here", code: 0))
    }
    
    private func getMessageRef(_ threadId: String) -> CollectionReference? {
        let cName = ChatCollectionName.message.rawValue
        let path = cName + "/" + threadId + "/messages"
        Logger.debug(#function + " - \(path)")
        return FirestoreManager.shared.getCollectionRef(path)
    }
    
    private func getSortedMessageRef(_ threadId: String) -> Query? {
        return getMessageRef(threadId)?.order(by: "sentAt", descending: false)
    }
    
    private func retrieveThreadDocs(snapShot: QuerySnapshot) -> [ChatThreadDocument] {
        var threads: [ChatThreadDocument] = []
        for document in snapShot.documents {
            Logger.debug("\(document.documentID)")
            let result = Result {
                try document.data(as: ChatThreadDocument.self)
            }
            switch result {
            case .success(let chatThread):
                //if let chatThread = chatThread {
                    threads.append(chatThread)
                //}
            case .failure(let error): Logger.debug("error: " + error.localizedDescription)
            }
        }
        return threads
    }
    
    private func retrieveDocument(snapShot: DocumentSnapshot?) -> ChatThreadDocument? {
        if let document = snapShot, document.exists {
            Logger.debug(#function + ": docId = \(document.documentID)")
            let result = Result {
                try document.data(as: ChatThreadDocument.self)
            }
            switch result {
            case .success(let chatThread): return chatThread
            case .failure(let error):
                Logger.debug("error: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    private func createThread(for type: ChatThreadType, members: [ChatMember], completion: @escaping (String?) -> Void) {
        guard type != .channel else {
            Logger.debug("Not permitted to create PUBLIC thread")
            completion(nil)
            return
        }
        Logger.debug(#function + " - " + type.rawValue + " : " + members.map { $0.userName ?? "no name" }.joined(separator: ","))
        let date = Date()
        let threadDoc = ChatThreadDocument(
            type: type.rawValue,
            name: members.compactMap { $0.id }.map { String($0) }.joined(separator: "_"),
            tournamentClassId: nil, // always nil
            createdAt: date,
            lastSentAt: date,
            lastSentAuthorId: nil,
            icon: nil,
            members: members.compactMap { $0.id },
            membersDetail: members)
        let cName = ChatCollectionName.thread.rawValue
        let doc = FirestoreManager.shared.getCollectionRef(cName)?.document()
        _ = try? doc?.setData(from: threadDoc, merge: true) { error in
            if let error = error {
                Logger.debug(#function + ": " + error.localizedDescription)
                completion(nil)
            } else {
                completion(doc?.documentID)
            }
        }
    }
    
    private func createAuthor(me: UserInfo) -> ChatMember {
        return ChatMember(id: me.id, picture: me.picture, userName: me.userName)
    }
    
    private func createChatMember(user: UserInfo) -> ChatMember {
        return ChatMember(id: user.id, picture: user.picture, userName: user.userName)
    }
    
    private func createChatMember(user: UserInfo) -> [String: AnyHashable] {
        return ["id": user.id, "picture": user.picture, "userName": user.userName]
    }
}

// MARK: - public methods -

// common
extension ChatManager {
    func retrieveThread(id threadId: String, completion: @escaping (ChatThreadDocument?) -> Void) {
        let cName = ChatCollectionName.thread.rawValue
        // NOTE: if you change order or whereField, need to re-create index on Firestore.
        let doc = FirestoreManager.shared
            .getCollectionRef(cName)?.document(threadId)
        doc?.getDocument(source: .default, completion: { (snapShot, error) in
            completion(self.retrieveDocument(snapShot: snapShot))
        })
    }
}

// MARK: Channel
extension ChatManager {
    func getAllChannels(completion: @escaping ([ChatThreadDocument]) -> Void) {
        let cName = ChatCollectionName.thread.rawValue
        // NOTE: if you change order or whereField, need to re-create index on Firestore.
        let collection = FirestoreManager.shared
            .getCollectionRef(cName)?
            .whereField("type", isEqualTo: ChatThreadType.channel.rawValue)
            .order(by: "lastSentAt", descending: true)
        collection?.getDocuments(source: .default,
                                 completion: { (snapShot, error) in
            switch self.handleResult(snapShot: snapShot, error: error) {
            case .failure(_): completion([])
            case .success(let snapShot):
                let channels = self.retrieveThreadDocs(snapShot: snapShot)
                completion(channels)
            }
        })
    }
}

// MARK: DM
extension ChatManager {
    func getAllDMs(completion: @escaping ([ChatThreadDocument]) -> Void) {
        guard let userInfo = AppData.shared.currentUser else {
            completion([])
            return
        }
        let cName = ChatCollectionName.thread.rawValue
        // NOTE: if you change order or whereField, need to re-create index on Firestore.
        let collection = FirestoreManager.shared
            .getCollectionRef(cName)?
            .whereField("type", isEqualTo: ChatThreadType.dm.rawValue)
            .whereField("members", arrayContains: userInfo.id)
            .order(by: "lastSentAt", descending: true)
        collection?.getDocuments(source: .default, completion: { snapShot, error in
            switch self.handleResult(snapShot: snapShot, error: error) {
            case .failure(_): completion([])
            case .success(let snapShot):
                let dms = self.retrieveThreadDocs(snapShot: snapShot)
                completion(dms)
            }
        })
    }
    
    func retrieveDMThreadId(partner: ChatMember, completion: @escaping (String?) -> Void) {
        guard let me = AppData.shared.currentUser else { completion(nil); return }
        
        let cName = ChatCollectionName.thread.rawValue
        // NOTE: if you change order or whereField, need to re-create index on Firestore.
        let collection = FirestoreManager.shared
            .getCollectionRef(cName)?
            .whereField("type", isEqualTo: ChatThreadType.dm.rawValue)
            .whereField("members", arrayContains: me.id)
            .order(by: "lastSentAt", descending: true)
        collection?.getDocuments(source: .default,
                                 completion: { (snapShot, error) in
            switch self.handleResult(snapShot: snapShot, error: error) {
            case .success(let snapShot):
                let channels = self.retrieveThreadDocs(snapShot: snapShot)
                // NOTE: Currently, it is not possible to filter by multiple values from members.
                //       So, from the result of arrayContains: me.id, filter by partner.id.
                //       I have tried the following, but to no avail.
                //       .whereField("members", arrayContains: [me.id, partner.id!]) -> not hit
                //       .whereField("members", isEqualTo: [me.id, partner.id!]) -> problem with order
                if let hit = channels.first(where: { $0.members.contains(partner.id ?? -1) }) {
                    completion(hit.id)
                } else {
                    completion(nil)
                }
            case .failure(_): completion(nil)
            }
        })
    }
    
    func retrieveOrCreateDMThreadId(partner: ChatMember, completion: @escaping (String?) -> Void) {
        guard let me = AppData.shared.currentUser else { completion(nil); return }
        
        retrieveDMThreadId(partner: partner) { docId in
            if let docId = docId {
                completion(docId)
            } else {
                let members: [ChatMember] = [self.createAuthor(me: me), partner]
                self.createThread(for: .dm, members: members, completion: completion)
            }
        }
    }
    
    func setDMLastReadAt(docId: String, completion: @escaping (String?) -> Void) {
        guard let me = AppData.shared.currentUser else { completion(nil); return }
        let path = ChatCollectionName.thread.rawValue
        var updatedData: [String: Any] = [:]
        updatedData.updateValue(FieldValue.serverTimestamp(), forKey: "lastRead" + String(me.id))
        FirestoreManager.shared.getCollectionRef(path)?
            .document(docId).updateData(updatedData, completion: { error in
                completion(docId)
            })
    }
    
    func fetchLastReadAt(completion: @escaping ([String]) -> Void) {
        guard let me = AppData.shared.currentUser else { completion([]); return }
        getAllDMs() { [self] dms in
            var results: [String] = []
            print(String(dms.count))
            dms.forEach({dm in
                let path = ChatCollectionName.thread.rawValue
                FirestoreManager.shared.getCollectionRef(path)?
                    .document(dm.id!).getDocument() {document, args  in
                        
                        let lastReadAt = (document?.get("lastRead" + String(me.id)) ?? Timestamp.init(seconds: 0, nanoseconds: 0)) as! Timestamp
                        let lastReadTime = Date(timeIntervalSince1970: TimeInterval(lastReadAt.seconds))
                        let cName = ChatCollectionName.message.rawValue
                        let path = cName + "/" + dm.id! + "/messages"
                    
                        FirestoreManager.shared.getCollectionRef(path)!.whereField("author", isNotEqualTo: me.id).getDocuments(source: .default, completion:  { (snapShot, error) in
                            switch self.handleResult(snapShot: snapShot, error: error) {
                            case .success(let snapShot):
                                var messages: [ChatMessage] = []
                                for document in snapShot.documents {
                                    let result = Result {
                                        try document.data(as: ChatMessage.self)
                                    }
                                    switch result {
                                    case .success(let message):
                                        //if let message = message {
                                            if message.sentAt > lastReadTime {
                                                messages.append(message)
                                            }
                                        //}
                                    case .failure(let error): Logger.debug("error: " + error.localizedDescription)
                                    }
                                }
                                if messages.count > 0 {
                                    addUnreadMessages(threadId: dm.id!)
                                } else {
                                    removeUnreadMessages(threadId: dm.id!)
                                }
                            case .failure(_):
                                print("All messages read already!")
                            }
                        })
                        
                    }
                
            })
            completion(results)
        }
    }
    
    func addUnreadMessages(threadId: String) {
        guard !AppData.shared.unreadThreads.contains(threadId) else {
            return
        }
        AppData.shared.unreadThreads.append(threadId)
        AppData.shared.unreadThreads.removeDuplicates()
        NotificationCenter.default.post(name: .refreshUnreadDMDot, object: nil)
        NotificationCenter.default.post(name: .refreshUnreadDMDotTab, object: nil)
        NotificationCenter.default.post(name: .refreshUnreadDMDotItem, object: nil)
    }
    
    func removeUnreadMessages(threadId: String) {
        guard AppData.shared.unreadThreads.contains(threadId) else {
            return
        }
        AppData.shared.unreadThreads.removeAll(where: {element in
            return element == threadId
        })
        NotificationCenter.default.post(name: .refreshUnreadDMDot, object: nil)
        NotificationCenter.default.post(name: .refreshUnreadDMDotTab, object: nil)
        NotificationCenter.default.post(name: .refreshUnreadDMDotItem, object: nil)
    }
}

// MARK: CS
extension ChatManager {
    
    func retrieveSupportThreadId(completion: @escaping (String?) -> Void) {
        guard let me = AppData.shared.currentUser else { completion(nil); return }
        
        let cName = ChatCollectionName.thread.rawValue
        // NOTE: if you change order or whereField, need to re-create index on Firestore.
        let collection = FirestoreManager.shared
            .getCollectionRef(cName)?
            .whereField("type", isEqualTo: ChatThreadType.support.rawValue)
            .whereField("members", arrayContains: me.id)
            .order(by: "lastSentAt", descending: true)
        collection?.getDocuments(source: .default,
                                 completion: { (snapShot, error) in
            switch self.handleResult(snapShot: snapShot, error: error) {
            case .success(let snapShot):
                let channels = self.retrieveThreadDocs(snapShot: snapShot)
                completion(channels.first?.id)
            case .failure(_): completion(nil)
            }
        })
    }
    
    func retrieveOrCreateSupportThreadIdForMe(completion: @escaping (String?) -> Void) {
        guard let me = AppData.shared.currentUser else { completion(nil); return }
        
        retrieveSupportThreadId { docId in
            if let docId = docId { completion(docId); return }
            let members: [ChatMember] = [self.createAuthor(me: me), .init(id: Self.CS_ID, picture: nil, userName: "Support")]
            self.createThread(for: .support, members: members, completion: completion)
        }
    }
}

// MARK: Message
extension ChatManager {
    func getAllMessages(by threadId: String, completion: @escaping ([ChatMessage]) -> Void) {
        let collection = getSortedMessageRef(threadId)
        collection?.getDocuments(source: .default,
                                 completion: { (snapShot, error) in
            switch self.handleResult(snapShot: snapShot, error: error) {
            case .failure(_): completion([])
            case .success(let snapShot):
                var messages: [ChatMessage] = []
                for document in snapShot.documents {
                    Logger.debug("\(document.documentID)")
                    let result = Result {
                        try document.data(as: ChatMessage.self)
                    }
                    switch result {
                    case .success(let message):
                        //if let message = message {
                            messages.append(message)
                        //}
                    case .failure(let error): Logger.debug("error: " + error.localizedDescription)
                    }
                }
                completion(messages)
            }
        })
    }
    
    
    func listenMessage(_ threadId: String, didChange: DidChange?) {
        unlistenMessage()
        setDMLastReadAt(docId: threadId) { [self]_ in
            fetchLastReadAt() {_ in
                
            }
        }
        listener = getSortedMessageRef(threadId)?.addSnapshotListener(
            includeMetadataChanges: false,
            listener: { snapShot, error in
                switch self.handleResult(snapShot: snapShot, error: error) {
                case .failure(_): break
                case .success(let snapShot):
                    var diffMessages: [(DocumentChangeType, ChatMessage)] = []
                    snapShot.documentChanges.forEach { diff in
                        switch diff.type {
                        case .modified, .removed: break // not supported yet.
                        case .added:
                            let result = Result {
                                try diff.document.data(as: ChatMessage.self)
                            }
                            switch result {
                            case .success(let message):
                                //if let message = message {
                                    diffMessages.append((.added, message))
                                //}
                            case .failure(let error):
                                Logger.debug(#function + ": " + error.localizedDescription)
                            }
                        }
                    }
                    didChange?(diffMessages)
                }
            })
    }
    
    func unlistenMessage() {
        listener?.remove()
        listener = nil
    }
    
    func submitMessage(to documentId: String, message: String, needToAddMe: Bool, completion: CompletionHandler? = nil) {
        guard AppData.shared.isLoggedIn() else { completion?(false); return }
        guard let me = AppData.shared.currentUser else { completion?(false); return }
        let author = createAuthor(me: me)
        
        // NOTE: Since WriteBatch does not have `addDocument`, these processes are done in parallel
        var errors: [Error] = []
        let dispatch = DispatchGroup()
        dispatch.enter()
        let data = ChatMessage(id: nil, body: message, sentAt: Date(), author: author)
        _ = try? getMessageRef(documentId)?.addDocument(from: data) { error in
            if let error = error { errors.append(error) }
            dispatch.leave()
        }
        var updatedData: [String: Any] = [:]
        // NOTE: to notify to all users, need to update lastSentAt and lastSentAuthorId
        updatedData.updateValue(FieldValue.serverTimestamp(), forKey: "lastSentAt")
        updatedData.updateValue(me.id, forKey: "lastSentAuthorId")
        // NOTE: members and membersDetail に含まれていなければ投稿者を追加
        if needToAddMe {
            updatedData.updateValue(FieldValue.arrayUnion([me.id]), forKey: "members")
            let detail: [String: AnyHashable] = createChatMember(user: me)
            updatedData.updateValue(FieldValue.arrayUnion([detail]), forKey: "membersDetail")
        }
        
        let path = ChatCollectionName.thread.rawValue
        dispatch.enter()
        FirestoreManager.shared.getCollectionRef(path)?
            .document(documentId).updateData(updatedData, completion: { error in
                if let error = error { errors.append(error) }
                dispatch.leave()
            })
        
        dispatch.notify(queue: .main) {
            Logger.debug(#function + errors.map { $0.localizedDescription }.joined(separator: "\n") )
            completion?(errors.isEmpty)
        }
        setDMLastReadAt(docId: documentId) {_ in
            
        }
        
        // send notification
        let cName = ChatCollectionName.thread.rawValue
        // NOTE: if you change order or whereField, need to re-create index on Firestore.
        let collection = FirestoreManager.shared
            .getCollectionRef(cName)?.document(documentId).getDocument(source: .default, completion: { document, error in
                let result = Result {
                    try document?.data(as: ChatThreadDocument.self)
                }
                switch result {
                case .success(let chatThread):
                    if let chatThread = chatThread {
                        for member in chatThread.members {
                            if member != me.id {
                                ApiManager.shared.sendDMNotification(idToken: LocalStorageManager.idToken, targetUserId: member, msgContent: message, msgTemplateId: 0) { reuslt in
                                    
                                }
                            }
                        }
                    }
                case .failure(let error):
                    Logger.debug("error: " + error.localizedDescription)
                }
        })
    }
}
