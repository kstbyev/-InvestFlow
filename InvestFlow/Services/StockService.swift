import Foundation

class StockService {
    static let shared = StockService()
    
    private let baseURL = "https://mustdev.ru/api/stocks.json"
    
    private init() {}
    
    func fetchStocks(completion: @escaping ([Stock]?, Error?) -> Void) {
        // Сначала попробуем загрузить с сервера
        guard let url = URL(string: baseURL) else {
            print("Invalid URL, using mock data")
            completion(getMockStocks(), nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    print("Using mock data instead")
                    completion(self.getMockStocks(), nil)
                    return
                }
                
                guard let data = data else {
                    print("No data received, using mock data")
                    completion(self.getMockStocks(), nil)
                    return
                }
                
                do {
                    let stocks = try JSONDecoder().decode([Stock].self, from: data)
                    completion(stocks, nil)
                } catch {
                    print("Decoding error: \(error)")
                    completion(self.getMockStocks(), nil)
                }
            }
        }.resume()
    }
    
    private func getMockStocks() -> [Stock] {
        return Stock.createTestStocks()
    }
}
