import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, ScrollView, StyleSheet, RefreshControl, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { colors, spacing, radius, formatBRL } from '../../src/theme';
import { Payment } from '../../src/types';
import { fetchPendingPayments, fetchPayments } from '../../src/services/supabase';
import { PaymentCard, EmptyState } from '../../src/components';

function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return 'Bom dia';
  if (hour < 18) return 'Boa tarde';
  return 'Boa noite';
}

export default function HomeScreen() {
  const router = useRouter();
  const [payments, setPayments] = useState<Payment[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const loadData = useCallback(async () => {
    try {
      const data = await fetchPayments(new Date());
      setPayments(data);
    } catch {
      // Demo data when no Supabase
      setPayments([]);
    }
  }, []);

  useEffect(() => { loadData(); }, [loadData]);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const todayPayments = payments.filter(
    (p) => p.status === 'pending' && new Date(p.due_date + 'T12:00:00').toDateString() === new Date().toDateString()
  );
  const overduePayments = payments.filter((p) => p.status === 'overdue');
  const upcomingPayments = payments.filter(
    (p) => p.status === 'pending' && new Date(p.due_date + 'T12:00:00') > new Date()
  ).slice(0, 5);
  const totalPaid = payments.filter((p) => p.status === 'paid').reduce((s, p) => s + p.amount, 0);
  const totalPending = payments.filter((p) => p.status !== 'paid' && p.status !== 'skipped').reduce((s, p) => s + p.amount, 0);
  const paidCount = payments.filter((p) => p.status === 'paid').length;
  const completionRate = payments.length > 0 ? paidCount / payments.length : 0;

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.content}
      showsVerticalScrollIndicator={false}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.accent} />}
    >
      {/* Greeting */}
      <Text style={styles.greeting}>{getGreeting()} 👋</Text>

      {/* Summary Card */}
      <View style={styles.summaryCard}>
        <View style={styles.summaryRow}>
          <View style={styles.summaryItem}>
            <Text style={styles.summaryLabel}>Pago</Text>
            <Text style={[styles.summaryAmount, { color: colors.success }]}>{formatBRL(totalPaid)}</Text>
          </View>
          <View style={styles.summaryItem}>
            <Text style={styles.summaryLabel}>Pendente</Text>
            <Text style={[styles.summaryAmount, { color: colors.warning }]}>{formatBRL(totalPending)}</Text>
          </View>
        </View>

        {/* Progress Bar */}
        <View style={styles.progressBg}>
          <View style={[styles.progressFill, { width: `${completionRate * 100}%` }]} />
        </View>
        <Text style={styles.progressText}>{paidCount}/{payments.length} pagamentos</Text>
      </View>

      {/* Today */}
      {todayPayments.length > 0 && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>HOJE</Text>
          {todayPayments.map((p) => (
            <PaymentCard
              key={p.id}
              payment={p}
              isUrgent
              onPress={() => router.push(`/payment/${p.id}`)}
            />
          ))}
        </View>
      )}

      {/* Overdue */}
      {overduePayments.length > 0 && (
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: colors.error }]}>ATRASADOS</Text>
          {overduePayments.map((p) => (
            <PaymentCard
              key={p.id}
              payment={p}
              isUrgent
              onPress={() => router.push(`/payment/${p.id}`)}
            />
          ))}
        </View>
      )}

      {/* Upcoming */}
      {upcomingPayments.length > 0 && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>PRÓXIMOS</Text>
          {upcomingPayments.map((p) => (
            <PaymentCard
              key={p.id}
              payment={p}
              onPress={() => router.push(`/payment/${p.id}`)}
            />
          ))}
        </View>
      )}

      {/* Empty state */}
      {payments.length === 0 && (
        <EmptyState
          icon="home"
          title="Bem-vindo ao Dono"
          description="Adicione seus prestadores de serviço e nunca mais esqueça um pagamento."
          actionTitle="Adicionar Prestador"
          onAction={() => router.push('/provider/add')}
        />
      )}

      {/* FAB */}
      <TouchableOpacity
        style={styles.fab}
        onPress={() => router.push('/provider/add')}
        activeOpacity={0.85}
      >
        <Ionicons name="add" size={28} color={colors.white} />
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  content: { padding: spacing.md, paddingBottom: 100 },
  greeting: { fontSize: 28, fontWeight: '700', color: colors.textPrimary, marginBottom: spacing.lg, letterSpacing: -0.5 },
  summaryCard: {
    padding: spacing.lg,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.divider,
    marginBottom: spacing.xl,
    gap: spacing.md,
  },
  summaryRow: { flexDirection: 'row', justifyContent: 'space-between' },
  summaryItem: { gap: spacing.xs },
  summaryLabel: { fontSize: 12, color: colors.textTertiary },
  summaryAmount: { fontSize: 20, fontWeight: '600', fontVariant: ['tabular-nums'] },
  progressBg: { height: 6, backgroundColor: colors.surface, borderRadius: 3 },
  progressFill: { height: 6, backgroundColor: colors.success, borderRadius: 3 },
  progressText: { fontSize: 12, color: colors.textTertiary, textAlign: 'center' },
  section: { marginBottom: spacing.xl, gap: spacing.sm },
  sectionTitle: { fontSize: 12, fontWeight: '500', color: colors.textTertiary, letterSpacing: 1, marginLeft: spacing.md },
  fab: {
    position: 'absolute',
    right: spacing.md,
    bottom: spacing.md,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: colors.accent,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: colors.accent,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
});
