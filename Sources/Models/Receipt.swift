import Foundation

public struct Receipt: Identifiable, Hashable, Codable {
    public var id: UUID
    public var merchantName: String
    public var category: BillCategory
    public var date: Date
    public var items: [ReceiptItem]
    public var taxAmount: Double
    public var tipPercentage: Double
    public var customTipAmount: Double?

    public init(
        id: UUID = UUID(),
        merchantName: String = "Dinner with Friends",
        category: BillCategory = .restaurant,
        date: Date = Date(),
        items: [ReceiptItem] = [],
        taxAmount: Double = 0.0,
        tipPercentage: Double = 18.0,
        customTipAmount: Double? = nil
    ) {
        self.id = id
        self.merchantName = merchantName
        self.category = category
        self.date = date
        self.items = items
        self.taxAmount = taxAmount
        self.tipPercentage = tipPercentage
        self.customTipAmount = customTipAmount
    }

    public var subtotal: Double {
        items.reduce(0.0) { $0 + $1.price }
    }

    public var effectiveTipAmount: Double {
        if let custom = customTipAmount {
            return custom
        }
        return subtotal * (tipPercentage / 100.0)
    }

    public var grandTotal: Double {
        subtotal + taxAmount + effectiveTipAmount
    }

    public var unassignedItems: [ReceiptItem] {
        items.filter { !$0.isAssigned }
    }

    public var isFullyAssigned: Bool {
        !items.isEmpty && unassignedItems.isEmpty
    }
}
