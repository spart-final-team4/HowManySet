import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

final class RecordDetailViewController: UIViewController, View {

    // MARK: - Properties
    let recordDetailView = RecordDetailView()
    var disposeBag = DisposeBag()

    // MARK: - DataSource
    private let dataSource = RxCollectionViewSectionedReloadDataSource<RecordDetailSectionModel>(configureCell: { dataSource, collectionView, indexPath, item in
        switch item {
        case let .summary(record):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SummaryInfoCell.identifier,
                for: indexPath
            ) as? SummaryInfoCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: record)
            return cell

        case let .set(index, set):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WorkoutDetailInfoCell.identifier,
                for: indexPath
            ) as? WorkoutDetailInfoCell else {
                return UICollectionViewCell()
            }
            cell.configure(index: index, set: set)
            return cell

        case let .memo(comment):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MemoInfoCell.identifier,
                for: indexPath
            ) as? MemoInfoCell else {
                return UICollectionViewCell()
            }
            cell.configure(comment: comment)
            return cell
        }
    },
    configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
        switch dataSource.sectionModels[indexPath.section].model {
        case let .workoutDetail(workout) where kind == UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: WorkoutDetailHeaderView.identifier,
                for: indexPath
            ) as? WorkoutDetailHeaderView else {
                return UICollectionReusableView()
            }
            header.configure(title: workout.name)
            return header
        default:
            return UICollectionReusableView()
        }
    }
    )

    // MARK: - Initializer
    init(reactor: RecordDetailViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func loadView() {
        view = recordDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bindKeyboardNotifications()
        bindTapToDismissKeyboard()
    }
}

