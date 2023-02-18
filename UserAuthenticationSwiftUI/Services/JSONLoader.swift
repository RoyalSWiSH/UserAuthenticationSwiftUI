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

//import xid


// Library for image croping. Put into another view later.
import Mantis


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
    // Ladder will be changed on the user client
    var ladder: Ladder
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
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case index = "index"
        case name = "name"
    }
}

struct Band: Codable, Hashable {
    var column: Column
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
    
    // TODO: Make gelAnalysisResponse editable and pass it around to store data later and replace columnName and pixelToBasepairReferenceLadder
    @State var columnName: String
    
    @State private var isShowingPopover: Bool = false
    // TODO: Remove default value
    @State var roundedBasePairSize: Int = 0
    
    // Toggel switch to turn a band into a reference band used as DNA ladder
    @State var isReferenceBand: Bool = false
    
    var fontSize: Int = 14
    
    init(pixelToBasepairReferenceLadder: Binding<[PixelToBasePairArray]>, band: Band ) {
        // initialize all variables first
        self.roundedBasePairSize = band.bpSize
        self._pixelToBasepairReferenceLadder = pixelToBasepairReferenceLadder
        
        self.roundedBasePairSize = 0
        self.band = band
        //        self.bandName = ""
        
        if band.intensity == "pocket" {
            self.columnName = "Sample " + String(band.column.index)
        }
        else {
            self.columnName = ""
        }
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
            
            let lin_max_basePair = log(Float(upperBand!.basePair))
            let lin_min_basePair = log(Float(lowerBand!.basePair))
            
            let lin_slope = Double(lin_max_basePair - lin_min_basePair)/Double(upperBand!.yPixel - lowerBand!.yPixel)
            let lin_Cross = Double(lin_max_basePair) - lin_slope * Double(upperBand!.yPixel)
            
            let expCross = exp(lin_Cross)
            
            return Int(round(powerMappingFromPixelToBasePair(yPositionInPixels: yPositionInPixels, exponent: lin_slope, yCross: expCross)))
            
        }
        else {
            return Int(0)
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
        
        return yCross*pow(Double(yPositionInPixels), exponent)
    }
    
    // y = C*e^(r*x)
    func powerMappingFromPixelToBasePair(yPositionInPixels: Int, exponent: Double, yCross: Double) -> Double {
        //let a = yCross*pow(Double(yPositionInPixels), exponent)
        
        return yCross*exp((exponent*Double(yPositionInPixels)))
    }
    
    func calcBandError(bandSize: Int) -> Int {
        return Int(ceil(Double(bandSize) * 0.25))
    }
    
    func calcBandWidth(band: Band) -> Int {
        return band.xMax-band.xMin
    }
    
