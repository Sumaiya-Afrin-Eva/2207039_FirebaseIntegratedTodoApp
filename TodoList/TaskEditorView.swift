
import SwiftUI

struct TaskEditorView: View {

    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var taskDescription: String

    let task: TodoTask?
    let onSave: (String, String) -> Void

    init(
        task: TodoTask? = nil,
        onSave: @escaping (String, String) -> Void
    ) {

        self.task = task
        self.onSave = onSave

        _title = State(initialValue: task?.title ?? "")
        _taskDescription = State(
            initialValue: task?.description ?? ""
        )
    }

    var body: some View {

        NavigationStack {

            Form {

                Section("Task Information") {

                    TextField("Task Title", text: $title)

                    TextField(
                        "Task Description",
                        text: $taskDescription,
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                }
            }
            .navigationTitle(
                task == nil ? "Add Task" : "Edit Task"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {

                        onSave(
                            title.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ),
                            taskDescription.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                        )

                        dismiss()
                    }
                    .disabled(
                        title.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
        }
    }
}
