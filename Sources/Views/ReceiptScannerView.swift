import SwiftUI
import PhotosUI

public struct ReceiptScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable public var viewModel: BillSplitterViewModel

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isProcessing = false
    @State private var errorMessage: String?

    public init(viewModel: BillSplitterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Scanner Graphic
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .frame(width: 220, height: 280)
                        .background(Color.blue.opacity(0.04))

                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue)

                        Text("Point camera at receipt or select a photo")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                if isProcessing {
                    ProgressView("Analyzing receipt with Apple Vision...")
                        .font(.subheadline)
                        .padding()
                }

                if let err = errorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Spacer()

                // Actions
                VStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Select Receipt from Photos")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            await processPhoto(newItem)
                        }
                    }

                    // Demo sample button for Simulator
                    Button(action: {
                        let sample = ReceiptScanner.sampleScannedData
                        viewModel.applyScannedData(sample)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Load Sample Receipt (Simulator Demo)")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Scan Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    #if canImport(UIKit)
    private func processPhoto(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        isProcessing = true
        errorMessage = nil

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                let scanner = ReceiptScanner()
                let result = try await scanner.scanImage(image)
                await MainActor.run {
                    viewModel.applyScannedData(result)
                    isProcessing = false
                    dismiss()
                }
            } else {
                throw ReceiptScanner.ScannerError.invalidImage
            }
        } catch {
            await MainActor.run {
                isProcessing = false
                errorMessage = error.localizedDescription
            }
        }
    }
    #endif
}
