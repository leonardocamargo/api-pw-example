import SwiftUI

// MARK: - Provider List View
struct ProviderListView: View {
    @State private var providers: [Provider] = []
    @State private var showAddProvider = false
    @State private var searchText = ""
    @State private var selectedCategory: ProviderCategory?

    var filteredProviders: [Provider] {
        var result = providers

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DonoTheme.Spacing.md) {
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DonoTheme.Spacing.sm) {
                            // All
                            CategoryChip(
                                category: .outro,
                                isSelected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                            }

                            ForEach(ProviderCategory.allCases.filter { $0 != .outro }) { category in
                                CategoryChip(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            }
                        }
                        .padding(.horizontal, DonoTheme.Spacing.md)
                    }

                    // Provider list
                    if filteredProviders.isEmpty {
                        DonoEmptyState(
                            icon: "person.2",
                            title: "Nenhum prestador",
                            description: "Adicione seus prestadores de serviço para começar.",
                            actionTitle: "Adicionar"
                        ) {
                            showAddProvider = true
                        }
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredProviders, id: \.id) { provider in
                                NavigationLink {
                                    ProviderDetailView(provider: provider)
                                } label: {
                                    ProviderRow(provider: provider)
                                }

                                if provider.id != filteredProviders.last?.id {
                                    DonoDivider()
                                        .padding(.leading, 72)
                                }
                            }
                        }
                        .padding(.horizontal, DonoTheme.Spacing.md)
                    }
                }
            }
            .background(DonoTheme.Colors.background)
            .searchable(text: $searchText, prompt: "Buscar prestador")
            .navigationTitle("Prestadores")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DonoIconButton("plus") {
                        showAddProvider = true
                    }
                }
            }
            .sheet(isPresented: $showAddProvider) {
                AddProviderView()
            }
            .task {
                await loadProviders()
            }
        }
    }

    private func loadProviders() async {
        do {
            let dtos = try await SupabaseService.shared.fetchProviders()
            providers = dtos.map { dto in
                Provider(
                    id: dto.id,
                    userId: dto.userId,
                    name: dto.name,
                    category: ProviderCategory(rawValue: dto.category) ?? .outro,
                    pixKey: dto.pixKey,
                    pixKeyType: PixKeyType(rawValue: dto.pixKeyType) ?? .aleatoria,
                    defaultAmount: dto.defaultAmount,
                    frequency: PaymentFrequency(rawValue: dto.frequency) ?? .mensal,
                    dueDay: dto.dueDay
                )
            }
        } catch {
            print("Error loading providers: \(error)")
        }
    }
}

// MARK: - Provider Row
struct ProviderRow: View {
    let provider: Provider

    var body: some View {
        HStack(spacing: DonoTheme.Spacing.md) {
            DonoAvatar(provider.name)

            VStack(alignment: .leading, spacing: DonoTheme.Spacing.xs) {
                Text(provider.name)
                    .font(DonoTheme.Typography.bodyMedium)
                    .foregroundColor(DonoTheme.Colors.textPrimary)

                HStack(spacing: DonoTheme.Spacing.sm) {
                    Image(systemName: provider.category.icon)
                        .font(.system(size: 10))
                        .foregroundColor(provider.category.color)
                    Text(provider.category.label)
                        .font(DonoTheme.Typography.caption)
                        .foregroundColor(DonoTheme.Colors.textSecondary)
                    Text("·")
                        .foregroundColor(DonoTheme.Colors.textTertiary)
                    Text("Dia \(provider.dueDay)")
                        .font(DonoTheme.Typography.caption)
                        .foregroundColor(DonoTheme.Colors.textSecondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: DonoTheme.Spacing.xs) {
                Text(provider.defaultAmount.brlFormatted)
                    .font(DonoTheme.Typography.moneySmall)
                    .foregroundColor(DonoTheme.Colors.textPrimary)

                Text(provider.frequency.label)
                    .font(DonoTheme.Typography.caption)
                    .foregroundColor(DonoTheme.Colors.textTertiary)
            }
        }
        .padding(.vertical, DonoTheme.Spacing.sm + 4)
    }
}
