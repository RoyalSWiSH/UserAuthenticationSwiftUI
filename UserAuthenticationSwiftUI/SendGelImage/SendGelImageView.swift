//
//  SendGelImageView.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 23.04.22.
//

import SwiftUI


struct SendGelImageView: View {
    var image: SendImageModel
    @State var numberofRows = 0
    let url = URL(string: "https://image.tmdb.org/t/p/original/pThyQovXQrw2m0s9x82twj48Jq4.jpg")!
    @available(iOS 15.0, *)
    @StateObject var response: Response
    
    
    var body: some View {
        
        NavigationView {
            list.navigationBarItems(trailing: addButton)
                .onAppear {
                    print("Navigation View Api().callAPI()")
                    Api().getGelImageMetaData()
                    
                }
            
            if #available(iOS 15.0, *) {
                JSONContentUI()
            } else {
                // Fallback on earlier versions
            }
        }
    }
        
    
        private var list: some View {
            List(0..<numberofRows, id: \.self) { _ in
            AsyncImage(url: self.url, placeholder: { Text("Loading ... 123") })
                .aspectRatio(2 / 3, contentMode: .fit)
                .frame(minHeight: 200, maxHeight: 200)
                
          
            }
        }
        
    private var addButton: some View {
        Button(action: { self.numberofRows += 1}) {Image(systemName: "plus")}
    }
//        VStack {
//
//            AsyncImage(url: url, placeholder: { Text("Loading ... 123") })
//                .aspectRatio(contentMode: .fit)
//
//            image.photoImg
//                .resizable()
//                .scaledToFit()
         // only usable in iOS 15
//            AsyncImage(url: URL(string: "https://jooinn.com/images/gel-electrophoresis-7.jpg"))
//                .frame(width: 200, height: 200)
 //       Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            
//            AsyncImage(
//                                 url: url,
//                                 placeholder: Text("Loading ...")
//                   ).aspectRatio(contentMode: .fit)
            //       } //:ZSTACK
}


struct SendGelImageView_Previews: PreviewProvider {
    static var previews: some View {
        
        if #available(iOS 15.0, *) {
            SendGelImageView(image: imageData, response: response)
        } else {
            // Fallback on earlier versions
        }
    }
}
