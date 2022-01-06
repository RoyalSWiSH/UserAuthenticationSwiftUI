//
//  CloseModifier.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 04.01.22.
//

import SwiftUI

struct CloseModifier: ViewModifier {
    @Environment(\.presentationMode) var presentationMode
    func body(content: Content) -> some View {
        content
            .toolbar {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            }
    }
}

extension View {
    func applyClose() -> some View {
        self.modifier(CloseModifier())
        }
}
