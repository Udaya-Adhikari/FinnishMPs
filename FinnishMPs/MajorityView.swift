
import SwiftUI
import SwiftData

struct MajorityView: View {
    @Query private var allMembers: [SavedMP]

    @State private var selectedParties: Set<String> = []

    private var partyCodes: [String] {
        Array(Set(allMembers.map { $0.party }))
            .sorted()
    }

    private func memberCount(for party: String) -> Int {
        allMembers.filter { $0.party == party }.count
    }

    private var totalSeats: Int {
        selectedParties.reduce(0) { total, party in
            total + memberCount(for: party)
        }
    }

    private var hasMajority: Bool {
        totalSeats > 100
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Build Your Coalition")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Select the parties you want to include in your government.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("\(selectedParties.count) parties selected")
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 8)
            }

            Section("Available Parties") {
                ForEach(partyCodes, id: \.self) { party in
                    Button {
                        if selectedParties.contains(party) {
                            selectedParties.remove(party)
                        } else {
                            selectedParties.insert(party)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(
                                systemName: selectedParties.contains(party)
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .font(.title2)
                            .foregroundStyle(
                                selectedParties.contains(party)
                                    ? .blue
                                    : .secondary
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(PartyInfo.fullName(for: party))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)

                                Text(party.uppercased())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(memberCount(for: party)) seats")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            Section("Coalition Result") {
                VStack(spacing: 16) {
                    Text("Combined Parliamentary Seats")
                        .font(.headline)

                    Text("\(totalSeats)")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(hasMajority ? .green : .primary)

                    Text("out of 200 seats")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ProgressView(
                        value: Double(min(totalSeats, 200)),
                        total: 200
                    )
                    .tint(hasMajority ? .green : .blue)

                    HStack {
                        Text("0")
                        Spacer()
                        Text("100")
                        Spacer()
                        Text("200")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Divider()

                    Label(
                        hasMajority
                            ? "Majority Government Achieved!"
                            : "No Parliamentary Majority Yet",
                        systemImage: hasMajority
                            ? "checkmark.seal.fill"
                            : "info.circle.fill"
                    )
                    .font(.headline)
                    .foregroundStyle(hasMajority ? .green : .orange)
                    .multilineTextAlignment(.center)

                    Text(
                        hasMajority
                            ? "Your coalition has more than 100 MPs."
                            : "You need \(101 - totalSeats) more seats to reach a majority."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                    Button("Clear All Parties") {
                        selectedParties.removeAll()
                    }
                    .foregroundStyle(.red)
                    .disabled(selectedParties.isEmpty)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Majority Calculator")
    }
}

#Preview {
    NavigationStack {
        MajorityView()
    }
    .modelContainer(
        for: [SavedMP.self, SavedParty.self],
        inMemory: true
    )
}

