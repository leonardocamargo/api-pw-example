import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet, RefreshControl } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { colors, spacing, radius, formatBRL } from '../../src/theme';
import { Payment } from '../../src/types';
import { fetchPayments } from '../../src/services/supabase';
import { PaymentCard } from '../../src/components';

const DAYS = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return 'Bom dia';
  if (hour < 18) return 'Boa tarde';
  return 'Boa noite';
}

export default function CalendarScreen() {
  const router = useRouter();
  const [currentMonth, setCurrentMonth] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [payments, setPayments] = useState<Payment[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const year = currentMonth.getFullYear();
  const month = currentMonth.getMonth();
  const firstDay = new Date(year, month, 1).getDay();
  const daysInMonth = new Date(year, month + 1, 0).getDate();

  const monthLabel = currentMonth.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });

  const prevMonth = () => setCurrentMonth(new Date(year, month - 1, 1));
  const nextMonth = () => setCurrentMonth(new Date(year, month + 1, 1));

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

  const days: (number | null)[] = [
    ...Array(firstDay).fill(null),
    ...Array.from({ length: daysInMonth }, (_, i) => i + 1),
  ];
  while (days.length % 7 !== 0) days.push(null);

  const isToday = (day: number) => {
    const today = new Date();
    return day === today.getDate() && month === today.getMonth() && year === today.getFullYear();
  };

  const isSelected = (day: number) => {
    return day === selectedDate.getDate() && month === selectedDate.getMonth() && year === selectedDate.getFullYear();
  };

  // Check if a day has payments
  const dayHasPayment = (day: number) => {
    const dateStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    return payments.some((p) => p.due_date === dateStr);
  };

  // Get payments for selected date
  const selectedDateStr = `${selectedDate.getFullYear()}-${String(selectedDate.getMonth() + 1).padStart(2, '0')}-${String(selectedDate.getDate()).padStart(2, '0')}`;
  const selectedPayments = payments.filter((p) => p.due_date === selectedDateStr);

  // Summary
  const totalPaid = payments.filter((p) => p.status === 'paid').reduce((s, p) => s + p.amount, 0);
  const totalPending = payments.filter((p) => p.status !== 'paid' && p.status !== 'skipped').reduce((s, p) => s + p.amount, 0);

  return (
    <ScrollView
      style={styles.container}
      showsVerticalScrollIndicator={false}
      contentContainerStyle={{ paddingBottom: 120 }}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.accent} />}
    >
      {/* Greeting */}
      <Text style={styles.greeting}>{getGreeting()}</Text>

      {/* Summary */}
      <View style={styles.summaryRow}>
        <View style={[styles.summaryCard, { borderLeftColor: colors.success }]}>
          <Text style={styles.summaryLabel}>Pago</Text>
          <Text style={[styles.summaryAmount, { color: colors.success }]}>{formatBRL(totalPaid)}</Text>
        </View>
        <View style={[styles.summaryCard, { borderLeftColor: colors.warning }]}>
          <Text style={styles.summaryLabel}>Pendente</Text>
          <Text style={[styles.summaryAmount, { color: colors.warning }]}>{formatBRL(totalPending)}</Text>
        </View>
      </View>

      {/* Month nav */}
      <View style={styles.monthNav}>
        <TouchableOpacity onPress={prevMonth} style={styles.navButton}>
          <Ionicons name="chevron-back" size={18} color={colors.textSecondary} />
        </TouchableOpacity>
        <Text style={styles.monthLabel}>{monthLabel}</Text>
        <TouchableOpacity onPress={nextMonth} style={styles.navButton}>
          <Ionicons name="chevron-forward" size={18} color={colors.textSecondary} />
        </TouchableOpacity>
      </View>

      {/* Day headers */}
      <View style={styles.daysRow}>
        {DAYS.map((d, i) => (
          <Text key={i} style={styles.dayHeader}>{d}</Text>
        ))}
      </View>

      {/* Grid */}
      <View style={styles.grid}>
        {days.map((day, i) => (
          <TouchableOpacity
            key={i}
            style={styles.dayCell}
            disabled={!day}
            onPress={() => day && setSelectedDate(new Date(year, month, day))}
          >
            {day && (
              <View style={[styles.dayInner, isSelected(day) && styles.selectedDay]}>
                <Text style={[
                  styles.dayText,
                  isToday(day) && !isSelected(day) && { color: colors.accent, fontWeight: '700' },
                  isSelected(day) && { color: colors.white, fontWeight: '600' },
                ]}>
                  {day}
                </Text>
                {dayHasPayment(day) && !isSelected(day) && <View style={styles.dot} />}
              </View>
            )}
          </TouchableOpacity>
        ))}
      </View>

      {/* Selected day payments */}
      <View style={styles.selectedSection}>
        <Text style={styles.selectedLabel}>
          {selectedDate.toLocaleDateString('pt-BR', { weekday: 'long', day: 'numeric', month: 'long' })}
        </Text>
        {selectedPayments.length > 0 ? (
          <View style={styles.paymentsList}>
            {selectedPayments.map((p) => (
              <PaymentCard
                key={p.id}
                payment={p}
                onPress={() => router.push(`/payment/${p.id}`)}
              />
            ))}
          </View>
        ) : (
          <View style={styles.emptyDay}>
            <Ionicons name="sunny-outline" size={28} color={colors.textTertiary} />
            <Text style={styles.emptyText}>Nenhum pagamento neste dia</Text>
          </View>
        )}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  greeting: {
    fontSize: 26,
    fontWeight: '700',
    color: colors.textPrimary,
    paddingHorizontal: spacing.md,
    paddingTop: spacing.md,
    letterSpacing: -0.5,
  },
  summaryRow: {
    flexDirection: 'row',
    gap: spacing.sm,
    paddingHorizontal: spacing.md,
    marginTop: spacing.md,
    marginBottom: spacing.lg,
  },
  summaryCard: {
    flex: 1,
    backgroundColor: colors.white,
    borderRadius: radius.md,
    padding: spacing.md,
    borderLeftWidth: 3,
    gap: spacing.xs,
  },
  summaryLabel: { fontSize: 12, color: colors.textTertiary, fontWeight: '500' },
  summaryAmount: { fontSize: 18, fontWeight: '600', fontVariant: ['tabular-nums'] },
  monthNav: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.md,
    marginBottom: spacing.sm,
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
  daysRow: {
    flexDirection: 'row',
    paddingHorizontal: spacing.md,
    marginBottom: spacing.xs,
  },
  dayHeader: {
    flex: 1,
    textAlign: 'center',
    fontSize: 12,
    fontWeight: '500',
    color: colors.textTertiary,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingHorizontal: spacing.md,
  },
  dayCell: {
    width: '14.28%',
    alignItems: 'center',
    paddingVertical: 3,
  },
  dayInner: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
  },
  selectedDay: { backgroundColor: colors.accent },
  dayText: { fontSize: 14, color: colors.textPrimary },
  dot: {
    position: 'absolute',
    bottom: 3,
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: colors.accent,
  },
  selectedSection: {
    padding: spacing.md,
    marginTop: spacing.sm,
    gap: spacing.sm,
  },
  selectedLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.textPrimary,
    textTransform: 'capitalize',
  },
  paymentsList: { gap: spacing.sm },
  emptyDay: {
    alignItems: 'center',
    paddingVertical: spacing.xl,
    gap: spacing.sm,
  },
  emptyText: { fontSize: 14, color: colors.textTertiary },
});
