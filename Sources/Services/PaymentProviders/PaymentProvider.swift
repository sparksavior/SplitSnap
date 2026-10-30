import SwiftUI

/// Protocol defining any external payment method (Venmo, Cash App, Apple Cash, Zelle).
/// Designed modularly so you can add new payment networks in the future by creating
/// a new struct that conforms to this protocol without modifying existing views!
public protocol PaymentProvider {
    var id: String { get }
    var displayName: String { get }
    var iconName: String { get }
    var brandColor: Color { get }

    func makeChargeURL(for summary: PersonBillSummary, merchant: String) -> URL?
    func makeShareText(for summary: PersonBillSummary, merchant: String) -> String
}

// MARK: - Venmo Provider
public struct VenmoPaymentProvider: PaymentProvider {
    public let id = "venmo"
    public let displayName = "Venmo"
    public let iconName = "dollarsign.circle.fill"
    public let brandColor = Color(hex: "#008CFF")

    public init() {}

    public func makeChargeURL(for summary: PersonBillSummary, merchant: String) -> URL? {
        let cleanHandle = summary.person.venmoHandle
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "@", with: "")

        let amountString = String(format: "%.2f", summary.totalOwed)
        let note = "SplitSnap: \(merchant) (\(summary.summaryDescription))"

        var components = URLComponents()
        components.scheme = "venmo"
        components.host = "paycharge"
        components.queryItems = [
            URLQueryItem(name: "txn", value: "charge"),
            URLQueryItem(name: "recipients", value: cleanHandle.isEmpty ? nil : cleanHandle),
            URLQueryItem(name: "amount", value: amountString),
            URLQueryItem(name: "note", value: note)
        ]

        return components.url
    }

    public func makeShareText(for summary: PersonBillSummary, merchant: String) -> String {
        let amount = String(format: "%.2f", summary.totalOwed)
        let subtotal = String(format: "%.2f", summary.itemsSubtotal)
        let tax = String(format: "%.2f", summary.taxShare)
        let tip = String(format: "%.2f", summary.tipShare)

        return """
        🧾 SplitSnap Bill for \(summary.person.name)
        Venue: \(merchant)
        Items: \(summary.summaryDescription) (Subtotal: $\(subtotal))
        Tax Share: $\(tax) | Tip Share: $\(tip)
        👉 Total Owed: $\(amount) (via Venmo)
        """
    }
}

// MARK: - Cash App Provider
public struct CashAppPaymentProvider: PaymentProvider {
    public let id = "cashapp"
    public let displayName = "Cash App"
    public let iconName = "dollarsign.square.fill"
    public let brandColor = Color(hex: "#00D632")

    public init() {}

    public func makeChargeURL(for summary: PersonBillSummary, merchant: String) -> URL? {
        let cleanCashtag = summary.person.venmoHandle // Can be used for cashtag as well
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "$", with: "")

        let amountString = String(format: "%.2f", summary.totalOwed)
        guard !cleanCashtag.isEmpty else { return nil }

        // Cash App URL scheme: https://cash.app/$cashtag/amount
        return URL(string: "https://cash.app/$\(cleanCashtag)/\(amountString)")
    }

    public func makeShareText(for summary: PersonBillSummary, merchant: String) -> String {
        let amount = String(format: "%.2f", summary.totalOwed)
        return """
        🧾 SplitSnap Bill for \(summary.person.name)
        Total: $\(amount) for \(merchant).
        Pay via Cash App!
        """
    }
}

// MARK: - Provider Registry
public class PaymentProviderRegistry {
    public static let shared = PaymentProviderRegistry()

    public let availableProviders: [PaymentProvider] = [
        VenmoPaymentProvider(),
        CashAppPaymentProvider()
    ]

    public var defaultProvider: PaymentProvider {
        availableProviders.first ?? VenmoPaymentProvider()
    }
}
