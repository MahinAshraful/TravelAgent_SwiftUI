import SwiftUI
import SafariServices

struct ContentView: View {
    // Natural language query field
    @State private var flightQuery = "I want to fly from New York to Istanbul on June 15, 2025 and return on June 29, 2025 with 2 adults and 1 child who is 5 years old."
    
    // UI state
    @State private var isLoading = false
    @State private var bookingURL: String?
    @State private var errorMessage: String?
    @State private var showSafari = false
    @State private var extractedParams: [String: Any]?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tell me about your trip")) {
                    TextEditor(text: $flightQuery)
                        .frame(height: 120)
                        .foregroundColor(.primary)
                    
                    Text("Example: \"I want to fly from New York to London next Friday and return the following Monday with 2 adults.\"")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section {
                    Button(action: searchFlights) {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Spacer()
                            }
                        } else {
                            HStack {
                                Spacer()
                                Image(systemName: "sparkles")
                                Text("Find My Flights")
                                    .bold()
                                Spacer()
                            }
                        }
                    }
                    .disabled(isLoading || flightQuery.isEmpty)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                if let extractedParams = extractedParams {
                    Section(header: Text("Understood Flight Details")) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("From:")
                                Spacer()
                                Text(extractedParams["leaving_airport"] as? String ?? "Unknown")
                                    .bold()
                            }
                            
                            HStack {
                                Text("To:")
                                Spacer()
                                Text(extractedParams["destination_airport"] as? String ?? "Unknown")
                                    .bold()
                            }
                            
                            HStack {
                                Text("Departure:")
                                Spacer()
                                Text(extractedParams["departure_date"] as? String ?? "Unknown")
                                    .bold()
                            }
                            
                            HStack {
                                Text("Return:")
                                Spacer()
                                Text(extractedParams["return_date"] as? String ?? "Unknown")
                                    .bold()
                            }
                            
                            HStack {
                                Text("Passengers:")
                                Spacer()
                                Text(passengerSummary(from: extractedParams))
                                    .bold()
                            }
                        }
                    }
                }
                
                if let _ = bookingURL {
                    Section {
                        Button(action: {
                            showSafari = true
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "airplane.departure")
                                Text("Book Flight")
                                    .bold()
                                Image(systemName: "arrow.right")
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("AI Flight Search")
            .sheet(isPresented: $showSafari) {
                if let bookingURLString = bookingURL, let url = URL(string: bookingURLString) {
                    SafariView(url: url)
                }
            }
        }
    }
    
    private func passengerSummary(from params: [String: Any]) -> String {
        let adults = params["num_adults"] as? Int ?? 0
        let seniors = params["num_seniors"] as? Int ?? 0
        let students = params["num_students"] as? Int ?? 0
        let childrenAges = params["children_ages"] as? [Int] ?? []
        let infantsOnSeat = params["infants_on_seat"] as? Int ?? 0
        let infantsOnLap = params["infants_on_lap"] as? Int ?? 0
        
        var parts = [String]()
        
        if adults > 0 {
            parts.append("\(adults) Adult\(adults > 1 ? "s" : "")")
        }
        
        if seniors > 0 {
            parts.append("\(seniors) Senior\(seniors > 1 ? "s" : "")")
        }
        
        if students > 0 {
            parts.append("\(students) Student\(students > 1 ? "s" : "")")
        }
        
        if !childrenAges.isEmpty {
            parts.append("\(childrenAges.count) Child\(childrenAges.count > 1 ? "ren" : "")")
        }
        
        if infantsOnSeat > 0 {
            parts.append("\(infantsOnSeat) Infant\(infantsOnSeat > 1 ? "s" : "") (seat)")
        }
        
        if infantsOnLap > 0 {
            parts.append("\(infantsOnLap) Infant\(infantsOnLap > 1 ? "s" : "") (lap)")
        }
        
        return parts.joined(separator: ", ")
    }
    
    private func searchFlights() {
        // Reset state
        isLoading = true
        errorMessage = nil
        bookingURL = nil
        extractedParams = nil
        
        // Call AI API
        FlightAPI.searchFlightsWithAI(query: flightQuery) { result in
            isLoading = false
            
            switch result {
            case .success(let response):
                bookingURL = response.bookingURL
                extractedParams = response.extractedParams
            case .failure(let error):
                errorMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
}

struct ChildrenSelectionView: View {
    @Binding var childrenAges: [Int]
    @State private var newChildAge = 10
    
    var body: some View {
        Form {
            Section(header: Text("Add Child")) {
                Stepper("Age: \(newChildAge) years", value: $newChildAge, in: 2...17)
                
                Button("Add Child") {
                    childrenAges.append(newChildAge)
                }
                .disabled(childrenAges.count >= 8)
            }
            
            Section(header: Text("Current Children")) {
                ForEach(childrenAges.indices, id: \.self) { index in
                    HStack {
                        Text("Child \(index + 1): \(childrenAges[index]) years")
                        Spacer()
                        Button(action: {
                            childrenAges.remove(at: index)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                if childrenAges.isEmpty {
                    Text("No children added")
                        .foregroundColor(.gray)
                        .italic()
                }
            }
        }
        .navigationTitle("Children")
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // Nothing to update
    }
}

#Preview {
    ContentView()
}
