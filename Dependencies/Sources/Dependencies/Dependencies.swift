import Foundation
import ComposableArchitecture

public extension Int {
    var int16: Int16 { Int16(self) }
    var int32: Int32 { Int32(self) }
    
    var string: String { "\(self)" }
}

public extension Int16 {
    var int: Int { Int(self) }
}

public extension Int32 {
    var int: Int { Int(self) }
    var string: String { "\(self)" }
}

public extension Double {
    
    /// Double 转 String
    /// - Parameters:
    ///   - maxSuffix: 最多显示的小数点位数
    ///   - short: 是否抹0
    /// - Returns: Double String
    func decimalFormat(maxSuffix: Int = 2, short: Bool = true) -> String {
        let fm = NumberFormatter()
        fm.numberStyle = .decimal
        fm.usesGroupingSeparator = false
        fm.minimumFractionDigits = short ? 0 : maxSuffix
        fm.maximumFractionDigits = maxSuffix
        fm.roundingIncrement = 0.01

        return fm.string(from: NSNumber(value: self)) ?? ""
    }
}

public extension String {
    var int: Int? { Int(self) }
    var int32: Int32? { Int32(self) }
    var double: Double? { Double(self) }
}

public extension Optional where Wrapped == String {
    
    var orEmpty: String {
        self ?? ""
    }
}

public extension Optional where Wrapped == Int {
    
    var orZero: Int {
        self ?? 0
    }
}

public extension Optional where Wrapped == Double {
    
    var orZero: Double {
        self ?? 0
    }
}

typealias UUIDArrayOf<Element> = IdentifiedArray<UUID?, Element> where Element: Identifiable

public extension Sequence {
    
    /// 移除重复 element，保留原顺序。
    /// - Returns: [Element]
    func unique() -> [Element] where Element: Hashable {
        var seen: Set<Element> = []
        return filter({ (element) -> Bool in
            if seen.contains(element) {
                return false
            } else {
                seen.insert(element)
                return true
            }
        })
    }

    /// 移除重复 keyPath 的 element，保留原顺序。
    /// - Returns: [Element]
    func unique<T>(_ keyPath: KeyPath<Element, T>) -> [Element] where T: Hashable {
        var seen: Set<T> = []
        return filter { element in
            let id = element[keyPath: keyPath]
            if seen.contains(where: { id == $0 }) {
                return false
            } else {
                seen.insert(id)
                return true
            }
        }
    }
}

public enum DateFormatHit {
    case none
    case RFC822
    case RFC3339
}


public extension Date {
    
    /// 判断是否超时
    /// - Parameters:
    ///   - other: 对比时间
    ///   - interval: 间隔；默认 600 秒
    /// - Returns: Bool
    func timeout(_ other: Date = Date(), interval: TimeInterval = 600) -> Bool {
        other.timeIntervalSinceReferenceDate - timeIntervalSinceReferenceDate > interval
    }
    
    static func internetDateTimeFormatter() -> DateFormatter {
        let locale = Locale(identifier: "en_US_POSIX")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }
    
    /// Get a date from a string - hint can be used to speed up
    static func dateFromInternet(dateString: String, format hint: DateFormatHit = .none) -> Date? {
        var date: Date?
        if hint != .RFC3339 {
            // try RFC822 first
            date = Date.dateFromRFC822(dateString: dateString)
            if date == nil {
                date = Date.dateFromRFC3339(dateString: dateString)
            }
            if date == nil {
                date = Date.dateFromNoneHit(dateString: dateString)
            }
        } else {
            //Try RFC3339 first
            date = Date.dateFromRFC3339(dateString: dateString)
            if (date == nil) {
                date = Date.dateFromRFC822(dateString: dateString)
            }
            if date == nil {
                date = Date.dateFromNoneHit(dateString: dateString)
            }
        }
        return date
    }
    
