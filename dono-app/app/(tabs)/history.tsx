import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet, RefreshControl } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { colors, spacing, radius, formatBRL } from '../../src/theme';
import { Payment, PaymentStatus, statusConfig } from '../../src/types';
import { fetchPayments } from '../../src/services/supabase';
import { StatusBadge, EmptyState, Avatar } from '../../src/components';

export default function HistoryScreen() {
  const router = useRouter();
  const [currentMonth, setCurrentMonth] = useState(new Date());
  const [filterStatus, setFilterStatus] = useState<PaymentStatus | null>(null);
  const [payments, setPayments] = useState<Payment[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const year = currentMonth.getFullYear();
  const month = currentMonth.getMonth();
  const monthLabel = currentMonth.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });

  const loadData = useCallback(async () => {
    try {
      const data = await fetchPayments(currentMonth);
      setPayments(data);
    } catch {
      setPayments([]);
    }
  }, [currentMonth]);

  useEffect(() => { loadData(); }, [loadData]);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const filtered = filterStatus ? payments.filter((p) => p.status === filterStatus) : payments;

  const totalPaid = payments.filter((p) => p.status === 'paid').reduce((s, p) => s + p.amount, 0);
  const totalPending = payments.filter((p) => p.status === 'pending').reduce((s, p) => s + p.amount, 0);
  const totalOverdue = payments.filter((p) => p.status === 'overdue').reduce((s, p) => s + p.amount, 0);

  return (
    <ScrollView
      style={styles.container}
      showsVerticalScrollIndicator={false}
      contentContainerStyle={{ paddingBottom: 120 }}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.accent} />}
    >
      {/* Month nav */}
      <View style={styles.monthNav}>
        <TouchableOpacity onPress={() => setCurrentMonth(new Date(year, month - 1, 1))} style={styles.navButton}>
          <Ionicons name="chevron-back" size={18} color={colors.textSecondary} />
        </TouchableOpacity>
        <Text style={styles.monthLabel}>{monthLabel}</Text>
        <TouchableOpacity onPress={() => setCurrentMonth(new Date(year, month + 1, 1))} style={styles.navButton}>
          <Ionicons name="chevron-forward" size={18} color={colors.textSecondary} />
        </TouchableOpacity>
      </View>

      {/* Summary */}
      <View style={styles.summaryRow}>
        <View style={styles.summaryItem}>
          <View style={[styles.summaryDot, { backgroundColor: colors.success }]} />
          <Text style={styles.summaryLabel}>Pago</Text>
          <Text style={styles.summaryAmount}>{formatBRL(totalPaid)}</Text>
        </View>
        <View style={styles.summaryItem}>
          <View style={[styles.summaryDot, { backgroundColor: colors.warning }]} />
          <Text style={styles.summaryLabel}>Pendente</Text>
          <Text style={styles.summaryAmount}>{formatBRL(totalPending)}</Text>
        </View>
        <View style={styles.summaryItem}>
          <View style={[styles.summaryDot, { backgroundColor: colors.error }]} />
          <Text style={styles.summaryLabel}>Atrasado</Text>
          <Text style={styles.summaryAmount}>{formatBRL(totalOverdue)}</Text>
        </View>
      </View>

      {/* Filters */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.filters} contentContainerStyle={{ paddingHorizontal: spacing.md }}>
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
          description="Nenhum pagamento encontrado para este periodo."
        />
      ) : (
        <View style={styles.list}>
          {filtered.map((payment) => (
            <TouchableOpacity
              key={payment.id}
              style={styles.historyRow}
              onPress={() => router.push(`/payment/${payment.id}`)}
            >
              <Avatar name={payment.provider?.name ?? 'P'} size={40} />
              <View style={styles.historyInfo}>
                <Text style={styles.historyName}>{payment.provider?.name ?? 'Prestador'}</Text>
                <Text style={styles.historyDate}>
                  {new Date(payment.due_date + 'T12:00:00').toLocaleDateString('pt-BR', { day: 'numeric', month: 'short' })}
                </Text>
              </View>
              <View style={styles.historyRight}>
                <Text style={styles.historyAmount}>{formatBRL(payment.amount)}</Text>
                <StatusBadge status={payment.status} />
              </View>
            </TouchableOpacity>
          ))}
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  monthNav: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: spacing.md,
  },
  navButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: colors.surface,
    alignItems: 'center',
    justifyContent: 'center',
  },
  monthLabel: {
    fontSize: 17,
    fontWeight: '600',
    color: colors.textPrimary,
    textTransform: 'capitalize',
  },
  summaryRow: {
    flexDirection: 'row',
    marginHorizontal: spacing.md,
    backgroundColor: colors.white,
    borderRadius: radius.lg,
    padding: spacing.md,
    marginBottom: spacing.md,
    gap: spacing.sm,
  },
  summaryItem: { flex: 1, gap: spacing.xs },
  summaryDot: { width: 8, height: 8, borderRadius: 4 },
  summaryLabel: { fontSize: 12, fontWeight: '500', color: colors.textTertiary },
  summaryAmount: { fontSize: 15, fontWeight: '600', color: colors.textPrimary, fontVariant: ['tabular-nums'] },
  filters: { marginBottom: spacing.md },
  chip: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    borderRadius: radius.full,
    backgroundColor: colors.white,
    borderWidth: 1,
    borderColor: colors.border,
    marginRight: spacing.sm,
  },
  chipActive: { backgroundColor: colors.accent, borderColor: colors.accent },
  chipText: { fontSize: 12, fontWeight: '500', color: colors.textSecondary },
  chipTextActive: { color: colors.white },
  list: { paddingHorizontal: spacing.md },
  historyRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm + 2,
    gap: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  historyInfo: { flex: 1, gap: 2 },
  historyName: { fontSize: 15, fontWeight: '500', color: colors.textPrimary },
  historyDate: { fontSize: 12, color: colors.textSecondary },
  historyRight: { alignItems: 'flex-end', gap: spacing.xs },
  historyAmount: { fontSize: 15, fontWeight: '600', color: colors.textPrimary, fontVariant: ['tabular-nums'] },
});
