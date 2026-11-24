
import Foundation

struct PartyInfo {

    static let names: [String: String] = [
        "kesk": "Centre Party",
        "kok": "National Coalition Party",
        "ps": "Finns Party",
        "sd": "Social Democratic Party",
        "vihr": "Green League",
        "vas": "Left Alliance",
        "r": "Swedish People's Party",
        "kd": "Christian Democrats",
        "liik": "Movement Now"
    ]

    static func fullName(for code: String) -> String {
        names[code.lowercased()] ?? code.uppercased()
    }
}

