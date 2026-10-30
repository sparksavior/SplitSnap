import SwiftUI

public struct HomeView: View {
    @State private var viewModel = BillSplitterViewModel()
    @State private var showScannerSheet = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero Card: Current / Active Bill
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ACTIVE BILL")
                                    .font(.caption2)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(.blue)

                                Text(viewModel.receipt.merchantName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }

                            Spacer()

                            Text("$\(String(format: "%.2f", viewModel.receipt.grandTotal))")
                                .font(.title3)
                                .fontWeight(.heavy)
                        }

                        // Progress: Items assigned
                        let totalCount = viewModel.receipt.items.count
                        let assignedCount = totalCount - viewModel.receipt.unassignedItems.count
                        let progress = totalCount > 0 ? Double(assignedCount) / Double(totalCount) : 0.0

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("\(assignedCount) of \(totalCount) items claimed")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(Int(progress * 100))%")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(progress == 1.0 ? .green : .blue)
                            }

                            ProgressView(value: progress)
                                .tint(progress == 1.0 ? .green : .blue)
                        }

                        Divider()

                        NavigationLink {
                            ItemClaimView(viewModel: viewModel)
                        } label: {
                            HStack {
                                Text("Claim & Split Items")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .foregroundStyle(.blue)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)

                    // Quick Actions Grid
                    HStack(spacing: 12) {
                        Button(action: {
                            showScannerSheet = true
                        }) {
                            VStack(alignment: .leading, spacing: 10) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.title)
                                    .foregroundStyle(.blue)

                                Text("Scan Receipt")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text("Use Apple Vision OCR to extract dishes & prices")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            ItemClaimView(viewModel: viewModel)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Image(systemName: "person.3.fill")
                                    .font(.title)
                                    .foregroundStyle(.green)

                                Text("Active Friends")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text("\(viewModel.people.count) friends ready to split this bill")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }

                    // Feature highlights / Resume showcase
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why SplitSnap is Built Different")
                            .font(.headline)

                        VStack(spacing: 10) {
                            FeatureRow(icon: "lock.shield.fill", color: .green, title: "100% On-Device & Private", desc: "Receipt OCR runs locally with Apple Vision. No photos ever leave your phone.")
                            FeatureRow(icon: "percent", color: .orange, title: "Proportional Tax & Tip", desc: "No more paying for your friend's wine tax. Tax & tip calculate proportionally.")
                            FeatureRow(icon: "link", color: .blue, title: "1-Tap Venmo Deep Links", desc: "Charges open directly inside Venmo with prefilled amounts and item notes.")
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("SplitSnap")
            .sheet(isPresented: $showScannerSheet) {
                ReceiptScannerView(viewModel: viewModel)
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
