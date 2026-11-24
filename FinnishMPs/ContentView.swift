
import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = MPViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.members.isEmpty {
                    ProgressView("Loading Finnish Parliament...")
                        .padding()

                } else if let error = viewModel.errorMessage,
                          viewModel.members.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)

                        Text("Something went wrong")
                            .font(.headline)

                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button("Try Again") {
                            viewModel.fetchMPs(context: modelContext)
                        }
                    }
                    .padding()

                } else {
                    List {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Welcome to")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text("Finnish Parliament")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)

                                Text("Explore members, political parties and parliamentary coalitions.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                HStack(spacing: 8) {
                                    Image(systemName: "person.3.fill")
                                        .foregroundStyle(.blue)

                                    Text("\(viewModel.members.count) Members of Parliament")
                                        .font(.headline)
                                }
                                .padding(.top, 8)
                            }
                            .padding(.vertical, 10)
                        }

                        Section {
                            ForEach(viewModel.members) { member in
                                NavigationLink {
                                    MPDetailView(member: member)
                                } label: {
                                    HStack(spacing: 14) {
                                        MPListImage(member: member)

                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(member.fullName)
                                                .font(.headline)
                                                .foregroundStyle(.primary)

                                            Text(PartyInfo.fullName(for: member.party))
                                                .font(.subheadline)
                                                .foregroundStyle(.blue)
                                                .lineLimit(1)

                                            Text(member.constituency)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        if member.minister {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundStyle(.green)
                                                .font(.caption)
                                                .help("Minister")
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        } header: {
                            Text("Members")
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        viewModel.fetchMPs(context: modelContext)
                    }
                }
            }
            .navigationTitle("Parliament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 18) {
                        NavigationLink {
                            MajorityView()
                        } label: {
                            Image(systemName: "chart.bar.xaxis")
                                .foregroundStyle(.green)
                        }

                        NavigationLink {
                            PartiesView()
                        } label: {
                            Image(systemName: "building.2")
                                .foregroundStyle(.blue)
                        }

                        NavigationLink {
                            FavouritesView()
                        } label: {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }

                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Button {
                                viewModel.fetchMPs(context: modelContext)
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.start(context: modelContext)
            }
        }
    }
}

struct MPListImage: View {
    let member: MP

    var imageURL: URL? {
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
        AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding(12)
                .foregroundStyle(.gray)
                .background(Color.gray.opacity(0.15))
        }
        .frame(width: 58, height: 58)
        .clipShape(Circle())
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [SavedMP.self, SavedParty.self],
            inMemory: true
        )
}

