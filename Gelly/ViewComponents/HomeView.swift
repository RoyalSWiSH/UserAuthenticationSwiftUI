//
//  HomeView.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 04.01.22.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sessionService: SessionServiceImpl
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("First Name: \(sessionService.userDetails?.firstName ?? "N/A")")
                Text("Last Name: \(sessionService.userDetails?.lastName ?? "N/A" )")
                Text("Occupation: \(sessionService.userDetails?.occupation ?? "N/A")")
            }
            ButtonView(title: "Logout") {
                // TODO: Handle logout action here
                sessionService.logout()
            }
        }
        .padding(.horizontal, 16)
        .navigationTitle("Main Content View")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            // Keep preview from crashing
            .environmentObject(SessionServiceImpl())
    }
}
