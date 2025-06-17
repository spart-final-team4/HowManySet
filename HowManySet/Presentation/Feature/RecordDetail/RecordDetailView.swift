import UIKit
import SnapKit
import Then

final class RecordDetailView: UIView {

    private let collectionView: UICollectionView = {
        let layout = RecordDetailView.createLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Record Detail UI 관련 extension
private extension RecordDetailView {
    func setupUI() {
        backgroundColor = .background
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    func setAppearance() {
        collectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
        }
    }

    func setViewHierarchy() {
        addSubview(collectionView)
    }

    func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewCompositionalLayout
private extension RecordDetailView {
    static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch sectionIndex {
            case 0:
                return makeSummarySection()
            default:
                return nil
            }
        }
    }

    static func makeSummarySection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(150)
            )
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(210)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 28, leading: 28, bottom: 20, trailing: 28)
        return section
    }
}

// Expose the collectionView if needed
extension RecordDetailView {
    var publicCollectionView: UICollectionView { collectionView }
}
