# 🛠️ SplitSnap — Technical & Architecture Guide (For Senior Devs / Agent)

> **AI Assistant in Xcode**: For a complete, machine-readable system context, guidelines, and roadmap, also see [`AI_CONTEXT.md`](AI_CONTEXT.md) at the project root.
> 
> **Document Purpose**: Complete engineering documentation, architectural design decisions, data flow contracts, and expansion protocols for SplitSnap.

---

## 1. System Architecture Overview

SplitSnap follows the **MVVM-S (Model-View-ViewModel-Service)** pattern leveraging modern **Swift 5.9+ and iOS 17+** declarative paradigms:

```
┌────────────────────────────────────────────────────────┐
│                   UI Layer (SwiftUI)                   │
│   HomeView  ◄──►  ItemClaimView  ◄──►  SplitSummaryView│
└───────────────────────────▲────────────────────────────┘
                            │ (Binds via @Observable)
┌───────────────────────────▼────────────────────────────┐
│                  ViewModel Layer                       │
│              BillSplitterViewModel                     │
│  - Reactive state management                           │
│  - Item assignment mutation                            │
│  - Mathematical calculation dispatch                   │
└───────────────────────────▲────────────────────────────┘
                            │ (Invokes)
┌───────────────────────────┴────────────────────────────┐
│                    Service Layer                       │
│  ┌──────────────────────┐    ┌──────────────────────┐  │
│  │    ReceiptScanner    │    │ PaymentProviderStack │  │
│  │ (Vision OCR pipeline)│    │ (Deep-link & shares) │  │
│  └──────────────────────┘    └──────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

---

## 2. Core Domain Models (`Sources/Models/`)

### `Person`
Represents an individual in the bill pool:
- `id: UUID`: Stable unique identifier.
- `name: String`: Display name.
- `venmoHandle: String`: Optional `@handle` used by payment providers.
- `colorHex: String`: Hex code converted to dynamic SwiftUI `Color` for visual identification chips.

### `ReceiptItem`
Represents a line item from a receipt:
- `assignedPersonIds: Set<UUID>`: Set of friends claiming this item.
- `splitCount: Int`: Computed `max(1, assignedPersonIds.count)`.
- `pricePerPerson: Double`: Computed `price / splitCount`.

### `Receipt`
The root expense model:
- `category: BillCategory`: Categorization (`.restaurant`, `.groceries`, `.rent`, `.utilities`, `.travel`, `.custom`).
- `items: [ReceiptItem]`: Itemized array.
- `taxAmount: Double`: Total sales tax.
- `tipPercentage: Double` / `customTipAmount: Double?`: Configurable gratuity.

### `PersonBillSummary` (Mathematical Engine)
Computes an individual’s exact share based on **proportional distribution**:
$$\text{TaxShare}_i = \text{TotalTax} \times \left( \frac{\text{Subtotal}_i}{\text{TotalSubtotal}} \right)$$
$$\text{TipShare}_i = \text{TotalTip} \times \left( \frac{\text{Subtotal}_i}{\text{TotalSubtotal}} \right)$$
$$\text{TotalOwed}_i = \text{Subtotal}_i + \text{TaxShare}_i + \text{TipShare}_i$$

---

## 3. Apple Vision OCR Pipeline (`ReceiptScanner.swift`)

The OCR engine processes images strictly **on-device**:
1. Converts `UIImage` to `CGImage`.
2. Instantiates `VNRecognizeTextRequest` with `.accurate` recognition level and language correction.
3. Iterates over `[VNRecognizedTextObservation]` top candidate strings.
4. Regex pattern matching `#"\$?\s*(\d{1,4}[.,]\d{2})\b"#` separates item names from dollar amounts.
5. Auto-classifies `"Tax"`, `"Subtotal"`, `"Tip"`, and `"Total"` keywords to prevent line-item contamination.

---

## 4. Extensibility Guide: How to Add New Features

### A. How to Add a New Payment Provider (e.g. Zelle, PayPal)
1. Navigate to `Sources/Services/PaymentProviders/PaymentProvider.swift`.
2. Implement the `PaymentProvider` protocol:
   ```swift
   public struct ZellePaymentProvider: PaymentProvider {
       public let id = "zelle"
       public let displayName = "Zelle"
       public let iconName = "bolt.circle.fill"
       public let brandColor = Color.purple

       public func makeChargeURL(for summary: PersonBillSummary, merchant: String) -> URL? {
           // Return custom URL scheme or universal web link
       }
       public func makeShareText(for summary: PersonBillSummary, merchant: String) -> String {
           // Return custom SMS/WhatsApp text
       }
   }
   ```
3. Register the new provider in `PaymentProviderRegistry.shared.availableProviders`.

### B. How to Add Roommate Rent / Utility Splitting
1. Notice `BillCategory` already defines `.rent` and `.utilities`.
2. To add custom split mechanics (like splitting rent by room square footage):
   - Add a `splitRule: SplitRule` enum to `ReceiptItem`.
   - Update `PersonBillSummary` to evaluate custom weight factors.

---

## 5. Coding Standards & Conventions
- **Observation**: Always use Swift 5.9 `@Observable` rather than legacy Combine `@Published` / `ObservableObject`.
- **Platform Separation**: UIKit-dependent code is protected via `#if canImport(UIKit)`.
- **Zero Third-Party Dependencies**: SplitSnap has zero external CocoaPods or SPM dependencies, guaranteeing clean builds and fast compilation.
