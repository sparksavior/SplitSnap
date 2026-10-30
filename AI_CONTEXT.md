# 🤖 SplitSnap — Comprehensive Context for AI Coding Assistants

> **Instructions for the AI Assistant in Xcode:**  
> Read this document first. This file contains the complete system architecture, data models, business logic, mathematical formulas, and expansion roadmap for **SplitSnap**. Do not reinvent existing architecture—adhere strictly to the design patterns and protocols defined here.

---

## 1. Project Metadata
* **Project Name:** SplitSnap
* **Target OS:** iOS 17.0+, macOS 14.0+
* **Language & Frameworks:** Swift 5.9+, SwiftUI (modern declarative syntax), Apple Vision Framework (`VNRecognizeTextRequest`), Swift Observation (`@Observable`).
* **Dependencies:** **Zero external dependencies** (no CocoaPods, no SPM packages). Pure native Apple SDKs.
* **Active Git Identity:** `sparksavior` (`sparksavior@users.noreply.github.com`).
* **Root Location:** `/Users/nikhil/Documents/SplitSnap`
* **Entry Point:** `Package.swift` and `Sources/SplitSnapApp.swift`.

---

## 2. Core Mission & User Problem
Existing bill splitters (like Splitwise) are cluttered with ads, locked behind paid subscription paywalls, and upload receipts to third-party servers. SplitSnap provides:
1. **100% On-Device Apple Vision OCR**: Extracts dishes, prices, and tax from receipts using the Apple Neural Engine.
2. **Visual Friend Assignment**: Tap a friend’s avatar, then tap the dishes they shared.
3. **True Proportional Gratuity & Tax**: Friends who order an \$8 salad never pay the tax/tip for someone else's \$45 steak.
4. **1-Tap Payment Deep-Linking**: Generates native `venmo://paycharge` and Cash App links pre-filled with cents and item descriptions.

---

## 3. Complete Source File Index (`Sources/`)

```
Sources/
├── SplitSnapApp.swift                 # @main App entry point (WindowGroup with HomeView)
├── Models/
│   ├── Person.swift                   # ID, name, avatar hex color, initials, venmoHandle
│   ├── ReceiptItem.swift              # ID, name, price, assignedPersonIds (Set<UUID>), splitCount
│   ├── Receipt.swift                  # ID, merchantName, category, date, items, tax, tip %, grandTotal
│   ├── BillCategory.swift             # Enum: .restaurant, .groceries, .rent, .utilities, .travel, .custom
│   └── PersonBillSummary.swift        # Pure mathematical breakdown per individual
├── Services/
│   ├── ReceiptScanner.swift           # Vision OCR (VNRecognizeTextRequest) + Regex parser + Simulator Mock
│   ├── VenmoLinkBuilder.swift         # Legacy & direct URL scheme constructor for Venmo & SMS sharing
│   └── PaymentProviders/
│       └── PaymentProvider.swift      # Protocol-oriented payment rails (Venmo, Cash App, Registry)
├── ViewModels/
│   └── BillSplitterViewModel.swift    # Primary @Observable state manager coordinating active receipt & friends
└── Views/
    ├── HomeView.swift                 # Main dashboard, active bill progress card, feature highlights
    ├── ItemClaimView.swift            # The core dish-claiming interface with sticky friends bar
    ├── SplitSummaryView.swift         # Final per-person bill cards + Venmo charge triggers
    ├── TipTaxAdjusterView.swift       # Tip percentage buttons (15/18/20/25%) and tax summary
    ├── ReceiptScannerView.swift       # PhotosPicker sheet + Vision OCR trigger + Simulator Demo button
    └── Components/
        ├── PersonAvatarView.swift     # Circular initials avatar with dynamic selection border
        └── ReceiptRowView.swift       # Interactive line item row showing claim status & split pills
```

---

## 4. Architectural Rules & Guidelines for the AI

### Rule 1: State Management (Use `@Observable`, NEVER `ObservableObject`)
SplitSnap uses Apple's iOS 17 Observation framework.
* **Do NOT use** `@Published`, `ObservableObject`, or `@ObservedObject`.
* **Always use** the `@Observable` macro on ViewModels.
* In SwiftUI views, bind with `@Bindable var viewModel: BillSplitterViewModel` or `@State private var viewModel = BillSplitterViewModel()`.

### Rule 2: Multi-Person Dish Splitting Math
When an item is shared by $N$ friends:
$$\text{portion} = \frac{1.0}{N}$$
$$\text{itemShareCost} = \text{item.price} \times \text{portion}$$

### Rule 3: Proportional Tax & Tip Calculation
Grating and tax must never be split evenly if friends consumed unequal totals. In `PersonBillSummary.swift`:
$$\text{Individual Ratio} = \frac{\sum \text{Person's Item Costs}}{\text{Receipt Subtotal}}$$
$$\text{Individual Tax Share} = \text{Total Tax} \times \text{Individual Ratio}$$
$$\text{Individual Tip Share} = \text{Total Tip} \times \text{Individual Ratio}$$
$$\text{Individual Total Owed} = \text{Personal Subtotal} + \text{Tax Share} + \text{Tip Share}$$

### Rule 4: Pluggable Payment Rails (`PaymentProvider` Protocol)
To add a new payment method (e.g., Zelle, Apple Cash, PayPal):
1. Create a struct conforming to `PaymentProvider`:
   ```swift
   public protocol PaymentProvider {
       var id: String { get }
       var displayName: String { get }
       var iconName: String { get }
       var brandColor: Color { get }
       func makeChargeURL(for summary: PersonBillSummary, merchant: String) -> URL?
       func makeShareText(for summary: PersonBillSummary, merchant: String) -> String
   }
   ```
2. Append it to `PaymentProviderRegistry.shared.availableProviders`.

---

## 5. Next Steps Roadmap (What you can ask Xcode AI to build next)

When you are in Xcode talking to the AI, here are the immediate features ready to be implemented:

1. **Local History Persistence with SwiftData**:
   * Convert `Receipt` and `Person` into `@Model` classes so that past split bills are saved locally across app restarts.
2. **Rent & Roommate Expense Module**:
   * Add a segmented control on `HomeView` to switch between "Restaurant Bill" and "Roommate Rent / Utilities".
   * For Rent: allow splitting by custom percentages or room square footage.
3. **Live Camera Scanner (AVCaptureSession)**:
   * Currently, `ReceiptScannerView` uses `PhotosPicker` (photo library) and a **Simulator Demo Button**. Add an in-app live camera feed using `AVCaptureVideoDataOutput` for real-time receipt scanning.
4. **Dynamic Island / Live Activity**:
   * Show active bill status (e.g., "3 of 4 friends settled on Venmo") in the Dynamic Island via `ActivityKit`.

---

## 6. Testing in Xcode Simulator (No Camera Required)
If the user is running in the iOS Simulator on Mac:
1. Tap **"Scan Receipt"**.
2. Tap **"Load Sample Receipt (Simulator Demo)"**.
3. The sample data in `ReceiptScanner.sampleScannedData` will automatically populate the entire state with an authentic multi-item restaurant check.
