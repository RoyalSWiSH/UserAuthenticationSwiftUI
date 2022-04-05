//
//  PickerViewController.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 08.01.22.
//

import Foundation
import UIKit
import PhotosUI
import SwiftUI

class PickerViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    // Array to store images
    var itemProvider: [NSItemProvider] = []
    // Store which selected image is currently displayed
    var iterator: IndexingIterator<[NSItemProvider]>?


    @IBAction func presentPicker(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images

        // Multiimage support
        configuration.selectionLimit = 0


        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self //??
        picker.present(picker, animated: true)
    }

    // Method to display next image
    func displayNextImage() {
        if let itemProvider = iterator?.next(), itemProvider.canLoadObject(ofClass: UIImage.self) {
            let previousImage = imageView.image
            itemProvider.loadObject(ofClass: UIImage.self) { [ weak self ] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else {return}
                    self.imageView.image = image
                }

            }
        }
    }

    // Display next image when touch has ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        displayNextImage()
    }
}

extension PickerViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    // Close image picker after images were selected
        picker.dismiss(animated: true)


        itemProvider = results.map(\.itemProvider)
        iterator = itemProvider.makeIterator()
        displayNextImage()

//        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
//            let previousImage = imageView.image
//            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//                DispatchQueue.main.async {
//                    guard let self = self, let image = image as? UIImage, self.imageView.image ==
//                            previousImage else { return }
//
//                    // Display image on screen
//                    self.imageView.image = image
//
//                    // TODO: Handle error when image can't be displaied
//                }
//            }
//        }


    }



}
