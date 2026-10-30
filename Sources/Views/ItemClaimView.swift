import SwiftUI

public struct ItemClaimView: View {
    @Bindable public var viewModel: BillSplitterViewModel
    @State private var showAddPersonSheet = false
    @State private var newPersonName = ""
    @State private var newPersonVenmo = ""

    public init(viewModel: BillSplitterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Friends Bar
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Who is splitting?")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(viewModel.people.count) people")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(viewModel.people) { person in
                                Button(action: {
                                    viewModel.selectedPersonId = person.id
                                }) {
                                    PersonAvatarView(
                                        person: person,
                                        isSelected: viewModel.selectedPersonId == person.id
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            // Add Friend Button
                            Button(action: {
                                showAddPersonSheet = true
                            }) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                                            .foregroundStyle(.secondary)
                                            .frame(width: 52, height: 52)
                                        Image(systemName: "plus")
                                            .font(.title3)
                                            .foregroundStyle(.blue)
                                    }
                                    Text("Add")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Current Selector Status
                if let active = viewModel.selectedPerson {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(active.color)
                            .frame(width: 10, height: 10)
                        Text("Tap items below to assign to **\(active.name)**")
                            .font(.caption)
                        Spacer()
                        if !viewModel.receipt.isFullyAssigned {
                            Text("\(viewModel.receipt.unassignedItems.count) unassigned")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Receipt Items List
                VStack(spacing: 10) {
                    ForEach(viewModel.receipt.items) { item in
                        ReceiptRowView(
                            item: item,
                            allPeople: viewModel.people,
                            activePerson: viewModel.selectedPerson,
                            onToggleActivePerson: {
                                viewModel.toggleItemForSelectedPerson(itemId: item.id)
                            },
                            onSplitAll: {
                                viewModel.splitItemEvenlyAmongAll(itemId: item.id)
                            }
                        )
                    }
                }
                .padding(.horizontal)

                // Tip & Tax Configuration
                TipTaxAdjusterView(viewModel: viewModel)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(viewModel.receipt.merchantName)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            NavigationLink {
                SplitSummaryView(viewModel: viewModel)
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Review Split & Charges")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showAddPersonSheet) {
            NavigationStack {
                Form {
                    Section("Friend Info") {
                        TextField("Name (e.g. Jordan)", text: $newPersonName)
                        TextField("Venmo Handle (optional, e.g. @jordan)", text: $newPersonVenmo)
                    }
                }
                .navigationTitle("Add Friend")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showAddPersonSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            viewModel.addPerson(name: newPersonName, venmo: newPersonVenmo)
                            newPersonName = ""
                            newPersonVenmo = ""
                            showAddPersonSheet = false
                        }
                        .disabled(newPersonName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .presentationDetents([.fraction(0.35)])
        }
    }
}
