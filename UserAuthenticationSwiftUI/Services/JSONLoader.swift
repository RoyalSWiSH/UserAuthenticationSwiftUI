//
//  JSONLoader.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 01.05.22.
//

import Foundation
import SwiftUI
import Combine

import Accelerate


// iOS 15 check can be removed since target plattform changed to iOS 15, look for better compatibility later


@available(iOS 15.0, *)
class Response: Codable, ObservableObject {
    // Reconvert to array [Result]
    var results: Result
    
    init(result: Result) throws {
        self.results = result
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let gelImageMetaData = try? newJSONDecoder().decode(GelImageMetaData.self, from: jsonData)

// MARK: - GelImageMetaData
//class GelImageMetaData: Codable, ObservableObject {
//    let gelImageMetaDataDescription: Description
//   // let data: [Datum]
//
//    enum CodingKeys: String, CodingKey {
//        case gelImageMetaDataDescription = "description"
//    //    case data
//    }
//
//    init(description: Description) {
//        self.gelImageMetaDataDescription = description
//       // self.data = data
//    }
//
////    init(description: Description, data: [Datum]) {
////        self.gelImageMetaDataDescription = description
////        self.data = data
////    }
//}

struct GelImageMetaData: Codable, Hashable {
    let gelImageMetaDataDescription: Description
    let data: [Data]
    
    enum CodingKeys: String, CodingKey {
        case gelImageMetaDataDescription = "description"
        case data
    }
}

// Replacement for GelImageMetaData

struct GelAnalysisResponse: Codable, Hashable {
    let meta: Meta
    let gelImage: GelImage
    let experimentalMethod: ExperimentalMethod
    let ladder: Ladder
    let detection: Detection
    let columns: [Column]
    let bands: [Band]
    
    enum CodingKeys: String, CodingKey {
        case meta = "meta"
        case gelImage = "image"
        case experimentalMethod = "experimentalMethod"
        case ladder = "ladder"
        case detection = "detection"
        case columns = "columns"
        case bands = "bands"
    }
}

// TODO: Change the types for Xid, CreatedOn and LastUpdated to something better than string
struct Meta: Codable, Hashable {
    let title: String
    let xid: String
    let createdOn: String
    let lastUpdated: String
    
    // Declare the corresponding JSON keys
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case xid = "xid"
        case createdOn = "createdOn"
        case lastUpdated = "lastUpdated"
    }
}

struct GelImage: Codable, Hashable {
    let s3url: String
    let filename: String
    let xid: String
    
    // Declare the corresponding JSON keys
    enum CodingKeys: String, CodingKey {
        case s3url = "s3url"
        case filename = "filename"
        case xid = "xid"
    }
}

struct ExperimentalMethod: Codable, Hashable {
    let name: String
    let sampleType: String
    let units: String
    
    // Declare the corresponding JSON keys
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case sampleType = "sampleType"
        case units = "units"
    }
}

struct Ladder: Codable, Hashable {
    let name: String
    let xid: String
    let fragments: [Fragment]
    
    // Declare the corresponding JSON keys
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case xid = "xid"
        case fragments = "fragments"
    }
}

struct Fragment: Codable, Hashable {
    let position: Int
    let length: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "position"
        case length = "length"
    }
}

struct Detection: Codable, Hashable {
    let mode: String
    let trainingDate: String
    let inferenceDate: String
    
    enum CodingKeys: String, CodingKey {
        case mode = "mode"
        case trainingDate = "trainingDate"
        case inferenceDate = "inferenceDate"
    }
}

struct Column: Codable, Hashable {
    let index: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case index = "index"
        case name = "name"
    }
}

struct Band: Codable, Hashable {
    let column: Int
    var bpSize: Int // is not correctly assigned by remote analysis, since reference ladder is missing
    let intensity: String
    let smear: String
    //   let detection: String
    let xid: String
    let confidence: Double
    let xMin: Int
    let yMin: Int
    let xMax: Int
    let yMax: Int
    
    enum CodingKeys: String, CodingKey {
        case column = "column"
        case bpSize = "bpSize"
        case intensity = "intensity"
        case smear = "smear"
        //      case detection = "detection"
        case xid = "xid"
        case confidence = "confidence"
        case xMin = "xMin"
        case yMin = "yMin"
        case xMax = "xMax"
        case yMax = "yMax"
    }
}

struct BandView: View {
    @State var band: Band
    
    // Reference ladder to convert pixels to baise pairs (maybe add band and reference variables to Band
    // Bind to state of parent view, such that making a band a reference ladder and attaching a reference value to it can redraw the values of all the other bands.
    @Binding private var pixelToBasepairReferenceLadder: [PixelToBasePairArray]
    
    @State private var isShowingPopover: Bool = false
    // TODO: Remove default value
    @State var roundedBasePairSize: Int = 0
    
    init(pixelToBasepairReferenceLadder: Binding<[PixelToBasePairArray]>, band: Band ) {
        // initialize all variables first
        self.roundedBasePairSize = band.bpSize
        self._pixelToBasepairReferenceLadder = pixelToBasepairReferenceLadder
      
        self.roundedBasePairSize = 0
        self.band = band
        // Note: Can't modify state variable in init.

        print(self._pixelToBasepairReferenceLadder)

    }

