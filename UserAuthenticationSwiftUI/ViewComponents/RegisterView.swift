//
//  RegisterView.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 04.01.22.
//

import SwiftUI

struct RegisterView: View {
    
    // Dismissing Screens in SwiftUI
  //  @Environment(\.presentationMode) var presentationMode
    
    // Add View Model to RegistrationView
    @StateObject private var vm = RegistrationViewModelImpl(service:  RegistrationServiceImpl()
    )
    
    var body: some View {
        // Independent view, separate from the session state, therefore uses a NavigationView as well
        NavigationView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    
                    InputTextFieldView(text: $vm.userDetails.email, placeholder: "Email", keyboardType: .emailAddress, sfSymbol: "envelope")
                    
                    InputPasswordView(password: $vm.userDetails.password, placeholder: "Password", sfSymbol: "lock")
                    
                    Divider()
                    
                    InputTextFieldView(text: $vm.userDetails.firstName, placeholder: "First Name", keyboardType: .namePhonePad, sfSymbol: nil)
                    
                    InputTextFieldView(text: $vm.userDetails.lastName, placeholder: "Last Name", keyboardType: .namePhonePad, sfSymbol: nil)
                    
                    InputTextFieldView(text: $vm.userDetails.occupation, placeholder: "Occupation", keyboardType: .namePhonePad, sfSymbol: nil)
                }
            
                ButtonView(title: "Sign up") {
                    // TODO: Handle create action here
                    vm.register()
                }
            }
            .padding(.horizontal, 15)
            .navigationTitle("Register")
            .applyClose()
        } // NavigationView
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
