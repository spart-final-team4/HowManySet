# CLAUDE.md

## 프로젝트 컨텍스트

운동 루틴을 기록하는 iOS 앱으로, 비회원(Realm 로컬)과 회원(Firestore 클라우드)을 동일한 인터페이스로 지원하며 Live Activity · Apple Watch 연동을 포함한다.

---

## 명령어

### 빌드
패키지 매니저는 **Swift Package Manager**만 사용한다 (Podfile 없음).

```bash
# 빌드
xcodebuild -scheme HowManySet -destination 'platform=iOS Simulator,name=iPhone 16' build

# Debug 빌드 (시뮬레이터 실행)
xcodebuild -scheme HowManySet -destination 'platform=iOS Simulator,name=iPhone 16' -configuration Debug build
```

- Xcode 16.4 이상, 최소 배포 타겟 iOS 16.2, Swift 5.0 (실제 코드는 Swift 6 동시성 사용)
- 현재 테스트 타겟 없음 — Unit/UI 테스트 파일 없음
- 배포는 Xcode Organizer → TestFlight 또는 App Store Connect 사용

### 필수 설정 (최초 1회)
두 파일은 `.gitignore`에 포함되어 있어 클론 후 직접 생성해야 한다.

1. **`Secrets.xcconfig`** — 프로젝트 루트에 생성 (Kakao / Google / AdMob 키 포함)
2. **`HowManySet/Resources/GoogleService-Info.plist`** — Firebase 콘솔에서 다운로드

---

## 코드스타일

### 아키텍처 레이어
```
Presentation → Domain ← Data
```
의존성은 단방향. Domain은 Realm/Firebase를 모르고 순수 Swift Entity만 사용한다.

- **Presentation**: ViewController + ReactorKit Reactor + View
- **Domain**: Entity, UseCase Protocol + Impl, Repository Protocol
- **Data**: RepositoryImpl (Realm/Firestore 구현체), DTO, RMModel (Realm), FSModel (Firestore)

### ReactorKit (Action → Mutation → State)
모든 화면은 `Reactor` 클래스를 가진다. 뷰는 Action을 전송하고 State를 구독하며, Reactor 내부에서만 상태를 변경한다.

```swift
// VC에서
reactor.action.onNext(.someAction)
reactor.state.map { $0.someValue }.bind(to: ...).disposed(by: disposeBag)

// Reactor에서
func mutate(action: Action) -> Observable<Mutation> { ... }
func reduce(state: State, mutation: Mutation) -> State { ... }
```

- Reactor 로직이 길어질 경우 `HomeViewReactor+Extension.swift`처럼 extension으로 분리한다.

### MARK 주석 필수 순서 (Reactor)
```swift
// MARK: - Action
// MARK: - Mutation
// MARK: - State
// MARK: - Properties
// MARK: - Initializer
```

### UseCase 구조 (Protocol / Impl 분리)
```
Domain/UseCase/
  Protocols/Record/SaveRecordUseCaseProtocol.swift   ← 프로토콜
  Record/SaveRecordUseCase.swift                      ← 구현체
```
DI는 반드시 Protocol 타입으로 주입한다. UseCase 하나는 동작 하나만 담당한다.

### 데이터 모델 변환 흐름
```
RMWorkoutRoutine (Realm) ──toDTO()──► WorkoutRoutineDTO ──toEntity()──► WorkoutRoutine (Domain Entity)
FSWorkoutRoutine (Firestore) ──init(from:)──► WorkoutRoutineDTO ──toEntity()──► WorkoutRoutine
```
레이어 경계를 넘을 때 반드시 DTO를 거친다. Entity ↔ RM/FS Model 직접 변환 금지.

### Repository — uid 기반 데이터 분기
`uid: String?`가 nil이면 **Realm (비회원, 로컬)**, non-nil이면 **Firestore (회원, 클라우드)** 를 사용한다.

```swift
func saveRecord(uid: String?, item: WorkoutRecord) {
    if let uid { saveToFirestore(uid: uid, ...) } else { saveToRealm(...) }
}
```

### Firestore 비동기 패턴
- **읽기**: `Single.create { } + Task { }` 조합
- **쓰기/수정/삭제**: `Task { }` 직접 사용 (Single 불필요)

### RxSwift 관례
- `Single<T>`는 1회성 fetch에 사용. `try await single.value`로 async/await 브릿지 가능 (RxSwift 6.9.0)
- 클로저 캡처 시 `unowned self` 대신 반드시 `[weak self] / guard let self` 패턴 사용
- 각 화면의 `disposeBag`은 해당 VC 또는 Reactor에 소속

### 에러 처리 — Fire and Forget
Repository 쓰기 작업은 에러를 호출부로 throw하지 않고 내부에서 `print`로만 처리한다.
새 Repository 메서드 작성 시 이 패턴을 유지해야 한다.

```swift
func createRecordToFirebase(...) {
    do { ... } catch { print("Firestore 기록 저장 실패: \(error)") }  // throw 하지 않음
}
```

