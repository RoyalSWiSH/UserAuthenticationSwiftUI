//
//  RegistrationService.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 04.01.22.
//

import Foundation
import Combine
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestoreSwift


enum RegistrationKeys: String {
    case firstName
    case lastName
    case occupation
}


protocol RegistrationService {
    // Return a publisher AnyPublisher, that we can subscribe to and will return Void on success, since we need any returning data, or an Error
    func register(with details: RegistrationDetails) -> AnyPublisher<Void, Error>
}

// Now we create a implementation that uses our protocol. Use final such that
final class RegistrationServiceImpl: RegistrationService {
    func register(with details: RegistrationDetails) -> AnyPublisher<Void, Error> {
        // Use Combine feature Deffered and Future
        
        Deferred {
            
            Future { promise in
                // Call FirebaseAuth
                Auth.auth()
                    .createUser(withEmail: details.email, password: details.password) { res, error in
                        
                        if let err = error {
                            promise(.failure(err))
                        } else {
                            
                            // Associate Firebase Realtime DB with User
                            if let uid = res?.user.uid {
                                let values = [RegistrationKeys.firstName.rawValue: details.firstName,
                                              RegistrationKeys.lastName.rawValue: details.lastName,
                                RegistrationKeys.occupation.rawValue: details.occupation] as [String: Any]
                                
                                // Add to Firebase Realtime DB
                                // TODO: Show alert messagre if error occured
                                // Does not add details to database right now 06.01.2022
                                Database.database()
                                    .reference()
                                    .child("users")
                                    .child(uid)
                                    .updateChildValues(values) { error, ref in
                                        if let err = error {
                                            promise(.failure(err))
                                        } else {
                                            promise(.success(()))
                                        }
                                    }
                                // TOOD: Try Firestore Database
                                
                            }
                            else {
                                promise(.failure(NSError(domain: "Invalid User ID", code: 0, userInfo: nil)))
                            }
                            
                        }
                    }
            }
            
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
        
    }
}
