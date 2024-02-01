//
//  ContentView.swift
//  CubStartFinal
//
//  Created by Jonathan Dinh on 11/22/23.
//

import SwiftUI
import UIKit

class UserSession: ObservableObject {
    @Published var isLoggedIn: Bool = false
}

class UserCredentials: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmed_password: String = ""
}

class TimerModel: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var timerEnded: Bool = false
    var originalDuration: TimeInterval = 0
    var timer: Timer?
    weak var presentingView: UIViewController?
    
    func startTimer(duration: TimeInterval) {
        originalDuration = duration
        timeRemaining = duration
        timer?.invalidate() // Invalidate existing timer if any
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                // Timer completed, handle as needed
                self.timer?.invalidate()
                self.timer = nil
                self.timerEnded = true
                
                if let presentingView = self.presentingView {
                    self.showTimerEndedPopup(in: presentingView)
                }
            }
        }
    }

    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }

    func resumeTimer() {
        if timeRemaining > 0 {
            startTimer(duration: timeRemaining)
        }
    }

    func resetTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = originalDuration
        originalDuration = 0 // Reset original duration to 0
        timerEnded = false
    }
    func showTimerEndedPopup(in viewController: UIViewController){
        let alertController = UIAlertController(title: "Timer Ended", message: "Time's up!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        viewController.present(alertController, animated: true, completion: nil)
    }
}



struct FeastLoginView: View {
    // Environment objects for managing user session and credentials
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var userCredentials: UserCredentials

    // State variables to manage user input and view control
    @State private var isSignUp: Bool = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmedPassword: String = ""
    @State private var wrongPassword: Bool = false
    @State private var showSignUpSuccessMessage = false
    
    // Connects RecipeBook Screen
    @StateObject var favoriteRecipes = FavoriteRecipes()

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                // Image at the top of the login view
                ZStack {
                    Circle()
                        .fill(Color.pink.opacity(0.2))
                        .frame(width: 180, height: 180)

                    Image("Culinary")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 180) // Adjust the size as needed
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.pink.opacity(0.2), lineWidth: 3))
                        .offset(y: -10)

                }
                .padding(.bottom)


                Spacer()
                
                // Displays error message for incorrect credentials
                if wrongPassword && !isSignUp {
                    Text("Wrong username or password, please try again")
                        .padding()
                        .foregroundColor(.black)
                        .cornerRadius(20)
                }
                
                VStack(spacing: 20) {
                    // Text field for username/email input
                    TextField("Username or Email", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .foregroundStyle(Color.black)
                    
                    // Secure field for password input
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .foregroundStyle(Color.black)
                    
                    // Secure field for confirming password (visible during sign-up)
                    if isSignUp {
                        SecureField("Confirm Password", text: $confirmedPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .foregroundStyle(Color.black)
                    }
                    
                    // Button for sign-in or sign-up action
                    Button(action: signInOrSignUp) {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .padding()
                            .foregroundColor(AppColors.secondaryColor)
                            .background(AppColors.primaryColor)
                            .cornerRadius(20)
                    }

                    // Transition to ProfileView on successful login
                    .fullScreenCover(isPresented: $userSession.isLoggedIn) {
                        NavigationView {
                            ProfileView(username: username)
                                .environmentObject(favoriteRecipes)
                        }
                    }
                    // Alert for successful sign-up
                    .alert(isPresented: $showSignUpSuccessMessage) {
                        Alert(title: Text("Sign Up Successful"), message: Text("Your account has been created successfully."), dismissButton: .default(Text("OK")))
                    }
                    
                    // Toggle button between Sign In and Sign Up view
                    Button(action: {
                        isSignUp.toggle()
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Text for forgotten password
                Text("Forgot Password?")
                    .foregroundColor(.black)
                    .padding(.bottom, 20)
            }
            .padding()
            .background(Color.pink.opacity(0.2).edgesIgnoringSafeArea(.all))
        }
    }

    // Functions to handle sign-in and sign-up logic
    private func signInOrSignUp() {
        if isSignUp {
            signUp()
        } else {
            signIn()
        }
    }

    private func signIn() {
        // Validate user credentials and update session status
        if UserManager.shared.validateUser(username: username, password: password) {
            userSession.isLoggedIn = true
        } else {
            wrongPassword = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                wrongPassword = false
            }
        }
    }

    private func signUp() {
        // Create a new user account and display success message
        if confirmedPassword == password {
            UserManager.shared.createUser(username: username, password: password)
            showSignUpSuccessMessage = true
            clearInputFields()
        } else {
            // Handle scenario where passwords do not match
        }
    }

    private func clearInputFields() {
        // Clears the input fields post-sign up
        username = ""
        password = ""
        confirmedPassword = ""
        isSignUp = false
    }
}

