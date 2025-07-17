import Foundation

/// Manages the user's favorite stocks using UserDefaults storage
final class FavoritesManager {
    // MARK: - Singleton
    
    static let shared = FavoritesManager()
    
    // MARK: - Properties
    
    private let favoritesKey = "favorite_stocks"
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public Methods
    
    /// Returns a set of favorite stock tickers
    func getFavoriteTickers() -> Set<String> {
        let array = userDefaults.array(forKey: favoritesKey) as? [String] ?? []
        return Set(array)
    }
    
    /// Adds a stock ticker to favorites
    /// - Parameter ticker: The stock ticker to add
    func addToFavorites(ticker: String) {
        var favorites = getFavoriteTickers()
        favorites.insert(ticker)
        saveFavorites(favorites)
    }
    
    /// Removes a stock ticker from favorites
    /// - Parameter ticker: The stock ticker to remove
    func removeFromFavorites(ticker: String) {
        var favorites = getFavoriteTickers()
        favorites.remove(ticker)
        saveFavorites(favorites)
    }
    
    /// Checks if a stock ticker is marked as favorite
    /// - Parameter ticker: The stock ticker to check
    /// - Returns: True if the ticker is in favorites
    func isFavorite(ticker: String) -> Bool {
        getFavoriteTickers().contains(ticker)
    }
    
    // MARK: - Private Methods
    
    /// Saves the set of favorite tickers to UserDefaults
    private func saveFavorites(_ favorites: Set<String>) {
        userDefaults.set(Array(favorites), forKey: favoritesKey)
    }
} 