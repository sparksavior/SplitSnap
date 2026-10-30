import SwiftUI

public struct TipTaxAdjusterView: View {
    @Bindable public var viewModel: BillSplitterViewModel

    private let tipPercentages: [Double] = [15.0, 18.0, 20.0, 25.0]

    public init(viewModel: BillSplitterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tip & Tax")
                .font(.headline)

            // Tip Selector
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Tip:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", viewModel.receipt.effectiveTipAmount)) (\(Int(viewModel.receipt.tipPercentage))%)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                HStack(spacing: 8) {
                    ForEach(tipPercentages, id: \.self) { pct in
                        Button(action: {
                            viewModel.receipt.customTipAmount = nil
                            viewModel.receipt.tipPercentage = pct
                        }) {
                            Text("\(Int(pct))%")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(viewModel.receipt.customTipAmount == nil && viewModel.receipt.tipPercentage == pct ? Color.blue : Color(UIColor.tertiarySystemGroupedBackground))
                                .foregroundStyle(viewModel.receipt.customTipAmount == nil && viewModel.receipt.tipPercentage == pct ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }

            Divider()

            // Tax and Total Summary
            HStack {
                Text("Tax:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("$\(String(format: "%.2f", viewModel.receipt.taxAmount))")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            HStack {
                Text("Bill Grand Total:")
                    .font(.headline)
                Spacer()
                Text("$\(String(format: "%.2f", viewModel.receipt.grandTotal))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
