import SwiftUI
import Combine

@Observable
public class BillSplitterViewModel {
    public var receipt: Receipt
    public var people: [Person]
    public var selectedPersonId: UUID?
    public var isScanning: Bool = false
    public var scannerError: String?

    public init() {
        let initialPeople = [
            Person(name: "You", venmoHandle: "@you"),
            Person(name: "Alex", venmoHandle: "@alex-99", colorHex: "#FF9500"),
            Person(name: "Sam", venmoHandle: "@sam_w", colorHex: "#34C759"),
            Person(name: "Taylor", venmoHandle: "@taylor_m", colorHex: "#AF52DE")
        ]
        self.people = initialPeople
        self.selectedPersonId = initialPeople.first?.id

        // Pre-load with sample restaurant receipt
        let sample = ReceiptScanner.sampleScannedData
        self.receipt = Receipt(
            merchantName: sample.merchantName,
            items: sample.items,
            taxAmount: sample.tax,
            tipPercentage: 18.0
        )

        // Pre-assign a couple items so the UI immediately looks alive
        if let first = people.first, let second = people.dropFirst().first {
            if receipt.items.indices.contains(0) {
                receipt.items[0].assignedPersonIds.insert(first.id)
            }
            if receipt.items.indices.contains(1) {
                receipt.items[1].assignedPersonIds.insert(second.id)
            }
            if receipt.items.indices.contains(2) {
                // Shared appetizer between both
                receipt.items[2].assignedPersonIds.insert(first.id)
                receipt.items[2].assignedPersonIds.insert(second.id)
            }
        }
    }

    public var summaries: [PersonBillSummary] {
        people.map { person in
            PersonBillSummary(person: person, receipt: receipt)
        }
    }

    public var selectedPerson: Person? {
        people.first(where: { $0.id == selectedPersonId })
    }

    // Toggle assigning an item to the currently selected person
    public func toggleItemForSelectedPerson(itemId: UUID) {
        guard let personId = selectedPersonId else { return }
        toggleAssignment(itemId: itemId, personId: personId)
    }

    public func toggleAssignment(itemId: UUID, personId: UUID) {
        guard let index = receipt.items.firstIndex(where: { $0.id == itemId }) else { return }
        if receipt.items[index].assignedPersonIds.contains(personId) {
            receipt.items[index].assignedPersonIds.remove(personId)
        } else {
            receipt.items[index].assignedPersonIds.insert(personId)
        }
    }

    public func splitItemEvenlyAmongAll(itemId: UUID) {
        guard let index = receipt.items.firstIndex(where: { $0.id == itemId }) else { return }
        let allIds = Set(people.map { $0.id })
        if receipt.items[index].assignedPersonIds == allIds {
            receipt.items[index].assignedPersonIds.removeAll()
        } else {
            receipt.items[index].assignedPersonIds = allIds
        }
    }

    public func addPerson(name: String, venmo: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newPerson = Person(name: trimmed, venmoHandle: venmo)
        people.append(newPerson)
        selectedPersonId = newPerson.id
    }

    public func removePerson(id: UUID) {
        people.removeAll(where: { $0.id == id })
        for i in receipt.items.indices {
            receipt.items[i].assignedPersonIds.remove(id)
        }
        if selectedPersonId == id {
            selectedPersonId = people.first?.id
        }
    }

    public func applyScannedData(_ data: ScannedReceiptData) {
        self.receipt = Receipt(
            merchantName: data.merchantName,
            items: data.items,
            taxAmount: data.tax,
            tipPercentage: 18.0
        )
    }

    public func resetBill() {
        self.receipt = Receipt()
    }
}
