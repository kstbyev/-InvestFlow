import UIKit
import SnapKit

protocol StockTableViewCellDelegate: AnyObject {
    func didTapFavoriteButton(for stock: Stock)
}

class StockTableViewCell: UITableViewCell {
    static let identifier = "StockTableViewCell"
    
    weak var delegate: StockTableViewCellDelegate?
    private var stock: Stock?
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let logoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.10).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let tickerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemYellow
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    
    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .darkGray
        label.numberOfLines = 1
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let priceChangeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    private let tickerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    private let priceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .trailing
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupSubviews()
        setupStackViews()
        setupActions()
    }
    
    private func setupSubviews() {
        contentView.addSubview(cardView)
        cardView.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageView)
        cardView.addSubview(textStack)
        cardView.addSubview(priceStack)
    }
    
    private func setupStackViews() {
        tickerStack.addArrangedSubview(tickerLabel)
        tickerStack.addArrangedSubview(favoriteButton)
        textStack.addArrangedSubview(tickerStack)
        textStack.addArrangedSubview(companyNameLabel)
        priceStack.addArrangedSubview(priceLabel)
        priceStack.addArrangedSubview(priceChangeLabel)
    }
    
    private func setupActions() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        setupCardViewConstraints()
        setupLogoConstraints()
        setupTextStackConstraints()
        setupPriceStackConstraints()
    }
    
    private func setupCardViewConstraints() {
        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func setupLogoConstraints() {
        logoContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
    }
    
    private func setupTextStackConstraints() {
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(logoContainerView.snp.trailing).offset(16)
            make.centerY.equalToSuperview().offset(-6)
            make.trailing.lessThanOrEqualTo(priceStack.snp.leading).offset(-8)
        }
    }
    
    private func setupPriceStackConstraints() {
        priceStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(100)
        }
    }
    
    func configure(with stock: Stock, indexPath: IndexPath?) {
        self.stock = stock
        setupAppearance()
        configureLabels()
        configurePrice()
        configureLogo()
        configureFavoriteButton()
        configureCardBackground(for: indexPath)
    }
    
    private func setupAppearance() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    private func configureLabels() {
        tickerLabel.text = stock.ticker
        companyNameLabel.text = stock.companyName
    }
    
    private func configurePrice() {
        let priceText = formatPrice(stock.price)
        priceLabel.text = priceText
        priceLabel.font = UIFont.boldSystemFont(ofSize: 22)
        priceLabel.textColor = .black
        
        let changeText = formatPriceChange(stock.priceChange, stock.priceChangePercent)
        priceChangeLabel.text = changeText
        priceChangeLabel.textColor = stock.priceChange >= 0 ? 
            UIColor(red: 0.18, green: 0.69, blue: 0.36, alpha: 1) : 
            UIColor(red: 0.91, green: 0.23, blue: 0.23, alpha: 1)
    }
    
    private func formatPrice(_ price: Double) -> String {
        let isInt = floor(price) == price
        if isInt {
            let intValue = Int(price)
            let formatted = NumberFormatter.localizedString(from: NSNumber(value: intValue), number: .decimal)
            return "$" + formatted
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.groupingSeparator = ","
            formatter.decimalSeparator = "."
            let formatted = formatter.string(from: NSNumber(value: price)) ?? String(format: "%.2f", price)
            return "$" + formatted
        }
    }
    
    private func formatPriceChange(_ change: Double, _ percent: Double) -> String {
        let changeSign = change >= 0 ? "+" : "-"
        let absChange = abs(change)
        let absPercent = abs(percent)
        return "\(changeSign)$\(String(format: "%.1f", absChange).replacingOccurrences(of: ".", with: ",")) (\(changeSign)\(String(format: "%.1f", absPercent).replacingOccurrences(of: ".", with: ","))%)"
    }
    
    private func configureLogo() {
        if let logoURLString = stock.logoURL, let url = URL(string: logoURLString) {
            loadLogoImage(from: url, fallbackName: stock.iconName)
        } else if let icon = UIImage(named: stock.iconName) {
            logoImageView.image = icon
        } else {
            logoImageView.image = UIImage(systemName: "building.2.fill")
        }
    }
    
    private func configureFavoriteButton() {
        let starName = stock.isFavorite ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: starName), for: .normal)
        favoriteButton.tintColor = stock.isFavorite ? 
            UIColor(red: 1, green: 0.8, blue: 0, alpha: 1) : 
            UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    }
    
    private func configureCardBackground(for indexPath: IndexPath?) {
        var color: UIColor = .white
        if let indexPath = indexPath {
            let isGray = indexPath.row % 2 == 1
            color = isGray ? UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1) : .white
        }
        cardView.backgroundColor = color
        cardView.layer.shadowOpacity = 1
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.cardView.backgroundColor = selected ? UIColor.systemGray4 : (self.indexPathColor ?? self.cardView.backgroundColor)
        }
    }
    
    private var indexPathColor: UIColor? {
        if let superview = self.superview as? UITableView {
            if let indexPath = superview.indexPath(for: self) {
                let isGray = indexPath.row % 2 == 1
                return isGray ? UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1) : .white
            }
        }
        return .white
    }
    
    private static var imageCache = NSCache<NSURL, UIImage>()
    
    private func loadLogoImage(from url: URL, fallbackName: String) {
        if let cached = StockTableViewCell.imageCache.object(forKey: url as NSURL) {
            logoImageView.image = cached
            return
        }
        
        logoImageView.image = UIImage(systemName: "building.2.fill")
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    if let icon = UIImage(named: fallbackName) {
                        self.logoImageView.image = icon
                    } else {
                        self.logoImageView.image = UIImage(systemName: "building.2.fill")
                    }
                }
                return
            }
            
            StockTableViewCell.imageCache.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async {
                self.logoImageView.image = image
            }
        }.resume()
    }
    
    @objc private func favoriteButtonTapped() {
        if let stock = stock {
            delegate?.didTapFavoriteButton(for: stock)
        }
    }
}