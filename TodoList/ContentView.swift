
import SwiftUI

struct ContentView: View {

    @EnvironmentObject var authViewModel: AuthViewModel

    @StateObject private var todoViewModel = TodoViewModel()

    @State private var showingEditor = false
    @State private var selectedTask: TodoTask?

    var body: some View {

        Group {

            if let user = authViewModel.user {

                NavigationStack {

                    VStack {

                        if todoViewModel.tasks.isEmpty {

                            Spacer()

                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 55))
                                .foregroundColor(.gray)

                            Text("No tasks yet")
                                .font(.title2)
                                .bold()

                            Text("Tap + to create your first task.")
                                .foregroundColor(.secondary)

                            Spacer()

                        } else {

                            List {

                                ForEach(todoViewModel.tasks) { task in

                                    HStack(spacing: 12) {

                                        Button {
                                            todoViewModel.toggleTask(task)
                                        } label: {
                                            Image(
                                                systemName: task.isCompleted
                                                ? "checkmark.circle.fill"
                                                : "circle"
                                            )
                                            .font(.title2)
                                            .foregroundColor(task.isCompleted ? .green : .gray)
                                        }
                                        .buttonStyle(.plain)

                                        Button {
                                            selectedTask = task
                                            showingEditor = true
                                        } label: {
                                            VStack(alignment: .leading, spacing: 5) {

                                                Text(task.title)
                                                    .font(.headline)
                                                    .strikethrough(task.isCompleted)
                                                    .foregroundColor(
                                                        task.isCompleted ? .secondary : .primary
                                                    )

                                                Text(task.description)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(2)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .buttonStyle(.plain)

                                    }
                                    .padding(.vertical, 5)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedTask = task
                                        showingEditor = true
                                    }
                                    .swipeActions {

                                        Button(role: .destructive) {
                                            todoViewModel.deleteTask(task)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }

                                        Button {
                                            selectedTask = task
                                            showingEditor = true
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("My Tasks")
                    .toolbar {

                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Logout") {
                                authViewModel.logout()
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                selectedTask = nil
                                showingEditor = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $showingEditor) {

                        TaskEditorView(task: selectedTask) {
                            title, description in

                            if let selectedTask = selectedTask {

                                todoViewModel.updateTask(
                                    taskId: selectedTask.id,
                                    title: title,
                                    description: description
                                )

                            } else {

                                todoViewModel.addTask(
                                    title: title,
                                    description: description,
                                    ownerId: user.uid
                                )
                            }
                        }
                    }
                    .alert(
                        "Firestore Error",
                        isPresented: $todoViewModel.showError
                    ) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(todoViewModel.errorMessage)
                    }
                    .onAppear {
                        todoViewModel.startListening(for: user.uid)
                    }
                    .onDisappear {
                        todoViewModel.stopListening()
                    }
                }

            } else {

                AuthView()
            }
        }
    }
}
