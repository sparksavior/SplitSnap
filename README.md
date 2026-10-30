# 🧾 SplitSnap — The Smart iOS Bill & Receipt Splitter

> **Privacy-First, On-Device Receipt OCR & Instant Venmo Settle-Up for iOS 17+**

---

## 🌟 Why SplitSnap?
SplitSnap solves the frustration of post-dinner group math without the ads, paywalls, or privacy-invasive cloud uploads of older apps like Splitwise:
- **100% On-Device Apple Vision OCR**: Point your camera or pick a receipt photo. Apple's native Neural Engine extracts all items, subtotals, and taxes on-device with zero server delay.
- **Visual Item Assignment**: Tap friend avatar chips (You, Alex, Sam, etc.) and tap dishes to claim or split evenly.
- **True Proportional Tax & Tip**: Fair distribution where each person's tax and tip match their exact share of the meal.
- **1-Tap Venmo Deep Linking**: Generates native `venmo://paycharge` links pre-filled with the exact cents and item notes.

---

## 🏗️ Architecture & Modern iOS Stack

```
Sources/
├── Models/
│   ├── Person.swift             # Friend identity, avatar colors, Venmo handles
│   ├── ReceiptItem.swift        # Item name, price, multi-person split math
│   ├── Receipt.swift            # Subtotal, tax, tip configuration
│   └── PersonBillSummary.swift  # Individual breakdown & owed math
├── Services/
│   ├── ReceiptScanner.swift     # Apple Vision (VNRecognizeTextRequest) parser
│   └── VenmoLinkBuilder.swift   # Universal & native app deep-link generator
├── ViewModels/
│   └── BillSplitterViewModel.swift # @Observable state management
└── Views/
    ├── HomeView.swift           # Dashboard & quick actions
    ├── ReceiptScannerView.swift # Vision photo scanner & simulator demo
    ├── ItemClaimView.swift      # Interactive multi-person dish claiming
    ├── TipTaxAdjusterView.swift # Tip percentage slider & tax editor
    ├── SplitSummaryView.swift   # Final breakdown & Venmo charge links
    └── Components/              # Modular UI components (Avatars, Rows)
```

---

## 🚀 How to Open and Run in Xcode

1. Open **Xcode** on your Mac.
2. Go to **File** > **Open...** (or double-click the `Package.swift` file in `/Users/nikhil/Documents/SplitSnap`).
3. Select an iOS Simulator (e.g., **iPhone 16 Pro**).
4. Press `Cmd + R` to build and run!
5. In the simulator, tap **"Scan Receipt"** -> **"Load Sample Receipt (Simulator Demo)"** to instantly test the flow without needing physical camera hardware.

---

## 💼 Resume & Interview Talking Points

When demonstrating this project in interviews:
1. **Apple Vision Framework**: Explain how `VNRecognizeTextRequest` parses receipt lines at 60 FPS using regex boundary detection for numbers and currency.
2. **SwiftUI State Management**: Highlight the `@Observable` macro (iOS 17+ Observation framework) replacing legacy `ObservableObject` and `@Published`.
3. **URL Scheme Deep Linking**: Explain how the app constructs deep links to external apps (`venmo://paycharge`) with graceful fallbacks.
4. **Clean Code & Modularity**: Point to the separation of concern between the Parser service, the reactive View Model, and the modular Views.
