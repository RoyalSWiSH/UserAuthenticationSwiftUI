//
//  UserAuthenticationSwiftUIApp.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 25.12.21.
//

import SwiftUI
import Firebase
import FirebaseCore
import Mixpanel
import Adapty

//:MARK Add App Delegate to initialize Firebase or Supabase
// Do I need @UIApplicationMain?
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
   

        FirebaseApp.configure()
        
    // In-App Analytics
//    Mixpanel.initialize(token: "e69103063a3c6a5aa0a362b4413e9e1b", trackAutomaticEvents: true)

//    mixpanel.serverURL = "https://api-eu.mixpanel.com"
        print("Init mixpanel")
        var mixpanel = Mixpanel.initialize(token: "e69103063a3c6a5aa0a362b4413e9e1b", trackAutomaticEvents: true)
        mixpanel.serverURL = "https://api-eu.mixpanel.com"
        mixpanel.track(event: "App Opened", properties: [
            "source": "mixpanel",
            "Opted out of email": true
        ])
     Mixpanel.initialize(token: "e69103063a3c6a5aa0a362b4413e9e1b", trackAutomaticEvents: true, serverURL: "https://api-eu.mixpanel.com/")
        Mixpanel.mainInstance().track(event: "App Opened", properties: [
            "source": "Mixpanel",
            "Opted out of email": true
        ])
        // Subscription management
        Adapty.activate("public_live_r2z6oX4U.UgtZd8j2w9x6ASf7tugJ")
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

