import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet, Switch, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors, spacing, radius } from '../../src/theme';
import { BankApp, allBanks } from '../../src/types';
import { getPreferredBank, setPreferredBank } from '../../src/services/bank';

function SettingsRow({ icon, title, onPress }: { icon: string; title: string; onPress: () => void }) {
  return (
    <TouchableOpacity style={styles.row} onPress={onPress}>
      <View style={[styles.rowIcon, { backgroundColor: colors.surface }]}>
        <Ionicons name={icon as any} size={16} color={colors.textSecondary} />
      </View>
      <Text style={styles.rowTitle}>{title}</Text>
      <Ionicons name="chevron-forward" size={14} color={colors.textTertiary} />
    </TouchableOpacity>
  );
}

function SettingsToggle({ icon, title, value, onValueChange }: { icon: string; title: string; value: boolean; onValueChange: (v: boolean) => void }) {
  return (
    <View style={styles.row}>
      <View style={[styles.rowIcon, { backgroundColor: colors.surface }]}>
        <Ionicons name={icon as any} size={16} color={colors.textSecondary} />
      </View>
      <Text style={[styles.rowTitle, { flex: 1 }]}>{title}</Text>
      <Switch value={value} onValueChange={onValueChange} trackColor={{ true: colors.accent }} />
    </View>
  );
}

export default function ProfileScreen() {
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [biometricEnabled, setBiometricEnabled] = useState(false);
  const [preferredBank, setBank] = useState<BankApp | null>(null);
  const [showBankPicker, setShowBankPicker] = useState(false);

  useEffect(() => {
    getPreferredBank().then(setBank);
  }, []);

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false} contentContainerStyle={{ paddingBottom: 120 }}>
      {/* Avatar / User Header */}
      <View style={styles.header}>
        <View style={styles.avatarCircle}>
          <Ionicons name="person" size={32} color={colors.textTertiary} />
        </View>
        <Text style={styles.userName}>Minha Conta</Text>
        <Text style={styles.userSub}>Gerencie suas preferencias</Text>
      </View>

      {/* Bank */}
      <Text style={styles.sectionTitle}>BANCO PREFERIDO</Text>
      <View style={styles.card}>
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
              <View style={[styles.bankIcon, { backgroundColor: colors.surface }]}>
                <Ionicons name="business" size={16} color={colors.textSecondary} />
              </View>
              <Text style={styles.bankPlaceholder}>Selecionar banco</Text>
            </>
          )}
          <Ionicons name={showBankPicker ? 'chevron-up' : 'chevron-down'} size={14} color={colors.textTertiary} />
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
                {preferredBank?.id === bank.id && <Ionicons name="checkmark-circle" size={18} color={colors.accent} />}
              </TouchableOpacity>
            ))}
          </View>
        )}
      </View>

      {/* Preferences */}
      <Text style={styles.sectionTitle}>PREFERENCIAS</Text>
      <View style={styles.card}>
        <SettingsToggle icon="notifications" title="Lembretes de pagamento" value={notificationsEnabled} onValueChange={setNotificationsEnabled} />
        <View style={styles.separator} />
        <SettingsToggle icon="finger-print" title="Bloquear com biometria" value={biometricEnabled} onValueChange={setBiometricEnabled} />
      </View>

      {/* Premium */}
      <Text style={styles.sectionTitle}>PLANO</Text>
      <TouchableOpacity style={styles.premiumCard}>
        <View style={styles.premiumBadge}>
          <Ionicons name="diamond" size={20} color={colors.warning} />
        </View>
        <View style={styles.premiumInfo}>
          <Text style={styles.premiumTitle}>Dono Premium</Text>
          <Text style={styles.premiumDesc}>Prestadores ilimitados, relatorios e mais</Text>
        </View>
        <View style={styles.premiumPrice}>
          <Text style={styles.premiumPriceText}>R$ 9,90</Text>
          <Text style={styles.premiumPriceSub}>/mes</Text>
        </View>
      </TouchableOpacity>

      {/* About */}
      <Text style={styles.sectionTitle}>SOBRE</Text>
      <View style={styles.card}>
        <SettingsRow icon="star" title="Avaliar na App Store" onPress={() => {}} />
        <View style={styles.separator} />
        <SettingsRow icon="chatbubble" title="Enviar feedback" onPress={() => {}} />
        <View style={styles.separator} />
        <SettingsRow icon="document-text" title="Termos de uso" onPress={() => {}} />
      </View>

      <Text style={styles.version}>Dono v1.0.0</Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background, padding: spacing.md },
  header: {
    alignItems: 'center',
    paddingVertical: spacing.xl,
    gap: spacing.sm,
  },
  avatarCircle: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: colors.surface,
    alignItems: 'center',
    justifyContent: 'center',
  },
  userName: { fontSize: 20, fontWeight: '600', color: colors.textPrimary },
  userSub: { fontSize: 14, color: colors.textSecondary },
  sectionTitle: {
    fontSize: 12,
    fontWeight: '500',
    color: colors.textTertiary,
    letterSpacing: 1,
    marginTop: spacing.lg,
    marginBottom: spacing.sm,
    marginLeft: spacing.xs,
  },
  card: {
    backgroundColor: colors.white,
    borderRadius: radius.lg,
    overflow: 'hidden',
  },
  separator: {
    height: 1,
    backgroundColor: colors.divider,
    marginLeft: 52,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm + 4,
  },
  rowIcon: {
    width: 28,
    height: 28,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  rowTitle: { flex: 1, fontSize: 16, color: colors.textPrimary },
  bankRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    padding: spacing.md,
  },
  bankIcon: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  bankName: { flex: 1, fontSize: 16, fontWeight: '500', color: colors.textPrimary },
  bankPlaceholder: { flex: 1, fontSize: 16, color: colors.textSecondary },
  bankList: { borderTopWidth: 1, borderTopColor: colors.divider },
  bankOption: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    padding: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  bankOptionName: { flex: 1, fontSize: 16, color: colors.textPrimary },
  premiumCard: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: spacing.md,
    backgroundColor: colors.white,
    borderRadius: radius.lg,
    gap: spacing.md,
  },
  premiumBadge: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: colors.warningLight,
    alignItems: 'center',
    justifyContent: 'center',
  },
  premiumInfo: { flex: 1, gap: 2 },
  premiumTitle: { fontSize: 16, fontWeight: '600', color: colors.textPrimary },
  premiumDesc: { fontSize: 12, color: colors.textSecondary },
  premiumPrice: { alignItems: 'flex-end' },
  premiumPriceText: { fontSize: 16, fontWeight: '600', color: colors.accent },
  premiumPriceSub: { fontSize: 12, color: colors.textTertiary },
  version: { fontSize: 12, color: colors.textTertiary, textAlign: 'center', marginTop: spacing.xl, marginBottom: spacing.xxl },
});
