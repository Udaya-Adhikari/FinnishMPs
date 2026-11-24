
import SwiftUI
import SwiftData

struct MPDetailView: View {
    let member: MP

    @Environment(\.modelContext) private var modelContext
    @State private var savedMP: SavedMP?
    @State private var isFavourite = false
    @State private var note = ""

    var pictureURL: URL? {
        guard let picture = member.picture,
              !picture.isEmpty else {
            return nil
        }

        let filename = (picture as NSString).lastPathComponent

        return URL(
            string: "https://users.metropolia.fi/~peterh/edustajakuvat/\(filename)"
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 14) {
                    AsyncImage(url: pictureURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 65))
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.15))
                    }
                    .frame(width: 155, height: 155)
                    .clipShape(Circle())

                    Text(member.fullName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(PartyInfo.fullName(for: member.party))
                        .font(.headline)
                        .foregroundStyle(.blue)

                    if member.minister {
                        Label("Government Minister", systemImage: "checkmark.seal.fill")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
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

                VStack(alignment: .leading, spacing: 16) {
                    Label("Parliamentary Information", systemImage: "info.circle")
                        .font(.headline)

                    detailRow(title: "Constituency", value: member.constituency)
                    detailRow(title: "Birth Year", value: String(member.bornYear))
                    detailRow(title: "Seat Number", value: String(member.seatNumber))
                    detailRow(title: "Party", value: member.party.uppercased())
                    detailRow(title: "Minister", value: member.minister ? "Yes" : "No")

                    if let twitter = member.twitter, !twitter.isEmpty {
                        detailRow(title: "Twitter / X", value: twitter)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    Label("Personal Notes", systemImage: "note.text")
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
            }
            .padding()
        }
        .navigationTitle("MP Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSavedMP()
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .fontWeight(.semibold)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func loadSavedMP() {
        do {
            let descriptor = FetchDescriptor<SavedMP>()
            let savedMembers = try modelContext.fetch(descriptor)

            if let existing = savedMembers.first(where: {
                $0.personNumber == member.personNumber
            }) {
                savedMP = existing
                isFavourite = existing.isFavourite
                note = existing.note
            } else {
                let newMP = SavedMP(
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

                modelContext.insert(newMP)
                try modelContext.save()

                savedMP = newMP
            }
        } catch {
            print("Could not load MP: \(error)")
        }
    }

    private func saveChanges() {
        guard let savedMP else { return }

        savedMP.isFavourite = isFavourite

        do {
            try modelContext.save()
        } catch {
            print("Could not save favourite: \(error)")
        }
    }

    private func saveNote(_ newValue: String) {
        guard let savedMP else { return }

        savedMP.note = newValue

        do {
            try modelContext.save()
        } catch {
            print("Could not save note: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        MPDetailView(
            member: MP(
                personNumber: 1467,
                seatNumber: 64,
                first: "Petri",
                last: "Huru",
                party: "ps",
                minister: false,
                picture: nil,
                twitter: "",
                bornYear: 1966,
                constituency: "Satakunta"
            )
        )
    }
    .modelContainer(
        for: [SavedMP.self, SavedParty.self],
        inMemory: true
    )
}

