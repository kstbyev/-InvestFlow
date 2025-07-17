import Foundation
import UIKit

/// Represents a stock with its market data and visual representation
struct Stock: Codable, Equatable, Identifiable {
    // MARK: - Properties
    
    /// Unique identifier for the stock (using ticker as id)
    var id: String { ticker }
    
    /// Stock symbol/ticker (e.g., "AAPL")
    let ticker: String
    
    /// Full company name (e.g., "Apple Inc.")
    let companyName: String
    
    /// Current stock price
    let price: Double
    
    /// Absolute price change
    let priceChange: Double
    
    /// Percentage price change
    let priceChangePercent: Double
    
    /// Name of the icon asset in the asset catalog
    let iconName: String
    
    /// Optional URL to company logo
    let logoURL: String?
    
    /// Whether the stock is marked as favorite
    var isFavorite: Bool
    
    // MARK: - Computed Properties
    
    /// Formatted price string with 2 decimal places (e.g., "131.93")
    var formattedPrice: String {
        String(format: "%.2f", price)
    }
    
    /// Formatted price change string with sign and 2 decimal places (e.g., "+$0.12")
    var formattedPriceChange: String {
        let sign = priceChange >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", abs(priceChange)))"
    }
    
    /// Formatted price change percentage with sign and 2 decimal places (e.g., "+0.09%")
    var formattedPriceChangePercent: String {
        let sign = priceChangePercent >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", abs(priceChangePercent)))%"
    }
    
    /// Color indicating positive or negative price change
    var priceChangeColor: UIColor {
        priceChange >= 0 ? .systemGreen : .systemRed
    }
    
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey {
        case ticker = "symbol"
        case companyName = "name"
        case price
        case priceChange = "change"
        case priceChangePercent = "changePercent"
        case iconName
        case logoURL = "logo"
        case isFavorite
    }
    
    // MARK: - Initialization
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ticker = try container.decode(String.self, forKey: .ticker)
        companyName = try container.decode(String.self, forKey: .companyName)
        price = try container.decode(Double.self, forKey: .price)
        priceChange = try container.decode(Double.self, forKey: .priceChange)
        priceChangePercent = try container.decode(Double.self, forKey: .priceChangePercent)
        iconName = try container.decodeIfPresent(String.self, forKey: .iconName) ?? ""
        logoURL = try container.decodeIfPresent(String.self, forKey: .logoURL)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }
    
    init(
        ticker: String,
        companyName: String,
        price: Double,
        priceChange: Double,
        priceChangePercent: Double,
        iconName: String,
        logoURL: String? = nil,
        isFavorite: Bool = false
    ) {
        self.ticker = ticker
        self.companyName = companyName
        self.price = price
        self.priceChange = priceChange
        self.priceChangePercent = priceChangePercent
        self.iconName = iconName
        self.logoURL = logoURL
        self.isFavorite = isFavorite
    }
}

// MARK: - Mock Data

extension Stock {
    /// Creates an array of test stocks for development and testing
    static func createTestStocks() -> [Stock] {
        [
            Stock(ticker: "AAPL",
                  companyName: "Apple Inc.",
                  price: 131.93,
                  priceChange: 0.12,
                  priceChangePercent: 0.09,
                  iconName: "apple",
                  logoURL: "https://example.com/apple.png"),
            
            Stock(ticker: "GOOGL",
                  companyName: "Alphabet Inc.",
                  price: 2321.24,
                  priceChange: -12.31,
                  priceChangePercent: -0.53,
                  iconName: "google",
                  logoURL: "https://example.com/google.png"),
            
            Stock(ticker: "MSFT",
                  companyName: "Microsoft Corporation",
                  price: 245.17,
                  priceChange: 1.23,
                  priceChangePercent: 0.50,
                  iconName: "microsoft",
                  logoURL: "https://example.com/microsoft.png"),
            
            Stock(ticker: "AMZN",
                  companyName: "Amazon.com Inc.",
                  price: 3116.42,
                  priceChange: -23.42,
                  priceChangePercent: -0.75,
                  iconName: "amazon",
                  logoURL: "https://example.com/amazon.png"),
            
            Stock(ticker: "TSLA",
                  companyName: "Tesla Inc.",
                  price: 621.87,
                  priceChange: 15.72,
                  priceChangePercent: 2.59,
                  iconName: "tesla",
                  logoURL: "https://example.com/tesla.png")
        ]
    }
} 