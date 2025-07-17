import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    
    private let favoritesKey = "favorite_stocks"
    
    private init() {}
    
    func getFavoriteTickers() -> Set<String> {
        let array = UserDefaults.standard.array(forKey: favoritesKey) as? [String] ?? []
        return Set(array)
    }
    
    func addToFavorites(ticker: String) {
        var favorites = getFavoriteTickers()
        favorites.insert(ticker)
        saveFavorites(favorites)
    }
    
    func removeFromFavorites(ticker: String) {
        var favorites = getFavoriteTickers()
        favorites.remove(ticker)
        saveFavorites(favorites)
    }
    
    func isFavorite(ticker: String) -> Bool {
        return getFavoriteTickers().contains(ticker)
    }
    
    private func saveFavorites(_ favorites: Set<String>) {
        UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
    }
} 