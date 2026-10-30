import SwiftUI

public struct SplitSummaryView: View {
    @Bindable public var viewModel: BillSplitterViewModel
    @State private var copiedPersonId: UUID?

    public init(viewModel: BillSplitterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Venue & Total Card
                VStack(spacing: 8) {
                    Text(viewModel.receipt.merchantName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Total Bill: $\(String(format: "%.2f", viewModel.receipt.grandTotal))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        Label("$\(String(format: "%.2f", viewModel.receipt.subtotal)) items", systemImage: "cart")
                        Label("$\(String(format: "%.2f", viewModel.receipt.taxAmount)) tax", systemImage: "percent")
                        Label("$\(String(format: "%.2f", viewModel.receipt.effectiveTipAmount)) tip", systemImage: "heart")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // Individual Breakdowns
                ForEach(viewModel.summaries) { summary in
                    VStack(alignment: .leading, spacing: 12) {
                        // Person Header
                        HStack(spacing: 12) {
                            PersonAvatarView(person: summary.person, showName: false, size: 40)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(summary.person.name)
                                    .font(.headline)
                                if !summary.person.venmoHandle.isEmpty {
                                    Text(summary.person.venmoHandle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Text("$\(String(format: "%.2f", summary.totalOwed))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(summary.person.color)
                        }

                        Divider()

                        // Assigned items list
                        VStack(spacing: 6) {
                            ForEach(summary.assignedItemsWithPortion, id: \.item.id) { entry in
                                HStack {
                                    Text(entry.portion < 0.99 ? "\(entry.item.name) (1/\(Int(round(1.0 / entry.portion))))" : entry.item.name)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", entry.shareCost))")
                                        .font(.subheadline)
                                }
                            }

                            HStack {
                                Text("+ Tax & Tip Share")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("+$\(String(format: "%.2f", summary.taxShare + summary.tipShare))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Action Buttons: Venmo & Share
                        HStack(spacing: 10) {
                            if let venmoURL = VenmoLinkBuilder.makeChargeURL(for: summary, merchant: viewModel.receipt.merchantName) {
                                Link(destination: venmoURL) {
                                    HStack {
                                        Image(systemName: "dollarsign.circle.fill")
                                        Text("Charge on Venmo")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }

                            ShareLink(item: VenmoLinkBuilder.makeShareText(for: summary, merchant: viewModel.receipt.merchantName)) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.subheadline)
                                    .padding(10)
                                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                                    .foregroundStyle(.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Split Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}