### Coordinator 패턴
화면 전환은 Coordinator가 전담. 부모-자식 간 통신은 `finishFlow` 클로저 사용.

```
AppCoordinator → TabBarCoordinator → HomeCoordinator / RoutineListCoordinator / CalendarCoordinator / MyPageCoordinator
AppCoordinator → AuthCoordinator → NicknameInputCoordinator → OnBoardingCoordinator
                                 → EditRoutineCoordinator
                                 → RoutineCompleteCoordinator
```

### DIContainer
모든 VC 생성은 `DIContainer`를 통해서만 수행한다. VC가 직접 의존성을 생성하지 않는다.
`make*ViewController()` 호출 시마다 Service / Repository / UseCase를 **매번 새로 생성**한다 (싱글톤 불사용 — 의도적 설계).

### MembershipView (SwiftUI ↔ UIKit 브릿지)
`MembershipView`는 SwiftUI로 작성되어 `UIHostingController`로 UIKit에 임베드된다.
버튼 액션은 클로저 프로퍼티(`dismiss`, `signUpWithKakao` 등)를 통해 `MembershipViewHostingController.connectEvents()`에서 주입한다.

### ViewCaller
동일한 VC가 여러 진입점에서 사용될 때 `ViewCaller` enum으로 분기한다.
- `.fromTabBar` — 탭바에서 직접 진입
- `.fromHome` — 홈(운동 중 화면)에서 진입

### Home 전용 Service 레이어
`Presentation/Feature/Home/Service/`에 Home 화면 전용 서비스가 위치한다 (다른 화면에는 없는 구조).
- `LiveActivitySyncService` — 0.5초 폴링으로 AppGroup 이벤트 감지
- `WorkoutAnimationService` — 운동 카드 애니메이션 처리

### 기타 규칙
- 모든 VC, Reactor, UseCase, Repository는 `final class`로 선언
- 클래스와 주요 메서드에 `///` 형태 문서 주석 작성
- 폰트: `UIFont.pretendard(size:weight:)` extension 사용
- 다국어: SwiftUI는 `Text("key")`, UIKit은 `String(localized: "key")`

### 주요 UserDefaults 키

| 키 | 값 |
|---|---|
| `userProvider` | `"kakao"` / `"google"` / `"apple"` / `"anonymous"` / `"none"` |
| `userUID` | Firebase UID (회원만 존재) |
| `hasSetNickname` | Bool |
| `hasCompletedOnboarding` | Bool |

---

## 주의사항

### ⚠️ migration 기능 미완성
`MembershipViewReactor.migration(uid:)`에 실제 저장/삭제 로직이 없고, `MembershipViewController`의 버튼 클로저 본체가 주석 처리 상태다. 이 기능을 건드리기 전에 반드시 미완성 상태임을 확인할 것.

### ⚠️ AppCoordinator Firebase Auth 타이머
앱 시작 시 Firebase Auth 콜백이 nil로 오면 1초 대기 후 비로그인으로 분기한다 (`initialAuthWait = .seconds(1)`).
`hasRouted` 플래그로 중복 분기를 방지하므로, Auth 상태 변경 로직 수정 시 이 플래그를 반드시 고려해야 한다.

### ⚠️ 비회원 로그아웃 — UserDefaults 전체 삭제
비회원(`uid == nil`) 로그아웃 시 `removePersistentDomain`으로 Bundle의 UserDefaults를 **전체 삭제**한다.
일반 사용자는 개별 키만 삭제한다. 비회원 관련 로직 수정 시 이 차이를 인지해야 한다.

### ⚠️ Live Activity AppGroup 잔여 데이터
앱 시작 시 `AppDelegate`에서 AppGroup 잔여 데이터를 정리한다.
`LiveActivityAppGroupEventBridge` 관련 코드를 수정할 때 이 정리 로직이 영향받지 않는지 확인해야 한다.

### ⚠️ FirestoreDataType 타입 캐스팅
`FirestoreDataType<T>.type`은 내부에서 `as! T.Type` 강제 캐스팅을 사용한다.
잘못된 제네릭 타입으로 호출하면 런타임 크래시가 발생하므로, 호출 시 타입 파라미터가 FS 모델과 일치해야 한다.

```swift
// 올바른 사용
firestoreService.read(userId: uid, type: FirestoreDataType<FSWorkoutRecord>.workoutRecord)
// 틀린 사용 — 런타임 크래시
firestoreService.read(userId: uid, type: FirestoreDataType<FSWorkoutRoutine>.workoutRecord)
```

### ⚠️ 멀티 타겟
- **HowManySetWidget** — Live Activity (잠금화면, Dynamic Island)
- **HowManySetIntentExtension** — Live Activity App Intent (세트 완료, 휴식 재생/일시정지, 스킵, 운동 종료)
- **HowManySetWatch Watch App** — Apple Watch 연동

공유 코드를 수정할 때 세 타겟 모두 빌드가 통과하는지 확인해야 한다.
