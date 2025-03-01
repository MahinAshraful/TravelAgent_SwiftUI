import SwiftUI

struct ContentView: View {
    @State private var message = "Hello, world!"
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(message)
            
            Button("Call API") {
                fetchData()
            }
        }
        .padding()
    }
    
    func fetchData() {
        SayText.fetchData { newMessage in
            self.message = newMessage
        }
    }
}

#Preview {
    ContentView()
}
