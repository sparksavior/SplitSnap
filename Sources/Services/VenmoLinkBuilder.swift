import Foundation

public struct VenmoLinkBuilder {
    public static func makeChargeURL(for summary: PersonBillSummary, merchant: String) -> URL? {
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

    public static func makeShareText(for summary: PersonBillSummary, merchant: String) -> String {
        let amount = String(format: "%.2f", summary.totalOwed)
        let subtotal = String(format: "%.2f", summary.itemsSubtotal)
        let tax = String(format: "%.2f", summary.taxShare)
        let tip = String(format: "%.2f", summary.tipShare)

        return """
        🧾 SplitSnap Bill for \(summary.person.name)
        Venue: \(merchant)
        Items: \(summary.summaryDescription) (Subtotal: $\(subtotal))
        Tax Share: $\(tax) | Tip Share: $\(tip)
        👉 Total Owed: $\(amount)
        """
    }
}
