import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet, Switch } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors, spacing, radius } from '../../src/theme';
import { BankApp, allBanks } from '../../src/types';
import { getPreferredBank, setPreferredBank } from '../../src/services/bank';

function SettingsRow({ icon, title, onPress }: { icon: string; title: string; onPress: () => void }) {
  return (
    <TouchableOpacity style={styles.row} onPress={onPress}>
      <Ionicons name={icon as any} size={18} color={colors.textSecondary} />
      <Text style={styles.rowTitle}>{title}</Text>
      <Ionicons name="chevron-forward" size={14} color={colors.textTertiary} />
    </TouchableOpacity>
  );
}

function SettingsToggle({ icon, title, value, onValueChange }: { icon: string; title: string; value: boolean; onValueChange: (v: boolean) => void }) {
  return (
    <View style={styles.row}>
      <Ionicons name={icon as any} size={18} color={colors.textSecondary} />
      <Text style={[styles.rowTitle, { flex: 1 }]}>{title}</Text>
      <Switch value={value} onValueChange={onValueChange} trackColor={{ true: colors.accent }} />
    </View>
  );
}

export default function SettingsScreen() {
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [biometricEnabled, setBiometricEnabled] = useState(false);
  const [preferredBank, setBank] = useState<BankApp | null>(null);
  const [showBankPicker, setShowBankPicker] = useState(false);

  useEffect(() => {
    getPreferredBank().then(setBank);
  }, []);

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Bank */}
      <Text style={styles.sectionTitle}>BANCO PREFERIDO</Text>
      <TouchableOpacity style={styles.bankRow} onPress={() => setShowBankPicker(!showBankPicker)}>
        {preferredBank ? (
          <>
            <View style={[styles.bankIcon, { backgroundColor: preferredBank.color + '26' }]}>
              <Text style={{ color: preferredBank.color, fontWeight: '700' }}>{preferredBank.icon}</Text>
            </View>
            <Text style={styles.bankName}>{preferredBank.name}</Text>
          </>
        ) : (
          <>
            <Ionicons name="business" size={18} color={colors.textSecondary} />
            <Text style={styles.bankPlaceholder}>Selecionar banco</Text>
          </>
        )}
        <Ionicons name="chevron-forward" size={14} color={colors.textTertiary} />
      </TouchableOpacity>

      {showBankPicker && (
        <View style={styles.bankList}>
          {allBanks.map((bank) => (
            <TouchableOpacity
              key={bank.id}
              style={styles.bankOption}
              onPress={async () => {
                await setPreferredBank(bank);
                setBank(bank);
                setShowBankPicker(false);
              }}
            >
              <View style={[styles.bankIcon, { backgroundColor: bank.color + '26' }]}>
                <Text style={{ color: bank.color, fontWeight: '700', fontSize: 12 }}>{bank.icon}</Text>
              </View>
              <Text style={styles.bankOptionName}>{bank.name}</Text>
              {preferredBank?.id === bank.id && <Ionicons name="checkmark" size={18} color={colors.accent} />}
            </TouchableOpacity>
          ))}
        </View>
      )}

      {/* Notifications */}
      <Text style={styles.sectionTitle}>NOTIFICAÇÕES</Text>
      <SettingsToggle icon="notifications" title="Lembretes de pagamento" value={notificationsEnabled} onValueChange={setNotificationsEnabled} />

      {/* Security */}
      <Text style={styles.sectionTitle}>SEGURANÇA</Text>
      <SettingsToggle icon="finger-print" title="Bloquear com biometria" value={biometricEnabled} onValueChange={setBiometricEnabled} />

      {/* Premium */}
      <Text style={styles.sectionTitle}>PLANO</Text>
      <TouchableOpacity style={styles.premiumCard}>
        <View style={styles.premiumLeft}>
          <Ionicons name="diamond" size={18} color={colors.warning} />
          <View>
            <Text style={styles.premiumTitle}>Dono Premium</Text>
            <Text style={styles.premiumDesc}>Prestadores ilimitados, relatórios e mais</Text>
          </View>
        </View>
        <View style={styles.premiumPrice}>
          <Text style={styles.premiumPriceText}>R$ 9,90/mês</Text>
        </View>
      </TouchableOpacity>

      {/* About */}
      <Text style={styles.sectionTitle}>SOBRE</Text>
      <SettingsRow icon="star" title="Avaliar na App Store" onPress={() => {}} />
      <SettingsRow icon="mail" title="Enviar feedback" onPress={() => {}} />
      <SettingsRow icon="document-text" title="Termos de uso" onPress={() => {}} />

      <Text style={styles.version}>Dono v1.0.0</Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background, padding: spacing.md },
  sectionTitle: { fontSize: 12, fontWeight: '500', color: colors.textTertiary, letterSpacing: 1, marginTop: spacing.lg, marginBottom: spacing.sm, marginLeft: spacing.md },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm + 4,
  },
  rowTitle: { flex: 1, fontSize: 16, color: colors.textPrimary },
  bankRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    padding: spacing.md,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.divider,
  },
  bankIcon: { width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center' },
  bankName: { flex: 1, fontSize: 16, fontWeight: '500', color: colors.textPrimary },
  bankPlaceholder: { flex: 1, fontSize: 16, color: colors.textSecondary },
  bankList: { borderWidth: 1, borderColor: colors.divider, borderRadius: radius.md, marginTop: spacing.sm },
  bankOption: { flexDirection: 'row', alignItems: 'center', gap: spacing.md, padding: spacing.md, borderBottomWidth: 1, borderBottomColor: colors.divider },
  bankOptionName: { flex: 1, fontSize: 16, color: colors.textPrimary },
  premiumCard: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: spacing.md,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.warning + '4D',
  },
  premiumLeft: { flexDirection: 'row', alignItems: 'center', gap: spacing.md, flex: 1 },
  premiumTitle: { fontSize: 16, fontWeight: '500', color: colors.textPrimary },
  premiumDesc: { fontSize: 12, color: colors.textSecondary },
  premiumPrice: { backgroundColor: colors.accentSubtle, paddingHorizontal: spacing.sm, paddingVertical: spacing.xs, borderRadius: radius.full },
  premiumPriceText: { fontSize: 12, fontWeight: '500', color: colors.accent },
  version: { fontSize: 12, color: colors.textTertiary, textAlign: 'center', marginTop: spacing.xl, marginBottom: spacing.xxxl },
});
