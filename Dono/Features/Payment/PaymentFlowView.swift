import SwiftUI

// MARK: - Payment Flow View
// A tela mais importante do app — o fluxo de pagamento

struct PaymentFlowView: View {
    let payment: Payment

    @State private var viewModel = PaymentFlowViewModel()
    @Environment(BankDeepLinkService.self) var bankService
    @Environment(\.dismiss) var dismiss

    @State private var showBankPicker = false
    @State private var showQRCode = false
    @State private var pixCopied = false
    @State private var showConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DonoTheme.Spacing.xl) {

                    // MARK: - Provider Info
                    providerHeader

                    // MARK: - Amount
                    amountSection

                    // MARK: - Pix Details
                    pixDetailsSection

                    // MARK: - Pay Button (Hero)
                    paySection

                    // MARK: - Alternative: QR Code
                    qrCodeSection

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
                    Text("Pagamento")
                        .font(DonoTheme.Typography.headline)
                        .foregroundColor(DonoTheme.Colors.textPrimary)
                }
            }
            .sheet(isPresented: $showBankPicker) {
                BankPickerView { bank in
                    Task {
                        await viewModel.payWithBank(payment: payment, bank: bank)
                    }
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showConfirmation) {
                PaymentConfirmationView(paymentId: payment.id)
            }
        }
    }

    // MARK: - Provider Header

    private var providerHeader: some View {
        VStack(spacing: DonoTheme.Spacing.md) {
            if let provider = payment.provider {
                DonoAvatar(provider.name, size: 64)

                Text(provider.name)
                    .font(.custom("PlayfairDisplay-SemiBold", size: 22))
                    .foregroundColor(DonoTheme.Colors.textPrimary)

                HStack(spacing: DonoTheme.Spacing.sm) {
                    DonoCategoryIcon(provider.category, size: 20)
                    Text(provider.category.label)
                        .font(DonoTheme.Typography.caption)
                        .foregroundColor(DonoTheme.Colors.textSecondary)

                    Text("·")
                        .foregroundColor(DonoTheme.Colors.textTertiary)

                    Text(payment.dueDateFormatted)
                        .font(DonoTheme.Typography.caption)
                        .foregroundColor(
                            payment.isOverdue ? DonoTheme.Colors.error : DonoTheme.Colors.textSecondary
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DonoTheme.Spacing.md)
    }

    // MARK: - Amount

    private var amountSection: some View {
        VStack(spacing: DonoTheme.Spacing.xs) {
            Text(payment.amount.brlFormatted)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .foregroundColor(DonoTheme.Colors.textPrimary)
                .contentTransition(.numericText())

            DonoStatusBadge(status: payment.status)
        }
    }

    // MARK: - Pix Details

    private var pixDetailsSection: some View {
        VStack(spacing: DonoTheme.Spacing.sm) {
            if let provider = payment.provider {
                HStack {
                    VStack(alignment: .leading, spacing: DonoTheme.Spacing.xs) {
                        Text("Chave Pix")
                            .font(DonoTheme.Typography.caption)
                            .foregroundColor(DonoTheme.Colors.textTertiary)

                        Text(provider.pixKey)
                            .font(DonoTheme.Typography.body)
                            .foregroundColor(DonoTheme.Colors.textPrimary)
                    }

                    Spacer()

                    // Tipo da chave
                    Text(provider.pixKeyType.label)
                        .font(DonoTheme.Typography.captionMedium)
                        .foregroundColor(DonoTheme.Colors.textSecondary)
                        .padding(.horizontal, DonoTheme.Spacing.sm)
                        .padding(.vertical, DonoTheme.Spacing.xs)
                        .background(DonoTheme.Colors.surface)
                        .clipShape(Capsule())
                }
                .padding(DonoTheme.Spacing.md)
                .overlay(
                    RoundedRectangle(cornerRadius: DonoTheme.Radius.md)
                        .strokeBorder(DonoTheme.Colors.divider, lineWidth: 1)
                )
            }

            // Pix Copia e Cola (copiable)
            if pixCopied {
                HStack(spacing: DonoTheme.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DonoTheme.Colors.success)
                    Text("Pix copiado!")
                        .font(DonoTheme.Typography.captionMedium)
                        .foregroundColor(DonoTheme.Colors.success)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Pay Section

    private var paySection: some View {
        VStack(spacing: DonoTheme.Spacing.md) {
            // Hero pay button
            if let bank = bankService.preferredBank {
                DonoPayButton(
                    bankName: bank.name,
                    amount: payment.amount,
                    isLoading: viewModel.isProcessing
                ) {
                    Task {
                        await viewModel.payWithBank(payment: payment, bank: bank)
                        withAnimation { pixCopied = true }
                        DonoTheme.Haptics.success()

                        // Reset after 3s
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        withAnimation { pixCopied = false }
                    }
                }
            } else {
                DonoPrimaryButton("Escolher banco e pagar", icon: "building.columns") {
                    showBankPicker = true
                }
            }

            // Change bank
            if bankService.preferredBank != nil {
                DonoGhostButton("Usar outro banco", icon: "arrow.triangle.2.circlepath") {
                    showBankPicker = true
                }
            }

            // Mark as paid manually
            DonoDivider()

            DonoGhostButton("Já paguei por fora", icon: "checkmark") {
                Task {
                    await viewModel.markAsPaid(payment: payment)
                    DonoTheme.Haptics.success()
                    dismiss()
                }
            }
        }
    }

    // MARK: - QR Code

    private var qrCodeSection: some View {
        VStack(spacing: DonoTheme.Spacing.md) {
            DonoGhostButton("Mostrar QR Code", icon: "qrcode") {
                withAnimation { showQRCode.toggle() }
            }

            if showQRCode, let provider = payment.provider {
                let brCode = PixService.shared.generateBRCode(
                    pixKey: provider.pixKey,
                    merchantName: provider.name,
                    amount: payment.amount
                )

                if let qrImage = PixService.shared.generateQRCode(from: brCode) {
                    VStack(spacing: DonoTheme.Spacing.sm) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding(DonoTheme.Spacing.md)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: DonoTheme.Radius.md))

                        Text("Escaneie com o app do banco")
                            .font(DonoTheme.Typography.caption)
                            .foregroundColor(DonoTheme.Colors.textTertiary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
}

// MARK: - Bank Picker
struct BankPickerView: View {
    @Environment(BankDeepLinkService.self) var bankService
    @Environment(\.dismiss) var dismiss
    let onSelect: (BankApp) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: DonoTheme.Spacing.md) {
                Text("Escolha seu banco")
                    .font(.custom("PlayfairDisplay-SemiBold", size: 20))
                    .foregroundColor(DonoTheme.Colors.textPrimary)
                    .padding(.top, DonoTheme.Spacing.md)

                if bankService.installedBanks.isEmpty {
                    // Show all banks (can't detect on simulator)
                    bankList(banks: BankApp.allBanks)
                } else {
                    bankList(banks: bankService.installedBanks)
                }
            }
            .background(DonoTheme.Colors.background)
        }
    }

    private func bankList(banks: [BankApp]) -> some View {
        ScrollView {
            LazyVStack(spacing: DonoTheme.Spacing.sm) {
                ForEach(banks) { bank in
                    Button {
                        bankService.setPreferredBank(bank)
                        onSelect(bank)
                        DonoTheme.Haptics.medium()
                        dismiss()
                    } label: {
                        HStack(spacing: DonoTheme.Spacing.md) {
                            // Bank icon
                            ZStack {
                                Circle()
                                    .fill(bank.color.opacity(0.15))
                                    .frame(width: 44, height: 44)

                                Image(systemName: bank.iconName)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(bank.color)
                            }

                            Text(bank.name)
                                .font(DonoTheme.Typography.bodyMedium)
                                .foregroundColor(DonoTheme.Colors.textPrimary)

                            Spacer()

                            if bank.id == bankService.preferredBank?.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(DonoTheme.Colors.accent)
                            }

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(DonoTheme.Colors.textTertiary)
                        }
                        .padding(.horizontal, DonoTheme.Spacing.md)
                        .padding(.vertical, DonoTheme.Spacing.sm + 4)
                    }

                    if bank.id != banks.last?.id {
                        DonoDivider()
                            .padding(.leading, 72)
                    }
                }
            }
            .padding(.horizontal, DonoTheme.Spacing.md)
        }
    }
}
