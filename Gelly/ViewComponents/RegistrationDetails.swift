//
//  RegistratioDetals.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 04.01.22.
//

import Foundation

struct RegistrationDetails {
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    var occupation: String
}

extension RegistrationDetails {
    // Make this static so it doesn't have to be initialized
    static var new: RegistrationDetails {
        RegistrationDetails(email: "",
                            password: "",
                            firstName: "",
                            lastName: "",
                            occupation: "")
    }
}
