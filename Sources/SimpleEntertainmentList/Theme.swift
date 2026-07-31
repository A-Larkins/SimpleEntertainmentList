import SwiftUI

enum Theme {
    static let paper = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor(red: 0.106, green: 0.094, blue: 0.082, alpha: 1)
            : NSColor(red: 0.965, green: 0.953, blue: 0.925, alpha: 1)
    })

    static let ink = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor(red: 0.925, green: 0.902, blue: 0.855, alpha: 1)
            : NSColor(red: 0.141, green: 0.122, blue: 0.102, alpha: 1)
    })

    static let accent = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor(red: 0.831, green: 0.647, blue: 0.416, alpha: 1)
            : NSColor(red: 0.541, green: 0.416, blue: 0.294, alpha: 1)
    })

    static let accentSoft = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor(red: 0.173, green: 0.149, blue: 0.110, alpha: 1)
            : NSColor(red: 0.937, green: 0.902, blue: 0.847, alpha: 1)
    })

    static let displayFont = Font.custom("Georgia", size: 20)
}
