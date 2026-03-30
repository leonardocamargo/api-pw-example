import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet, TextInput } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { colors, spacing, radius, formatBRL } from '../../src/theme';
import { Provider, categoryConfig, ProviderCategory } from '../../src/types';
import { fetchProviders } from '../../src/services/supabase';
import { Avatar, EmptyState } from '../../src/components';

export default function ProvidersScreen() {
  const router = useRouter();
  const [providers, setProviders] = useState<Provider[]>([]);
  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<ProviderCategory | null>(null);

  useEffect(() => {
    fetchProviders().then(setProviders).catch(() => setProviders([]));
  }, []);

  const filtered = providers.filter((p) => {
    if (selectedCategory && p.category !== selectedCategory) return false;
    if (search && !p.name.toLowerCase().includes(search.toLowerCase())) return false;
    return true;
  });

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Search */}
      <View style={styles.searchBox}>
        <Ionicons name="search" size={16} color={colors.textTertiary} />
        <TextInput
          style={styles.searchInput}
          placeholder="Buscar prestador"
          placeholderTextColor={colors.textTertiary}
          value={search}
          onChangeText={setSearch}
        />
      </View>

      {/* Category chips */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.chips}>
        <TouchableOpacity
          style={[styles.chip, !selectedCategory && styles.chipActive]}
          onPress={() => setSelectedCategory(null)}
        >
          <Text style={[styles.chipText, !selectedCategory && styles.chipTextActive]}>Todos</Text>
        </TouchableOpacity>
        {(Object.keys(categoryConfig) as ProviderCategory[]).map((cat) => (
          <TouchableOpacity
            key={cat}
            style={[styles.chip, selectedCategory === cat && styles.chipActive]}
            onPress={() => setSelectedCategory(selectedCategory === cat ? null : cat)}
          >
            <Text style={[styles.chipText, selectedCategory === cat && styles.chipTextActive]}>
              {categoryConfig[cat].label}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* List */}
      {filtered.length === 0 ? (
        <EmptyState
          icon="people"
          title="Nenhum prestador"
          description="Adicione seus prestadores de serviço para começar."
          actionTitle="Adicionar"
          onAction={() => router.push('/provider/add')}
        />
      ) : (
        <View style={styles.list}>
          {filtered.map((provider) => (
            <TouchableOpacity
              key={provider.id}
              style={styles.providerRow}
              onPress={() => router.push(`/provider/${provider.id}`)}
            >
              <Avatar name={provider.name} />
              <View style={styles.providerInfo}>
                <Text style={styles.providerName}>{provider.name}</Text>
                <Text style={styles.providerMeta}>
                  {categoryConfig[provider.category].label} · Dia {provider.due_day}
                </Text>
              </View>
              <View style={styles.providerRight}>
                <Text style={styles.providerAmount}>{formatBRL(provider.default_amount)}</Text>
                <Text style={styles.providerFreq}>{provider.frequency}</Text>
              </View>
            </TouchableOpacity>
          ))}
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background, padding: spacing.md },
  searchBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    paddingHorizontal: spacing.md,
    height: 44,
    gap: spacing.sm,
    marginBottom: spacing.md,
  },
  searchInput: { flex: 1, fontSize: 16, color: colors.textPrimary },
  chips: { marginBottom: spacing.lg },
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
  list: { gap: 0 },
  providerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm + 4,
    gap: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  providerInfo: { flex: 1, gap: spacing.xs },
  providerName: { fontSize: 16, fontWeight: '500', color: colors.textPrimary },
  providerMeta: { fontSize: 12, color: colors.textSecondary },
  providerRight: { alignItems: 'flex-end', gap: spacing.xs },
  providerAmount: { fontSize: 16, fontWeight: '500', color: colors.textPrimary, fontVariant: ['tabular-nums'] },
  providerFreq: { fontSize: 12, color: colors.textTertiary },
});
