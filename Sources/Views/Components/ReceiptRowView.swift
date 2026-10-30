import SwiftUI

public struct ReceiptRowView: View {
    public let item: ReceiptItem
    public let allPeople: [Person]
    public let activePerson: Person?
    public let onToggleActivePerson: () -> Void
    public let onSplitAll: () -> Void

    public init(
        item: ReceiptItem,
        allPeople: [Person],
        activePerson: Person?,
        onToggleActivePerson: @escaping () -> Void,
        onSplitAll: @escaping () -> Void
    ) {
        self.item = item
        self.allPeople = allPeople
        self.activePerson = activePerson
        self.onToggleActivePerson = onToggleActivePerson
        self.onSplitAll = onSplitAll
    }

    private var assignedPeople: [Person] {
        allPeople.filter { item.assignedPersonIds.contains($0.id) }
    }

    private var isAssignedToActive: Bool {
        guard let active = activePerson else { return false }
        return item.assignedPersonIds.contains(active.id)
    }

    public var body: some View {
        Button(action: onToggleActivePerson) {
            HStack(alignment: .center, spacing: 14) {
                // Checkmark / Claim Indicator
                ZStack {
                    Circle()
                        .stroke(isAssignedToActive ? (activePerson?.color ?? .blue) : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 26, height: 26)

                    if isAssignedToActive {
                        Circle()
                            .fill(activePerson?.color ?? .blue)
                            .frame(width: 16, height: 16)
                    }
                }

                // Item info
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    if assignedPeople.isEmpty {
                        Text("Tap to assign to \(activePerson?.name ?? "someone")")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        // People sharing this item
                        HStack(spacing: 4) {
                            ForEach(assignedPeople) { p in
                                HStack(spacing: 3) {
                                    Circle()
                                        .fill(p.color)
                                        .frame(width: 8, height: 8)
                                    Text(p.name)
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(p.color.opacity(0.12))
                                .clipShape(Capsule())
                            }

                            if item.splitCount > 1 {
                                Text("($\(String(format: "%.2f", item.pricePerPerson)) ea)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Spacer()

                // Price & Split All Button
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", item.price))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Button(action: onSplitAll) {
                        Text(item.assignedPersonIds.count == allPeople.count ? "Unsplit" : "Split All")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
