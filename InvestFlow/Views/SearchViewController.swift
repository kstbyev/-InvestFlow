import UIKit
import SnapKit

protocol SearchViewControllerDelegate: AnyObject {
    func didSelectStock(_ stock: Stock)
}

class SearchViewController: UIViewController {
    weak var delegate: SearchViewControllerDelegate?
    
    private var allStocks: [Stock] = []
    private var filteredStocks: [Stock] = []
    private var isSearching = false
    
    private let searchBarView = SearchBarView()
    private let popularRequestsLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular requests"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        return label
    }()
    private let recentSearchesLabel: UILabel = {
        let label = UILabel()
        label.text = "You've searched for this"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        return label
    }()
    
    private let popularRequests = ["Apple", "Amazon", "Google", "Tesla", "Microsoft", "First Solar", "Alibaba", "Facebook", "Mastercard"]
    private let recentSearches = ["Nvidia", "Nokia", "Yandex", "GM", "Microsoft", "Baidu", "Intel", "AMD", "Visa", "Bank of America"]
    
    private lazy var popularCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
        return collectionView
    }()
    private lazy var recentCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
        return collectionView
    }()
    
    private let resultsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupDelegates()
        loadStocks()
        searchBarView.showsBackButton = true
        searchBarView.onBack = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Search"
        view.addSubview(searchBarView)
        view.addSubview(popularRequestsLabel)
        view.addSubview(popularCollectionView)
        view.addSubview(recentSearchesLabel)
        view.addSubview(recentCollectionView)
        view.addSubview(resultsTableView)
        resultsTableView.register(StockTableViewCell.self, forCellReuseIdentifier: StockTableViewCell.identifier)
    }
    
    private func setupConstraints() {
        searchBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        popularRequestsLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBarView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        popularCollectionView.snp.makeConstraints { make in
            make.top.equalTo(popularRequestsLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(40)
        }
        recentSearchesLabel.snp.makeConstraints { make in
            make.top.equalTo(popularCollectionView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        recentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(recentSearchesLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(40)
        }
        resultsTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBarView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupDelegates() {
        searchBarView.textField.delegate = self
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
    }
    
    private func loadStocks() {
        StockService.shared.fetchStocks { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let stocks):
                    self?.allStocks = stocks
                case .failure(let error):
                    print("Failed to load stocks: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showTagsLayout() {
        popularRequestsLabel.isHidden = false
        popularCollectionView.isHidden = false
        recentSearchesLabel.isHidden = false
        recentCollectionView.isHidden = false
        resultsTableView.isHidden = true
    }
    private func showResultsLayout() {
        popularRequestsLabel.isHidden = true
        popularCollectionView.isHidden = true
        recentSearchesLabel.isHidden = true
        recentCollectionView.isHidden = true
        resultsTableView.isHidden = false
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if updatedText.isEmpty {
            isSearching = false
            filteredStocks = []
            showTagsLayout()
        } else {
            isSearching = true
            filteredStocks = allStocks.filter {
                $0.companyName.lowercased().contains(updatedText.lowercased()) ||
                $0.ticker.lowercased().contains(updatedText.lowercased())
            }
            showResultsLayout()
        }
        resultsTableView.reloadData()
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isSearching = false
        filteredStocks = []
        showTagsLayout()
        resultsTableView.reloadData()
        return true
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == popularCollectionView {
            return popularRequests.count
        } else {
            return recentSearches.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        let title = collectionView == popularCollectionView ? popularRequests[indexPath.item] : recentSearches[indexPath.item]
        cell.configure(title: title)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let title = collectionView == popularCollectionView ? popularRequests[indexPath.item] : recentSearches[indexPath.item]
        searchBarView.textField.text = title
        isSearching = true
        filteredStocks = allStocks.filter {
            $0.companyName.lowercased().contains(title.lowercased()) ||
            $0.ticker.lowercased().contains(title.lowercased())
        }
        showResultsLayout()
        resultsTableView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = collectionView == popularCollectionView ? popularRequests[indexPath.item] : recentSearches[indexPath.item]
        let font = UIFont.systemFont(ofSize: 14)
        let size = (title as NSString).size(withAttributes: [.font: font])
        return CGSize(width: size.width + 32, height: 32)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStocks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.identifier, for: indexPath) as? StockTableViewCell else {
            return UITableViewCell()
        }
        let stock = filteredStocks[indexPath.row]
        cell.configure(with: stock, indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stock = filteredStocks[indexPath.row]
        delegate?.didSelectStock(stock)
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true)
    }
}

extension SearchViewController: StockTableViewCellDelegate {
    func didTapFavoriteButton(for stock: Stock) {
        if let index = allStocks.firstIndex(where: { $0.ticker == stock.ticker }) {
            allStocks[index].isFavorite.toggle()
            resultsTableView.reloadData()
        }
    }
} 
