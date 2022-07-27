//
//  Helpers.swift
//  MovieDB
//
//  Created by allie on 13/7/2022.
//

import Foundation

enum FileSize {
    case original
    case face(w: Int, h: Int)
    case multiFaces(w: Int, h: Int)
    case best(w: Int, h: Int)
    case duotone(w: Int, h: Int, filter: String = "032541,01b4e4")

    var rawValue: String {
        switch self {
        case .original:
            return "original"
            
        case .face(let w, let h):
            return "w\(w)_and_h\(h)_face"
            
        case .multiFaces(let w, let h):
            return "w\(w)_and_h\(h)_multi_faces"
            
        case .best(w: let w, h: let h):
            return "w\(w)_and_h\(h)_bestv2"
            
        case let .duotone(w, h, filter):
            return "w\(w)_and_h\(h)_multi_faces_filter(duotone,\(filter))"
        }
    }
}

extension String {
    static let baseURL = "https://api.themoviedb.org/3"

    func imagePath(_ fileSize: FileSize = .face(w: 440, h: 660)) -> String {
        "https://image.tmdb.org/t/p/\(fileSize.rawValue)\(self)"
    }
}

let defaultQueryItems = [
    URLQueryItem(name: "api_key", value: ""),
    URLQueryItem(name: "language", value: "zh"),
    URLQueryItem(name: "include_image_language", value: "en,null"),
]

extension URL {
    
    /// 生成热门请求链接
    /// - Parameters:
    ///   - mediaType: 类型, .all 不可用
    ///   - page: 页码数
    /// - Returns: 请求链接
    static func popular(mediaType: MediaType, page: Int = 1) -> URL {
        url(
            paths: [
                mediaType.rawValue,
                "popular",
            ],
            queryItems: ["page": page]
        )
    }
    
    /// 生成趋势请求链接
    /// - Parameters:
    ///   - mediaType: 类型
    ///   - timeWindow: 时间
    ///   - page: 页码数
    /// - Returns: 请求链接
    static func trending(mediaType: MediaType, timeWindow: TimeWindow, page: Int = 1) -> URL {
        url(
            paths: [
                "trending",
                mediaType.rawValue,
                timeWindow.rawValue
            ],
            queryItems: ["page": page]
        )
    }
    
    /// 生成详情请求链接
    /// - Parameters:
    ///   - mediaType: 类型
    ///   - id: id
    /// - Returns: 请求链接
    static func details(mediaType: MediaType, id: Int, appendToResponse: AppendToResponse...) -> URL {
        url(
            paths: [mediaType.rawValue, id],
            queryItems: [
                "append_to_response": appendToResponse.map { $0.rawValue }.joined(separator: ",")
            ]
        )
    }
    
    private static func url(paths: [Any], queryItems: [String: Any]) -> URL {
        var url = URL(string: .baseURL)!
        paths.map { "\($0)" }.forEach { url.append(path: $0) }
        url.append(
            queryItems: defaultQueryItems + queryItems
                .mapValues { "\($0)" }
                .map(URLQueryItem.init)
        )
        return url
    }
}

extension Date {
    
    func string(_ localizedDateFormatFromTemplates: String..., locale identifier: String? = Locale.preferredLanguages.first) -> String {
        let dateFormatter = DateFormatter()
        let template = localizedDateFormatFromTemplates.reduce(into: "") { $0 += $1 }
        dateFormatter.locale = Locale(identifier: identifier ?? "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate(template)
        return dateFormatter.string(from: self)
    }
}
