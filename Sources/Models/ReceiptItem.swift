import Foundation

public struct ReceiptItem: Identifiable, Hashable, Codable {
    public var id: UUID
    public var name: String
    public var price: Double
    public var assignedPersonIds: Set<UUID>

    public init(id: UUID = UUID(), name: String, price: Double, assignedPersonIds: Set<UUID> = []) {
        self.id = id
        self.name = name
        self.price = price
        self.assignedPersonIds = assignedPersonIds
    }

    public var isAssigned: Bool {
        !assignedPersonIds.isEmpty
    }

    public var splitCount: Int {
        max(1, assignedPersonIds.count)
    }

    public var pricePerPerson: Double {
        guard !assignedPersonIds.isEmpty else { return price }
        return price / Double(assignedPersonIds.count)
    }
}
