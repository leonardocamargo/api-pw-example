import React from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import { colors, spacing, radius, formatBRL } from '../../src/theme';
import { Avatar } from '../../src/components';

export default function ProviderDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();

  // In production: fetch provider by id
  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      <View style={styles.header}>
        <Avatar name="Prestador" size={72} />
        <Text style={styles.name}>Prestador</Text>
        <Text style={styles.meta}>Carregando detalhes...</Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  header: { alignItems: 'center', paddingVertical: spacing.xl, gap: spacing.md },
  name: { fontSize: 24, fontWeight: '700', color: colors.textPrimary },
  meta: { fontSize: 14, color: colors.textSecondary },
});
