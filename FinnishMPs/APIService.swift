
//
//  APIService.swift
//  FinnishMPs
//
//  Created by Kapil
//  Student ID: 2420250
//

import Foundation

class APIService {

    func fetchMPs(completion: @escaping ([MP]?, Error?) -> Void) {

        let urlString = "https://users.metropolia.fi/~peterh/mps.json"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil, URLError(.badURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil, URLError(.badServerResponse))
                return
            }

            do {
                let decoder = JSONDecoder()
                let members = try decoder.decode([MP].self, from: data)

                print("Successfully loaded \(members.count) MPs")

                completion(members, nil)

            } catch {
                print("JSON decoding error: \(error)")
                completion(nil, error)
            }
        }

        task.resume()
    }
}

