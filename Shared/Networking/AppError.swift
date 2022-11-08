import Foundation

enum AppError: Error, Equatable, Identifiable {
    var id: String { localizedDescription }

    case badURL
    case error(Error)
    case sample(String?)
    
    static func ==(lhs: AppError, rhs: AppError) -> Bool {
        lhs.id == rhs.id
    }
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badURL: return "无效 URL"
        case .error(let error):
            return error.localizedDescription
        case .sample(let string):
            return string ?? ""
        }
    }
}
