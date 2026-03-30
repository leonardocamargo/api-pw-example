import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, StyleSheet, TouchableOpacity, Modal } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import * as Clipboard from 'expo-clipboard';
import { colors, spacing, radius, formatBRL } from '../../src/theme';
import { BankApp, allBanks } from '../../src/types';
import { Avatar, PayButton, PrimaryButton, SecondaryButton, GhostButton } from '../../src/components';
import { generateBRCode } from '../../src/services/pix';
import { copyPixAndOpenBank, getPreferredBank, setPreferredBank } from '../../src/services/bank';

export default function PaymentFlowScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const [preferredBank, setBank] = useState<BankApp | null>(null);
  const [showBankPicker, setShowBankPicker] = useState(false);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [isPaying, setIsPaying] = useState(false);

  // Demo data — in production fetch from Supabase
  const providerName = 'Prestador';
  const amount = 250.0;
  const pixKey = '11999999999';

  useEffect(() => {
    getPreferredBank().then(setBank);
  }, []);

  const handlePay = async (bank?: BankApp) => {
    setIsPaying(true);
    const success = await copyPixAndOpenBank(pixKey, providerName, amount, bank);
    setIsPaying(false);
    if (success) {
      // User returns from bank → show confirmation
      setTimeout(() => setShowConfirmation(true), 500);
    }
  };

  const handleCopyOnly = async () => {
    const brCode = generateBRCode(pixKey, providerName, 'SAO PAULO', amount);
    await Clipboard.setStringAsync(brCode);
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  };

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Provider Header */}
      <View style={styles.header}>
        <Avatar name={providerName} size={64} />
        <Text style={styles.providerName}>{providerName}</Text>
        <Text style={styles.amount}>{formatBRL(amount)}</Text>
      </View>

      {/* Pix Info */}
      <View style={styles.pixCard}>
        <Text style={styles.pixLabel}>Chave Pix</Text>
        <Text style={styles.pixKey}>{pixKey}</Text>
      </View>

      {/* Pay Button */}
      <View style={styles.paySection}>
        {preferredBank ? (
          <PayButton
            bankName={preferredBank.name}
            amount={amount}
            onPress={() => handlePay(preferredBank)}
            isLoading={isPaying}
          />
        ) : (
          <PrimaryButton
            title="Escolher banco e pagar"
            icon="wallet"
            onPress={() => setShowBankPicker(true)}
          />
        )}

        <View style={styles.altActions}>
          <GhostButton title="Copiar só o Pix" icon="clipboard-outline" onPress={handleCopyOnly} />
          <GhostButton title="Trocar banco" icon="swap-horizontal" onPress={() => setShowBankPicker(true)} />
        </View>

        <SecondaryButton
          title="Já paguei por fora"
          icon="checkmark-circle"
          onPress={() => setShowConfirmation(true)}
        />
      </View>

      {/* Bank Picker Modal */}
      <Modal visible={showBankPicker} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Escolha seu banco</Text>
            {allBanks.map((bank) => (
              <TouchableOpacity
                key={bank.id}
                style={styles.bankRow}
                onPress={async () => {
                  await setPreferredBank(bank);
                  setBank(bank);
                  setShowBankPicker(false);
                  handlePay(bank);
                }}
              >
                <View style={[styles.bankIcon, { backgroundColor: bank.color + '26' }]}>
                  <Text style={{ color: bank.color, fontWeight: '700' }}>{bank.icon}</Text>
                </View>
                <Text style={styles.bankName}>{bank.name}</Text>
              </TouchableOpacity>
            ))}
            <GhostButton title="Cancelar" onPress={() => setShowBankPicker(false)} />
          </View>
        </View>
      </Modal>

      {/* Confirmation Modal */}
      <Modal visible={showConfirmation} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={[styles.modalContent, { alignItems: 'center' }]}>
            <View style={styles.successCircle}>
              <Ionicons name="checkmark" size={48} color={colors.success} />
            </View>
            <Text style={styles.successText}>Pagamento confirmado!</Text>
            <PrimaryButton
              title="Voltar"
              onPress={() => { setShowConfirmation(false); router.back(); }}
              style={{ width: '100%' }}
            />
          </View>
        </View>
      </Modal>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  header: { alignItems: 'center', paddingVertical: spacing.xl, gap: spacing.md },
  providerName: { fontSize: 24, fontWeight: '700', color: colors.textPrimary },
  amount: { fontSize: 36, fontWeight: '700', color: colors.textPrimary, fontVariant: ['tabular-nums'] },
  pixCard: {
    marginHorizontal: spacing.md,
    padding: spacing.md,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.divider,
    gap: spacing.sm,
    marginBottom: spacing.xl,
  },
  pixLabel: { fontSize: 12, fontWeight: '500', color: colors.textTertiary, textTransform: 'uppercase', letterSpacing: 1 },
  pixKey: { fontSize: 16, fontWeight: '500', color: colors.textPrimary, fontVariant: ['tabular-nums'] },
  paySection: { paddingHorizontal: spacing.md, gap: spacing.md },
  altActions: { flexDirection: 'row', justifyContent: 'center', gap: spacing.xl },
  modalOverlay: { flex: 1, backgroundColor: colors.overlay, justifyContent: 'flex-end' },
  modalContent: {
    backgroundColor: colors.background,
    borderTopLeftRadius: radius.xl,
    borderTopRightRadius: radius.xl,
    padding: spacing.lg,
    paddingBottom: spacing.xxxl,
    gap: spacing.sm,
  },
  modalTitle: { fontSize: 20, fontWeight: '700', color: colors.textPrimary, textAlign: 'center', marginBottom: spacing.md },
  bankRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.md, padding: spacing.md, borderBottomWidth: 1, borderBottomColor: colors.divider },
  bankIcon: { width: 40, height: 40, borderRadius: 20, alignItems: 'center', justifyContent: 'center' },
  bankName: { flex: 1, fontSize: 16, fontWeight: '500', color: colors.textPrimary },
  successCircle: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: colors.successLight,
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: spacing.lg,
  },
  successText: { fontSize: 22, fontWeight: '600', color: colors.textPrimary, marginBottom: spacing.lg },
});