    // TODO: Write test
    func transformPixelToBasePairs(yPositionInPixels: Int, pixelToBasePairReference: [PixelToBasePairArray]) -> Int {
        
        if pixelToBasePairReference.count > 1 {
            
            // Get the first band in the ladder on the upper image side with a larger DNA fragment size. x2
            let upperBand = pixelToBasePairReference.max { a, b in a.yPixel < b.yPixel }
            // Get the last band in the ladder on the lower image side with a smaller DNA fragment size. x1
            let lowerBand = pixelToBasePairReference.min { a, b in a.yPixel < b.yPixel }
            
           
            
            // deprecated
            let max_y = pixelToBasePairReference.map { $0.yPixel }.max()
            let min_y = pixelToBasePairReference.map { $0.yPixel }.min()
            

            
            // TOOD: Get Index of max value
            // deprecated
            let max_basePair = pixelToBasePairReference.map { $0.basePair }.max()
            let min_basePair = pixelToBasePairReference.map { $0.basePair }.min()
            
        
            // keep slope negative
            let slope = Double(max_basePair! - min_basePair!)/Double(max_y! - min_y!)
            
            // Calculate intersection with y-axis
            
            let yCross = Double(max_basePair!) - slope * Double(max_y!)
            
            // Some temporary code to fit power function instead of linear
            var r = Double((log(Float(min_basePair!))-log(Float(max_basePair!)))/(log(Float(max_y!))-log(Float(min_y!))))
            var c = Double(min_y!)/pow(Double(min_basePair!), Double(r))
            
//            c = 1802.563
//            r = -0.140702
            
            let lin_max_basePair = log(Float(upperBand!.basePair))
            let lin_min_basePair = log(Float(lowerBand!.basePair))
            
            let lin_slope = Double(lin_max_basePair - lin_min_basePair)/Double(upperBand!.yPixel - lowerBand!.yPixel)
            let lin_Cross = Double(lin_max_basePair) - lin_slope * Double(upperBand!.yPixel)
            
            let expCross = pow(2.71828, lin_Cross)
            
            return Int(powerMappingFromPixelToBasePair(yPositionInPixels: yPositionInPixels, exponent: lin_slope, yCross: expCross))
            
//            return Int(exponentialMappingFromPixelToBasePair(yPositionInPixels: yPositionInPixels, exponent: r, yCross: c))
//            let basePairArray = pixelToBasePairReference.map { $0.basePair }
//            let yArray = pixelToBasePairReference.map { $0.yPixel }
//            var intercept: Double
//            var slope2: Double
//            vDSP.lsqPower()
//            var results = vDSP.power(basePairArray, yArray, n: basePairArray.count, m: 1, inter: &intercept, slope: &slope2)
            
//            return Int(linearMappingFromPixelToBasePair(yPositionInPixels:
//                                                        yPositionInPixels, slope: slope, yCross: yCross))
        }
        else {
            return Int(yPositionInPixels)
        }
    }
    
    // TODO: Write test
    func linearMappingFromPixelToBasePair(yPositionInPixels: Int, slope: Double, yCross: Double) -> Double {
        // Linear mapping of pixels to base pairs. This is a very simplistic way to calculate this. Better linear regression, which requires CreateML and an M1 Chip.
        // yPositionInPixels: Position of the band on the image in pixels
        // slope: Gradient to transform pixels into basepairs
        // yCross: Crossing of slope with y-axis
        return Double(Double(yPositionInPixels)*slope+yCross)
    }
    
    // y = C*x^(r)
    func exponentialMappingFromPixelToBasePair(yPositionInPixels: Int, exponent: Double, yCross: Double) -> Double {
        let a = yCross*pow(Double(yPositionInPixels), exponent)
        
        return yCross*pow(Double(yPositionInPixels), exponent)
    }
    
    // y = C*e^(r*x)
    func powerMappingFromPixelToBasePair(yPositionInPixels: Int, exponent: Double, yCross: Double) -> Double {
        //let a = yCross*pow(Double(yPositionInPixels), exponent)
        
        return yCross*pow(Double(2.71828), (exponent*Double(yPositionInPixels)))
    }
    var body: some View {
        
        
        //                                                            let yPosition = band.yMin
        //
        //                                                            let basePairSize:Double = transformPixelToBasePairs(yPositionInPixels: yPosition, pixelToBasePairReference: pixelToBasepairReference)
        //
                                                                    
        //                                                            let roundedBasePairSize: Int = Int( round(basePairSize*10)/10 )
        
        VStack {
        
            Text((band.intensity == "pocket") ? "Pocket" : String(transformPixelToBasePairs(yPositionInPixels: band.yMin, pixelToBasePairReference: pixelToBasepairReferenceLadder)) )
            .onTapGesture(count: 2) {
                self.isShowingPopover = true
                
                
                
//                selectedBandItem = band
//                let a: PixelToBasePairArray = PixelToBasePairArray(yPixel: band.yMin, basePair: roundedBasePairSize)
//                pixelToBasepairReference.append(a)
            }
            .popover(isPresented: $isShowingPopover) {
//                print("hallo")
                Text("Band " + String(band.yMin))
                Text("Convert reference band at position " + String(transformPixelToBasePairs(yPositionInPixels: band.yMin, pixelToBasePairReference: pixelToBasepairReferenceLadder)) + "px to base pairs").font(.headline).padding()
//                // Better way to unwrap .last instead of !?
//                TextField("What size does this band have?",  value: $pixelToBasepairReferenceLadder.last!.basePair, format: .number)
                TextField("What size does this band have?",  value: $band.bpSize, format: .number)
//                // Show array of base pair sizes for the reference ladder
                Text("Ladder Px: " + (pixelToBasepairReferenceLadder.map{element in String(element.yPixel)}.joined(separator: ",")))
                Text("Ladder Bp: " + (pixelToBasepairReferenceLadder.map{element in String(element.basePair)}.joined(separator: ",")))
//                let a: PixelToBasePairArray = PixelToBasePairArray(yPixel: band.yMin, basePair: roundedBasePairSize)
                Button("Mark as reference band") {
                    self.pixelToBasepairReferenceLadder.append(PixelToBasePairArray(yPixel: band.yMin, basePair: band.bpSize))
                }
                //pixelToBasepairReferenceLadder.append(a)
            }
        }
    }
}

