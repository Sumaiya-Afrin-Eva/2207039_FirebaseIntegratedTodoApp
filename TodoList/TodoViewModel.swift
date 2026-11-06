
import Foundation
import Combine
import FirebaseFirestore

class TodoViewModel: ObservableObject {

    @Published var tasks: [TodoTask] = []
    @Published var errorMessage = ""
    @Published var showError = false

    private let db = Firestore.firestore()

    private var listener: ListenerRegistration?

    // Fetch tasks belonging to the logged-in user
    func startListening(for userId: String) {

        listener?.remove()

        listener = db.collection("tasks")
            .whereField("ownerId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in

                if let error = error {
                    self?.handleError(error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    return
                }

                let fetchedTasks = documents.compactMap { document
                    -> TodoTask? in

                    let data = document.data()

                    guard
                        let title = data["title"] as? String,
                        let description = data["description"] as? String,
                        let isCompleted = data["isCompleted"] as? Bool,
                        let ownerId = data["ownerId"] as? String
                    else {
                        return nil
                    }

                    let timestamp =
                        data["createdAt"] as? Timestamp

                    return TodoTask(
                        id: document.documentID,
                        title: title,
                        description: description,
                        isCompleted: isCompleted,
                        ownerId: ownerId,
                        createdAt: timestamp?.dateValue() ?? Date()
                    )
                }

                DispatchQueue.main.async {
                    self?.tasks = fetchedTasks.sorted {
                        $0.createdAt > $1.createdAt
                    }
                }
            }
    }

    // Add a new task
    func addTask(
        title: String,
        description: String,
        ownerId: String
    ) {

        let taskData: [String: Any] = [
            "title": title,
            "description": description,
            "isCompleted": false,
            "ownerId": ownerId,
            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection("tasks").addDocument(
            data: taskData
        ) { [weak self] error in

            if let error = error {
                self?.handleError(error)
            }
        }
    }

    // Update task title and description
    func updateTask(
        taskId: String,
        title: String,
        description: String
    ) {

        db.collection("tasks")
            .document(taskId)
            .updateData([
                "title": title,
                "description": description
            ]) { [weak self] error in

                if let error = error {
                    self?.handleError(error)
                }
            }
    }

    // Mark a task as completed or incomplete
    func toggleTask(_ task: TodoTask) {

        db.collection("tasks")
            .document(task.id)
            .updateData([
                "isCompleted": !task.isCompleted
            ]) { [weak self] error in

                if let error = error {
                    self?.handleError(error)
                }
            }
    }

    // Delete a task
    func deleteTask(_ task: TodoTask) {

        db.collection("tasks")
            .document(task.id)
            .delete { [weak self] error in

                if let error = error {
                    self?.handleError(error)
                }
            }
    }

    // Stop listening when user logs out
    func stopListening() {
        listener?.remove()
        listener = nil
        tasks = []
    }

    // Handle Firestore errors
    private func handleError(_ error: Error) {

        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }

    deinit {
        listener?.remove()
    }
}
