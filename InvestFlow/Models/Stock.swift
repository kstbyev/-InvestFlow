import Foundation
import UIKit

struct Stock: Codable, Equatable {
    let ticker: String
    let companyName: String
    let price: Double
    let priceChange: Double
    let priceChangePercent: Double
    let iconName: String // имя картинки в Assets
    let logoURL: String? // ссылка на логотип
    
    var isFavorite: Bool = false
    
    var formattedPrice: String {
        return String(format: "%.2f", price)
    }
    
    var formattedPriceChange: String {
        let sign = priceChange >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", abs(priceChange)))"
    }
    
    var formattedPriceChangePercent: String {
        let sign = priceChangePercent >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", abs(priceChangePercent)))%"
    }
    
    var priceChangeColor: UIColor {
        return priceChange >= 0 ? .systemGreen : .systemRed
    }
    
    // MARK: - Decoding from JSON
    enum CodingKeys: String, CodingKey {
        case ticker = "symbol"
        case companyName = "name"
        case price
        case priceChange = "change"
        case priceChangePercent = "changePercent"
        case iconName
        case logoURL = "logo"
        case isFavorite
    }
    
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
        logoURL: String?,
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
    
    // Создание тестовых данных согласно макету
    static func createTestStocks() -> [Stock] {
        var stocks = [
            Stock(ticker: "AAPL", companyName: "Apple Inc.", price: 131.93, priceChange: 0.12, priceChangePercent: 0.09, iconName: "apple", logoURL: "https://mustdev.ru/images/AAPL"),
            Stock(ticker: "GOOGL", companyName: "Alphabet Class A", price: 1825.00, priceChange: 15.50, priceChangePercent: 0.85, iconName: "google", logoURL: "https://mustdev.ru/images/GOOGL"),
            Stock(ticker: "AMZN", companyName: "Amazon.com", price: 3204.00, priceChange: -0.12, priceChangePercent: -0.004, iconName: "amazon", logoURL: "https://mustdev.ru/images/AMZN"),
            Stock(ticker: "BAC", companyName: "Bank of America Corp", price: 3204.00, priceChange: 0.12, priceChangePercent: 1.15, iconName: "bankofamerica", logoURL: "https://mustdev.ru/images/BAC"),
            Stock(ticker: "MSFT", companyName: "Microsoft Corporation", price: 3204.00, priceChange: 0.12, priceChangePercent: 1.15, iconName: "microsoft", logoURL: "https://mustdev.ru/images/MSFT"),
            Stock(ticker: "TSLA", companyName: "Tesla Motors", price: 3204.00, priceChange: 0.12, priceChangePercent: 1.15, iconName: "tesla", logoURL: "https://mustdev.ru/images/TSLA"),
            Stock(ticker: "YNDX", companyName: "Yandex, LLC", price: 13.93, priceChange: 0.12, priceChangePercent: 1.15, iconName: "yandex", logoURL: "https://mustdev.ru/images/YNDX"),
            Stock(ticker: "MA", companyName: "Mastercard", price: 3204.00, priceChange: 0.12, priceChangePercent: 1.15, iconName: "mastercard", logoURL: "https://mustdev.ru/images/MA")
        ]
        // Избранные по умолчанию
        stocks = stocks.map { stock in
            var mutableStock = stock
            if ["AAPL", "MSFT", "TSLA"].contains(stock.ticker) {
                mutableStock.isFavorite = true
            }
            return mutableStock
        }
        return stocks
    }
} 