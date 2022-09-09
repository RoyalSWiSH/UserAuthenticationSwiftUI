//
//  GelImagesSampleData.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 26.04.22.
//

import Foundation
import SwiftUI

//let img: Image = Image("GelDemo")
//let sample_image_01: PhotoPickerModel = PhotoPickerModel(with: img)

let imageData: SendImageModel = SendImageModel(photo: "GelDemo", photoImg: Image("GelDemo"))


@available(iOS 15.0, *)
let uid: UUID = UUID()
let box1: BoxCoord = BoxCoord(position_x1: 3, position_x2: 3, position_y1: 2, position_y2: 2)
let box2: BoxCoord = BoxCoord(position_x1: 3, position_x2: 3, position_y1: 2, position_y2: 2)
@available(iOS 15.0, *)
let result: Result = Result(gelID: 1, id: uid, numberOfBands: 2, bands: [box1, box2], title: "Gel Data 1")
@available(iOS 15.0, *)
// Remove try! and catch error
let response: Response = try! Response(result: result)
