import Foundation
import RxDataSources

// MARK: - Section 구분
enum RecordDetailSection: IdentifiableType, Equatable {
    case summary
    case workoutDetail(workout: Workout)

    var identity: String {
        switch self {
        case .summary:
            return "summary"
        case .workoutDetail(let workout):
            return workout.name
        }
    }
}

// MARK: - Section의 아이템 구분
enum RecordDetailSectionItem: IdentifiableType, Equatable {
    case summary(record: WorkoutRecord)
    case set(index: Int, set: WorkoutSet)

    var identity: String {
        switch self {
        case let .summary(record):
            return "summary_\(record.date.timeIntervalSince1970)"
        case let .set(index, _):
            return "set_\(index)"
        }
    }
}

// MARK: - 타입에 사용할 typealias
typealias RecordDetailSectionModel = AnimatableSectionModel<RecordDetailSection, RecordDetailSectionItem>
