import SwiftUI

// MARK: - Add Provider View
struct AddProviderView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = AddProviderViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DonoTheme.Spacing.lg) {

                    // MARK: - Name
                    DonoTextField(
                        label: "Nome do prestador",
                        placeholder: "Ex: João Jardineiro",
                        text: $viewModel.name,
                        icon: "person"
                    )

                    // MARK: - Category
                    VStack(alignment: .leading, spacing: DonoTheme.Spacing.sm) {
                        Text("Categoria")
                            .font(DonoTheme.Typography.captionMedium)
                            .foregroundColor(DonoTheme.Colors.textSecondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DonoTheme.Spacing.sm) {
                                ForEach(ProviderCategory.allCases) { category in
                                    CategoryChip(
                                        category: category,
                                        isSelected: viewModel.category == category
                                    ) {
                                        viewModel.category = category
                                        DonoTheme.Haptics.selection()
                                    }
                                }
                            }
                        }
                    }

                    // MARK: - Pix Key Type
                    VStack(alignment: .leading, spacing: DonoTheme.Spacing.sm) {
                        Text("Tipo da chave Pix")
                            .font(DonoTheme.Typography.captionMedium)
                            .foregroundColor(DonoTheme.Colors.textSecondary)

                        HStack(spacing: DonoTheme.Spacing.sm) {
                            ForEach(PixKeyType.allCases) { keyType in
                                PixKeyTypeChip(
                                    keyType: keyType,
                                    isSelected: viewModel.pixKeyType == keyType
                                ) {
                                    viewModel.pixKeyType = keyType
                                    DonoTheme.Haptics.selection()
                                }
                            }
                        }
                    }

                    // MARK: - Pix Key
                    DonoTextField(
                        label: "Chave Pix",
                        placeholder: viewModel.pixKeyType.placeholder,
                        text: $viewModel.pixKey,
                        keyboardType: viewModel.pixKeyType.keyboardType,
                        icon: viewModel.pixKeyType.icon
                    )

                    // MARK: - Amount
                    DonoMoneyInput(
                        label: "Valor padrão",
                        amount: $viewModel.amount
                    )

                    // MARK: - Frequency
                    VStack(alignment: .leading, spacing: DonoTheme.Spacing.sm) {
                        Text("Frequência")
                            .font(DonoTheme.Typography.captionMedium)
                            .foregroundColor(DonoTheme.Colors.textSecondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DonoTheme.Spacing.sm) {
                                ForEach(PaymentFrequency.allCases) { freq in
                                    FrequencyChip(
                                        frequency: freq,
                                        isSelected: viewModel.frequency == freq
                                    ) {
                                        viewModel.frequency = freq
                                        DonoTheme.Haptics.selection()
                                    }
                                }
                            }
                        }
                    }

                    // MARK: - Due Day
                    VStack(alignment: .leading, spacing: DonoTheme.Spacing.sm) {
                        Text("Dia do vencimento")
                            .font(DonoTheme.Typography.captionMedium)
                            .foregroundColor(DonoTheme.Colors.textSecondary)

                        HStack {
                            Text("Dia")
                                .font(DonoTheme.Typography.body)
                                .foregroundColor(DonoTheme.Colors.textSecondary)

                            Picker("", selection: $viewModel.dueDay) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)").tag(day)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(DonoTheme.Colors.accent)

                            Text("de cada mês")
                                .font(DonoTheme.Typography.body)
                                .foregroundColor(DonoTheme.Colors.textSecondary)

                            Spacer()
                        }
                        .padding(.horizontal, DonoTheme.Spacing.md)
                        .frame(height: 52)
                        .background(DonoTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: DonoTheme.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: DonoTheme.Radius.md)
                                .strokeBorder(DonoTheme.Colors.border, lineWidth: 1)
                        )
                    }

                    // MARK: - Notes
                    DonoTextField(
                        label: "Observações (opcional)",
                        placeholder: "Ex: Pagar até meio-dia",
                        text: $viewModel.notes,
                        icon: "note.text"
                    )

                    // MARK: - Save Button
                    DonoPrimaryButton(
                        "Salvar prestador",
                        icon: "checkmark",
                        isLoading: viewModel.isSaving
                    ) {
                        Task {
                            await viewModel.save()
                            if viewModel.savedSuccessfully {
                                DonoTheme.Haptics.success()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isValid)
                    .opacity(viewModel.isValid ? 1.0 : 0.5)
                    .padding(.top, DonoTheme.Spacing.md)

                    Spacer(minLength: DonoTheme.Spacing.xxl)
                }
                .padding(.horizontal, DonoTheme.Spacing.lg)
                .padding(.top, DonoTheme.Spacing.md)
            }
            .background(DonoTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DonoIconButton("xmark") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Text("Novo prestador")
                        .font(DonoTheme.Typography.headline)
                        .foregroundColor(DonoTheme.Colors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: ProviderCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DonoTheme.Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                Text(category.label)
                    .font(DonoTheme.Typography.captionMedium)
            }
            .foregroundColor(isSelected ? .white : DonoTheme.Colors.textSecondary)
            .padding(.horizontal, DonoTheme.Spacing.md)
            .padding(.vertical, DonoTheme.Spacing.sm)
            .background(isSelected ? category.color : DonoTheme.Colors.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.clear : DonoTheme.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Pix Key Type Chip
struct PixKeyTypeChip: View {
    let keyType: PixKeyType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(keyType.label)
                .font(DonoTheme.Typography.captionMedium)
                .foregroundColor(isSelected ? .white : DonoTheme.Colors.textSecondary)
                .padding(.horizontal, DonoTheme.Spacing.md)
                .padding(.vertical, DonoTheme.Spacing.sm)
                .background(isSelected ? DonoTheme.Colors.accent : DonoTheme.Colors.surface)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : DonoTheme.Colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Frequency Chip
struct FrequencyChip: View {
    let frequency: PaymentFrequency
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(frequency.label)
                .font(DonoTheme.Typography.captionMedium)
                .foregroundColor(isSelected ? .white : DonoTheme.Colors.textSecondary)
                .padding(.horizontal, DonoTheme.Spacing.md)
                .padding(.vertical, DonoTheme.Spacing.sm)
                .background(isSelected ? DonoTheme.Colors.accent : DonoTheme.Colors.surface)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : DonoTheme.Colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Add Provider ViewModel
@Observable @MainActor
final class AddProviderViewModel {
    var name = ""
    var category: ProviderCategory = .casa
    var pixKeyType: PixKeyType = .cpf
    var pixKey = ""
    var amount: Double = 0
    var frequency: PaymentFrequency = .mensal
    var dueDay: Int = 10
    var notes = ""

    var isSaving = false
    var savedSuccessfully = false
    var error: String?

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !pixKey.trimmingCharacters(in: .whitespaces).isEmpty &&
        amount > 0
    }

    func save() async {
        guard isValid else { return }
        isSaving = true
        defer { isSaving = false }

        guard let userId = SupabaseService.shared.currentUser?.id else {
            error = "Usuário não autenticado"
            return
        }

        let provider = ProviderDTO(
            id: UUID(),
            userId: userId,
            name: name.trimmingCharacters(in: .whitespaces),
            category: category.rawValue,
            pixKey: pixKey.trimmingCharacters(in: .whitespaces),
            pixKeyType: pixKeyType.rawValue,
            defaultAmount: amount,
            frequency: frequency.rawValue,
            dueDay: dueDay,
            notes: notes.isEmpty ? nil : notes,
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )

        do {
            try await SupabaseService.shared.insertProvider(provider)

            // Schedule first notification
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month], from: Date())
            components.day = dueDay
            if let dueDate = calendar.date(from: components) {
                await NotificationService.shared.schedulePaymentReminder(
                    paymentId: provider.id,
                    providerName: name,
                    amount: amount,
                    dueDate: dueDate
                )
            }

            savedSuccessfully = true
        } catch {
            self.error = "Erro ao salvar: \(error.localizedDescription)"
        }
    }
}
