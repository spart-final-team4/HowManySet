import Foundation
import RxDataSources

// MARK: - Section 구분
enum RecordDetailSection: IdentifiableType, Equatable {
    case summary
    case workoutDetail(workout: Workout)
    case memo(comment: String?)

    var identity: String {
        switch self {
        case .summary:
            return "summary"
        case let .workoutDetail(workout):
            return workout.name
        case .memo:
            return "memo"
        }
    }

    /// 이 섹션이 summary 섹션인지 여부
    var isSummary: Bool {
        if case .summary = self { return true }
        return false
    }

    /// 이 섹션이 운동 상세 섹션인지 여부
    var isWorkoutDetail: Bool {
        if case .workoutDetail = self { return true }
        return false
    }

    /// 이 섹션이 메모 섹션인지 여부
    var isMemo: Bool {
        if case .memo = self { return true }
        return false
    }
}

// MARK: - Section의 아이템 구분
enum RecordDetailSectionItem: IdentifiableType, Equatable {
    case summary(record: WorkoutRecord)
    case set(index: Int, set: WorkoutSet)
    case memo(comment: String?)

    var identity: String {
        switch self {
        case let .summary(record):
            return "summary_\(record.date.timeIntervalSince1970)"
        case let .set(index, _):
            return "set_\(index)"
        case .memo:
            return "memo"
        }
    }
}

// MARK: - 타입에 사용할 typealias
typealias RecordDetailSectionModel = AnimatableSectionModel<RecordDetailSection, RecordDetailSectionItem>
