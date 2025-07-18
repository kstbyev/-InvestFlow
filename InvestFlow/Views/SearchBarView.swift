import UIKit
import SnapKit

class SearchBarView: UIView {
    let textField = UITextField()
    private let iconView = UIImageView()
    private let backButton = UIButton(type: .system)
    var onBack: (() -> Void)?
    
    var showsBackButton: Bool = true {
        didSet {
            backButton.isHidden = !showsBackButton
            updateIconConstraints()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        setupAppearance()
        setupSubviews()
        setupConstraints()
        setupTextField()
    }
    
    private func setupAppearance() {
        backgroundColor = .clear
        layer.cornerRadius = 22
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupSubviews() {
        addSubview(iconView)
        addSubview(backButton)
        addSubview(textField)
        
        setupBackButton()
        setupIconView()
    }
    
    private func setupBackButton() {
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .black
        backButton.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    private func setupIconView() {
        iconView.image = UIImage(systemName: "magnifyingglass")
        iconView.tintColor = .black
        iconView.contentMode = .scaleAspectFit
    }
    
    private func setupConstraints() {
        setupBackButtonConstraints()
        setupIconViewConstraints()
        setupTextFieldConstraints()
    }
    
    private func setupBackButtonConstraints() {
        backButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    private func setupIconViewConstraints() {
        updateIconConstraints()
    }
    
    private func setupTextFieldConstraints() {
        textField.snp.remakeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview().inset(8)
            make.height.equalTo(28)
        }
    }
    
    private func setupTextField() {
        textField.placeholder = "Find company or ticker"
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textColor = .black
    }
    
    private func updateIconConstraints() {
        iconView.snp.remakeConstraints { make in
            if showsBackButton {
                make.leading.equalTo(backButton.snp.trailing).offset(4)
            } else {
                make.leading.equalToSuperview().offset(14)
            }
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        layoutIfNeeded()
    }
    
    @objc private func backTapped() {
        onBack?()
    }
    
    func resetSearchBar() {
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    func updateIconPosition() {
        updateIconConstraints()
    }
}
 