//final class StringExtensionsTests: XCTestCase {
//    func testUppercaseFirst() {
//        let input = "antoine"
//        let expectedOutput = 0
//        let bandView = BandView()
//        XCTAssertEqual(bandView.linearMappingFromPixelToBasePair(yPositionInPixels: 0, slope: 0, yCross: 0), expectedOutput, "The String is not correctly capitalized.")
//    }
//}

extension GelAnalysisResponse {
    
    
    enum DecodingError: Error {
        case descriptionError
        case dataError
    }
    init(from decoder: Decoder) throws {
        let meta: Meta
        let gelImage: GelImage
        
        let experimentalMethod: ExperimentalMethod
        let ladder: Ladder
        let detection: Detection
        let columns: [Column]
        let bands: [Band]
        
        let container = try decoder.container(keyedBy:CodingKeys.self)
        
        do {
            meta =  try container.decode(Meta.self, forKey: .meta)
        }
        catch {
            print("Error decoding Meta")
            throw DecodingError.descriptionError
        }
        
        do {
            gelImage =  try container.decode(GelImage.self, forKey: .gelImage)
        }
        catch {
            print("Error decoding GelImage")
            print(error)
            throw DecodingError.descriptionError
        }
        
        do {
            experimentalMethod =  try container.decode(ExperimentalMethod.self, forKey: .experimentalMethod)
        }
        catch {
            print(error)
            throw DecodingError.descriptionError
        }
        
        do {
            ladder =  try container.decode(Ladder.self, forKey: .ladder)
        }
        catch {
            print(error)
            throw DecodingError.descriptionError
        }
        
        do {
            detection =  try container.decode(Detection.self, forKey: .detection)
        }
        catch {
            print(error)
            throw DecodingError.descriptionError
        }
        
        do {
            columns =  try container.decode([Column].self, forKey: .columns)
        }
        catch {
            print(error)
            throw DecodingError.descriptionError
        }
        
        do {
            bands =  try container.decode([Band].self, forKey: .bands)
        }
        catch {
            print(error)
            throw DecodingError.descriptionError
        }
        //        guard let desc = try container.decode(Description?.self, forKey: .gelImageMetaDataDescription)
        //        else {
        //            print("Error decoding description")
        //            throw DecodingError.descriptionError
        //        }
        //
        self.meta = meta
        self.gelImage = gelImage
        self.experimentalMethod = experimentalMethod
        self.ladder = ladder
        self.detection = detection
        self.columns = columns
        self.bands = bands
    }
}

extension GelImageMetaData {
    
    
    enum DecodingError: Error {
        case descriptionError
        case dataError
    }
    init(from decoder: Decoder) throws {
        let desc: Description
        let data: [Data]
        let container = try decoder.container(keyedBy:CodingKeys.self)
        
        do {
            desc =  try container.decode(Description.self, forKey: .gelImageMetaDataDescription)
        }
        catch {
            print("Error decoding description")
            throw DecodingError.descriptionError
        }
        
        do {
            data =  try container.decode([Data].self, forKey: .data)
        }
        catch {
            print(error)
            throw DecodingError.descriptionError
        }
        
        //        guard let desc = try container.decode(Description?.self, forKey: .gelImageMetaDataDescription)
        //        else {
        //            print("Error decoding description")
        //            throw DecodingError.descriptionError
        //        }
        //
        self.gelImageMetaDataDescription = desc
        self.data = data
    }
}

// MARK: - Datum
struct BandData: Codable, Hashable {
    let column: Int
    let bpSize: JSONNull?
    let visibility, smear, detection, uid: String
    let path: [Path]
    let box: Box
}

// MARK: - Box
struct Box: Codable, Hashable {
    let x, y: Int
    let height, width: Int
}

// MARK: - Path
struct Path: Codable, Hashable {
    let x, y: Double
}

// MARK: - Description
struct Description: Codable, Hashable {
    let title, uid, apiVersion, jsonVersion: String
    let sampleType, experimentalMethod, units, ladder: String
    let detection: Detection
    let columns: [Column]
    let image: ImageProperties
}

//// MARK: - Column
//struct Column: Codable, Hashable {
//    let number: Int
//    let name, uid: String
// //   let boundaries: Boundaries
//}

// MARK: - Boundaries
struct Boundaries: Codable, Hashable {
    let xLeft, xRight: Double
}

//// MARK: - Detection
//struct Detection: Codable, Hashable {
//    let mode, algorithm, date: String
//}

// MARK: - Image
struct ImageProperties: Codable, Hashable {
    let size: Size
    let hash: Hash
}

// MARK: - Hash
struct Hash: Codable, Hashable {
    let value, algorithm: String
}

