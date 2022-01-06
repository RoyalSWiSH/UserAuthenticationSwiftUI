//
//  LoginView.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 03.01.22.
//

import SwiftUI

struct LoginView: View {
    
    @State private var showRegistration = false
    @State private var showForgotPassword = false
    
    @StateObject private var vm = LoginViewModelImpl(
        service: LoginServiceImpl()
    )
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                InputTextFieldView(text: $vm.credentials.email, placeholder: "Email", keyboardType: .emailAddress, sfSymbol: "envelope")
                InputPasswordView(password: $vm.credentials.passoword, placeholder: "Password", sfSymbol: "lock")
            } // VStack
            
            // MARK: Forgot Password
            HStack {
                // User Spacer to push Forgot Password to right side
                Spacer()
                Button(action: {
                    showForgotPassword.toggle()
                }, label: {
                    Text("Forgot Password?")
                })
                .font(.system(size: 16, weight: .bold))
                .sheet(isPresented: $showForgotPassword, content: {
                ForgotPasswordView()
                })
            }
            
            // MARK: Login and Register Button
            
            VStack(spacing: 16) {
                ButtonView(title: "Login") {
                    // TODO: Handle login acton here
                    vm.login()
                }
                ButtonView(title: "Register",
                           background: .clear,
                           foreground: .blue,
                           border: .blue) {
                    // Handle presentation to registration
                    showRegistration.toggle()
                }
                .sheet(isPresented: $showRegistration, content: {
                    RegisterView()
                })
            }
        } // VStack
        .padding(.horizontal, 15)
        .navigationTitle("Login")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        // Use NavigationView in here because NavigationView is used in
        NavigationView {
            LoginView()
        }
    }
}
