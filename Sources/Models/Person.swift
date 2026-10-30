import SwiftUI

public struct Person: Identifiable, Hashable, Codable {
    public var id: UUID
    public var name: String
    public var venmoHandle: String
    public var colorHex: String

    public init(id: UUID = UUID(), name: String, venmoHandle: String = "", colorHex: String? = nil) {
        self.id = id
        self.name = name
        self.venmoHandle = venmoHandle
        self.colorHex = colorHex ?? Self.randomColorHex()
    }

    public var color: Color {
        Color(hex: colorHex)
    }

    public var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2, let first = parts.first?.first, let second = parts.last?.first {
            return "\(first)\(second)".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private static let presetColors: [String] = [
        "#007AFF", // Blue
        "#34C759", // Green
        "#FF9500", // Orange
        "#AF52DE", // Purple
        "#FF2D55", // Pink
        "#5856D6", // Indigo
        "#00C7BE", // Teal
        "#FF3B30"  // Red
    ]

    public static func randomColorHex() -> String {
        presetColors.randomElement() ?? "#007AFF"
    }
}

// Color hex helper
extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 122, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
