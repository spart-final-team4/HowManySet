import UIKit
import SnapKit
import Then

final class RecordDetailView: UIView {

    /// 동적 레이아웃을 적용한 컬렉션 뷰
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            return NSCollectionLayoutSection(group: .vertical(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                  heightDimension: .absolute(1)),
                subitems: []
            ))
        }
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
    static func createLayout(sections: [RecordDetailSectionModel]) -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard sectionIndex < sections.count else { return nil }
            let section = sections[sectionIndex].model

            switch section {
            case .summary:
                return makeSummarySection()
            case .workoutDetail:
                return makeWorkoutSection()
            case .memo:
                return makeMemoSection()
            }
        }
    }

    /// 첫 번째 섹션: SummaryInfoCell 단일 셀
    static func makeSummarySection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(250)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 28, leading: 28, bottom: 20, trailing: 28)
        return section
    }

    /// 두 번째 섹션: 운동 상세 (가로 스크롤)
    static func makeWorkoutSection() -> NSCollectionLayoutSection {
        // 세트 하나 (아이템) 크기
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .estimated(80),
                heightDimension: .estimated(80)
            )
        )

        // 수평 그룹: 한 줄에 여러 세트들
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .estimated(500),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )

        // 섹션: 운동 1개, 수평 스크롤
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 0, leading: 28, bottom: 8, trailing: 28)
        section.interGroupSpacing = 12

        // 섹션 헤더: 운동 이름
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(36)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]
        return section
    }

    /// 세 번째 섹션: MemoInfoCell 단일 셀 (수직 방향)
    static func makeMemoSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(160)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(160)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 28, bottom: 0, trailing: 28)
        return section
    }
}

// MARK: - Computed Property
extension RecordDetailView {
    var publicCollectionView: UICollectionView { collectionView }
}

// MARK: - updateLayout
extension RecordDetailView {
    func updateLayout(with sections: [RecordDetailSectionModel]) {
        collectionView.setCollectionViewLayout(
            Self.createLayout(sections: sections),
            animated: false
        )
    }
}
