//
//  PhotoPickerModel.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 03.04.22.
//

import SwiftUI
import Photos

struct PhotoPickerModel: Identifiable, Hashable {
    enum MediaType {
        case photo, video, livePhoto
    }
    
    var id: String
    var photo: UIImage?  // TODO: Replace with Image
    var url: URL?
    var livePhoto: PHLivePhoto?
    var mediaType: MediaType = .photo
    
    
    init(with photo: UIImage) {
        id = UUID().uuidString
        self.photo = photo
        mediaType = .photo
    }
    
    init(with videoURL: URL) {
        id = UUID().uuidString
        url = videoURL
        mediaType = .video
    }
    
    init(with livePhoto: PHLivePhoto)
    {
        id = UUID().uuidString
        self.livePhoto = livePhoto
        mediaType = .livePhoto
    }
    
    mutating func delete() {
        switch mediaType {
        case .photo: photo = nil
        case .livePhoto: livePhoto = nil
        case .video:
            guard let url = url else {return}
            try? FileManager.default.removeItem(at: url)
            self.url = nil
        }
    }
}


class PickedMediaItems: ObservableObject {
    @Published var items = [PhotoPickerModel] ()
    
    func append(item: PhotoPickerModel) {
        items.append(item)
    }
    
    func deleteAll() {
        for (index, _) in items.enumerated() {
            items[index].delete()
        }
        items.removeAll()
    }
}
