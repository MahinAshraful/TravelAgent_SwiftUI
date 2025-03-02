import SwiftUI
import SafariServices

struct ContentView: View {
    // Search parameters
    @State private var leavingAirport = "JFK"
    @State private var destinationAirport = "IST"
    @State private var departureDate = Date()
    @State private var returnDate = Date().addingTimeInterval(86400 * 14)  // 2 weeks from now
    @State private var numAdults = 1
    @State private var numSeniors = 0
    @State private var numStudents = 0
    @State private var childrenAges: [Int] = []
    @State private var infantsOnSeat = 0
    @State private var infantsOnLap = 0
    
    // UI state
    @State private var isLoading = false
    @State private var bookingURL: String?
    @State private var errorMessage: String?
    @State private var showSafari = false
    
    // Date formatter for API dates
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Flight Route")) {
                    HStack {
                        Text("From:")
                        TextField("Departure Airport", text: $leavingAirport)
                            .multilineTextAlignment(.trailing)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                    }
                    
                    HStack {
                        Text("To:")
                        TextField("Destination Airport", text: $destinationAirport)
                            .multilineTextAlignment(.trailing)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                    }
                }
                
                Section(header: Text("Travel Dates")) {
                    DatePicker("Departure Date", selection: $departureDate, displayedComponents: .date)
                    DatePicker("Return Date", selection: $returnDate, displayedComponents: .date)
                }
                
                Section(header: Text("Passengers")) {
                    Stepper("Adults: \(numAdults)", value: $numAdults, in: 1...9)
                    Stepper("Seniors: \(numSeniors)", value: $numSeniors, in: 0...9)
                    Stepper("Students: \(numStudents)", value: $numStudents, in: 0...9)
                    
                    NavigationLink(destination: ChildrenSelectionView(childrenAges: $childrenAges)) {
                        HStack {
                            Text("Children (2-17 years)")
                            Spacer()
                            Text("\(childrenAges.count)")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Stepper("Infants (on seat): \(infantsOnSeat)", value: $infantsOnSeat, in: 0...4)
                    Stepper("Infants (on lap): \(infantsOnLap)", value: $infantsOnLap, in: 0...4)
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
                                Text("Search Best Flights")
                                    .bold()
                                Spacer()
                            }
                        }
                    }
                    .disabled(isLoading)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
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
            .navigationTitle("Flight Search")
            .sheet(isPresented: $showSafari) {
                if let bookingURLString = bookingURL, let url = URL(string: bookingURLString) {
                    SafariView(url: url)
                }
            }
        }
    }
    
    private func searchFlights() {
        // Reset state
        isLoading = true
        errorMessage = nil
        bookingURL = nil
        
        // Call API
        FlightAPI.searchFlights(
            leavingAirport: leavingAirport,
            destinationAirport: destinationAirport,
            departureDate: dateFormatter.string(from: departureDate),
            returnDate: dateFormatter.string(from: returnDate),
            numAdults: numAdults,
            numSeniors: numSeniors,
            numStudents: numStudents,
            childrenAges: childrenAges,
            infantsOnSeat: infantsOnSeat,
            infantsOnLap: infantsOnLap
        ) { result in
            isLoading = false
            
            switch result {
            case .success(let url):
                bookingURL = url
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
