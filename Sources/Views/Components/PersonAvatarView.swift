import SwiftUI

public struct PersonAvatarView: View {
    public let person: Person
    public var isSelected: Bool
    public var showName: Bool
    public var size: CGFloat

    public init(person: Person, isSelected: Bool = false, showName: Bool = true, size: CGFloat = 52) {
        self.person = person
        self.isSelected = isSelected
        self.showName = showName
        self.size = size
    }

    public var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(person.color)
                    .frame(width: size, height: size)

                Text(person.initials)
                    .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                if isSelected {
                    Circle()
                        .stroke(Color.primary, lineWidth: 3)
                        .frame(width: size + 8, height: size + 8)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

            if showName {
                Text(person.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)
            }
        }
    }
}
