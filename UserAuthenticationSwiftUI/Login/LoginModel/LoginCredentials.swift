//
//  LoginCredentials.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 06.01.22.
//

import Foundation

struct LoginCredentials {
    // Bind this to View (so use var not let)
    var email: String
    var passoword: String
}

extension LoginCredentials {
    static var new: LoginCredentials {
        LoginCredentials(email: "", passoword: "")
    }
}
