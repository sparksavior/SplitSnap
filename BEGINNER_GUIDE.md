# 📱 SplitSnap — The Absolute Beginner's Guide (Start Here!)

> **Hey there! 👋**  
> If you have never opened Xcode or written a line of Swift in your life, **this guide is for you**. No confusing technical jargon. Just clear, simple explanations of what this app is, how it works, and how to run it on your Mac.

---

## 1. What is SplitSnap? (The 10-Second Pitch)

Imagine you go out to dinner with 3 friends:
1. You snap a photo of the paper receipt with your iPhone.
2. The app **reads the words and numbers** right off the receipt automatically (no typing!).
3. You tap your friend **Alex** and tap the pizza. You tap **Sam** and tap the burger. You tap both of them on the appetizer to split it 50/50.
4. The app figures out everyone's exact share of tax and tip down to the penny.
5. Tap **"Charge on Venmo"** and it opens Venmo with the exact amount pre-filled!

---

## 2. The 3 Apple Words You Need to Know

| Word | What it means in plain English |
| :--- | :--- |
| **Xcode** | The giant workshop app made by Apple where you build, test, and run iPhone apps. (Think of it like Microsoft Word, but for building software). |
| **Swift** | The programming language Apple invented. It reads almost like English sentences. |
| **SwiftUI** | Apple's modern tool for designing screens. Instead of drawing buttons by hand, you write code like `Text("Hello")` or `Button("Click Me")` and Apple paints it on the screen. |

---

## 3. Where is the Code on Your Mac?

Everything is organized neatly inside your **Documents** folder:
📁 `/Users/nikhil/Documents/SplitSnap`

Here is what is inside:
```
SplitSnap/
├── Package.swift               👈 Double-click this to open the whole project in Xcode!
├── BEGINNER_GUIDE.md           👈 This file!
├── DEVELOPER_GUIDE.md          👈 The deep technical blueprint for me (the AI)
└── Sources/                    👈 All your app's screens and logic
    ├── SplitSnapApp.swift      👈 The "front door" where the app starts
    ├── Models/                 👈 The data (What is a Person? What is a Receipt Item?)
    ├── Services/               👈 The engine (The camera scanner & Venmo link maker)
    ├── ViewModels/             👈 The brain (Does the math and keeps track of who tapped what)
    └── Views/                  👈 The visual screens you see and touch on your phone
```

---

## 4. How to Run SplitSnap on Your Mac (Step-by-Step)

You already have Xcode installed! Here is how to run the app right now:

### Step 1: Open Xcode
Open **Xcode** from your Mac’s Applications folder or Spotlight search (`Cmd + Space` > type `Xcode`).

### Step 2: Open SplitSnap
In the top menu bar, click:
**File** > **Open...**  
Then navigate to:
`Documents` > `SplitSnap` > select the **`Package.swift`** file (or the `SplitSnap` folder) and click **Open**.

### Step 3: Pick a Virtual iPhone
Look at the very top bar of Xcode. You’ll see a dropdown next to the Play button that says something like **"My Mac"** or **"Any iOS Device"**.
* Click it and choose **iPhone 16 Pro** (or any iPhone simulator).

### Step 4: Click the Big ▶ Play Button!
Click the **Play ▶ button** in the top-left corner (or press `Cmd + R` on your keyboard).
* A realistic virtual iPhone will pop up on your computer screen!
* SplitSnap will open right up!

---

## 5. How to Play with the App in the Simulator

Because the virtual iPhone on your Mac doesn't have a real physical camera, we built in a **Demo Button** so you can test it instantly:

1. On the home screen, tap **"Scan Receipt"**.
2. Tap the button that says: **"Load Sample Receipt (Simulator Demo)"**.
3. *Boom!* A real Italian restaurant receipt is loaded with pizza, pasta, drinks, and calamari.
4. Tap through the friends at the top (**You**, **Alex**, **Sam**, **Taylor**).
5. Tap different dishes to assign them. Notice the little colored pills show who ordered what!
6. Tap **"Review Split & Charges"** at the bottom to see everyone's final bill and the Venmo charge button!

---

## 6. How is this App Built for the Future? (Modularity)

You mentioned you might want to add other types of splitting later (like splitting **Rent**, **Groceries**, or **Road Trips**).

We designed the code in **Lego blocks**:
* **Want to add a new category?** We created `BillCategory.swift` which already has Rent, Utilities, Groceries, and Travel ready to plug in.
* **Want to add Cash App or Apple Cash?** We built a flexible `PaymentProvider` system so you can add new payment buttons without breaking existing code.
* **Want to change how screens look?** Every screen lives in its own file inside the `Views/` folder, so you can change one without messing up the rest.

---

**Whenever you are ready to make changes, add new features, or push to GitHub, just tell me and we will do it together!** 🚀
