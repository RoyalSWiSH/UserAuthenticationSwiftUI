//
//  LoginViewModel.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 06.01.22.
//

import Foundation
import Combine

enum LoginState {
    case successfull
    case failed(error: Error)
    case na
}

protocol LoginViewModel {
    func login()
    var service: LoginService { get }
    var state: LoginState { get }
    var credentials: LoginCredentials { get }
    // inject service into ViewModel
    init(service: LoginService)
}

final class LoginViewModelImpl: ObservableObject, LoginViewModel {
    @Published var state: LoginState = .na
    @Published var credentials: LoginCredentials = LoginCredentials.new
    
    private var subscriptions = Set<AnyCancellable>()
    
    let service: LoginService
    
    init(service: LoginService) {
        self.service = service
    }
    
    func login() {
        
        service
            .login(with: credentials)
            .sink { res in
                switch res {
                case .failure( let err):
                    self.state = .failed(error: err)
                default: break
                }
            } receiveValue: { [weak self] in
                self?.state = .successfull
            }
            .store(in: &subscriptions) //?
        // Use publisher to set state based on the result of that publisher
    }
}
