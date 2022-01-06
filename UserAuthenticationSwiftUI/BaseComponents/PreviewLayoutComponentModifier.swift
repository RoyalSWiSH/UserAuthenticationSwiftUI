//
//  PreviewLayoutComponentModifier.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 26.12.21.
//
//  Used to abbreviate modifiers for preview of TextField, PasswordField...

import SwiftUI

struct PreviewLayoutComponentModifier: ViewModifier {
    let name: String
    
    func body(content: Content) -> some View {
    content
    .previewLayout(.sizeThatFits)
    .previewDisplayName("Text Input with sfSymbol")
    .padding()
    }
}

extension View {
    func preview(with name: String) -> some View {
        self.modifier(PreviewLayoutComponentModifier(name: name))
    }
}
