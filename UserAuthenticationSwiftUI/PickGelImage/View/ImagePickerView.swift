//
//  SwiftUIView.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 08.01.22.
//

// https://github.com/appcoda/PHPickerDemo/blob/main/final/PHPickerDemo/PHPickerDemo/ItemsView.swift
    

import SwiftUI
import PhotosUI
//For Videos
import AVKit

struct ImagePickerView: View {
    
    // Is image picker currently displayed?
    @State var showImagePicker: Bool = false
    
    @State var selectedImage: Image? = Image("")
    
    @ObservedObject var mediaItems = PickedMediaItems()
    
    var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
    
    var body: some View {
        NavigationView {
            List(mediaItems.items, id: \.id) { item in
                ZStack(alignment: .topLeading) {
                    if item.mediaType == .photo {
                        Image(uiImage: item.photo ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if item.mediaType == .video {
                        if let url = item.url {
                            VideoPlayer(player: AVPlayer(url: url))
                                .frame(minHeight: 200)
                        } else { EmptyView() }
                    } else {
                  //      if let livePhoto = item.livePhoto {
                        //    LivePhotoView(livePhoto: livePhoto)
                          //      .frame(minHeight: 200)
                            // TODO: Add new File LivePhotoView and outcomment
                   //     } else { EmptyView() }
                    }

                    Image(systemName: getMediaImageName(using: item))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)

                    }
                }
            .navigationBarItems(leading: Button(action: {
                mediaItems.deleteAll()
            }, label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }), trailing: Button(action: {
                showImagePicker = true
            }, label: {
                Image(systemName: "plus")
            }))
            }
    .sheet(isPresented: $showImagePicker, content: {
        PhotoPicker(mediaItems: mediaItems) { didSelectItem  in
            showImagePicker = false
        }
    })
    }
    
    fileprivate func getMediaImageName(using item: PhotoPickerModel) -> String {
        switch item.mediaType {
        case .photo: return "photo"
        case .video: return "video"
        case .livePhoto: return "livephoto"
        }
    }
}
    
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView()
    }
}


struct PhotoPicker: UIViewControllerRepresentable {
  
    
    @ObservedObject var mediaItems: PickedMediaItems
    
 //   @Binding var isPresented: Bool
    var didFinishPicking: (_ didSelectItems: Bool) -> Void
    
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
    var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos, .livePhotos])
    config.selectionLimit = 0
    config.preferredAssetRepresentationMode = .current
        
    let controller = PHPickerViewController(configuration: config)
    controller.delegate = context.coordinator
    return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    // Use a Coordinator to act as your PHPickerVIewControllerDelegate
    class Coordinator: PHPickerViewControllerDelegate {
        var parent: PhotoPicker
        
        init(with parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            // Why is this in the original?
            parent.didFinishPicking(!results.isEmpty)
            guard !results.isEmpty else {
                return
            }
            
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
            
//            for result in results {
//
//            }
            
            
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
            
     //       parent.isPresented = false // Set isPresented to flase because picking has finished
        }
    }
}
