
import SwiftUI
import SwiftData

struct PartyDetailView: View {
    let partyCode: String

    @Environment(\.modelContext) private var modelContext
    @Query private var savedParties: [SavedParty]
    @Query private var allMembers: [SavedMP]

    @State private var isFavourite = false
    @State private var note = ""

    private var party: SavedParty? {
        savedParties.first { $0.partyCode == partyCode }
    }

    private var members: [SavedMP] {
        allMembers.filter { $0.party == partyCode }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.blue.gradient)
                            .frame(width: 110, height: 110)

                        Text(partyCode.uppercased())
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    Text(PartyInfo.fullName(for: partyCode))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("\(members.count) Members of Parliament")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Button {
                    isFavourite.toggle()
                    saveChanges()
                } label: {
                    Label(
                        isFavourite ? "Remove from Favourites" : "Add to Favourites",
                        systemImage: isFavourite ? "star.fill" : "star"
                    )
                    .font(.headline)
                    .foregroundStyle(isFavourite ? .orange : .blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Label("Party Notes", systemImage: "note.text")
                        .font(.headline)

                    TextEditor(text: $note)
                        .frame(minHeight: 130)
                        .padding(8)
                        .background(Color.gray.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onChange(of: note) { _, newValue in
                            saveNote(newValue)
                        }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Label("Party Members", systemImage: "person.3")
                        .font(.headline)

                    ForEach(members) { member in
                        NavigationLink {
                            MPDetailView(
                                member: MP(
                                    personNumber: member.personNumber,
                                    seatNumber: member.seatNumber,
                                    first: member.first,
                                    last: member.last,
                                    party: member.party,
                                    minister: member.minister,
                                    picture: member.picture,
                                    twitter: member.twitter,
                                    bornYear: member.bornYear,
                                    constituency: member.constituency
                                )
                            )
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 34))
                                    .foregroundStyle(.blue)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(member.fullName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)

                                    Text("Seat \(member.seatNumber)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Party Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadParty()
        }
    }

    private func loadParty() {
        if let existingParty = party {
            isFavourite = existingParty.isFavourite
            note = existingParty.note
        } else {
            let newParty = SavedParty(partyCode: partyCode)
            modelContext.insert(newParty)

            do {
                try modelContext.save()
            } catch {
                print("Could not save party: \(error)")
            }
        }
    }

    private func saveChanges() {
        if let existingParty = party {
            existingParty.isFavourite = isFavourite

            do {
                try modelContext.save()
            } catch {
                print("Could not save party favourite: \(error)")
            }
        }
    }

    private func saveNote(_ newValue: String) {
        if let existingParty = party {
            existingParty.note = newValue

            do {
                try modelContext.save()
            } catch {
                print("Could not save party note: \(error)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        PartyDetailView(partyCode: "ps")
    }
    .modelContainer(
        for: [SavedMP.self, SavedParty.self],
        inMemory: true
    )
}

