import SwiftUI
import Foundation
struct VolunteerOrganization: Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var signUpLink: String
    var joinCode: String
}
let sampleOrganizations = [
    VolunteerOrganization(name: "SAVE Animal Shelter", description: "Play with kittens and puppies while also helping to clean up the shelter - Located in Montgomery, New Jersey", signUpLink: "https://savehomelessanimals.org/", joinCode: "SAVE3"),
    VolunteerOrganization(name: "CIEL Assisted Living", description: "Contribute to your community by working with senior citizens - Located in Princeton, New Jersey", signUpLink: "https://cielseniorliving.com/community/ciel-of-princeton/?utm_id=21343789427&utm_source=adwords", joinCode: "CIEL1"),
    VolunteerOrganization(name: "South Brunswick Public Library", description: "Help reorganize books and set up events at the South Brunswick Public Library! Located in Kendall Park, New Jersey", signUpLink: "https://sbpl.info/", joinCode: "SBPL4")
]
struct VolunteerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
struct ContentView: View {
    @State private var searchText = ""
    @State private var showProfile = false
    @State private var showGroups = false
    @State private var showAddOrganization = false
    @State private var organizations = sampleOrganizations
    @State private var joinCode = ""
    @State private var selectedOrganization: VolunteerOrganization? = nil
    @State private var showOrganizationDetail = false
    @AppStorage("authToken") var authToken: String?
    @State private var isLoggedIn: Bool = false
    
    var filteredOrganizations: [VolunteerOrganization] {
        if searchText.isEmpty {
            return organizations
        } else {
            return organizations.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoggedIn {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showProfile = true
                        }) {
                            Image(systemName: "person.circle")
                                .font(.largeTitle)
                                .foregroundColor(.navy)
                                .padding()
                        }
                        .sheet(isPresented: $showProfile) {
                            ProfileView(showProfile: $showProfile)
                        }
                        
                        Button(action: {
                            showGroups = true
                        }) {
                            Image(systemName: "list.bullet")
                                .font(.largeTitle)
                                .foregroundColor(.navy)
                                .padding()
                        }
                        .sheet(isPresented: $showGroups) {
                            VolunteerGroupsView(showGroups: $showGroups)
                        }
                        
                        Spacer()
                    }
                    
                    Text("Volunteer Opportunities")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.navy)
                        .padding(.horizontal)
                    
                    TextField("Search for opportunities", text: $searchText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    List(filteredOrganizations) { organization in
                        NavigationLink(destination: OrganizationDetailView(organization: organization)) {
                            Text(organization.name)
                                .foregroundColor(.navy)
                        }
                        .listRowBackground(Color.lightblue)
                    }
                    .navigationTitle("")
                    .background(Color.white)
                    
                    Button(action: {
                        showAddOrganization = true
                    }) {
                        Text("Add Organization")
                            .font(.headline)
                            .padding()
                            .background(Color.navy)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showAddOrganization) {
                        AddOrganizationView(showAddOrganization: $showAddOrganization, organizations: $organizations)
                    }
                    .padding()
                    
                    TextField("Enter Join Code", text: $joinCode)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if let matchedOrganization = organizations.first(where: { $0.joinCode.lowercased() == joinCode.lowercased() }) {
                            selectedOrganization = matchedOrganization
                            showOrganizationDetail = true
                        } else {
                            print("That code doesn't seem to work, try again!")
                        }
                    }) {
                        Text("Join with Code")
                            .font(.headline)
                            .padding()
                            .background(Color.navy)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    .sheet(isPresented: $showOrganizationDetail) {
                        if let selectedOrganization = selectedOrganization {
                            OrganizationDetailView(organization: selectedOrganization)
                        }
                    }
                }
            }
            .background(Color.white)
        }
        .fullScreenCover(isPresented: .constant(!isLoggedIn), content: {
            LoginView(isLoggedIn: $isLoggedIn)
        })
        .onAppear {
            isLoggedIn = false
            authToken = nil
        }
    }
}
struct OrganizationDetailView: View {
    var organization: VolunteerOrganization
    @State private var hours: String = ""
    @State private var isOwner: Bool = true
    @State private var volunteerHours = [("Adhithi Uppalapati", 10), ("Srihita Nuthalapati", 8)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(organization.name)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.navy)
            
