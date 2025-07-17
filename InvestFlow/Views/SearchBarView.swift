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
            observeBackButton()
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
        backgroundColor = .clear
        layer.cornerRadius = 22
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        
        addSubview(iconView)
        addSubview(backButton)
        addSubview(textField)
        
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .black
        backButton.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        iconView.image = UIImage(systemName: "magnifyingglass")
        iconView.tintColor = .black
        iconView.contentMode = .scaleAspectFit
        
        // Layout: если стрелка видна — лупа после стрелки, иначе лупа у левого края
        backButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        iconView.snp.remakeConstraints { make in
            if showsBackButton {
                make.leading.equalTo(backButton.snp.trailing).offset(4)
            } else {
                make.leading.equalToSuperview().offset(12)
            }
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        textField.snp.remakeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview().inset(8)
            make.height.equalTo(44 - 16)
        }
        textField.placeholder = "Find company or ticker"
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textColor = .black
    }
    
    private func observeBackButton() {
        backButton.isHidden = !showsBackButton
    }
    
    @objc private func backTapped() {
        onBack?()
    }
}
 