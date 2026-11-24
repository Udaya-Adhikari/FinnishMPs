
import SwiftUI
import SwiftData

struct FavouritesView: View {
    @Query(sort: \SavedMP.last) private var allMembers: [SavedMP]

    private var favouriteMembers: [SavedMP] {
        allMembers.filter { $0.isFavourite }
    }

    var body: some View {
        Group {
            if favouriteMembers.isEmpty {
                ContentUnavailableView(
                    "No Favourite MPs",
                    systemImage: "star",
                    description: Text("Your favourite parliament members will appear here.")
                )
            } else {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Your Favourite MPs")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("\(favouriteMembers.count) members saved")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }

                    Section("Saved Members") {
                        ForEach(favouriteMembers) { member in
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
                                HStack(spacing: 14) {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 42))
                                        .foregroundStyle(.blue)

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(member.fullName)
                                            .font(.headline)
                                            .foregroundStyle(.primary)

                                        Text(PartyInfo.fullName(for: member.party))
                                            .font(.subheadline)
                                            .foregroundStyle(.blue)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Favourites")
    }
}

#Preview {
    NavigationStack {
        FavouritesView()
    }
    .modelContainer(
        for: [SavedMP.self, SavedParty.self],
        inMemory: true
    )
}