    // See http://www.faqs.org/rfcs/rfc822.html
    static func dateFromRFC822(dateString: String) -> Date? {
        var date: Date?
        let dateFormatter = Date.internetDateTimeFormatter()
        let RFC822String = dateString.uppercased()
        
        if (RFC822String.contains(",")) {
            if (date == nil) { // Sun, 19 May 2002 15:21:36 GMT
                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
                date = dateFormatter.date(from: RFC822String)
            }
            if (date == nil) { // Sun, 19 May 2002 15:21 GMT
                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm zzz"
                date = dateFormatter.date(from: RFC822String)
            }
            if (date == nil) { // Sun, 19 May 2002 15:21:36
                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss"
                date = dateFormatter.date(from: RFC822String)
            }
            if (date == nil) { // Sun, 19 May 2002 15:21
                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm"
                date = dateFormatter.date(from: RFC822String)
            }
        } else {
            if (date == nil) { // 19 May 2002 15:21:36 GMT
                dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss zzz"
                date = dateFormatter.date(from: RFC822String)
            }
            if (date == nil) { // 19 May 2002 15:21 GMT
                dateFormatter.dateFormat = "d MMM yyyy HH:mm zzz"
                date = dateFormatter.date(from: RFC822String)
            }
            if (date == nil) { // 19 May 2002 15:21:36
                dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss"
                date = dateFormatter.date(from: RFC822String)
            }
            if (date == nil) { // 19 May 2002 15:21
                dateFormatter.dateFormat = "d MMM yyyy HH:mm"
                date = dateFormatter.date(from: RFC822String)
            }
        }
        return date
    }
    
    // See http://www.faqs.org/rfcs/rfc3339.html
    static func dateFromRFC3339(dateString: String) -> Date? {
        var date: Date?
        let dateFormatter = Date.internetDateTimeFormatter()
        var RFC3339String = dateString.uppercased()
        RFC3339String = RFC3339String.replacingOccurrences(of: "Z", with: "-0000")
        if (RFC3339String.count > 20) {
            RFC3339String = (RFC3339String as NSString).replacingOccurrences(of: ":", with: "", options: NSString.CompareOptions(rawValue: 0), range: NSMakeRange(0, RFC3339String.count - 20)) as String
        }
        if (date == nil) { // 1996-12-19T16:39:57-0800
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
            date = dateFormatter.date(from: RFC3339String)
        }
        if (date == nil) { // 1937-01-01T12:00:27.87+0020
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"
            date = dateFormatter.date(from: RFC3339String)
        }
        if (date == nil) { // 1937-01-01T12:00:27
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
            date = dateFormatter.date(from: RFC3339String)
        }
        return date
    }
    
    static func dateFromNoneHit(dateString: String) -> Date? {
        var date: Date?
        let dateFormatter = Date.internetDateTimeFormatter()
        let string = dateString.uppercased()
        
        if date == nil {
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd HH':'mm':'ss ZZZ"
            date = dateFormatter.date(from: string)
        }
        
        return date
    }
    
    struct DateFormats: ExpressibleByStringLiteral {

        let rawValue: String
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            rawValue = value
        }
        
        /// 12:34
        public static let HHmm: DateFormats = "HH:mm"
        /// January
        public static let MMMM: DateFormats = "MMMM"
        /// Jan
        public static let MMM: DateFormats = "MMM"
        /// 2019
        public static let yyyy: DateFormats = "yyyy"
        /// 09
        public static let dd: DateFormats = "dd"
        /// Tuesday
        public static let EEEE: DateFormats = "EEEE"
        /// Tue
        public static let E: DateFormats = "E"
    }
    
    func string(_ localizedDateFormatFromTemplates: DateFormats..., locale identifier: String? = Locale.preferredLanguages.first) -> String {
        let dateFormatter = DateFormatter()
        let template = localizedDateFormatFromTemplates.reduce(into: "") { $0 += $1.rawValue }
        dateFormatter.locale = Locale(identifier: identifier ?? "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate(template)
        return dateFormatter.string(from: self)
    }
}

public extension NSPredicate {
    
    /// 生成 NSPredicate，小于或等于时间
    /// - Parameter date: 时间
    /// - Returns: NSPredicate
    static func dateLessThanOrEquals(_ date: Date) -> NSPredicate {
        NSPredicate(format: "date <= %@", date as CVarArg)
    }
}
