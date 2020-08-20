//
//  FirebaseUtil.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class FirebaseUtil {
    static let db = Firestore.firestore()
    static let studentRef = db.collection("students")
    static let classRef = db.collection("classGroups")
    static let bookRef = db.collection("books")
    static let toDoImageRef = Storage.storage().reference().child("ToDo")
    static let profilePicRef = Storage.storage().reference().child("ProfilePic")
    
    static func newUser(uniqueID: String, name: String, completionHandler: ((_ student: Student?, _ err: Error?)->Void)?) throws {
        let newStudent = Student(name: name)
        try studentRef.document(uniqueID).setData(from: newStudent) { err in
            if let completionHandler = completionHandler {
                completionHandler(newStudent,err)
            }
        }
    }
    
    static func getUser(uniqueID: String, completionHandler:((_ student: Student?, _ err: Error?)->Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        studentRef.document(uniqueID).getDocument { (document, error) in
            let result = Result {
                try document?.data(as: Student.self)
            }
            switch result {
                case .success(let student):
                    completionHandler(student, nil)
                case .failure(let error):
                    completionHandler(nil, error)
            }
        }
    }
    
    static func getAllClassGroups(completionHandler:((_ classGroups: [String: ClassGroup]?, _ err: Error?)->Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        classRef.getDocuments() { (snapshot, err) in
            if let err = err {
                completionHandler(nil, err)
            }
            else {
                var retrievedData = [String: ClassGroup]()
                for document in snapshot!.documents {
                    let temp = try? document.data(as: ClassGroup.self)
                    retrievedData[document.documentID] = temp
                }
                completionHandler(retrievedData, nil)
            }
        }
    }
    
    static func getBooks(classGroupID: String, completionHandler: ((_ books: [String: Book]?, _ error: Error?)->Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        
        bookRef.whereField("classGroupID", isEqualTo: classGroupID).getDocuments { (snapshot, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                var bookDictionary = [String: Book]()
                for document in snapshot!.documents {
                    let temp = try? document.data(as: Book.self)
                    bookDictionary[document.documentID] = temp
                }
                completionHandler(bookDictionary, nil)
            }
        }
    }
    
    static func updateUser(uniqueID: String, query: [String: Any], completionHandler:((_ err: Error?)->Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        studentRef.document(uniqueID).updateData(query) { error in
            completionHandler(error)
        }
    }
    
    static func uploadImage(image: UIImage, mode: uploadImageMode, uniqueID: String, completionHandler:((_ url: String?, _ err: Error?) -> Void)?) {
        guard let completionHandler = completionHandler else {
            print("Missing completion handler")
            return
        }
        let imageName = "\(uniqueID).jpg"
        var storageRef: StorageReference
        switch (mode) {
            case .profilePic:
                storageRef = profilePicRef
            case .toDoImage:
                storageRef = toDoImageRef
        }
        storageRef = storageRef.child(imageName)
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                storageRef.downloadURL { (url, err) in
                    if let error = err {
                        completionHandler(nil, error)
                    }
                    else {
                        completionHandler(url!.absoluteString, nil)
                    }
                }
            }
        }
    }
}

enum uploadImageMode {
    case profilePic, toDoImage
}
