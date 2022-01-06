//
//  SessionService.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 05.01.22.
//

import Foundation
import Combine

import FirebaseAuth
import FirebaseDatabase


// possibble session states
enum SessionState {
    case loggedIn
    case loggedOut
}

protocol SessionService {
    var state: SessionState { get }
    var userDetails: SessionUserDetails? { get }
    
    func logout()
}

final class SessionServiceImpl: ObservableObject, SessionService {
    // mark as published to listen for changes later
    @Published var state: SessionState = .loggedOut
    @Published var userDetails: SessionUserDetails?
    
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        setupFirebaseAuthHandler()
    }
    
    func logout() {
        // Mark as optional try, if it fails nothing happens
        try? Auth.auth().signOut()
    }
}

// Why use extension here? Not just add this method above?
private extension SessionServiceImpl {
    func setupFirebaseAuthHandler() {
        handler = Auth
            .auth()
            .addStateDidChangeListener{ [weak self] res, user in
                guard let self = self else { return }
                self.state = user == nil ? .loggedOut : .loggedIn
                
                if let uid = user?.uid {
                    self.handleRefresh(with: uid)
                }
            }
    }
    
    // Update UserDetails when sucessfully logged in
    func handleRefresh(with uid: String) {
        
        Database
            .database()
            .reference()
            .child("users")
            .child(uid)
            .observe(.value) { [weak self] snapshot in
                guard let self = self, //?
                let value = snapshot.value as? NSDictionary,
                let firstName = value[RegistrationKeys.firstName.rawValue] as? String,
                let lastName = value[RegistrationKeys.lastName.rawValue] as? String,
                let occupation = value[RegistrationKeys.occupation.rawValue] as? String else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.userDetails = SessionUserDetails(firstName: firstName, lastName: lastName, occupation: occupation)
                }
                
            }
    }
}
