//
//  User.swift
//  FirebaseToDo
//
//  Created by dzmitry on 28.01.23.
//

import Foundation
import Firebase

struct User {
    
    // идентификатор пользователя
    let uid: String
    let email: String
    
    init(user: Firebase.User) {
        self.uid = user.uid
        self.email = user.email ?? ""
    }
}
