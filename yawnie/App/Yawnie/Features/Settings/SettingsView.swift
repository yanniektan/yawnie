import SwiftUI

@MainActor
struct SettingsView: View {
    @State private var model: SettingsViewModel
    @State private var editingList: SettingsViewModel.ListKind?
    @State private var newSender = ""
    @State private var senderProblem: String?

    init(model: SettingsViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        @Bindable var store = model.store
        Form {
            Section {
                TextField("City", text: $store.settings.city)
                    .textContentType(.addressCity)
                    .accessibilityIdentifier("settings.city")
                LabeledContent("Monthly budget") {
                    TextField("Monthly budget", value: $store.settings.monthlyBudget, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("settings.budget")
                }
            } header: {
                Text("Paper")
            } footer: {
                Text(model.dailyCapText())
            }

            ForEach(SettingsViewModel.ListKind.allCases) { kind in
                checklistSection(kind)
            }

            Section {
                DatePicker("Finish work", selection: workFinish, displayedComponents: .hourAndMinute)
                Stepper(value: $store.settings.repeatThreshold, in: AppSettings.repeatRange) {
                    LabeledContent("Repeat at", value: "\(store.settings.repeatThreshold)+ plays")
                }
            } header: {
                Text("Skills")
            } footer: {
                Text("Yoga shows the next class after you finish work. Sad songs counts a track as on repeat at this many plays.")
            }

            protectedSendersSection

            Section {
                LabeledContent("Printer", value: store.settings.printer?.name ?? "None chosen")
                Button(store.settings.printer == nil ? "Choose printer" : "Change printer") {
                    Task { await model.choosePrinter() }
                }
                .disabled(model.isPickingPrinter)
                if store.settings.printer != nil {
                    Button("Forget printer", role: .destructive, action: model.forgetPrinter)
                }
            } header: {
                Text("Printer")
            } footer: {
                Text("After you choose a printer, Print sends the page straight to it.")
            }
        }
        .font(.system(.body, design: .monospaced))
        .navigationTitle("Settings")
        .toolbar { EditButton() }
        .sheet(item: $editingList) { kind in
            ChecklistItemEditor(title: kind.title) { model.add($0, to: kind) }
        }
    }

    private var workFinish: Binding<Date> {
        Binding(
            get: { model.store.settings.workFinish.date(on: .now) },
            set: { model.store.settings.workFinish = TimeOfDay($0) }
        )
    }

    private func checklistSection(_ kind: SettingsViewModel.ListKind) -> some View {
        Section {
            ForEach(model.items(kind)) { item in
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                    Text(item.productURL?.absoluteString ?? "No Amazon link yet")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            .onDelete { model.remove(at: $0, from: kind) }
            .onMove { model.move(from: $0, to: $1, in: kind) }
            Button("Add item") { editingList = kind }
        } header: {
            Text(kind.title)
        }
    }

    private var protectedSendersSection: some View {
        Section {
            ForEach(model.store.settings.protectedSenders, id: \.self) { Text($0) }
                .onDelete { model.removeProtectedSenders(at: $0) }
            HStack {
                TextField("Sender", text: $newSender, prompt: Text(verbatim: "Address or domain"))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .onSubmit(addSender)
                Button("Add", action: addSender)
                    .disabled(newSender.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            if let senderProblem {
                Text(senderProblem).foregroundStyle(.red)
            }
        } header: {
            Text("Protected senders")
        } footer: {
            Text("Inbox clean-up never lists these.")
        }
    }

    private func addSender() {
        senderProblem = model.addProtectedSender(newSender)
        if senderProblem == nil { newSender = "" }
    }
}

private struct ChecklistItemEditor: View {
    let title: String
    let onSave: (ChecklistItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var link = ""

    private var result: Result<ChecklistItem, ChecklistItem.Problem> {
        ChecklistItem.validated(name: name, link: link)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Amazon link (optional)", text: $link)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                if case .failure(let problem) = result, !name.isEmpty || !link.isEmpty {
                    Text(problem.message).foregroundStyle(.red)
                }
            }
            .font(.system(.body, design: .monospaced))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if case .success(let item) = result {
                            onSave(item)
                            dismiss()
                        }
                    }
                    .disabled((try? result.get()) == nil)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(model: SettingsViewModel(store: SettingsStore(defaults: UserDefaults(suiteName: "preview.settings")!)))
    }
}
