//
//  RegistrationViewModel.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 04.01.22.
//

// Why do i need this file at all?

import Foundation
import Combine

enum RegistrationState {
    case successfull
    case failed(error: Error)
    case na
}

protocol RegistrationViewModel {
    func register()
    var service: RegistrationService { get }
    var state: RegistrationState { get }
    var userDetails: RegistrationDetails { get }
    init(service: RegistrationService)
}

final class RegistrationViewModelImpl: RegistrationViewModel, ObservableObject {
    let service: RegistrationService
    
    var state: RegistrationState = .na
    
    // Uses the extension 'new' from RegistrationDetails.swift
    var userDetails: RegistrationDetails = RegistrationDetails.new
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(service: RegistrationService) {
        self.service = service
    }
    
    func register() {
         service
            .register(with: userDetails)
            .sink { [weak self] res in
                switch res {
                case .failure(let error):
                    self?.state = .failed(error: error)
                default: break
                }
                
            } receiveValue: { [weak self] in
                self?.state = .successfull
            }
            .store(in: &subscriptions)
    }
}
