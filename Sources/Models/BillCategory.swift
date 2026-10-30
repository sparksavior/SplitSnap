import SwiftUI

/// Defines the category of expense being split.
/// Designed modularly so future updates can support specialized split logic
/// (e.g. Rent by square footage, utilities by days lived, travel Airbnb deposits).
public enum BillCategory: String, CaseIterable, Identifiable, Codable {
    case restaurant = "Dining & Drinks"
    case groceries = "Groceries & Supplies"
    case rent = "Rent & Housing"
    case utilities = "Utilities & Bills"
    case travel = "Trip & Travel"
    case custom = "General Split"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .groceries: return "cart.fill"
        case .rent: return "house.fill"
        case .utilities: return "bolt.fill"
        case .travel: return "airplane"
        case .custom: return "square.grid.2x2.fill"
        }
    }

    public var color: Color {
        switch self {
        case .restaurant: return .orange
        case .groceries: return .green
        case .rent: return .blue
        case .utilities: return .yellow
        case .travel: return .purple
        case .custom: return .indigo
        }
    }

    /// Whether this bill category typically carries a service tip
    public var supportsTip: Bool {
        switch self {
        case .restaurant: return true
        default: return false
        }
    }
}
