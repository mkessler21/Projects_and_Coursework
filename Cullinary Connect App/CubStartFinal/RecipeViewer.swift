//
//  RecipeViewer.swift
//  CubStartFinal
//
//  Created by Max Kessler on 11/28/23.
//

//import Foundation
//
//
//func fetchQuote() {
//    // Def URL
//    let urlString = "https://api.spoonacular.com/recipes/extract"
//    guard let url = URL(string: urlString) else { return }
//    
//    //Request creation
//    var request = URLRequest(url: url)
//    request.httpMethod = "GET"
//    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    // Add any additional headers if needed
//    
//    
//    //URLSession
//    let task = URLSession.shared.dataTask(with: request) { data,reponse, error in
//        guard let data = data, error == nil else {
//            print(error ?? "Data error")
//            return
//        }
//        
//        do {
//            let recipeData = try JSONDecoder().decode(Recipe.self, from: data)
//        } catch {
//            print("Error decoding response data")
//        }
//    }
//    task.resume()
//}