            Text(organization.description)
                .font(.body)
            Link("Sign Up", destination: URL(string: organization.signUpLink)!)
                .font(.headline)
                .foregroundColor(.blue)
            Spacer()
            Text("Join Code: \(organization.joinCode)")
                .font(.headline)
                .foregroundColor(.blue)
            
            Text("Volunteer Hours")
                .font(.headline)
                .foregroundColor(.navy)
            List(volunteerHours, id: \.0) { user, hours in
                Text("\(user): \(hours) hours")
            }
            .listRowBackground(Color.white)
            
            if isOwner {
                TextField("Enter Hours", text: $hours)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                
                Button(action: {
                    if let enteredHours = Int(hours) {
                        volunteerHours.append(("New Volunteer", enteredHours))
                        hours = ""
                    }
                }) {
                    Text("Add Hours")
                        .font(.headline)
                        .padding()
                        .background(Color.navy)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .navigationTitle(organization.name)
    }
}
struct ProfileView: View {
    @Binding var showProfile: Bool
    @State private var volunteerHours = [("SAVE Animal Shelter", 5), ("CIEL Assisted Living", 3)]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        showProfile = false
                    }) {
                        Image(systemName: "house")
                            .font(.largeTitle)
                            .padding()
                            .foregroundColor(.navy)
                    }
                    Spacer()
                }
                
                Text("Profile Information")
                    .font(.largeTitle)
                    .foregroundColor(.navy)
                Text("Name: Adhithi Uppalapati")
                Text("Email: uadhithi@gmail.com")
                Text("Interests: Computer Science, Teaching")
                
                Text("Volunteer Hours Breakdown")
                    .font(.headline)
                    .foregroundColor(.navy)
                List(volunteerHours, id: \.0) { organization, hours in
                    Text("\(organization): \(hours) hours")
                }
                Spacer()
            }
            .padding()
            .background(Color.white)
            .navigationTitle("Profile")
        }
    }
}
struct VolunteerGroupsView: View {
    @Binding var showGroups: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        showGroups = false
                    }) {
                        Image(systemName: "house")
                            .font(.largeTitle)
                            .padding()
                            .foregroundColor(.navy)
                    }
                    Spacer()
                }
                
                Text("Your Volunteer Groups")
                    .font(.largeTitle)
                    .foregroundColor(.navy)
                List {
                    Text("Musical Theatre")
                    Text("Assisted Living")
                    Text("Public Library")
                }
                .listRowBackground(Color.white)
                Spacer()
            }
            .padding()
            .background(Color.white)
            .navigationTitle("Groups")
        }
    }
}
struct AddOrganizationView: View {
    @Binding var showAddOrganization: Bool
    @Binding var organizations: [VolunteerOrganization]
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var signUpLink: String = ""
    
    func randomJoinCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<5).map { _ in characters.randomElement()! })
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Organization Name", text: $name)
                TextField("Description", text: $description)
                TextField("Sign Up Link", text: $signUpLink)
                
                Button(action: {
                    let newOrganization = VolunteerOrganization(name: name, description: description, signUpLink: signUpLink, joinCode: randomJoinCode())
                    organizations.append(newOrganization)
                    showAddOrganization = false
                }) {
                    Text("Add Organization")
                        .font(.headline)
                        .padding()
                        .background(Color.navy)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(name.isEmpty || description.isEmpty || signUpLink.isEmpty)
            }
            .navigationTitle("Add Organization")
            .navigationBarItems(leading: Button("Cancel") {
                showAddOrganization = false
            })
            .background(Color.white)
        }
    }
}
struct LoginView: View {
    @AppStorage("authToken") var authToken: String?
    @State private var email = ""
    @State private var password = ""
    @Binding var isLoggedIn: Bool
    @State private var showError = false
    @State private var errorMessage = ""
    @StateObject var loginViewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Button(action: {
                authToken = "dummyToken"
                isLoggedIn = true
            }) {
                Text("Login")
                    .font(.headline)
                    .padding()
                    .background(Color.navy)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
    }
    private func handleLogin() {
        loginViewModel.login { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                showError = false
            }
        }
    }
}
extension Color {
    static let navy = Color(red: 0.0, green: 0.0, blue: 0.5)
    static let lightblue = Color(red: 0.9, green: 0.9, blue: 1.0)
}


