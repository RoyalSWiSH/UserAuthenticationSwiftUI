//
//  JSONLoader.swift
//  UserAuthenticationSwiftUI
//
//  Created by Sebastian Roy on 01.05.22.
//

import Foundation
import SwiftUI

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
    let bpSize: Int
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
struct Data: Codable, Hashable {
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

// View to show data from API request in UI
@available(iOS 15.0, *)
struct JSONContentUI: View {
    @available(iOS 15.0, *)
    //Check Array
    @State private var results =  [Result]()
    
    @StateObject var users = Api()
    @StateObject var api = Api()
    
    let url = URL(string: "https://theminione.com/wp-content/uploads/2016/04/agarose-gel-electrophoresis-dna.jpg")!
    
    //@available(iOS 15.0, *)
    //@ObservedObject var response: Response
    
    @available(iOS 15.0, *)
    
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
        ZStack{
          
            
        AsyncImage(url: self.url, placeholder: { Text("Loading ... 123")
        })
        .aspectRatio(3 / 3, contentMode: .fit)
         //   .frame(minHeight: 300, maxHeight: 600)
         //   .position(x: 200, y: 0)
        .overlay(ForEach(api.gelAnalysisResponse, id: \.self) { gelImage in
                //  List {
                    //  Text(gelImage.gelImageMetaDataDescription.title)
               // VStack{
                ForEach(gelImage.bands, id: \.self) { box in
                    
                Rectangle()
                        .stroke(lineWidth: 2)
                        .frame(width: 20, height: 10)
                        .border(.red)
                        .foregroundColor(.blue)
                        .position(x: CGFloat(box.xMin), y: CGFloat(box.yMin))

                Text(String(box.yMin))
                        .border(.green)
                        .position(x: CGFloat(box.xMin), y: CGFloat(box.yMin))
                    }
                  }
             //   }
            )
            
         // List {
          //  ForEach(api.gelImageMetaData, id: \.self) { gelImage in
              //  List {
                   // Text(gelImage.gelImageMetaDataDescription.title)
//                    Rectangle()
//                            .stroke(lineWidth: 3)
//                            .size(CGSize(width: 20, height: 10))
//                            .foregroundColor(.blue)
//                            .position(x: CGFloat(200), y: 200)
          //      }
//                ForEach(gelImage.data, id:\.self) { gelImageBand in
//                        print("hello")
         //    }
                
       //     }
            //}
        
            
        }.foregroundColor(.yellow)
        
      
        
        List {
            ForEach(users.gelImageMetaData, id: \.self) { gelImage in
                HStack {
                    Text(gelImage.gelImageMetaDataDescription.title)
                }
//            ForEach(users.users, id: \.self) { user in
//                HStack {
//                    Text(user.title)
//                }
                
            }
        }
        .onAppear {
           // users.getGelImageMetaData()
          //  users.fetchJSON()
            api.getGelImageMetaData()
            
     
//            print("Ergebnis Titel")
//            print(gelimage.gelImageMetaDataDescription.title)
        }
    } // View
    
   
    
    func callAPI() {
        guard let url = URL(string: "https://www.google.de") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let string = String(data: data, encoding: .utf8) {
                print(string)
               
            }
        }
        task.resume()
    }
    
    
    @available(iOS 15.0, *)
    func loadData() async {
        guard let url = URL(string: "https://google.de") else {
            print("Invalid URL")
            return }
        do {
            // This line requires iOS 15, so changed min iOS to 15, change later for backward compatibility
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
            // Check Array
            results = [decodedResponse.results]
            print("LoadData()")
            print(results)
        } // try
        } catch {
            print("invalid data")
        } // catch
    } // loadData
} // struct


// Why Observable Object? Call this ViewModel?
class Api: ObservableObject {
    // To automatically update the view when model changes, initiate a published empty array of users
    @Published var users: [user] = []
    
    @Published var gelImageMetaData: [GelImageMetaData] = []
    
    @Published var gelAnalysisResponse: [GelAnalysisResponse] = []
    
    @Published var column: [Column] = []
    
    
    func getGelImageMetaData() {
        guard let url = URL(string: "http://127.0.0.1:1324/api/v1/electrophoresis/imageanalysis") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let string = String(data: data, encoding: .utf8) {
                print(string)
            
          // let json1 = try! JSONDecoder().decode(GelImageMetaData.self, from: data)
            do {
                let json = try JSONDecoder().decode(GelAnalysisResponse.self, from: data)
                print(json)
                DispatchQueue.main.async {
                      self.gelAnalysisResponse.append(json)
                      print("Ergebnis Titel")
                      print(json.meta.title)
                      print("Koordinaten yMin:")
                      print(json.bands[0].yMin)
                   // self.gelImageMetaData.append(json)
//                    print("Ergebnis Titel")
//                    print(json.gelImageMetaDataDescription.title)
//                    print("Visibility")
//                    print(json.data[0].path)
                    //return json
                }
            } catch {
                print("JSON Format does not comply with GelAnalysisResponse. \(error)")
                //print(json.gelImageMetaDataDescription.)
            }
            }
            
        }
        task.resume()
    }
    
    func fetchJSON() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let string = String(data: data, encoding: .utf8) {
               // print(string)
                
               // https://developer.apple.com/documentation/foundation/jsondecoder
                // For better debugging uncomment
                // let json1 = try! JSONDecoder().decode([user].self, from: data)
                
                // [user].self: data structure array of users to which JSON data from API call has to cast to
                do {
                let json = try JSONDecoder().decode([user].self, from: data)
                    print(json[0])
                    // Replace with async await?
                    DispatchQueue.main.async {
                        // self? ??
                        self.users = json
                    }
                } catch  {
                    print("JSON Format does not comply with struct keys.")
                }
            }
        }
        task.resume()
    }
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