// MARK: - UI Methods & Reactor Bind
extension RecordDetailViewController {
    /// 리액터 Binding
    func bind(reactor: RecordDetailViewReactor) {
        let record = reactor.currentState.record
        let headerView = recordDetailView.publicHeaderView
        
        recordDetailView.publicHeaderView.configure(with: record)

        // 요약뷰 구성
        let summarySection = RecordDetailSectionModel(
            model: .summary,
            items: [.summary(record: record)]
        )

        // 운동 세부 정보 섹션
        let workoutSections = record.workoutRoutine.workouts.enumerated().map { (_, workout) in
            let items = workout.sets.enumerated().map { (index, set) in
                RecordDetailSectionItem.set(index: index, set: set)
            }
            return RecordDetailSectionModel(
                model: .workoutDetail(workout: workout),
                items: items
            )
        }

        // 메모 섹션
        let memoSection = RecordDetailSectionModel(
            model: .memo(comment: record.comment),
            items: [.memo(comment: record.comment)]
        )

        // 전체 섹션
        let allSections = [summarySection] + workoutSections + [memoSection]

        // 레이아웃 업데이트
        recordDetailView.updateLayout(with: allSections)

        // 이후에 collecitonView에 데이터 바인딩
        Observable.just(allSections)
            .bind(to: recordDetailView.publicCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // MARK: - Data Binding

        // 저장 버튼 탭
        headerView.publicSaveButton.rx.tap
            .map { RecordDetailViewReactor.Action.tapSave }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 확인 버튼 탭
        headerView.publicConfirmButton.rx.tap
            .map { RecordDetailViewReactor.Action.tapConfirm }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 저장 버튼 활성화 상태 바인딩
        reactor.state
            .map(\.isSaveButtonEnabled)
            .distinctUntilChanged()
            .bind(with: self) { owner, isEnabled in
                owner.recordDetailView.publicHeaderView.updateSaveButtonEnabled(isEnabled)
            }
            .disposed(by: disposeBag)

        // 저장 버튼이 눌렸을 때 나타나는 토스트 뷰
        reactor.state
            .map(\.didUpdateMemo)
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, _ in
                owner.showToast(x: 0, y: -20, message: "메모가 수정되었어요!")
                // tapSave가 되었을 때만(한 번만) 반응하기 위해 false로 다시 설정
                owner.reactor?.action.onNext(.resetDidUpdateMemo)
            }
            .disposed(by: disposeBag)

        // shouldDismiss 상태 변화 -> 모달 닫기
        reactor.state
            .map(\.shouldDismiss)
            .distinctUntilChanged()
            .filter { $0 }
            .bind(with: self) { owner, _ in
                // Notification 전송
                NotificationCenter.default.post(name: .didDismissRecordDetail, object: nil)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        // MemoInfoCell에 있는 TextView와 상호작용
        recordDetailView.publicCollectionView.rx
            .willDisplayCell
            .compactMap { $0.cell as? MemoInfoCell }
            .bind(with: self) { (owner: RecordDetailViewController, cell: MemoInfoCell) in
                let textView = cell.publicMemoTextView

                // placeholder 로직
                textView.rx.didBeginEditing
                    .bind(with: owner) { _, _ in
                        if textView.text == "메모를 입력해주세요." {
                            textView.text = nil
                            textView.textColor = .white
                        }
                        textView.layer.borderColor = UIColor.grey3.cgColor
                        textView.layer.borderWidth = 1
                    }
                    .disposed(by: owner.disposeBag)

                textView.rx.didEndEditing
                    .bind(with: owner) { _, _ in
                        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            textView.text = "메모를 입력해주세요."
                            textView.textColor = .grey3
                        }
                        textView.layer.borderWidth = 0
                    }
                    .disposed(by: owner.disposeBag)

                // 텍스트 업데이트 시 리액터로 전달
                textView.rx.text.orEmpty
                    .skip(until: textView.rx.didBeginEditing)
                    .distinctUntilChanged()
                    .map { RecordDetailViewReactor.Action.updateMemo($0) }
                    .bind(to: reactor.action)
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
    }

    /// 컬랙션 뷰 Setup (셀 register)
    private func setupCollectionView() {
        let collectionView = recordDetailView.publicCollectionView

        // 첫번째 section cell
        collectionView.register(
            SummaryInfoCell.self,
            forCellWithReuseIdentifier: SummaryInfoCell.identifier
        )

        // 두번째 section cell
        collectionView.register(
            WorkoutDetailInfoCell.self,
            forCellWithReuseIdentifier: WorkoutDetailInfoCell.identifier
        )

        // 두번째 section 헤더 뷰
        collectionView.register(
            WorkoutDetailHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: WorkoutDetailHeaderView.identifier
        )

        // 세번째 section cell
        collectionView.register(
            MemoInfoCell.self,
            forCellWithReuseIdentifier: MemoInfoCell.identifier
        )
    }
}

// MARK: - Keyboard notification Method
private extension RecordDetailViewController {
    /// 키보드 이벤트 핸들링 메서드 추가
    func bindKeyboardNotifications() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .bind(with: self) { owner, keyboardHeight in
                owner.recordDetailView.publicCollectionView.contentInset.bottom = keyboardHeight + 20
                owner.recordDetailView.publicCollectionView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 20
                owner.scrollToMemoCellIfNeeded()
            }
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .bind(with: self) { owner, _ in
                owner.recordDetailView.publicCollectionView.contentInset.bottom = 0
                owner.recordDetailView.publicCollectionView.verticalScrollIndicatorInsets.bottom = 0
            }
            .disposed(by: disposeBag)
    }

    /// 키보드 외 화면 터치 시 키보드 내려가는 메서드
    func bindTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .bind(with: self) { owner, _ in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - RecordDetailViewController
private extension RecordDetailViewController {
    /// TextView 전체를 자동으로 화면에 보여주는 메서드
    func scrollToMemoCellIfNeeded() {
        guard let sectionIndex = dataSource.sectionModels.firstIndex(where: {
            if case .memo = $0.model { return true }
            return false
        }) else { return }

        let indexPath = IndexPath(item: 0, section: sectionIndex)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.recordDetailView.publicCollectionView.scrollToItem(
                at: indexPath,
                at: .bottom,
                animated: true
            )
        }
    }
}
