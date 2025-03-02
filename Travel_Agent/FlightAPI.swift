import Foundation

class FlightAPI {
    // Change this to your API's URL
    static let baseURL = "http://localhost:5001"
    
    // Original manual search function
    static func searchFlights(
        leavingAirport: String,
        destinationAirport: String,
        departureDate: String,
        returnDate: String,
        numAdults: Int = 1,
        numSeniors: Int = 0,
        numStudents: Int = 0,
        childrenAges: [Int] = [],
        infantsOnSeat: Int = 0,
        infantsOnLap: Int = 0,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Create URL for the API endpoint
        guard let url = URL(string: "\(baseURL)/api/search_flights") else {
            completion(.failure(NSError(domain: "FlightAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Prepare the request parameters
        let parameters: [String: Any] = [
            "leaving_airport": leavingAirport,
            "destination_airport": destinationAirport,
            "departure_date": departureDate,
            "return_date": returnDate,
            "num_adults": numAdults,
            "num_seniors": numSeniors,
            "num_students": numStudents,
            "children_ages": childrenAges,
            "infants_on_seat": infantsOnSeat,
            "infants_on_lap": infantsOnLap
        ]
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Convert parameters to JSON data
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Create and start data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Ensure we have data
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "FlightAPI", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            // Parse the response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = json["success"] as? Bool, success {
                        if let bookingURL = json["booking_url"] as? String {
                            DispatchQueue.main.async {
                                completion(.success(bookingURL))
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(.failure(NSError(domain: "FlightAPI", code: 4, userInfo: [NSLocalizedDescriptionKey: "Missing booking URL in response"])))
                            }
                        }
                    } else {
                        let message = json["message"] as? String ?? "Unknown error"
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "FlightAPI", code: 5, userInfo: [NSLocalizedDescriptionKey: message])))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "FlightAPI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // New AI-powered search function
    // Response struct for AI Flight Search
    struct AIFlightResponse {
        let bookingURL: String
        let extractedParams: [String: Any]
    }
    
    static func searchFlightsWithAI(
        query: String,
        completion: @escaping (Result<AIFlightResponse, Error>) -> Void
    ) {
        // Create URL for the API endpoint
        guard let url = URL(string: "\(baseURL)/api/ai_flight_search") else {
            completion(.failure(NSError(domain: "AIFlightAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Prepare the request parameters
        let parameters: [String: Any] = [
            "query": query
        ]
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Convert parameters to JSON data
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Create and start data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Ensure we have data
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "AIFlightAPI", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            // Parse the response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = json["success"] as? Bool, success {
                        if let bookingURL = json["booking_url"] as? String,
                           let extractedParams = json["extracted_params"] as? [String: Any] {
                            
                            let response = AIFlightResponse(
                                bookingURL: bookingURL,
                                extractedParams: extractedParams
                            )
                            
                            DispatchQueue.main.async {
                                completion(.success(response))
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(.failure(NSError(domain: "AIFlightAPI", code: 4, userInfo: [NSLocalizedDescriptionKey: "Missing booking URL or parameters in response"])))
                            }
                        }
                    } else {
                        let message = json["message"] as? String ?? json["error"] as? String ?? "Unknown error"
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "AIFlightAPI", code: 5, userInfo: [NSLocalizedDescriptionKey: message])))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "AIFlightAPI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