    var body: some View {
        
        
        VStack {
            //            if UIScreen.main.bounds.size.width < 100 {
            //                fontSize = 10
            //            } else {
            //                fontSize = 14
            //            }
            
            Text((band.intensity == "pocket" || pixelToBasepairReferenceLadder.count < 2) ? columnName  : String(transformPixelToBasePairs(yPositionInPixels: ((band.yMin+band.yMax)/2), pixelToBasePairReference: pixelToBasepairReferenceLadder)) )
            //            Text(band.column.name)
            //                .border(.green)
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .light, design: .default))
            //                .minimumScaleFactor(0.01)
                .padding(CGFloat(3))
                .minimumScaleFactor(0.3)
            
        } // VStack
        .frame(minWidth:10, idealWidth: 15, maxWidth: 50, minHeight: 5, idealHeight:5, maxHeight: 20, alignment: .center)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture(count: 2) {
            self.isShowingPopover = true
            
            
            
            //                selectedBandItem = band
            //                let a: PixelToBasePairArray = PixelToBasePairArray(yPixel: band.yMin, basePair: roundedBasePairSize)
            //                pixelToBasepairReference.append(a)
        }
        .popover(isPresented: $isShowingPopover) {
            
            
            
            if band.intensity == "pocket" {
                Text("Edit column name").font(.headline).padding()
                TextField("What name does the column have?",  text: $columnName)
            }
            else {
                let bandSize = transformPixelToBasePairs(yPositionInPixels: ((band.yMin+band.yMax)/2), pixelToBasePairReference: pixelToBasepairReferenceLadder)
                let bandError = calcBandError(bandSize: bandSize)
                
                Text("Fragment Size: \(bandSize) +- \(bandError) bp (25 %)").font(.headline).padding()
//                Text("Band is at position " + String((band.yMin+band.yMax)/2) + " px")
                //                // Better way to unwrap .last instead of !?
                //                TextField("What size does this band have?",  value: $pixelToBasepairReferenceLadder.last!.basePair, format: .number)
                
//                if band.xid pixelToBasepairReferenceLadder.bandXid
//                    if pixelToBasepairReferenceLadder.contains(where: {$0.bandXid == band.xid}) {
                HStack{
                    Text("Reference Ladder")
                    Toggle("Reference Band", isOn: $isReferenceBand).labelsHidden()
                }
                    if isReferenceBand {
                    TextField("What size does this band have?",  value: $band.bpSize, format: .number)
                        Button("Add Band to Ladder") {
                            self.pixelToBasepairReferenceLadder.append(PixelToBasePairArray(yPixel:( (band.yMin+band.yMax)/2), basePair: band.bpSize, bandXid: band.xid))
                           
                        }
                        // Show array of base pair sizes for the reference ladder
                        Text("Ladder Px: " + (pixelToBasepairReferenceLadder.map{element in String(element.yPixel)}.joined(separator: ",")))
                        Text("Ladder Bp: " + (pixelToBasepairReferenceLadder.map{element in String(element.basePair)}.joined(separator: ",")))
                        //                let a: PixelToBasePairArray = PixelToBasePairArray(yPixel: band.yMin, basePair: roundedBasePairSize)
                    }
          
//                    .onChange(of: band.bpSize) { bpSize in
//                                    print(bpSize)
//                        self.pixelToBasepairReferenceLadder
//                                }
                
               
              
            }
            
          
            
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                Button("Close popup") {
                    // TODO: Make an x top right
                    self.isShowingPopover = false
                } // Button
            } // Check UIDevice
            //                } // popover
            //pixelToBasepairReferenceLadder.append(a)
        } // popover
        
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
        var ladder: Ladder
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
    var bandXid: String
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
    @State private var selectedBandItem:Band = Band(column: Column(index: 0, name: ""), bpSize: 100, intensity: "low", smear: "low", xid: "342qwasdf", confidence:1.0, xMin: 200, yMin: 100, xMax: 240, yMax: 140)
    // Reference ladder to convert pixels to baise pairs
    @State private var pixelToBasepairReference = [PixelToBasePairArray]()
    
    @State private var showingAlertSavedImage = false
    
    // Title of columns in gel images when identified as pockets
    @State private var bandColumns = [Column]()
    
    // Croping images
    @State var cropRectImage = CGRect(x: 0, y: 0, width: 1, height: 1)
    @State private var showingCropper = false
    // TODO: match this to images selected from image library in mediaItems somehow
    @State private var uiImage: UIImage = UIImage()
    
    @State private var cropShapeType: Mantis.CropShapeType = .rect
    @State private var presetFixedRatioType: Mantis.PresetFixedRatioType = .canUseMultiplePresetFixedRatio()
    
    // Feedback upvoty or frill for WebView
    private var feedbackUrl: URL? = URL(string: "https://app.frill.co/embed/widget/4fd962c8-0f6d-4311-99a8-1c04977462dc")
    
    
    // Not used 27. Jan 2023
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
        
        // TODO: Replace with NavigationSplitView, but thats iOS 16 only
        //        if UIDevice.current.userInterfaceIdiom == .pad {
        //            NavigationView {
        //
        //        } // iPad vs iPhone View
        //        else {
        NavigationView{
            List {
                NavigationLink {
                    VStack {
                        
                        //                Text("Welcome to SnowSeeker!")
                        List(mediaItems.items.indices, id: \.self) { index in
                            let item = mediaItems.items[index]
                            
                                   
                            let imageViewWithOverlay = ZStack(alignment: .topLeading) {
                                
                                if item.mediaType == .photo {
                                    
                                    // TODO: access mediaItems directly
                                    // var image = item.photo
                                    
                                    
                                    
                                    Image(uiImage: mediaItems.items[index].photo!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    // this overlay section is a dublication as in AsyncImage below, TODO: move out to and consolidate in separate function.
                                    
                                        .overlay(
                                            //                                                self.gelAnalysisResponse.isEmpty ? ZStack{ProgressView("Analyzing Gel Image...")} : nil
                                            //
                                            // Use GeometryReader to adjust for screen resizing of image to correctly position gel bands and recalculate pixel position as identified from server side object detection to screen position
                                            GeometryReader { geo in
                                                
                                                // This loop probably just has one item? Yes, but it could load multiple requests, for now gelAnalysisResponse is an array.
                                                // Loop through all API responses and then draw a box with the size of each band
                                                //                                                    ForEach(self.gelAnalysisResponse, id: \.self) { gelImage in
                                                
                                                // Check if there are equal number of analysis results as there are images.
                                                // For example when an image is selected but before it is send to the server those are not equal and therefore there are no bands to draw
                                                if self.gelAnalysisResponse.count == mediaItems.items.count {
                                                    
                                                    let imageResponse = self.gelAnalysisResponse.first(where: { $0.gelImage.xid == mediaItems.items[index].id } )
                                                    
                                                    //                                                        self.gelAnalysisResponse[index].bands
                                                    ForEach(imageResponse!.bands, id: \.self) { band in
                                                        
                                                        // MARK: Visual highlighting of gel bands and band size text formatting
                                                        //
                                                        
                                                        
                                                        BandView(pixelToBasepairReferenceLadder: $pixelToBasepairReference, band: band)
                                                        
                                                        // The divide by 8.4 part are hard coded scale factors to match coordinates from object detection to UI. TODO: Make fit overlay and coordiante transformations universal - 29. Okt 2022 DONE
                                                        
                                                            .position(x: getResizeAdjustedHorizontalPostition(geo: geo, band: band, imageWidth: mediaItems.items[index].photo!.size.width), y: getResizeAdjustedVerticalPostition(geo: geo, band: band, imageHeight: mediaItems.items[index].photo!.size.height))
                                                        // Change band box and text size based on iPhone orientation. Why small number 0.065 to get any effect?.
                                                        // TODO: Check for iPad device and orientation (less shrinking in portrait mode on iPad)
                                                        // TODO: Sometimes the adjustment is only recognized when turning back and forth again
                                                            .frame(width: geo.size.width * (UIDevice.current.orientation.isPortrait ? 0.07 : 1.6), height: geo.size.height * (UIDevice.current.orientation.isPortrait ? 0.07 : 1.2))
                                                            .onAppear() {
                                                                // Simple attempt to create columns that can have a name by identifying pockets. Those pockets might not exist or be detected. Better would be clustering of band coordinates, which would require ML
                                                                if band.intensity == "pocket" {
                                                                    
                                                                    //                                                                            band.column.name = "Sample " + String(band.column.index)
                                                                    // Delete
                                                                    if bandColumns.isEmpty {
                                                                        bandColumns.append(Column(index: 0, name: "Sample " + String(band.column.index) ))
                                                                    }
                                                                    else {
                                                                        bandColumns.append(Column(index: (bandColumns.last!.index+1), name: "Pocket " + String("Sample " + String(band.column.index) )))
                                                                        print(bandColumns.last!.index)
                                                                    }
                                                                    
                                                                }
                                                            }
                                                        
                                                        
                                                    } // ForEach
                                                }  // if
                                                
                                            } // GeometryReader
                                            //                                            } //else
                                        ) // overlay
                                        .onTapGesture(count: 2) {
                                            
                                        }
                                    
                                } // item.mediaType == .photo
                            } // ZStack
                            
                            HStack{
                                // Some status messages for the user
                                if self.gelAnalysisResponse.isEmpty {
                                    // TODO: Better placement or overlay over image
                              
                                    ProgressView("Analyzing Gel Image...")
                                }
                                else if self.pixelToBasepairReference.count < 2 {
                                    Image(systemName: "info.circle")
                                    Text("Select two bands per double tap as reference and assign a size.")
                                }
                                else {
                                    Image(systemName: "info.circle")
                                    Text("Data is not saved in this beta version. Save images to library.")
                                }
                                
                            Spacer()
                            // MARK: Save and Crop
                            Button {
                                //                                            uiImage = imageViewWithOverlay.snapshot()
                                // uiImage = item.photo
                                showingCropper = true
                            }label: {
                                Label("Crop", systemImage: "crop")
                            }.buttonStyle(BorderlessButtonStyle()) // Workaround to avoid Save and Crop action overlay each other https://stackoverflow.com/questions/58514891/two-buttons-inside-hstack-taking-action-of-each-other
                            .fullScreenCover(isPresented: $showingCropper, content: {
                                ImageCropper(image: $mediaItems.items[index].photo,
                                             cropShapeType: $cropShapeType,
                                             presetFixedRatioType: $presetFixedRatioType)
                                    .ignoresSafeArea()
                            })
                            
//
//                            if #available(iOS 16, *) {
//                                // TODO: On a current XCode setup use ShareLink
//                                // Run code in iOS 15 or later.
//                                //    ShareLink("Export", item: imageViewWithOverlay, preview: SharePreview(Text("Shared image"), image: imageViewWithOverlay))
//                                Button {
//                                    let image = imageViewWithOverlay.snapshot()
//
//                                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                                    showingAlertSavedImage = true
//                                } label: {
//                                    Label("Save", systemImage: "square.and.arrow.down")
//                                }
//                                .alert("Image saved. To view and share go to image library.", isPresented: $showingAlertSavedImage) {
//                                    Button("OK", role: .cancel) { }
//                                }
//
//                            } else {
                                // Fall back to earlier iOS APIs.
                                Button {
                                    let image = imageViewWithOverlay.snapshot()
                                    
                                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                    showingAlertSavedImage = true
                                } label: {
                                    Label("Save", systemImage: "square.and.arrow.down")
                                }.buttonStyle(BorderlessButtonStyle())
                                .alert("Image saved. To view and share go to image library.", isPresented: $showingAlertSavedImage) {
                                    Button("OK", role: .cancel) { }
                                }
//                            }
                            }
//                            ZStack {
                            imageViewWithOverlay
                            
                                
//                            }
                  
                            //
                        } // List
                        
                        .navigationBarItems(leading: Button(action: {}, label: {Image(systemName: "trash").foregroundColor(.red)}), trailing: Button(action: { showImagePicker = true }, label: {Image(systemName: "plus")})        .sheet(isPresented: $showImagePicker, content: {
                            PhotoPicker(mediaItems: mediaItems) { didSelectItem  in
                                showImagePicker = false
                            }
                        })) // .sheet)
                        
                        if mediaItems.items.isEmpty {
                            Text("Press + to load a DNA gel image")
                        }
                    } // VStack
                    .navigationBarTitle(Text("Gel Images"))
                    
                } // NavigationLink
            label: {
                Label("Notebook", systemImage: "pencil")
            } // NavigationLink
                NavigationLink { WebView(url:  self.feedbackUrl!).navigationBarTitle(Text("Feedback"))
                    //                            .navigationBarTitleDisplayMode(.inline)
                        .navigationBarHidden(true)
                    
                }
            label: {
                
                Label("Feedback", systemImage: "ellipsis.bubble")
                
            } // NavigationLink
                NavigationLink { Text("Settings")}
            label: {
                
                Label("Settings", systemImage: "gear")
                
            }.navigationBarTitleDisplayMode(.inline)
                // NavigationLink
            }
            // When images are selected, send them for analysis using the API with a POST requst
            .onReceive(mediaItems.$items) { mitems in
                //               self.imageAdded = true
                print("Image changed")
                //  Workaround to remove gel bands when new analysis is started. TODO: Make proper management of responses
                self.gelAnalysisResponse.removeAll()
                
                for item in mitems {
                    // use UUID given by iOS in struct to make it identifyable as filename
                    let fileName = item.id + ".jpg"
                    api.getGelImageMetaData(fileName: fileName, image: item.photo!) { result in
                        // Set result xid to item.id but could also do this on server
                        //                            result?.meta.xid = item.xid
                        self.gelAnalysisResponse.append(result!) //TODO: Catch error when unwrapping
                        print("Result")
                        print(result!)
                        //                            (self.gelAnalysisResponse.append(result)) ?? (self.gelAnalysisResponse = [result])
                    }
                    
                    print("Analyse selected image")
                    print(api.gelAnalysisResponse)
                }
            } // .onReceive
            //                 } // List
        } // NavigationView
        //                .navigationTitle("Gelly")
        //            } // else
        
    } // View
    

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
        
        // TODO: Remove hardcoded URL
        //            let url = URL(string: "http://127.0.0.1:1324/api/v1/electrophoresis/imageanalysis")
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
        
        // TODO: send xid
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

// View extension to export views of gel images as PNG, required below iOS 16, with current iOS 16 use ImageRenderer
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
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

// Crop gel images after selected from library or taken image with camera with Mantis

struct ImageCropper: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var cropShapeType: Mantis.CropShapeType
    @Binding var presetFixedRatioType: Mantis.PresetFixedRatioType
    
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: CropViewControllerDelegate {
        var parent: ImageCropper
        
        init(_ parent: ImageCropper) {
            self.parent = parent
        }
        
        func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
            parent.image = cropped
            print("transformation is \(transformation)")
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        }
        
        func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        }
        
        func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> CropViewController {
        var config = Mantis.Config()
        config.cropShapeType = cropShapeType
        config.presetFixedRatioType = presetFixedRatioType
        // use image for cropping as passed in Binding
        // TODO: Remove optional !
        let cropViewController = Mantis.cropViewController(image: image ?? UIImage(),
                                                           config: config)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }
    
    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {
        
    }
}
