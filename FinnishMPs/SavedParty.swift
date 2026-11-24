
import Foundation
import SwiftData

@Model
class SavedParty {
    @Attribute(.unique) var partyCode: String

    var isFavourite: Bool
    var note: String

    init(
        partyCode: String,
        isFavourite: Bool = false,
        note: String = ""
    ) {
        self.partyCode = partyCode
        self.isFavourite = isFavourite
        self.note = note
    }
}


