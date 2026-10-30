import Foundation

public struct PersonBillSummary: Identifiable, Hashable {
    public var id: UUID { person.id }
    public let person: Person
    public let assignedItemsWithPortion: [(item: ReceiptItem, portion: Double, shareCost: Double)]
    public let itemsSubtotal: Double
    public let taxShare: Double
    public let tipShare: Double
    public let totalOwed: Double

    public init(
        person: Person,
        receipt: Receipt
    ) {
        self.person = person

        var itemsList: [(item: ReceiptItem, portion: Double, shareCost: Double)] = []
        var subtotal: Double = 0.0

        for item in receipt.items where item.assignedPersonIds.contains(person.id) {
            let portion = 1.0 / Double(item.splitCount)
            let cost = item.price * portion
            itemsList.append((item, portion, cost))
            subtotal += cost
        }

        self.assignedItemsWithPortion = itemsList
        self.itemsSubtotal = subtotal

        let totalSubtotal = max(0.01, receipt.subtotal)
        let ratio = subtotal / totalSubtotal

        self.taxShare = receipt.taxAmount * ratio
        self.tipShare = receipt.effectiveTipAmount * ratio
        self.totalOwed = subtotal + self.taxShare + self.tipShare
    }

    public var summaryDescription: String {
        let itemNames = assignedItemsWithPortion.map { entry in
            if entry.portion < 0.99 {
                let fraction = "1/\(Int(round(1.0 / entry.portion)))"
                return "\(fraction) \(entry.item.name)"
            }
            return entry.item.name
        }.joined(separator: ", ")

        return itemNames.isEmpty ? "No items selected" : itemNames
    }
}