// MARK: - Size
struct Size: Codable, Hashable {
    let width, height: Int
    let unit: String
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public func hash(into hasher: inout Hasher) {
        // No-op
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
// END

//
// Struct for analyzed gel bands retrieved via API
@available(iOS 15.0, *)
struct Result:Codable, Hashable {
    let gelID: Int
    let id: UUID
    let numberOfBands: Int
    let bands: [BoxCoord]
    let title: String
    
    init(gelID: Int, id: UUID, numberOfBands: Int, bands: [BoxCoord], title: String) { // default struct initializer
        self.gelID = gelID
        self.id = id
        self.numberOfBands = numberOfBands
        self.bands = bands
        self.title = title
    }
    
}

//struct users: Codable, Hashable {
//    let users: [String: users]
//}

struct user:Codable, Hashable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

//callAPI()

// Coordinates for boxes around identified gel band
struct BoxCoord: Codable, Hashable {
    let position_x1: Int
    let position_x2: Int
    let position_y1: Int
    let position_y2: Int
}

struct PixelToBasePairArray: Codable, Hashable {
    var yPixel: Int
    var basePair: Int
}

enum FittingError: Error {
    case ArraySizesInequal
    
}

// View to show data from API request in UI
@available(iOS 15.0, *)
struct JSONContentUI: View {
    @available(iOS 15.0, *)
    //Check Array
    @State private var results =  [Result]()
    
    // Take an image and make a POST request
    @StateObject var api = Api()
    @State var gelAnalysisResponse = [GelAnalysisResponse]()
    
    // Image used to send as POST request
    @State var image:UIImage = UIImage()
    
    // State to handle popover to set band sizes for reference ladder
    @State private var showPopover:[Bool] = [false]
    @State private var showPopover2:Bool = false
    
    // Pick image from library
    @State var showImagePicker: Bool = false
    @ObservedObject var mediaItems = PickedMediaItems()
    @State private var imageAdded = false
    
    
    // Sample data for initialization
    @State private var selectedBandItem:Band = Band(column: 1, bpSize: 100, intensity: "low", smear: "low", xid: "342qwasdf", confidence:1.0, xMin: 200, yMin: 100, xMax: 240, yMax: 140)
    // Reference ladder to convert pixels to baise pairs
    @State private var pixelToBasepairReference = [PixelToBasePairArray]()
    
    
    //    let url = URL(string: "https://theminione.com/wp-content/uploads/2016/04/agarose-gel-electrophoresis-dna.jpg")!
    ////     TODO: Figure out how to use url with correct init, then remoce ImageLoaderForPOSTRequest, it is redundant
    //    var imageLoader = ImageLoaderForPOSTRequest(url:URL(string: "https://theminione.com/wp-content/uploads/2016/04/agarose-gel-electrophoresis-dna.jpg")!)
    ////
    /// url used to load image in AsyncImage for UI display
    let url = URL(string: "https://www.bioinformatics.nl/molbi/SimpleCloningLab/images/GelMovie_gel2.jpg")!
    // TODO: Figure out how to use url with correct init, then remove ImageLoaderForPOSTRequest, it is redundant
    // load the same image to use in POST request
    var imageLoader = ImageLoaderForPOSTRequest(url:URL(string: "https://www.bioinformatics.nl/molbi/SimpleCloningLab/images/GelMovie_gel2.jpg")!)
    
    // var asyncImage = AsyncImage(url: url, placeholder: { Text("Loading ... 123")
    // })
    
    
    
    // Functions to adjust the positioning in overlay to the screen resized image
    // TODO: Get px height of image
    func getResizeAdjustedHorizontalPostition(geo: GeometryProxy, band: Band, imageWidth: Double) -> CGFloat {
        
        return CGFloat(CGFloat((band.xMin+band.xMax)/2) * (geo.size.width / imageWidth))
    }
    
    func getResizeAdjustedVerticalPostition(geo: GeometryProxy, band: Band, imageHeight: Double) -> CGFloat {
        return CGFloat(CGFloat((band.yMin+band.yMax)/2) * (geo.size.height / (imageHeight)))
    }
    
//    func transformPixelToBasePairs(yPositionInPixels: Int, pixelToBasePairReference: [PixelToBasePairArray]) -> Double {
//
//        if pixelToBasePairReference.count > 1 {
//
//            let max_y = pixelToBasePairReference.map { $0.yPixel }.max()
//            let min_y = pixelToBasePairReference.map { $0.yPixel }.min()
//
//            let delta_y = Double(max_y! - min_y!)
//
//            // TOOD: Get Index of max value
//
//            let max_basePair = pixelToBasePairReference.map { $0.basePair }.max()
//            let min_basePair = pixelToBasePairReference.map { $0.basePair }.min()
//
//            let delta_basePair = Double(max_basePair! - min_basePair!)
//
//            let slope = delta_basePair/delta_y
//
//            return linearMappingFromPixelToBasePair(yPositionInPixels:
//                                                        yPositionInPixels, slope: slope, yCross: 0)
//        }
//        else {
//            return Double(yPositionInPixels)
//        }
//    }
//
//    func linearMappingFromPixelToBasePair(yPositionInPixels: Int, slope: Double, yCross: Double) -> Double {
//        // Linear mapping of pixels to base pairs. This is a very simplistic way to calculate this. Better linear regression, which requires CreateML and an M1 Chip.
//        // yPositionInPixels: Position of the band on the image in pixels
//        // slope: Gradient to transform pixels into basepairs
//        // yCross: Crossing of slope with y-axis
//        return Double(Double(yPositionInPixels)*slope+yCross)
//    }
    
    
//    @available(iOS 15.0, *)
    
    
    var body: some View {
        //        List(results, id: \.id) { item in
        //            VStack(alignment: .leading) {
        //                Text(item.title)
        //                    .font(.headline)
        //                //Text(item.numberOfBands)
        //            }
        //        }
        //        .task {
        //            await loadData()
        //        }
        // TODO: Replace with NavigationSplitView, but thats iOS 16 only
        if UIDevice.current.userInterfaceIdiom == .phone {
            NavigationView {

                VStack{

                    // TODO: Figure out how to get individual popover at the position of the band on iPad
                    Button("Analyze") { print("Analyse selected image 4")
                        for item in mediaItems.items {
                            api.getGelImageMetaData(fileName: "file", image: item.photo ?? UIImage()) {result in
                                
                            }
                            print("Analyse selected image")
                            print(api.gelAnalysisResponse)}}
//                    .popover(isPresented: $showPopover2) {
//                        Text("Convert refe rence band at position " + String(linearMappingFromPixelToBasePair(yPositionInPixels: selectedBandItem.yMin, slope: 1.0, yCross: 0.0)) + "px to base pairs").font(.headline).padding()
//                        // Better way to unwrap .last instead of !?
//                        TextField("What size does this band have?",  value: $pixelToBasepairReference.last!.basePair, format: .number)
//                        // Show array of base pair sizes for the reference ladder
//                        Text("Ladder Px: " + (pixelToBasepairReference.map{element in String(element.yPixel)}.joined(separator: ",")))
//                        Text("Ladder Bp: " + (pixelToBasepairReference.map{element in String(element.basePair)}.joined(separator: ",")))
//                    }



                    //       ZStack{
                    //
                    //        AsyncImage(url: self.url, placeholder: {
                    //            Text("Loading ... 123")
                    //        })
                    //        // TODO: Use imageloader from AsyncImage instead of loading the image for the second time
                    //        .onReceive(imageLoader.didChange) { data in
                    //                    self.image = UIImage(data: data) ?? UIImage()
                    //
                    //                    // Make call to API with the image loaded
                    //                    // TODO: Make this less ugly
                    ////                    api.getGelImageMetaData(fileName: "file", image: self.image)
                    //                 //   print("Image was loaded and send in onReceive")
                    //        } // onReceive
                    //        .overlay(
                    //        // Overlay of gel bands
                    //            GeometryReader { geo in
                    //
                    //            // This loop probably just has one item? Yes, but it could load multiple requests, for now gelAnalysisResponse is an array.
                    //            // Loop through all API responses and then draw a box with the size of each band
                    //            ForEach(api.gelAnalysisResponse, id: \.self) { gelImage in
                    //
                    //                ForEach(gelImage.bands, id: \.self) { band in
                    //// MARK: Visual highlighting of gel bands and band size text formatting
                    ////                Rectangle()
                    ////                        .stroke(lineWidth: 2)
                    ////                        .frame(width: 20, height: 10)
                    ////                        .border(.red)
                    ////                        .foregroundColor(.blue)
                    ////                        .position(x: CGFloat(box.xMin)/8.4, y: CGFloat(box.yMin)/4.1)
                    //
                    //
                    //                    // Convert position from pixel into base pairs and round them. Error in a gel 10 bp?
                    //
                    //
                    //                    let yPosition = band.yMin
                    //
                    //                    let basePairSize:Double = transformPixelToBasePairs(yPositionInPixels: yPosition, pixelToBasePairReference: pixelToBasepairReference)
                    //
                    //
                    //                    let roundedBasePairSize: Int = Int( round(basePairSize*10)/10 )
                    //                    Text(String(roundedBasePairSize))
                    //                        .border(.green)
                    //                        .foregroundColor(.black)
                    //                        .font(.system(size: 12, weight: .light, design: .serif))
                    //                       // .margin(top: 32, bottom: 8, left: 16, right: 16)
                    //                        .background(Color.gray.opacity(0.6))
                    //                        .onAppear() {
                    //                            // initialize popover state
                    //                            self.showPopover.append(false)
                    //                        }
                    //                        .onTapGesture(count: 2) {
                    //                            print("Double tapped!")
                    //                            self.showPopover[0] = true
                    //                            showPopover2 = true
                    //
                    //                            selectedBandItem = band
                    //                            let a: PixelToBasePairArray = PixelToBasePairArray(yPixel: band.yMin, basePair: roundedBasePairSize)
                    //                            pixelToBasepairReference.append(a)
                    //                        }
                    //                        .onLongPressGesture {
                    //                                print("Long pressed!")
                    //                        }
                    ////                        .popover(isPresented:  $showPopover2) {
                    //////                        .popover(isPresented: self.$showPopover[0]) {
                    ////                                    Text("Your content here")
                    ////                                        .font(.headline)
                    ////                                        .padding()
                    ////                                }
                    ////                        .popover(isPresented: self.$showPopover[0])
                    //                    // The divide by 8.4 part are hard coded scale factors to match coordinates from object detection to UI. TODO: Make fit overlay and coordiante transformations universal - 29. Okt 2022 DONE
                    //                        .position(x: getResizeAdjustedHorizontalPostition(geo: geo, band: band, imageWidth: self.image.size.width), y: getResizeAdjustedVerticalPostition(geo: geo, band: band, imageHeight: self.image.size.height))
                    //
                    //                    } // ForEach
                    //                  }  // ForEach
                    //                    }
                    //                ) // .overlay
                    //               .scaledToFit()
                    //
                    //       }.foregroundColor(.black)
                    //            .scaledToFit()

                } // VStack
                .navigationBarItems(leading: Button(action: {}, label: {Image(systemName: "trash").foregroundColor(.red)}), trailing: Button(action: { showImagePicker = true }, label: {Image(systemName: "plus")}))
                .navigationTitle("Gelly")

                //            Button(action: {}, label: {Image(systemName: "trash").foregroundColor(.red)})
                //            Button(action: { showImagePicker = true }, label: {Image(systemName: "plus")})

                //            VStack {
                //                Text("Welcome to SnowSeeker!")
                //            List(mediaItems.items, id: \.id) {item in
                //                ZStack(alignment: .topLeading) {
                //                    if item.mediaType == .photo {
                //
                //                        let image = item.photo ?? UIImage()
                //
                //                        Image(uiImage: item.photo ?? UIImage())
                //                        .resizable()
                //                        .aspectRatio(contentMode: .fit)
                //                        // this overlay section is a dublication as in AsyncImage below, TODO: move out to and consolidate in separate function.
                //                        .overlay(
                //                             // Overlay of gel bands
                //                                GeometryReader { geo in
                //
                //                                // This loop probably just has one item? Yes, but it could load multiple requests, for now gelAnalysisResponse is an array.
                //                                // Loop through all API responses and then draw a box with the size of each band
                //                                ForEach(api.gelAnalysisResponse, id: \.self) { gelImage in
                //
                //                                    ForEach(gelImage.bands, id: \.self) { band in
                //                    // MARK: Visual highlighting of gel bands and band size text formatting
                //                    //                Rectangle()
                //                    //                        .stroke(lineWidth: 2)
                //                    //                        .frame(width: 20, height: 10)
                //                    //                        .border(.red)
                //                    //                        .foregroundColor(.blue)
                //                    //                        .position(x: CGFloat(box.xMin)/8.4, y: CGFloat(box.yMin)/4.1)
                //
                //
                //                                        // Convert position from pixel into base pairs and round them. Error in a gel 10 bp?
                //
                //
                //                                        let yPosition = band.yMin
                //
                //                                        let basePairSize:Double = transformPixelToBasePairs(yPositionInPixels: yPosition, pixelToBasePairReference: pixelToBasepairReference)
                //
                //
                //                                        let roundedBasePairSize: Int = Int( round(basePairSize*10)/10 )
                //                                        Text(String(roundedBasePairSize))
                //                                            .border(.green)
                //                                            .foregroundColor(.black)
                //                                            .font(.system(size: 12, weight: .light, design: .serif))
                //                                           // .margin(top: 32, bottom: 8, left: 16, right: 16)
                //                                            .background(Color.gray.opacity(0.6))
                //                                            .onAppear() {
                //                                                // initialize popover state
                //                                                self.showPopover.append(false)
                //                                            }
                //                                            .onTapGesture(count: 2) {
                //                                                print("Double tapped!")
                //                                                self.showPopover[0] = true
                //                                                showPopover2 = true
                //
                //                                                selectedBandItem = band
                //                                                let a: PixelToBasePairArray = PixelToBasePairArray(yPixel: band.yMin, basePair: roundedBasePairSize)
                //                                                pixelToBasepairReference.append(a)
                //                                            }
                //                                            .onLongPressGesture {
                //                                                    print("Long pressed!")
                //                                            }
                //                    //                        .popover(isPresented:  $showPopover2) {
                //                    ////                        .popover(isPresented: self.$showPopover[0]) {
                //                    //                                    Text("Your content here")
                //                    //                                        .font(.headline)
                //                    //                                        .padding()
                //                    //                                }
                //                    //                        .popover(isPresented: self.$showPopover[0])
                //                                        // The divide by 8.4 part are hard coded scale factors to match coordinates from object detection to UI. TODO: Make fit overlay and coordiante transformations universal - 29. Okt 2022 DONE
                //                                            .position(x: getResizeAdjustedHorizontalPostition(geo: geo, band: band, imageWidth: image.size.width), y: getResizeAdjustedVerticalPostition(geo: geo, band: band, imageHeight: image.size.height))
                //
                //
                //                                        } // ForEach
                //                                      }  // ForEach
                //                                        }
                //                                    ).scaledToFit()
                //
                //                    }
                //            }.scaledToFit()
                //            }
                //        }
                //           RegisterView()
            } // NavigationView
            .navigationViewStyle(StackNavigationViewStyle())
            .sheet(isPresented: $showImagePicker, content: {
                PhotoPicker(mediaItems: mediaItems) { didSelectItem  in
                    showImagePicker = false
 
                    print("Analyse selected image 1")
                    for item in mediaItems.items {
                        // TODO: Call the function but return something and store it into an object
                        api.getGelImageMetaData(fileName: "file", image: item.photo ?? UIImage()) {result in
                            
                        }
//                        print("Analyse selected image")
//                        print(api.gelAnalysisResponse)
                    }
                }
            }) // .sheet
        } // iPad vs iPhone View
        else {
            NavigationView{
                List {
                    NavigationLink {
                        VStack {
                            
                            //                Text("Welcome to SnowSeeker!")
                            List(mediaItems.items, id: \.id) {item in
                                if self.gelAnalysisResponse.isEmpty {
                                    // TODO: Better placement or overlay over image
                                        ProgressView("Analyzing Gel Image...")
                                                   }
                                ZStack(alignment: .topLeading) {
                                    if item.mediaType == .photo {
                                        
                                        let image = item.photo ?? UIImage()
                                        
                                        Image(uiImage: item.photo ?? UIImage())
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                        // this overlay section is a dublication as in AsyncImage below, TODO: move out to and consolidate in separate function.
                                        
                                            .overlay(
//                                                self.gelAnalysisResponse.isEmpty ? ZStack{ProgressView("Analyzing Gel Image...")} : nil
//
                                                // Overlay of gel bands
                                                GeometryReader { geo in
                                                    
                                                    // This loop probably just has one item? Yes, but it could load multiple requests, for now gelAnalysisResponse is an array.
                                                    // Loop through all API responses and then draw a box with the size of each band
                                                    ForEach(api.gelAnalysisResponse, id: \.self) { gelImage in
                                                        
                                                        ForEach(gelImage.bands, id: \.self) { band in
                                                            // MARK: Visual highlighting of gel bands and band size text formatting
                                                            //                Rectangle()
                                                            //                        .stroke(lineWidth: 2)
                                                            //                        .frame(width: 20, height: 10)
                                                            //                        .border(.red)
                                                            //                        .foregroundColor(.blue)
                                                            //                        .position(x: CGFloat(box.xMin)/8.4, y: CGFloat(box.yMin)/4.1)
                                                            
                                                            
                                                            // Convert position from pixel into base pairs and round them. Error in a gel 10 bp?
//
//
//                                                            let yPosition = band.yMin
//
//                                                            let basePairSize:Double = transformPixelToBasePairs(yPositionInPixels: yPosition, pixelToBasePairReference: pixelToBasepairReference)
//
                                                            
//                                                            let roundedBasePairSize: Int = Int( round(basePairSize*10)/10 )
//                                                            Text(String(roundedBasePairSize))
                                                            
                                                            BandView(pixelToBasepairReferenceLadder: $pixelToBasepairReference, band: band)
//                                                                .border(.green)
//                                                                .foregroundColor(.black)
//                                                                .font(.system(size: 12, weight: .light, design: .serif))
//                                                            // .margin(top: 32, bottom: 8, left: 16, right: 16)
//                                                                .background(Color.gray.opacity(0.6))
//                                                                .onAppear() {
//                                                                    // initialize popover state
//                                                                    self.showPopover.append(false)
//                                                                }
//                                                                .onTapGesture(count: 2) {
//                                                                    print("Double tapped!")
//                                                                    self.showPopover[0] = true
//                                                                    showPopover2 = true
//
//                                                                    selectedBandItem = band
//                                                                    let a: PixelToBasePairArray = PixelToBasePairArray(yPixel: band.yMin, basePair: roundedBasePairSize)
//                                                                    pixelToBasepairReference.append(a)
//                                                                }
//                                                                .onLongPressGesture {
//                                                                    print("Long pressed!")
//                                                                }
//                                                                .popover(isPresented: self.$showPopover[0])
                                                            // The divide by 8.4 part are hard coded scale factors to match coordinates from object detection to UI. TODO: Make fit overlay and coordiante transformations universal - 29. Okt 2022 DONE
                                                            
                                                                .position(x: getResizeAdjustedHorizontalPostition(geo: geo, band: band, imageWidth: image.size.width), y: getResizeAdjustedVerticalPostition(geo: geo, band: band, imageHeight: image.size.height))
                                                            
                                                            
                                                        } // ForEach
                                                    }  // ForEach
                                          
                                                } // GeometryReader
//                                            } //else
                                            ) // overlay
                                        
                                    } // item.mediaType == .photo
                                } // ZStack
                                                                             
                            } // List
                            .navigationBarItems(leading: Button(action: {}, label: {Image(systemName: "trash").foregroundColor(.red)}), trailing: Button(action: { showImagePicker = true }, label: {Image(systemName: "plus")})        .sheet(isPresented: $showImagePicker, content: {
                                PhotoPicker(mediaItems: mediaItems) { didSelectItem  in
                                    showImagePicker = false
                                    
                                }
                            })) // .sheet)
                            
                            
                        } // VStack
                        .navigationBarTitle(Text("Foo"))
       
                    } // NavigationLink
                label: {
                    Label("LabBook", systemImage: "info.circle")
                } // NavigationLink
                    
                    NavigationLink { Text("Settings")}
                label: {

                    Label("Settings", systemImage: "gear")

                  } // NavigationLink
                }
                // When images are selected, send them for analysis using the API with a POST requst
                .onReceive(mediaItems.$items) { mitems in
//               self.imageAdded = true
                    print("Image changed")
                    for item in mitems {
                        api.getGelImageMetaData(fileName: "file", image: item.photo ?? UIImage()) { result in
                            self.gelAnalysisResponse.append(result!) //TODO: Catch error when unwrapping
//                            (self.gelAnalysisResponse.append(result)) ?? (self.gelAnalysisResponse = [result])
                        }

                        print("Analyse selected image")
                        print(api.gelAnalysisResponse)
                    }
                   } // .onReceive
//                 } // List
                } // NavigationView
//                .navigationTitle("Gelly")
            } // else

        } // View
        
        
        // TODO: This was a test to load data with async. Remove.
        //    func callAPI() {
        //        guard let url = URL(string: "https://www.google.de") else { return }
        //
        //        let task = URLSession.shared.dataTask(with: url) { data, response, error in
        //            if let data = data, let string = String(data: data, encoding: .utf8) {
        //                print(string)
        //
        //            }
        //        }
        //        task.resume()
        //    }
        //
        
        //    @available(iOS 15.0, *)
        // TODO: This was a test to load data with async. Remove.
        //    func loadData() async {
        //        guard let url = URL(string: "https://google.de") else {
        //            print("Invalid URL")
        //            return }
        //        do {
        //            // This line requires iOS 15, so changed min iOS to 15, change later for backward compatibility
        //        let (data, _) = try await URLSession.shared.data(from: url)
        //
        //        if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
        //            // Check Array
        //            let results = [decodedResponse.results]
        //            print("LoadData()")
        //            print(results)
        //        } // try
        //        } catch {
        //            print("invalid data")
        //        } // catch
        //    } // loadData
    } // struct
    
    
    // Why Observable Object? Call this ViewModel?
    // TODO: Rename Api to something more useful
    class Api: ObservableObject {
        // To automatically update the view when model changes, initiate a published empty array of users
        // @Published var users: [user] = []
        
        //@Published var gelImageMetaData: [GelImageMetaData] = []
        
        // Array where multiple responses can be loaded into
        @Published var gelAnalysisResponse: [GelAnalysisResponse] = []
        
        // @Published var column: [Column] = []
        
        // @State var image:UIImage = UIImage()
        
        // Take an UIImage, form a POST request and send it to analysis to obtain positions of bands and appends it to gelAnalysisResponse
        // Why not return response instead of appending to @Published state object?
        // Take a function that is executed when fetching data is completed and assigns the result to gelAnalysisResponse in view JSONContentUI
        func getGelImageMetaData(fileName: String, image: UIImage, completion: @escaping (GelAnalysisResponse?) -> Void) {
            
            
            // let url = URL(string: "http://127.0.0.1:1324/api/v1/electrophoresis/imageanalysis")
            let url = URL(string: "http://167.172.190.93:1324/api/v1/electrophoresis/imageanalysis")
            let boundary = UUID().uuidString
            
            let session = URLSession.shared
            
            var urlRequest = URLRequest(url: url!)
            urlRequest.httpMethod = "POST"
            
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var data = Data()
            
            // Add the image data to the raw http request data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            let paramName = "file"
            data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            data.append(image.pngData()!)
            
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            session.uploadTask(with: urlRequest, from: data) { data, response, error in
                if let data = data, let string = String(data: data, encoding: .utf8) {
                    print(string)
                    
                    // let json1 = try! JSONDecoder().decode(GelImageMetaData.self, from: data)
                    do {
                        let json = try JSONDecoder().decode(GelAnalysisResponse.self, from: data)
                        print(json)
                        DispatchQueue.main.async {
                            // Deprecated, use completion instead of gelAnalysisResponse as published state object
                            self.gelAnalysisResponse.append(json)
                            // call completion function in view to return data
                            completion(json)
                            print("Ergebnis Titel")
                            print(json.meta.title)
                            print("Koordinaten yMin:")
                            print(json.bands[0].yMin)
                            //return json
                        }
                    } catch {
                        print("JSON Format does not comply with GelAnalysisResponse. \(error)")
                        //print(json.gelImageMetaDataDescription.)
                    }
                }
            }.resume()
        } // func getGelImageMetaData(...)
        
        // TODO: Delete fetchJSON, since it is a sample request for TODOs to test http requests
        //    func fetchJSON() {
        //        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/") else { return }
        //
        //        let task = URLSession.shared.dataTask(with: url) { data, response, error in
        //            if let data = data, let _ = String(data: data, encoding: .utf8) {
        //               // print(string)
        //
        //                // https://developer.apple.com/documentation/foundation/jsondecoder
        //                // For better debugging uncomment
        //                // let json1 = try! JSONDecoder().decode([user].self, from: data)
        //
        //                // [user].self: data structure array of users to which JSON data from API call has to cast to
        //                do {
        //                let json = try JSONDecoder().decode([user].self, from: data)
        //                    print(json[0])
        //                    // Replace with async await?
        //                    DispatchQueue.main.async {
        //                        // self? ??
        //                        self.users = json
        //                    }
        //                } catch  {
        //                    print("JSON Format does not comply with struct keys.")
        //                }
        //            }
        //        }
        //        task.resume()
        //    }
}


struct JSONContentUI_Previews: PreviewProvider {
    static var previews: some View {
        
        if #available(iOS 15.0, *) {
            JSONContentUI()
        } else {
            // Fallback on earlier versions
        }
    }
}

extension Data {
    
    /// Append string to Data
    ///
    /// Rather than littering my code with calls to `data(using: .utf8)` to convert `String` values to `Data`, this wraps it in a nice convenient little extension to Data. This defaults to converting using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `Data`.
    
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data1 = string.data(using: encoding) {
            append(data1)
        }
    }
}

// Load an image from URL. Redundant to AsyncImage, but don't know how to receive the UIImage from there
class ImageLoaderForPOSTRequest: ObservableObject {
    // PassthroughSubject is a Combine object
    var didChange = PassthroughSubject<Data, Never>()
    // what happens here?
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    
    init(url:URL) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            // Why use DispatchQueue here?
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}
