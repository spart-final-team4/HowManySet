# HowManySet
![image1](https://github.com/user-attachments/assets/5e2523bb-d0fe-408c-a767-e6edd85fd3a3)
![image2](https://github.com/user-attachments/assets/7335ea90-4a7a-4322-a0b4-496bc5b7591d)

## 📌 프로젝트 소개
- **간략한 소개**: 나만의 운동과 루틴을 설정하고 효율적인 조작이 가능한 운동 루틴 기록 어플 HowManySet!  
- **앱 설명**: 루틴/운동 커스터마이징, 운동내역 공유, 캘린더 기반 기록 확인 및 메모, Live Activity, 다국어(영어, 일본어) 제공  
- **개발 기간**: 2025.05.29 ~  
- [**앱 다운로드**](https://apps.apple.com/kr/app/howmanyset/id6746778243?l=en-GB)

## 👥 팀 구성
- **팀명**: 근육몬 GO!

| 이름 | 역할 | 개발 내용 |
|------|------|--------|
| [정근호](https://github.com/eightroutes) | 리더 | 홈화면, 운동완료 페이지, Live Activity, Dynamic Island, 코디네이터 세팅 |
| [이민재](https://github.com/minjae-L) | 부리더 | Realm 설계, 마이페이지, 루틴 상세 페이지, 운동 편집 페이지, Usecase/Repository 세팅 |
| [고욱현](https://github.com/imo2k) | 팀원 | Firebase 설계, 로그인/로그아웃/계정탈퇴 구현, 닉네임 설정 및 온보딩 페이지, 다국어 지원 |
| [조선우](https://github.com/Sn8Ch0) | 팀원 | 캘린더 페이지, 기록 상세 페이지, 루틴 리스트 페이지, 루틴 이름 페이지 |
| 이상호 | 디자이너 | UI/UX 디자인, 로고 및 아이콘 제작 |

## 🗓️ 컨벤션 및 프로젝트 관리
- **코딩 컨벤션**: `StyleShare - Swift Style Guide`
- **커밋 컨벤션**: `Udacity Git Commit Message Style Guide`
- **브랜치 컨벤션**: 예) `feature/#이슈번호`
- **프로젝트 관리 툴**: Notion, GitHub, Figma, Slack
    - GitHub: 프로젝트 진행 중간부터 노션이 반영이 되지 않는 이슈가 있어 모든 것을 GitHub에서 진행했습니다.
    (Issues, Discussionis, CI, Projects)

## ⚙️ 개발 환경 및 기술 스택
- **개발 환경**
> Xcode 16.4  
> iOS 16.2  
> Swift 6.1  

- **사용 기술 스택**

| 기술 스택 | 이유 |
|------------------|----------------------------------|
| RxSwift | 비동기 처리와 반응형 프로그래밍 |
| ReactorKit | MVVM + 상황별 상태 관리 용이 |
| Firebase | 인증, 회원 데이터베이스 백업 동기화 |
| Realm | 비회원 로컬 데이터베이스 |
| SnapKit | 오토레이아웃 구성 |
| Then | 프로퍼티 선언 간결화 |
| FSCalendar | 캘린더 UI |
| ActivityKit | Live Activity 구현 |
| Clean Architecture + MVVM | 유지보수성과 확장성을 극대화 |
| Coordinator | 많은 화면 전환에 용이 |

## ✨ 주요 기능 소개
**로그인 화면**
- 로그인 및 계정 관리 (Google, Apple) ➡️ Firebase에 저장되어 데이터 백업 가능
- 비회원 로그인 기능 ➡️ Realm에 저장됨, 간편한 사용자를 위함
- Firebase/Realm 기반 사용자 데이터 분기 저장

![image3](https://github.com/user-attachments/assets/288a03b6-1a19-4bb4-af31-f7722385d34c)
![image4](https://github.com/user-attachments/assets/dd999fdc-ceac-4843-96f0-94362f3814cf)

**루틴 리스트 화면**
- 사용자 개인 루틴 생성 및 운동 커스터마이징
- 루틴 및 운동 생성 후 수정, 삭제 가능

![image5](https://github.com/user-attachments/assets/89fad2f8-dded-475a-b4fb-7343725eede7)

**홈 화면**
- 사용자화 된 정보로 실시간 운동 기록 (세트, 반복, 무게 등)
- 휴식 시간 타이머 및 조작 (기본 휴식 시간은 1분으로 고정)
- 운동 메모 기능 (운동 중 운동별 메모, 운동 완료 후 루틴에 대한 메모)
- Live Activity 통한 실시간 상태 표시 및 조작

![image6](https://github.com/user-attachments/assets/49028cb5-ecb3-4bb6-ba91-5753b125fcfb)
![image7](https://github.com/user-attachments/assets/c8b2bc5a-737c-48f4-94a8-3eb04ead5f56)

**캘린더 화면**
- 캘린더 기반 기록 조회 및 상세 보기
- 상세 기록에서 수행한만큼 기록 확인 및 메모 수정 가능

![image8](https://github.com/user-attachments/assets/81ada4c8-9fca-4578-a3de-7b9e0c6d2b35)

**마이페이지**
- 마이페이지에서 알림/언어 설정/버전/라이센스 정보/문의/리뷰/개인정보 고지/로그아웃/탈퇴 관리

![image9](https://github.com/user-attachments/assets/f69c7f32-de4c-4012-be6d-5612784fe40e)
![image10](https://github.com/user-attachments/assets/a2f0211c-6439-425c-8942-b95bb83b800f)

## 📁 폴더 구조
```
HowManySet
├── App
│   └── Coordinator
│       └── Protocol
├── Data
│   ├── DTO
│   ├── Firebase
│   │   └── Repositories
│   ├── Firestore
│   │   ├── Model
│   │   └── Repositories
│   ├── Model
│   ├── PersistentStorages
│   │   ├── Model
│   │   └── Stub
│   └── Repositories
├── Domain
│   ├── Entity
│   │   └── HomeEntity
│   ├── Repositories
│   └── UseCase
│       ├── Auth
│       ├── FSUserPage
│       ├── Protocols
│       │   ├── Auth
│       │   ├── Record
│       │   ├── Routine
│       │   ├── UserPage
│       │   └── Workout
│       ├── Record
│       ├── Routine
│       ├── UserPage
│       └── Workout
├── Presentation
│   ├── Common
│   │   ├── Enum
│   │   ├── Extension
│   │   └── ViewAnimator
│   ├── Feature
│   │   ├── Auth
│   │   │   └── Reactor
│   │   ├── Calendar
│   │   │   └── Reactor
│   │   ├── EditExercise
│   │   │   ├── AddExerciseView
│   │   │   ├── EditExerciseContentView
│   │   │   ├── EditExerciseCurrentView
│   │   │   ├── EditExerciseFooterView
│   │   │   ├── EditExerciseHeaderView
│   │   │   └── EditExerciseView
│   │   │       └── Reactor
│   │   ├── EditRoutine
│   │   │   └── Reactor
│   │   ├── Home
│   │   │   └── Reactor
│   │   ├── HomeStart
│   │   ├── MyPage
│   │   │   ├── PrivacyPolicy
│   │   │   ├── Reactor
│   │   │   └── View
│   │   │       └── MyPageCollectionView
│   │   │           └── MyPageCollectionViewCells
│   │   ├── OnBoarding
│   │   │   └── Reactor
│   │   ├── RecordDetail
│   │   │   ├── Cell
│   │   │   ├── HeaderView
│   │   │   ├── Model
│   │   │   └── Reactor
│   │   ├── RoutineComplete
│   │   ├── RoutineList
│   │   │   └── Reactor
│   │   ├── RoutineName
│   │   │   └── Reactor
│   │   └── Statistics
│   │       └── Reactor
│   └── Services
└── Resources
```
