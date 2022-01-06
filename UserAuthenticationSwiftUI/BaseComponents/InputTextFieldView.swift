//
//  InputTextFieldView.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 26.12.21.
//

import SwiftUI

struct InputTextFieldView: View {
    
    // TextField content
    @Binding var text: String
    // TextField Placeholder
    let placeholder: String
    // custom Keyboard Type e.g. specifically for email
    let keyboardType: UIKeyboardType
    // optional icon in the TextField
    let sfSymbol: String?
    
    private let textFieldLeading: CGFloat = 30
    
    var body: some View {
        TextField(placeholder, text: $text)
            .frame(maxWidth: .infinity,
                   minHeight: 44)
            // Increase padding if there is a sfSymbol
            .padding(.leading, sfSymbol == nil ? textFieldLeading / 2: textFieldLeading)
            .keyboardType(keyboardType)
            .background(
                // Show sfSymbol and apply border around TextField
                ZStack(alignment: .leading) {
                    if let systemImage = sfSymbol {
                        // icon in FextField
                        Image(systemName: systemImage)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.leading, 5)
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                    
                    // User RoundedRectangle for corder for better customization
                    RoundedRectangle(cornerRadius: 10,
                                     style: .continuous)
                        .stroke(Color.gray.opacity(0.25))
                }
            )
    }
}



struct InputTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        InputTextFieldView(text: .constant(""),
                           placeholder: "Email",
                           keyboardType: .emailAddress,
                           sfSymbol: "envelope")
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Text Input with sfSymbol")
            .padding()
        
        // TODO: Use PreviewLayourComponentModifier
        
        InputTextFieldView(text: .constant(""),
                           placeholder: "First Name",
                           keyboardType: .default,
                           sfSymbol: nil)
            .preview(with: "Enaul Text Input with sfsymbol")
    
    }
}
