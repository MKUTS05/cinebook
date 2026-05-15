import Foundation

struct Theatre: Identifiable, Hashable {
    let roomNumber: Int16

    var id: Int16 { roomNumber }
    var displayName: String { "Screen \(roomNumber)" }
    var typeName: String {
        switch roomNumber {
        case 3:  return "IMAX"
        case 4:  return "Premium"
        case 5:  return "Gold Class"
        default: return "Standard"
        }
    }
}