struct AppColors {
    static let primaryColor = Color.pink.opacity(0.2)
    static let secondaryColor = Color.white
    static let accentColor = Color.green
}

struct FeastLoginView_Previews: PreviewProvider {
    static var previews: some View {
        FeastLoginView()
            .environmentObject(UserSession()) // Providing UserSession environment object for the preview
            .environmentObject(FavoriteRecipes())
    }
}


struct ProfileView: View {
    // Environment object to manage user session state
    @EnvironmentObject var userSession: UserSession
    // Object for favorite recipes view
    @EnvironmentObject var favoriteRecipes: FavoriteRecipes
    
    // Properties for user profile information
    var username: String
    var userPhoto: String = "userPlaceholder" // Placeholder for user photo

    // States for managing editable profile data and view control
    @State private var editableProfileData = EditableProfileData(made: "", goal: "", fav: "")
    @State private var showingEditProfile = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile image
                Image(userPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.pink.opacity(0.2), lineWidth: 4))
                    .shadow(radius: 10)
                    .padding(.top, 20)

                // Username display
                Text(username)
                    .font(.title)
                    .padding(.bottom, 10)

                // Group of text displaying user's editable profile data
                Group {
                    Text("What I Made This Week: \(editableProfileData.made)")
                    Text("Next Thing To Cook: \(editableProfileData.goal)")
                    Text("Favorite Cuisine: \(editableProfileData.fav)")
                }
                .font(.body)
                .foregroundColor(.black)
                
                // Horizontal stack for displaying additional user stats
                HStack {
                    VStack {
                        Text("Recipes Saved")
                            .font(.headline)
                        Text("\(favoriteRecipes.recipes.count)")
                            .font(.title2)
                    }
                }.padding()

                // Button to edit the culinary profile
                
                NavigationLink(destination: RecipesView()){
                            Text("View Favorite Recipes")
                                .padding()
                                .foregroundColor(AppColors.secondaryColor)
                                .background(AppColors.primaryColor)
                                .cornerRadius(20)
                } .padding()
                
                
                Button("Edit Culinary Profile") {
                    showingEditProfile = true // Triggers the sheet to edit profile
                }
                .padding()
                .foregroundColor(AppColors.secondaryColor)
                .background(AppColors.primaryColor)
                .cornerRadius(20)
                .sheet(isPresented: $showingEditProfile) {
                    // Sheet to edit the profile, passing the binding to editable data
                    EditProfileView(profileData: $editableProfileData) { newData in
                        editableProfileData = newData // Updating profile data with new data
                    }
                }

                // Log out button
                Button("Log Out", action: logOut)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding()
            }
        }
        .padding()
        .background(Color.pink.opacity(0.2).edgesIgnoringSafeArea(.all))
    }

    // Function to handle the log out action
    private func logOut() {
        userSession.isLoggedIn = false // Sets the user session to logged out
    }
}

struct EditableProfileData {
    var made: String
    var goal: String
    var fav: String
}

struct EditProfileView: View {
    // Binding to the editable profile data from the parent view
    @Binding var profileData: EditableProfileData

    // Completion handler passed from the parent view for saving changes
    var onSave: (EditableProfileData) -> Void

    // Environment property to manage the presentation mode of this view
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            // Title for the edit profile section
            Text("Personal Information")
                .font(.headline)
                .padding(.top, 20)

            // Text field for editing the age
            TextField("What I Made This Week", text: $profileData.made)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            
            // Text field for editing the sex
            TextField("Next Thing to Cook", text: $profileData.goal)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)

            // Text field for editing the country
            TextField("Favorite Cuisine", text: $profileData.fav)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)

            // Submit button to save changes and dismiss the view
            Button("Submit") {
                onSave(profileData) // Calls the onSave closure with updated data
                presentationMode.wrappedValue.dismiss() // Dismisses the view
            }
            .padding()
            .foregroundColor(AppColors.secondaryColor)
            .background(AppColors.primaryColor)
            .cornerRadius(20)
            .shadow(radius: 5)

            Spacer() // Pushes all content to the top
        }
        .padding()
        .background(Color.pink.opacity(0.2).edgesIgnoringSafeArea(.all))
    }
}


/* FavoriteRecipes Page Objects/Delcarations Below

*/

struct Ingredient: Identifiable {
    var id = UUID()
    var name: String
    var amount: String
}

struct Recipe: Identifiable {
    var id = UUID()
    var name: String
    var rating: Double
    var ingredients: [Ingredient]
}

