
import Foundation

struct TodoTask: Identifiable {

    var id: String
    var title: String
    var description: String
    var isCompleted: Bool
    var ownerId: String
    var createdAt: Date
}
