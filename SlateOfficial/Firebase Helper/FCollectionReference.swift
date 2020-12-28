//
//  FCollectionReference.swift
//  SlateOfficial
//
//  Created by Timmy Van Cauwenberge on 12/1/20.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Recent
    case Messages
    case Typing
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}

