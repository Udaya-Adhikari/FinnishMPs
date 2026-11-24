

import Foundation
import Combine
import SwiftData

class MPViewModel: ObservableObject {

    @Published var members: [MP] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService()
    private var hasStartedLoading = false

    // Load saved members and refresh from the API
    func start(context: ModelContext) {
        print("TEST: MPViewModel started successfully")

        guard !hasStartedLoading else { return }
        hasStartedLoading = true

        loadSavedMPs(context: context)
        fetchMPs(context: context)
    }

    // Load members from the local database
    func loadSavedMPs(context: ModelContext) {

        do {
            let descriptor = FetchDescriptor<SavedMP>(
                sortBy: [
                    SortDescriptor(\.last),
                    SortDescriptor(\.first)
                ]
            )

            let savedMembers = try context.fetch(descriptor)

            members = savedMembers.map { saved in
                MP(
                    personNumber: saved.personNumber,
                    seatNumber: saved.seatNumber,
                    first: saved.first,
                    last: saved.last,
                    party: saved.party,
                    minister: saved.minister,
                    picture: saved.picture,
                    twitter: saved.twitter,
                    bornYear: saved.bornYear,
                    constituency: saved.constituency
                )
            }

            print("DATABASE: Loaded \(members.count) MPs")

        } catch {
            print("DATABASE ERROR: \(error.localizedDescription)")
        }
    }

    // Fetch updated members from the API
    func fetchMPs(context: ModelContext) {

        isLoading = members.isEmpty
        errorMessage = nil

        apiService.fetchMPs { [weak self] apiMembers, error in

            DispatchQueue.main.async {

                guard let self = self else { return }

                self.isLoading = false

                if let error = error {

                    print("API ERROR: \(error.localizedDescription)")

                    if self.members.isEmpty {
                        self.errorMessage = error.localizedDescription
                    }

                    return
                }

                guard let apiMembers = apiMembers else {
                    return
                }

                do {
                    // Fetch existing database records
                    let existingMembers = try context.fetch(
                        FetchDescriptor<SavedMP>()
                    )

                    let savedDictionary = Dictionary(
                        uniqueKeysWithValues: existingMembers.map {
                            ($0.personNumber, $0)
                        }
                    )

                    // Update existing records or insert new ones
                    for member in apiMembers {

                        if let saved = savedDictionary[member.personNumber] {

                            saved.seatNumber = member.seatNumber
                            saved.first = member.first
                            saved.last = member.last
                            saved.party = member.party
                            saved.minister = member.minister
                            saved.picture = member.picture
                            saved.twitter = member.twitter
                            saved.bornYear = member.bornYear
                            saved.constituency = member.constituency

                        } else {

                            let newMember = SavedMP(
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

                            context.insert(newMember)
                        }
                    }

                    // Save changes to SwiftData
                    try context.save()

                    self.members = apiMembers

                    print("DATABASE: Saved \(apiMembers.count) MPs")
                    print("DATABASE: Changes successfully persisted")

                } catch {

                    print("DATABASE SAVE ERROR: \(error.localizedDescription)")

                    if self.members.isEmpty {
                        self.errorMessage = "Could not save parliament data."
                    }
                }
            }
        }
    }
}
