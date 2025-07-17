import UIKit
import SnapKit

protocol StockTableViewCellDelegate: AnyObject {
    func didTapFavoriteButton(for stock: Stock)
}

class StockTableViewCell: UITableViewCell {
    static let identifier = "StockTableViewCell"
    
    weak var delegate: StockTableViewCellDelegate?
    private var stock: Stock?
    
    // Карточка
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
    // Логотип
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
    // Тикер и звезда
    private let tickerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
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
        label.numberOfLines = 2
        return label
    }()
    // Цена и изменение
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    private let priceChangeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    // Стек для тикера и звезды
    private let tickerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    // Стек для текста
    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 1
        stack.alignment = .leading
        return stack
    }()
    // Стек для цены
    private let priceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
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
        contentView.addSubview(cardView)
        cardView.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageView)
        cardView.addSubview(textStack)
        cardView.addSubview(priceStack)
        tickerStack.addArrangedSubview(tickerLabel)
        tickerStack.addArrangedSubview(favoriteButton)
        textStack.addArrangedSubview(tickerStack)
        textStack.addArrangedSubview(companyNameLabel)
        priceStack.addArrangedSubview(priceLabel)
        priceStack.addArrangedSubview(priceChangeLabel)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    private func setupConstraints() {
        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        logoContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(52)
        }
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(logoContainerView.snp.trailing).offset(16)
            make.centerY.equalToSuperview().offset(-6)
            make.trailing.lessThanOrEqualTo(priceStack.snp.leading).offset(-8)
        }
        priceStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(80)
        }
    }
    func configure(with stock: Stock, indexPath: IndexPath?) {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.stock = stock
        tickerLabel.text = stock.ticker
        companyNameLabel.text = stock.companyName
        // Форматируем цену: если дробная часть 0, показываем только целое число
        let price = stock.price
        let isInt = floor(price) == price
        let priceText: String
        if isInt {
            let intValue = Int(price)
            let formatted = NumberFormatter.localizedString(from: NSNumber(value: intValue), number: .decimal)
            priceText = "$" + formatted
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.groupingSeparator = ","
            formatter.decimalSeparator = "."
            let formatted = formatter.string(from: NSNumber(value: price)) ?? String(format: "%.2f", price)
            priceText = "$" + formatted
        }
        priceLabel.text = priceText
        priceLabel.font = UIFont.boldSystemFont(ofSize: 22)
        priceLabel.textColor = .black
        // Форматируем изменение цены
        let changeSign = stock.priceChange >= 0 ? "+" : "-"
        let absChange = abs(stock.priceChange)
        let absPercent = abs(stock.priceChangePercent)
        let changeText = "\(changeSign)$\(String(format: "%.2f", absChange).replacingOccurrences(of: ".", with: ",")) (\(changeSign)\(String(format: "%.2f", absPercent).replacingOccurrences(of: ".", with: ","))%)"
        priceChangeLabel.text = changeText
        priceChangeLabel.textColor = stock.priceChange >= 0 ? UIColor(red: 0.18, green: 0.69, blue: 0.36, alpha: 1) : UIColor(red: 0.91, green: 0.23, blue: 0.23, alpha: 1)
        // Логотип
        if let logoURLString = stock.logoURL, let url = URL(string: logoURLString) {
            loadLogoImage(from: url, fallbackName: stock.iconName)
        } else if let icon = UIImage(named: stock.iconName) {
            logoImageView.image = icon
        } else {
            logoImageView.image = UIImage(systemName: "building.2.fill")
        }
        // Звезда
        let starName = stock.isFavorite ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: starName), for: .normal)
        favoriteButton.tintColor = stock.isFavorite ? UIColor(red: 1, green: 0.8, blue: 0, alpha: 1) : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        // Фон карточки: белый/серый
        var color: UIColor = .white
        if let indexPath = indexPath {
            let isGray = indexPath.row % 2 == 1
            color = isGray ? UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1) : .white
        } else {
            color = .white
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
        // Для восстановления цвета после выделения
        if let superview = self.superview as? UITableView {
            if let indexPath = superview.indexPath(for: self) {
                let isGray = indexPath.row % 2 == 1
                return isGray ? UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1) : .white
            }
        }
        return .white
    }
    // MARK: - Logo image loading with cache
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
                        s