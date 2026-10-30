import Foundation
import Vision
#if canImport(UIKit)
import UIKit
#endif

public struct ScannedReceiptData {
    public var merchantName: String
    public var items: [ReceiptItem]
    public var tax: Double
    public var subtotal: Double
}

public class ReceiptScanner {
    public init() {}

    #if canImport(UIKit)
    public func scanImage(_ image: UIImage) async throws -> ScannedReceiptData {
        guard let cgImage = image.cgImage else {
            throw ScannerError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: self.emptyResult())
                    return
                }

                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                let parsed = self.parseTextLines(lines)
                continuation.resume(returning: parsed)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    #endif

    public func parseTextLines(_ lines: [String]) -> ScannedReceiptData {
        var merchantName = "Restaurant Bill"
        var items: [ReceiptItem] = []
        var detectedTax: Double = 0.0
        var detectedSubtotal: Double = 0.0

        // Price regex matching numbers like 14.50, $12.00, 9.99
        let priceRegex = try? NSRegularExpression(pattern: #"\$?\s*(\d{1,4}[.,]\d{2})\b"#)

        for (index, line) in lines.enumerated() {
            let lower = line.lowercased()

            // Guess merchant from first non-trivial line
            if index == 0 && !line.isEmpty && merchantName == "Restaurant Bill" {
                merchantName = line.capitalized
            }

            // Extract price if present
            guard let regex = priceRegex,
                  let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
                  let priceRange = Range(match.range(at: 1), in: line) else {
                continue
            }

            let priceString = String(line[priceRange]).replacingOccurrences(of: ",", with: ".")
            guard let price = Double(priceString), price > 0 else { continue }

            // Clean item name by stripping the price portion
            var itemName = line
            if let fullMatchRange = Range(match.range(at: 0), in: line) {
                itemName.removeSubrange(fullMatchRange)
            }
            itemName = itemName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))

            // Classify special lines
            if lower.contains("tax") || lower.contains("hst") || lower.contains("vat") {
                detectedTax = price
            } else if lower.contains("subtotal") || lower.contains("sub total") {
                detectedSubtotal = price
            } else if lower.contains("total") || lower.contains("balance") || lower.contains("amount due") {
                // Ignore grand total line as an item
                continue
            } else if lower.contains("tip") || lower.contains("gratuity") {
                // Ignore tip line
                continue
            } else if !itemName.isEmpty {
                items.append(ReceiptItem(name: itemName, price: price))
            }
        }

        return ScannedReceiptData(
            merchantName: merchantName,
            items: items,
            tax: detectedTax > 0 ? detectedTax : (detectedSubtotal * 0.08875),
            subtotal: detectedSubtotal
        )
    }

    private func emptyResult() -> ScannedReceiptData {
        ScannedReceiptData(merchantName: "Scanned Receipt", items: [], tax: 0, subtotal: 0)
    }

    // Realistic Demo Receipt for iOS Simulator testing
    public static var sampleScannedData: ScannedReceiptData {
        ScannedReceiptData(
            merchantName: "Bella Italia Trattoria",
            items: [
                ReceiptItem(name: "Wood-Fired Margherita Pizza", price: 18.50),
                ReceiptItem(name: "Truffle Tagliatelle", price: 24.00),
                ReceiptItem(name: "Crispy Calamari", price: 16.00),
                ReceiptItem(name: "Aperol Spritz", price: 14.00),
                ReceiptItem(name: "Chianti Classico Glass", price: 13.50),
                ReceiptItem(name: "Tiramisu della Nonna", price: 9.50)
            ],
            tax: 8.48,
            subtotal: 95.50
        )
    }

    public enum ScannerError: LocalizedError {
        case invalidImage
        public var errorDescription: String? {
            "Unable to process this image. Please ensure the receipt is well-lit and in focus."
        }
    }
}
