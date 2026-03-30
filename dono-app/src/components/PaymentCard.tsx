import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Payment } from '../types';
import { colors, spacing, radius, formatBRL } from '../theme';
import { Avatar } from './Avatar';
import { StatusBadge } from './StatusBadge';

interface Props {
  payment: Payment;
  isUrgent?: boolean;
  onPress: () => void;
}

function formatDueDate(dateStr: string): string {
  const date = new Date(dateStr + 'T12:00:00');
  const today = new Date();
  const tomorrow = new Date();
  tomorrow.setDate(today.getDate() + 1);

  if (date.toDateString() === today.toDateString()) return 'Hoje';
  if (date.toDateString() === tomorrow.toDateString()) return 'Amanhã';

  return date.toLocaleDateString('pt-BR', { day: 'numeric', month: 'long' });
}

export function PaymentCard({ payment, isUrgent, onPress }: Props) {
  const providerName = payment.provider?.name ?? 'Prestador';
  const categoryLabel = payment.provider?.category ?? '';

  return (
    <TouchableOpacity
      style={[styles.card, isUrgent && styles.urgentCard]}
      onPress={onPress}
      activeOpacity={0.85}
    >
      <Avatar name={providerName} />

      <View style={styles.info}>
        <Text style={styles.name}>{providerName}</Text>
        <View style={styles.metaRow}>
          <Text style={[styles.dueDate, isUrgent && { color: colors.error }]}>
            {formatDueDate(payment.due_date)}
          </Text>
          {categoryLabel ? (
            <>
              <Text style={styles.dot}>·</Text>
              <Text style={styles.category}>{categoryLabel}</Text>
            </>
          ) : null}
        </View>
      </View>

      <View style={styles.right}>
        <Text style={styles.amount}>{formatBRL(payment.amount)}</Text>
        <StatusBadge status={payment.status} />
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: spacing.md,
    backgroundColor: colors.background,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.divider,
    gap: spacing.md,
  },
  urgentCard: {
    backgroundColor: colors.accentSubtle + '80',
    borderColor: colors.accent + '4D',
  },
  info: { flex: 1, gap: spacing.xs },
  name: { fontSize: 16, fontWeight: '500', color: colors.textPrimary },
  metaRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  dueDate: { fontSize: 12, color: colors.textSecondary },
  dot: { color: colors.textTertiary },
  category: { fontSize: 12, color: colors.textTertiary },
  right: { alignItems: 'flex-end', gap: spacing.xs },
  amount: { fontSize: 16, fontWeight: '500', color: colors.textPrimary, fontVariant: ['tabular-nums'] },
});
