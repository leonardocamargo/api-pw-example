import React, { useState } from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { colors, spacing, radius } from '../../src/theme';
import { PrimaryButton, GhostButton } from '../../src/components';

const { width } = Dimensions.get('window');

const pages = [
  {
    icon: 'home' as const,
    title: 'Cuide do que\né seu',
    description: 'Organize todos os pagamentos da sua casa em um só lugar. Jardineiro, contador, piscineiro — tudo sob controle.',
    color: colors.accent,
  },
  {
    icon: 'notifications' as const,
    title: 'Nunca mais\nesqueça',
    description: 'Receba lembretes no dia certo. Com um toque, copie o Pix e abra seu banco. Pagamento feito em segundos.',
    color: colors.success,
  },
  {
    icon: 'bar-chart' as const,
    title: 'Veja pra\nonde vai',
    description: 'Acompanhe quanto gasta por mês, por categoria. Tenha clareza sobre seus custos recorrentes.',
    color: colors.warning,
  },
];

export default function OnboardingScreen() {
  const router = useRouter();
  const [page, setPage] = useState(0);
  const current = pages[page];

  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <View style={[styles.iconCircle, { backgroundColor: current.color + '1A' }]}>
          <Ionicons name={current.icon} size={48} color={current.color} />
        </View>

        <Text style={styles.title}>{current.title}</Text>
        <Text style={styles.description}>{current.description}</Text>
      </View>

      {/* Dots */}
      <View style={styles.dots}>
        {pages.map((_, i) => (
          <View key={i} style={[styles.dot, page === i && styles.dotActive]} />
        ))}
      </View>

      {/* Buttons */}
      <View style={styles.buttons}>
        {page < 2 ? (
          <>
            <PrimaryButton title="Continuar" onPress={() => setPage(page + 1)} />
            <GhostButton title="Pular" onPress={() => router.replace('/(tabs)')} />
          </>
        ) : (
          <PrimaryButton title="Começar" icon="arrow-forward" onPress={() => router.replace('/(tabs)')} />
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  content: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingHorizontal: spacing.lg },
  iconCircle: { width: 120, height: 120, borderRadius: 60, alignItems: 'center', justifyContent: 'center', marginBottom: spacing.xl },
  title: { fontSize: 32, fontWeight: '700', color: colors.textPrimary, textAlign: 'center', lineHeight: 40, letterSpacing: -0.5, marginBottom: spacing.md },
  description: { fontSize: 16, color: colors.textSecondary, textAlign: 'center', lineHeight: 24, paddingHorizontal: spacing.lg },
  dots: { flexDirection: 'row', justifyContent: 'center', gap: spacing.sm, marginBottom: spacing.xl },
  dot: { width: 8, height: 8, borderRadius: 4, backgroundColor: colors.divider },
  dotActive: { width: 24, backgroundColor: colors.accent },
  buttons: { paddingHorizontal: spacing.lg, paddingBottom: spacing.xxl, gap: spacing.md },
});
