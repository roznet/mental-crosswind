//
//  Metar.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 26/02/2022.
//

import Foundation

struct Metar : Decodable {
    enum Category: String, Decodable {
            case wind_direction, wind_speed
        }
    struct Value : Decodable{
        enum Category: String, Decodable {
                case value
            }
        var value : Int
    }
    
    var wind_direction : Value
    var wind_speed : Value
    
    static func metar(icao : String, callback : @escaping (_ : Metar?, _ : String) -> Void){
        if let url = URL(string: "https://avwx.rest/api/metar/\(icao)"),
           let token = Secrets.shared["avwx"]{
            var request = URLRequest(url: url)
            
            request.setValue("BEARER \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print( error)
                    callback(nil,icao)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                          callback(nil,icao)
                          return
                      }
                if let mimeType = httpResponse.mimeType, mimeType == "application/json",
                   let data = data {
                   let rv : Metar? = try? JSONDecoder().decode(Metar.self, from: data)
                    callback(rv,icao)
                }
            }
            task.resume()
        }
    }
}
