import UIKit
import SnapKit

class MainViewController: UIViewController {
    private var allStocks: [Stock] = []
    private var displayedStocks: [Stock] = []
    private var filteredStocks: [Stock] = []
    private var isSearching = false
    private var currentTab: TabType = .stocks
    
    private let searchBarView = SearchBarView()
    
    enum TabType {
        case stocks
        case favorites
    }
    
    // Новый UI для табов
    private let tabStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillProportionally
        stackView.backgroundColor = .clear
        stackView.layer.cornerRadius = 0
        stackView.layer.masksToBounds = false
        // Удаляем тень и разделитель
        return stackView
    }()
    
    private let stocksLabel: UILabel = {
        let label = UILabel()
        label.text = "Stocks"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .black
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let favouritesLabel: UILabel = {
        let label = UILabel()
        label.text = "Favourite"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .lightGray
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        return tableView
    }()
    
    private let popularRequestsLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular requests"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.isHidden = true
        return label
    }()
    private let recentSearchesLabel: UILabel = {
        let label = UILabel()
        label.text = "You've searched for this"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.isHidden = true
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
        collectionView.isHidden = true
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
        collectionView.isHidden = true
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
    private var searchBarTopConstraint: Constraint? = nil
    private var tabStackViewTopConstraint: Constraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        searchBarView.textField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadStocks()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayedStocks()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "InvestFlow"
        searchBarView.showsBackButton = false
        searchBarView.onBack = { [weak self] in
            self?.showMainLayout()
            self?.searchBarView.resetSearchBar()
            self?.isSearching = false
            self?.filteredStocks = []
            self?.resultsTableView.reloadData()
        }
        view.addSubview(searchBarView)
        view.addSubview(tableView)
        view.addSubview(tabStackView)
        view.addSubview(popularRequestsLabel)
        view.addSubview(popularCollectionView)
        view.addSubview(recentSearchesLabel)
        view.addSubview(recentCollectionView)
        // resultsTableView добавляем последним, чтобы он был поверх всех
        view.addSubview(resultsTableView)
        tabStackView.addArrangedSubview(stocksLabel)
        tabStackView.addArrangedSubview(favouritesLabel)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StockTableViewCell.self, forCellReuseIdentifier: StockTableViewCell.identifier)
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.register(StockTableViewCell.self, forCellReuseIdentifier: StockTableViewCell.identifier)
        searchBarView.textField.delegate = self
        updateTabAppearance()
    }
    
    private func setupConstraints() {
        searchBarView.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        tabStackView.snp.remakeConstraints { make in
            make.top.equalTo(searchBarView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(32)
        }
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(tabStackView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        resultsTableView.snp.remakeConstraints { make in
            make.top.equalTo(searchBarView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        // Теги располагаются независимо, поверх tableView, и скрываются вне поиска
        popularRequestsLabel.snp.remakeConstraints { make in
            make.top.equalTo(searchBarView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        popularCollectionView.snp.remakeConstraints { make in
            make.top.equalTo(popularRequestsLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(40)
        }
        recentSearchesLabel.snp.remakeConstraints { make in
            make.top.equalTo(popularCollectionView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        recentCollectionView.snp.remakeConstraints { make in
            make.top.equalTo(recentSearchesLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(40)
        }
        view.layoutIfNeeded()
    }
    
    private func setupActions() {
        let stocksTap = UITapGestureRecognizer(target: self, action: #selector(stocksLabelTapped))
        stocksLabel.addGestureRecognizer(stocksTap)
        let favTap = UITapGestureRecognizer(target: self, action: #selector(favouritesLabelTapped))
        favouritesLabel.addGestureRecognizer(favTap)
    }
    
    private func showTagsLayout() {
        searchBarView.showsBackButton = true
        UIView.animate(withDuration: 0.25) {
            self.popularRequestsLabel.alpha = 1
            self.popularCollectionView.alpha = 1
            self.recentSearchesLabel.alpha = 1
            self.recentCollectionView.alpha = 1
            self.resultsTableView.alpha = 0
            self.tabStackView.alpha = 0
            self.tableView.alpha = 0
        } completion: { _ in
            self.popularRequestsLabel.isHidden = false
            self.popularCollectionView.isHidden = false
            self.recentSearchesLabel.isHidden = false
            self.recentCollectionView.isHidden = false
            self.resultsTableView.isHidden = true
            self.tabStackView.isHidden = true
            self.tableView.isHidden = true
            // Откат: убираю reloadData
        }
    }
    private func showResultsLayout() {
        searchBarView.showsBackButton = true
        UIView.animate(withDuration: 0.25) {
            self.popularRequestsLabel.alpha = 0
            self.popularCollectionView.alpha = 0
            self.recentSearchesLabel.alpha = 0
            self.recentCollectionView.alpha = 0
            self.resultsTableView.alpha = 1
            self.tabStackView.alpha = 0
            self.tableView.alpha = 0
        } completion: { _ in
            self.popularRequestsLabel.isHidden = true
            self.popularCollectionView.isHidden = true
            self.recentSearchesLabel.isHidden = true
            self.recentCollectionView.isHidden = true
            self.resultsTableView.isHidden = false
            self.tabStackView.isHidden = true
            self.tableView.isHidden = true
            // searchBarView всегда видим
        }
    }
    private func showMainLayout() {
        searchBarView.showsBackButton = false
        UIView.animate(withDuration: 0.25) {
            self.popularRequestsLabel.alpha = 0
            self.popularCollectionView.alpha = 0
            self.recentSearchesLabel.alpha = 0
            self.recentCollectionView.alpha = 0
            self.resultsTableView.alpha = 0
            self.tabStackView.alpha = 1
            self.tableView.alpha = 1
        } completion: { _ in
            self.popularRequestsLabel.isHidden = true
            self.popularCollectionView.isHidden = true
            self.recentSearchesLabel.isHidden = true
            self.recentCollectionView.isHidden = true
            self.resultsTableView.isHidden = true
            self.tabStackView.isHidden = false
            self.tableView.isHidden = false
        }
    }
    
    @objc private func stocksLabelTapped() {
        currentTab = .stocks
        updateTabAppearance()
        updateDisplayedStocks()
    }
    
    @objc private func favouritesLabelTapped() {
        currentTab = .favorites
        updateTabAppearance()
        updateDisplayedStocks()
    }
    
    private func updateTabAppearance() {
        switch currentTab {
        case .stocks:
            stocksLabel.textColor = .black
            stocksLabel.font = UIFont.boldSystemFont(ofSize: 28)
            favouritesLabel.textColor = .lightGray
            favouritesLabel.font = UIFont.boldSystemFont(ofSize: 22)
        case .favorites:
            stocksLabel.textColor = .lightGray
            stocksLabel.font = UIFont.boldSystemFont(ofSize: 22)
            favouritesLabel.textColor = .black
            favouritesLabel.font = UIFont.boldSystemFont(ofSize: 28)
        }
    }
    
    private func loadStocks() {
        StockService.shared.fetchStocks { [weak self] stocks, error in
            DispatchQueue.main.async {
                if let stocks = stocks {
                    self?.allStocks = stocks
                    self?.updateDisplayedStocks()
                }
            }
        }
    }
    
    private func updateDisplayedStocks() {
        switch currentTab {
        case .stocks:
            displayedStocks = allStocks
        case .favorites:
            displayedStocks = allStocks.filter { $0.isFavorite }
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultsTableView {
            print("[DEBUG] numberOfRowsInSection (resultsTableView): \(filteredStocks.count)")
            return filteredStocks.count
        }
        return displayedStocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == resultsTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.identifier, for: indexPath) as? StockTableViewCell else {
                return UITableViewCell()
            }
            let stock = filteredStocks[indexPath.row]
            cell.configure(with: stock, indexPath: indexPath)
            cell.delegate = self
            // Fade-in анимация появления ячейки
            cell.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0.05 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.alpha = 1
            }, completion: nil)
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.identifier, for: indexPath) as? StockTableViewCell else {
            return UITableViewCell()
        }
        let stock = displayedStocks[indexPath.row]
        cell.configure(with: stock, indexPath: indexPath)
        cell.delegate = self
        // Fade-in анимация появления ячейки
        cell.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.05 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
            cell.alpha = 1
        }, completion: nil)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == resultsTableView && isSearching {
            let headerView = UIView()
            headerView.backgroundColor = .clear
            let titleLabel = UILabel()
            titleLabel.text = "Stocks"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
            titleLabel.textColor = .black
            let showMoreButton = UIButton(type: .system)
            showMoreButton.setTitle("Show more", for: .normal)
            showMoreButton.setTitleColor(.systemGray, for: .normal)
            showMoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            showMoreButton.contentHorizontalAlignment = .right
            showMoreButton.isUserInteractionEnabled = false
            headerView.addSubview(titleLabel)
            headerView.addSubview(showMoreButton)
            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
            }
            showMoreButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
                make.centerY.equalToSuperview()
            }
            return headerView
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == resultsTableView && isSearching {
            return 48
        }
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == resultsTableView {
            let stock = filteredStocks[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            showMainLayout()
            searchBarView.textField.text = ""
            isSearching = false
            filteredStocks = []
            resultsTableView.reloadData()
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension MainViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        showTagsLayout()
        // Убедимся, что теги и заголовки всегда видны при открытии поиска
        popularRequestsLabel.isHidden = false
        popularCollectionView.isHidden = false
        recentSearchesLabel.isHidden = false
        recentCollectionView.isHidden = false
        resultsTableView.isHidden = true
        tabStackView.isHidden = true
        tableView.isHidden = true
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Теперь просто разрешаем изменение текста, фильтрация будет по .editingChanged
        return true
    }
    
    @objc private func searchTextChanged(_ textField: UITextField) {
        let searchText = (textField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .lowercased()
        print("[DEBUG] searchText: '", searchText, "'")
        if searchText.isEmpty {
            isSearching = false
            filteredStocks = []
            showTagsLayout()
            // Гарантируем, что теги и заголовки видны
            popularRequestsLabel.isHidden = false
            popularCollectionView.isHidden = false
            recentSearchesLabel.isHidden = false
            recentCollectionView.isHidden = false
            resultsTableView.isHidden = true
            tabStackView.isHidden = true
            tableView.isHidden = true
        } else {
            isSearching = true
            filteredStocks = allStocks.filter { stock in
                let company = stock.companyName
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                    .lowercased()
                let ticker = stock.ticker
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                    .lowercased()
                let companyContains = company.contains(searchText)
                let tickerContains = ticker.contains(searchText)
                print("[DEBUG] company: '", company, "', ticker: '", ticker, "', companyContains: ", companyContains, ", tickerContains: ", tickerContains)
                return companyContains || tickerContains
            }
            print("[DEBUG] filteredStocks.count = \(filteredStocks.count)")
            // Показываем только resultsTableView
            resultsTableView.isHidden = false
            tabStackView.isHidden = true
            tableView.isHidden = true
            popularRequestsLabel.isHidden = true
            popularCollectionView.isHidden = true
            recentSearchesLabel.isHidden = true
            recentCollectionView.isHidden = true
        }
        resultsTableView.reloadData()
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isSearching = false
        filteredStocks = []
        showTagsLayout()
        // Гарантируем, что теги и заголовки видны
        popularRequestsLabel.isHidden = false
        popularCollectionView.isHidden = false
        recentSearchesLabel.isHidden = false
        recentCollectionView.isHidden = false
        resultsTableView.isHidden = true
        tabStackView.isHidden = true
        tableView.isHidden = true
        resultsTableView.reloadData()
        return true
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        let searchText = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .lowercased()
        searchBarView.textField.text = title
        isSearching = true
        filteredStocks = allStocks.filter {
            let company = $0.companyName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                .lowercased()
            let ticker = $0.ticker
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                .lowercased()
            return company.contains(searchText) || ticker.contains(searchText)
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

// MARK: - StockTableViewCellDelegate
extension MainViewController: StockTableViewCellDelegate {
    func didTapFavoriteButton(for stock: Stock) {
        if let index = allStocks.firstIndex(where: { $0.ticker == stock.ticker }) {
            allStocks[index].isFavorite.toggle()
            updateDisplayedStocks()
        }
    }
}

// MARK: - SearchViewControllerDelegate
extension MainViewController: SearchViewControllerDelegate {
    func didSelectStock(_ stock: Stock) {
        // Можно реализовать переход к деталям акции или просто печать
        print("Selected stock: \(stock.ticker)")
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let shouldHide = offsetY > 20
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut]) {
            self.searchBarView.alpha = shouldHide ? 0 : 1
        }
    }
} 