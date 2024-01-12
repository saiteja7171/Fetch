//  Created by Sai Teja Atluri on 1/11/24.

import SwiftUI

struct ContentView: View {
    @State private var meals: [Dessert] = []
    
    var body: some View {
        NavigationView {
            List(meals, id: \.idMeal) { meal in
                NavigationLink(destination: DessertDetailView(DessertId: meal.idMeal)) {
                    Text(meal.strMeal)
                }
            }
            .navigationTitle("Dessert Recipes")
            .onAppear {
                fetchDesserts()
            }
        }
    }
    
    // THis function is used to fetch the desserts.
    func fetchDesserts() {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let result = try JSONDecoder().decode(MealsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.meals = result.meals
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

struct DessertDetailView: View {
    let DessertId: String
    @State private var DessertDetails: DessertDetails?
    
    var body: some View {
        VStack {
            if let meal = DessertDetails {
                Text(meal.strMeal)
                    .font(.title)
                
                Text(meal.strInstructions)
                    .padding()
                
                List {
                    ForEach(meal.ingredients, id: \.self) { ingredient in
                        Text(ingredient)
                    }
                }
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            fetchDessertDetails()
        }
    }
    
    //This function is used to fetch the dessert details    
    func fetchDessertDetails() {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(DessertId)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching meal details:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(DessertDetailsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.DessertDetails = result.meals.first
                }
            }
            catch {
                print("Error decoding meal details:", error.localizedDescription)
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Dessert: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    var id: String { idMeal }
}

struct MealsResponse: Codable {
    let meals: [Dessert]
}

struct DessertDetails: Decodable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strDrinkAlternate: String?
    let strCategory: String?
    let strArea: String?
    let strInstructions: String
    let strMealThumb: String?
    let strTags: String?
    let strYoutube: String?
    let strIngredient1: String
    let strIngredient2: String
    
    var id: String { return idMeal }
    
    var ingredients: [String] {
        return [strIngredient1, strIngredient2].filter { !$0.isEmpty }
    }
}

struct DessertDetailsResponse: Decodable {
    let meals: [DessertDetails]
}
