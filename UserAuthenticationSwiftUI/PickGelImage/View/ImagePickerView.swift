//
//  SwiftUIView.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 08.01.22.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    
    // Is image picker currently displayed?
    @State var showImagePicker: Bool = false
    
    @State var selectedImage: Image? = Image("")
    
    @ObservedObject var mediaItems = PickedMediaItems()
    
    var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
        Button(action: {
            self.showImagePicker.toggle()
        }
        , label: {
            Text("Select Gel Image")
            Image("")
                .resizable()
                .frame(width: 120, height: 120, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
        }

        )

        Image(systemName: "plus")
            .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .foregroundColor(.white)
            .background(Color.gray)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
           // .padding(5)
        }
        .padding(5)
        ZStack() {
            Button("Present Picker") {
                showImagePicker.toggle()
            }
            .sheet(isPresented: $showImagePicker) {
    //            PickerViewController(sourceType: self.selectedImage)
                
    //            var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
              //  configuration.filter = .images
                
                // Multiimage support
            //    configuration.selectionLimit = 0
                PhotoPicker(configuration: configuration, mediaItems: mediaItems, isPresented: $showImagePicker)
                
            }
        
       
        List(mediaItems.items, id: \.id) { item in
           
            ZStack(alignment: .bottomLeading, content: {
                
                Image(uiImage: item.photo ?? UIImage())
                                           .resizable()
                                           .aspectRatio(contentMode: .fit)
                
            })
           
        }
        }
        
       
      
        
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView()
    }
}


struct PhotoPicker: UIViewControllerRepresentable {
    let configuration: PHPickerConfiguration
    
    @ObservedObject var mediaItems: PickedMediaItems
    
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
    let controller = PHPickerViewController(configuration: configuration)
    controller.delegate = context.coordinator
    return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Use a Coordinator to act as your PHPickerVIewControllerDelegate
    class Coordinator: PHPickerViewControllerDelegate {
        private let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            print(results)
            
            let isLivePhoto = false // correct later
            
            let objectType: NSItemProviderReading.Type = !isLivePhoto ? UIImage.self : PHLivePhoto.self
            if let itemProvider = results.first?.itemProvider
            {
                if itemProvider.canLoadObject(ofClass: objectType) {
                    itemProvider.loadObject(ofClass: objectType) { object, error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        
                        if !isLivePhoto {
                            if let image = object as? UIImage {
                                DispatchQueue.main.async {
                                    self.parent.mediaItems.append(item: PhotoPickerModel(with: image))
                                }
                            }
                        } else {
                            if let livePhoto = object as? PHLivePhoto {
                                DispatchQueue.main.async {
                                    self.parent.mediaItems.append(item: PhotoPickerModel(with: livePhoto))
                                }
                            }
                        }
                        
                    }
                }
            }
            
            for result in results {
                
            }
            
            
//                    if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
//                        let previousImage = imageView.image
//                        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//                            DispatchQueue.main.async {
//                                guard let self = self, let image = image as? UIImage, self.imageView.image ==
//                                        previousImage else { return }
//
//                                // Display image on screen
//                                self.imageView.image = image
//
//                                // TODO: Handle error when image can't be displaied
//                            }
//                        }
//                    }
            
            parent.isPresented = false // Set isPresented to flase because picking has finished
        }
    }
}
