
import Foundation
import SwiftData

@Model
class SavedMP {
    @Attribute(.unique) var personNumber: Int

    var seatNumber: Int
    var first: String
    var last: String
    var party: String
    var minister: Bool
    var picture: String?
    var twitter: String?
    var bornYear: Int
    var constituency: String

    // Favourite and personal notes
    var isFavourite: Bool
    var note: String

    init(
        personNumber: Int,
        seatNumber: Int,
        first: String,
        last: String,
        party: String,
        minister: Bool,
        picture: String?,
        twitter: String?,
        bornYear: Int,
        constituency: String,
        isFavourite: Bool = false,
        note: String = ""
    ) {
        self.personNumber = personNumber
        self.seatNumber = seatNumber
        self.first = first
        self.last = last
        self.party = party
        self.minister = minister
        self.picture = picture
        self.twitter = twitter
        self.bornYear = bornYear
        self.constituency = constituency
        self.isFavourite = isFavourite
        self.note = note
    }

    var fullName: String {
        "\(first) \(last)"
    }
}

