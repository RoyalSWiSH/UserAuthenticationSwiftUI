//
//  UserAuthenticationSwiftUIApp.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 25.12.21.
//

import SwiftUI
import Firebase
import FirebaseCore

//:MARK Add App Delegate to initialize Firebase or Supabase
// Do I need @UIApplicationMain?
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
    }
}


@main
struct UserAuthenticationSwiftUIApp: App {
    
    // Create AppDelegate to initialize dependencies like Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Register Session Service and use state of SessionService to decide which View should appear
    @StateObject var sessionService = SessionServiceImpl()
  //  @StateObject var response: Response
    
    // Whats the difference between Scene and View? Why do I need WindowGroup?
    var body: some Scene {
        WindowGroup {
//            NavigationView {
//                switch sessionService.state {
//                case .loggedIn:
//                    HomeView()
//                        // Inject service into HomeView from parent to child view
//                        .environmentObject(sessionService)
//                case .loggedOut:
//                    //LoginView()
//                    ImagePickerView()
            SendGelImageView(image: imageData, response: response)
////                    SendGelImageView(image: imageData, response: response)
//                }
//            } // NavigationView
           
        } // WindowGroup
    }
}

