import Foundation

enum AppError: LocalizedError {
    case noInternet
    case serverError(String)
    case decodingError
    case contentNotAvailable
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .noInternet:
            return L10n.AppErrors.noInternet
        case .serverError(let msg):
            return L10n.AppErrors.serverError + "\(msg)"
        case .decodingError:
            return L10n.AppErrors.decodingError
        case .contentNotAvailable:
            return L10n.AppErrors.contentNotAvailable
        case .unknown:
            return L10n.AppErrors.unknown
        }
    }
}
