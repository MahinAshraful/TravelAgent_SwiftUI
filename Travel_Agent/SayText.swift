//
//  SayTextAPI.swift
//  Travel_Agent
//
//  Created by Mahin Ashraful on 3/1/25.
//

import Foundation
import SwiftUI

class SayText {
    static func fetchData(completion: @escaping (String) -> Void) {
        let url = URL(string: "http://127.0.0.1:5001/")!
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    DispatchQueue.main.async {
                        completion(message)
                    }
                }
            }
        }.resume()
    }
}
