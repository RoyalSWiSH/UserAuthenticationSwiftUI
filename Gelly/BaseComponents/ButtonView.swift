//
//  ButtonComponentView.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 26.12.21.
//

import SwiftUI

struct ButtonView: View {

    // Clarify purpose of closure (?)
    typealias ActionHandler = () -> Void
    
    let title: String
    let background: Color
    let foreground: Color
    let border: Color
    let handler: ActionHandler
    
    private let cornerRadius: CGFloat = 10
    
    // Output from Generate Memberwise Initializer from cmd+klick on ButtonComponentView
    internal init(title: String, background: Color = .blue, foreground: Color = .white, border: Color = .clear, handler: @escaping ButtonView.ActionHandler) {
        self.title = title
        self.background = background
        self.foreground = foreground
        self.border = border
        self.handler = handler
    }
    
    
    var body: some View {
        Button(action: handler, label: {
            Text(title)
                .frame(maxWidth: .infinity, maxHeight: 50)
        })
        .background(background)
        .foregroundColor(foreground)
        .font(.system(size: 16, weight: .bold))
        .cornerRadius(cornerRadius)
        .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(border, lineWidth: 2))
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        // Add {} to avoid issues with handler
        ButtonView(title: "Button") { }
            .preview(with: "Primary Button View")
    }
}
