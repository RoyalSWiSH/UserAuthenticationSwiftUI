//
//  ImageLoader.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 28.04.22.

//  Tutorial: https://www.vadimbulavin.com/asynchronous-swiftui-image-loading-from-url-with-combine-and-swift/

import Foundation
import SwiftUI
import Combine


// Use ObservableObject to make model observable by implementing Observable Object (load, cancel, deinit, init?)
class ImageLoader: ObservableObject {
    
    // Bind image updates to view with @Published property wrapper
    @Published var image: UIImage?
    private let url: URL
    private var cache: ImageCache?
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    private(set) var isLoading = false
    
    // Combine
    private var cancellable: AnyCancellable?
    
    init(url: URL, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }
    
    deinit {
        cancel()
    }
    
    func load() {
        
        if let image = cache?[url] {
            self.image = image
            return
        }
        
        // Thread safe image caching. Indicates current loading status and exit if loading is already in progress
        guard !isLoading else { return }
        
        if let image = cache?[url] {
            self.image = image
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: Self.imageProcessingQueue)
            .map {UIImage(data: $0.data)}
            .replaceError(with: nil)
            // ? Handle subscription lifecycle events and update isLoading accordingly
            .handleEvents(receiveSubscription: {[weak self] _ in self?.onStart()},
                          receiveOutput: {[weak self] in self?.cache($0)},
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() }
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        image.map { cache?[url] = $0 }
    }
    
}


struct AsyncImage<Placeholder: View>: View {
    
    // Use StateObject to bind AsyncImage, so view updates when image changes automatically
    // Used StateObject over ObservedObject or EnvironmentObject for view to manage life cycle (?)
    
    // TODO: Make ImageLoader private again
    @StateObject var loader: ImageLoader
    private let placeholder: Placeholder
    
    
    init(url: URL, @ViewBuilder placeholder: () -> Placeholder) {
        self.placeholder = placeholder()
        // Pass url and environment cache to loader
        // Read image cache from AsyncImage environment and pass it directly to image loaders initializer
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }
    
    
    // Start image loading when AsyncImage appears. Don't need to cancel image loading onDisappear, automatically done by SwiftUI
    
    var body: some View {
        content
            .onAppear(perform: loader.load)
    }
    
    private var content: some View {
        // Placeholder will be replaced with actual image
        Group {
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable()
                
            } else {
                placeholder
            }
        }
        
    }
}


// Add thin abstraction layer on NSCache for caching to be used in ImageLoader
protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}


struct TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL)}
    }
}

// Make image cache app wide available via environment

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue}
    }
}
