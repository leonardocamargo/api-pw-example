import React, { useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { colors, spacing, radius } from '../../src/theme';
import { Payment } from '../../src/types';
import { PaymentCard } from '../../src/components';

const DAYS = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

export default function CalendarScreen() {
  const router = useRouter();
  const [currentMonth, setCurrentMonth] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [payments] = useState<Payment[]>([]);

  const year = currentMonth.getFullYear();
  const month = currentMonth.getMonth();
  const firstDay = new Date(year, month, 1).getDay();
  const daysInMonth = new Date(year, month + 1, 0).getDate();

  const monthLabel = currentMonth.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });

  const prevMonth = () => setCurrentMonth(new Date(year, month - 1, 1));
  const nextMonth = () => setCurrentMonth(new Date(year, month + 1, 1));

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

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Month nav */}
      <View style={styles.monthNav}>
        <TouchableOpacity onPress={prevMonth}><Ionicons name="chevron-back" size={20} color={colors.textSecondary} /></TouchableOpacity>
        <Text style={styles.monthLabel}>{monthLabel}</Text>
        <TouchableOpacity onPress={nextMonth}><Ionicons name="chevron-forward" size={20} color={colors.textSecondary} /></TouchableOpacity>
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
                  isToday(day) && { color: colors.accent, fontWeight: '700' },
                  isSelected(day) && { color: colors.white },
                ]}>
                  {day}
                </Text>
              </View>
            )}
          </TouchableOpacity>
        ))}
      </View>

      {/* Selected day info */}
      <View style={styles.selectedSection}>
        <Text style={styles.selectedLabel}>
          {selectedDate.toLocaleDateString('pt-BR', { day: 'numeric', month: 'long' })}
        </Text>
        <Text style={styles.noPayments}>Nenhum pagamento neste dia</Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  monthNav: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: spacing.lg },
  monthLabel: { fontSize: 18, fontWeight: '600', color: colors.textPrimary, textTransform: 'capitalize' },
  daysRow: { flexDirection: 'row', paddingHorizontal: spacing.md, marginBottom: spacing.sm },
  dayHeader: { flex: 1, textAlign: 'center', fontSize: 12, fontWeight: '500', color: colors.textTertiary },
  grid: { flexDirection: 'row', flexWrap: 'wrap', paddingHorizontal: spacing.md },
  dayCell: { width: '14.28%', alignItems: 'center', paddingVertical: spacing.xs },
  dayInner: { width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center' },
  selectedDay: { backgroundColor: colors.accent },
  dayText: { fontSize: 14, color: colors.textPrimary },
  selectedSection: { padding: spacing.lg, gap: spacing.sm },
  selectedLabel: { fontSize: 17, fontWeight: '600', color: colors.textPrimary },
  noPayments: { fontSize: 14, color: colors.textTertiary, paddingVertical: spacing.xl, textAlign: 'center' },
});
