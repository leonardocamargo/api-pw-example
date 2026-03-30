import React, { useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors, spacing, radius, formatBRL } from '../../src/theme';
import { Payment, PaymentStatus, statusConfig } from '../../src/types';
import { StatusBadge, EmptyState } from '../../src/components';

export default function HistoryScreen() {
  const [currentMonth, setCurrentMonth] = useState(new Date());
  const [filterStatus, setFilterStatus] = useState<PaymentStatus | null>(null);
  const [payments] = useState<Payment[]>([]);

  const year = currentMonth.getFullYear();
  const month = currentMonth.getMonth();
  const monthLabel = currentMonth.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });

  const filtered = filterStatus ? payments.filter((p) => p.status === filterStatus) : payments;

  const totalPaid = payments.filter((p) => p.status === 'paid').reduce((s, p) => s + p.amount, 0);
  const totalPending = payments.filter((p) => p.status === 'pending').reduce((s, p) => s + p.amount, 0);
  const totalOverdue = payments.filter((p) => p.status === 'overdue').reduce((s, p) => s + p.amount, 0);

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Month nav */}
      <View style={styles.monthNav}>
        <TouchableOpacity onPress={() => setCurrentMonth(new Date(year, month - 1, 1))}>
          <Ionicons name="chevron-back" size={20} color={colors.textSecondary} />
        </TouchableOpacity>
        <Text style={styles.monthLabel}>{monthLabel}</Text>
        <TouchableOpacity onPress={() => setCurrentMonth(new Date(year, month + 1, 1))}>
          <Ionicons name="chevron-forward" size={20} color={colors.textSecondary} />
        </TouchableOpacity>
      </View>

      {/* Summary */}
      <View style={styles.summary}>
        <View style={styles.summaryItem}>
          <Text style={[styles.summaryLabel, { color: colors.success }]}>Total pago</Text>
          <Text style={styles.summaryAmount}>{formatBRL(totalPaid)}</Text>
        </View>
        <View style={styles.summaryItem}>
          <Text style={[styles.summaryLabel, { color: colors.warning }]}>Pendente</Text>
          <Text style={styles.summaryAmount}>{formatBRL(totalPending)}</Text>
        </View>
        <View style={styles.summaryItem}>
          <Text style={[styles.summaryLabel, { color: colors.error }]}>Atrasado</Text>
          <Text style={styles.summaryAmount}>{formatBRL(totalOverdue)}</Text>
        </View>
      </View>

      {/* Filters */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.filters}>
        <TouchableOpacity
          style={[styles.chip, !filterStatus && styles.chipActive]}
          onPress={() => setFilterStatus(null)}
        >
          <Text style={[styles.chipText, !filterStatus && styles.chipTextActive]}>Todos</Text>
        </TouchableOpacity>
        {(Object.keys(statusConfig) as PaymentStatus[]).map((status) => (
          <TouchableOpacity
            key={status}
            style={[styles.chip, filterStatus === status && styles.chipActive]}
            onPress={() => setFilterStatus(filterStatus === status ? null : status)}
          >
            <Text style={[styles.chipText, filterStatus === status && styles.chipTextActive]}>
              {statusConfig[status].label}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {filtered.length === 0 ? (
        <EmptyState
          icon="time"
          title="Sem pagamentos"
          description="Nenhum pagamento encontrado para este período."
        />
      ) : (
        <View style={styles.list}>
          {filtered.map((payment) => (
            <View key={payment.id} style={styles.historyRow}>
              <View style={styles.historyInfo}>
                <Text style={styles.historyDate}>
                  {new Date(payment.due_date).toLocaleDateString('pt-BR', { day: 'numeric', month: 'long' })}
                </Text>
              </View>
              <Text style={styles.historyAmount}>{formatBRL(payment.amount)}</Text>
              <StatusBadge status={payment.status} />
            </View>
          ))}
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background, padding: spacing.md },
  monthNav: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: spacing.md },
  monthLabel: { fontSize: 18, fontWeight: '600', color: colors.textPrimary, textTransform: 'capitalize' },
  summary: {
    flexDirection: 'row',
    padding: spacing.lg,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.divider,
    marginBottom: spacing.lg,
  },
  summaryItem: { flex: 1, gap: spacing.xs },
  summaryLabel: { fontSize: 12, fontWeight: '500' },
  summaryAmount: { fontSize: 16, fontWeight: '500', color: colors.textPrimary, fontVariant: ['tabular-nums'] },
  filters: { marginBottom: spacing.lg },
  chip: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    borderRadius: radius.full,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    marginRight: spacing.sm,
  },
  chipActive: { backgroundColor: colors.accent, borderColor: colors.accent },
  chipText: { fontSize: 12, fontWeight: '500', color: colors.textSecondary },
  chipTextActive: { color: colors.white },
  list: {},
  historyRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
    gap: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  historyInfo: { flex: 1 },
  historyDate: { fontSize: 16, fontWeight: '500', color: colors.textPrimary },
  historyAmount: { fontSize: 16, fontWeight: '500', color: colors.textPrimary, fontVariant: ['tabular-nums'] },
});