struct RecipesView: View {
    @EnvironmentObject var favoriteRecipes: FavoriteRecipes
        
        var body: some View {
            List {
                ForEach($favoriteRecipes.recipes) { $recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: $recipe)) {
                        HStack {
                            Text(recipe.name)
                            Spacer()
                            Text(String(format: "%.1f", recipe.rating))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteRecipe)
                
                Button(action: addRecipe) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                        Text("Add New Recipe")
                    }
                }
            }
            .navigationTitle("My Favorites")
        }
        
        private func deleteRecipe(at offsets: IndexSet) {
            favoriteRecipes.recipes.remove(atOffsets: offsets)
        }
        
        private func addRecipe() {
            favoriteRecipes.recipes.append(Recipe(name: "New Recipe", rating: 5, ingredients: []))
        }
    }

class FavoriteRecipes: ObservableObject {
    @Published var recipes: [Recipe] = [
        Recipe(name: "Chocolate Lava Cake", rating: 4.7, ingredients: []),
        Recipe(name: "Lemon Pork Loin", rating: 4.5, ingredients: []),
        Recipe(name: "Roast Beef Sandwich", rating: 4.6, ingredients: [])
    ]
}

struct EditRatingView: View {
    @Binding var recipe: Recipe
        
        var body: some View {
            Form {
                Section(header: Text("Rating")) {
                    Slider(value: $recipe.rating, in: 0...5, step: 0.1) {
                        Text("Rating")
                    }
                    Text("\(recipe.rating, specifier: "%.1f") Stars")
                }
            }
            .navigationBarTitle("Edit Rating", displayMode: .inline)
        }
}
struct EditIngredientsView: View {
    @Binding var ingredients: [Ingredient]
    @State private var newName: String = ""
    @State private var newAmount: String = ""
    
    var body: some View {
        List {
            Section(header: Text("Add Ingredient")) {
                TextField("Ingredient Name", text: $newName)
                TextField("Amount (e.g., 2 cups)", text: $newAmount)
                Button("Add") {
                    let ingredient = Ingredient(name: newName, amount: newAmount)
                    ingredients.append(ingredient)
                    // Reset the input fields after adding
                    newName = ""
                    newAmount = ""
                }
            }

            Section(header: Text("Current Ingredients")) {
                ForEach(ingredients) { ingredient in
                    VStack(alignment: .leading) {
                        Text(ingredient.name)
                            .fontWeight(.bold)
                        Text(ingredient.amount)
                            .italic()
                    }
                }
                .onDelete(perform: deleteIngredient)
            }
        }
        .navigationBarTitle("Edit Ingredients", displayMode: .inline)
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
}

struct RecipeDetailView: View {
    @Binding var recipe: Recipe
    @StateObject var timerModel = TimerModel()
    @State private var editingDuration = false
    @State private var editedDuration = ""
    @State private var showingTimerEndedAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Recipe Name")) {
                TextField("Name", text: $recipe.name)
            }
            
            Section(header: Text("Rating")) {
                NavigationLink(destination: EditRatingView(recipe: $recipe)) {
                    Text("Edit Rating")
                }
            }
            
            Section(header: Text("Ingredients")) {
                NavigationLink(destination: EditIngredientsView(ingredients: $recipe.ingredients)) {
                    Text("Edit Ingredients")
                }
            }
            
            Section(header: Text("Timer")){
                HStack {
                    Text("Time Remaining: \(Int(timerModel.timeRemaining)) seconds")
                        .padding(.vertical)
                    
                    if !editingDuration {
                        Button("Edit") {
                            editingDuration = true
                            editedDuration = "\(Int(timerModel.originalDuration))"
                        }
                    } else {
                        TextField("Edit Time", text: $editedDuration) { editing in
                            // Handle editing events if needed
                        } onCommit: {
                            if let newDuration = TimeInterval(editedDuration) {
                                timerModel.originalDuration = newDuration
                                editingDuration = false
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .padding(.horizontal)
                    }
                }

                Button("Start"){
                    timerModel.startTimer(duration: timerModel.originalDuration)
                }
                .disabled(editingDuration) // disables Start button during editing
                
                Button("Pause"){
                    timerModel.pauseTimer()
                }
                Button("Resume"){
                    timerModel.resumeTimer()
                }
                Button("Reset Timer"){
                    timerModel.resetTimer()
                }
            }
        }
        .navigationBarTitle("Recipe Details", displayMode: .inline)
        .environmentObject(timerModel)
        .alert(isPresented: $timerModel.timerEnded) {
            Alert(title: Text("Time's up!"), dismissButton: .default(Text("OK")))
        }
    }
}












    

