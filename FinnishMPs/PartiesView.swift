
import SwiftUI
import SwiftData

struct PartiesView: View {
    @Query(sort: \SavedMP.last) private var allMembers: [SavedMP]
    @Query private var savedParties: [SavedParty]

    private var partyCodes: [String] {
        Array(Set(allMembers.map { $0.party }))
            .sorted()
    }

    private func memberCount(for party: String) -> Int {
        allMembers.filter { $0.party == party }.count
    }

    private func partyRecord(for code: String) -> SavedParty? {
        savedParties.first { $0.partyCode == code }
    }

    var body: some View {
        List {
            if partyCodes.isEmpty {
                ContentUnavailableView(
                    "No Parties Available",
                    systemImage: "person.3",
                    description: Text("Parliament data will appear here after loading.")
                )
            } else {
                Section {
                    ForEach(partyCodes, id: \.self) { code in
                        NavigationLink {
                            PartyDetailView(partyCode: code)
                        } label: {
                            HStack(spacing: 15) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 55, height: 55)

                                    Text(code.uppercased())
                                        .font(.headline)
                                        .foregroundStyle(.blue)
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(PartyInfo.fullName(for: code))
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text("\(memberCount(for: code)) Members of Parliament")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if partyRecord(for: code)?.isFavourite == true {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                } header: {
                    Text("Finnish Parliamentary Parties")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Political Parties")
    }
}

#Preview {
    NavigationStack {
        PartiesView()
    }
    .modelContainer(
        for: [SavedMP.self, SavedParty.self],
        inMemory: true
    )
}

