import UIKit
import SnapKit

class TagCell: UICollectionViewCell {
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.textAlignment = .center
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(title: String) {
        label.text = title
    }
} 