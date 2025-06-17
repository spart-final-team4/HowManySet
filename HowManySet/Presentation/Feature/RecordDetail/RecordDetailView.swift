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

            $0.register(
                WorkoutDetailHeaderView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: WorkoutDetailHeaderView.identifier
            )
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
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            if sectionIndex == 0 {
                return makeSummarySection() // 요약 섹션
            } else {
                return makeWorkoutSection() // 운동 상세 섹션
            }
        }
    }

    /// 첫 번째 섹션: SummaryInfoCell 단일 셀
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

    /// 두 번째 섹션부터: 운동 상세 (가로 스크롤)
    static func makeWorkoutSection() -> NSCollectionLayoutSection {
        // 세트 하나 (아이템) 크기
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .estimated(80),
                heightDimension: .estimated(80)
            )
        )

        // 수평 그룹: 한 줄에 여러 세트들
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .estimated(500),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )

        // 섹션: 운동 1개, 수평 스크롤
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 0, leading: 28, bottom: 16, trailing: 28)
        section.interGroupSpacing = 8

        // 섹션 헤더: 운동 이름
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(30)
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]
        return section
    }
}

// MARK: - Computed Property
extension RecordDetailView {
    var publicCollectionView: UICollectionView { collectionView }
}
