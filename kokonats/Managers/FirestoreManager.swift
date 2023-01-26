////  FirestoreManager.swift
//  kokonats
//
//  Created by sean on 2021/12/19.
//  
//

import Foundation
import Firebase
import FirebaseFirestore


final class FirestoreManager {
    static var shared = FirestoreManager()
    private var ref: DocumentReference? = nil
    private var firestore: Firestore

    private init() {
        firestore = Firestore.firestore()
    }

    func getState(collectionName: String, documentId: String, completion: @escaping (Int?) -> Void ) {
        let docRef = firestore.collection(collectionName).document(documentId)
        docRef.getDocument() { (document, error) in
            guard let document = document, let state = document.data()?["state"] as? Int else {
                    completion(nil)
                    return
            }

            completion(state)
        }
    }

    func getDocument(collectionName: String, documentId: String, completion: @escaping (DocumentSnapshot?) -> Void ) {
        let docRef = firestore.collection(collectionName).document(documentId)
        docRef.getDocument() { (document, error) in
            DispatchQueue.main.async {
                completion(document)
            }
        }
    }
    
    func getCollectionRef(_ collectionPath: String) -> CollectionReference? {
        return firestore.collection(collectionPath)
    }

    func getWriteBatch() -> WriteBatch {
        return firestore.batch()
    }
}
