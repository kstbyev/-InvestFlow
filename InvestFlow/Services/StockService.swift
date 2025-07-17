import Foundation

/// Service responsible for fetching stock data from the API
class StockService {
    // MARK: - Singleton
    
    static let shared = StockService()
    
    // MARK: - Properties
    
    private let baseURL = "https://mustdev.ru/api/stocks.json"
    private let session: URLSession
    
    // MARK: - Error Types
    
    enum StockError: Error {
        case invalidURL
        case networkError(Error)
        case noData
        case decodingError(Error)
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid API URL"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .noData:
                return "No data received from server"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Initialization
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public Methods
    
    /// Fetches stock data from the API or returns mock data if the API is unavailable
    /// - Parameter completion: Closure called with the fetched stocks or an error
    func fetchStocks(completion: @escaping (Result<[Stock], StockError>) -> Void) {
        guard let url = URL(string: baseURL) else {
            print("Invalid URL, using mock data")
            completion(.success(getMockStocks()))
            return
        }
        
        session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    print("Using mock data instead")
                    completion(.success(self.getMockStocks()))
                    return
                }
                
                guard let data = data else {
                    print("No data received, using mock data")
                    completion(.success(self.getMockStocks()))
                    return
                }
                
                do {
                    let stocks = try JSONDecoder().decode([Stock].self, from: data)
                    completion(.success(stocks))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.success(self.getMockStocks()))
                }
            }
        }.resume()
    }
    
    // MARK: - Private Methods
    
    /// Returns mock stock data for testing and development
    private func getMockStocks() -> [Stock] {
        Stock.createTestStocks()
    }
}
