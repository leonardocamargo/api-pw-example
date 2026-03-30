import React, { useState } from 'react';
import { View, Text, ScrollView, TextInput, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
import { colors, spacing, radius } from '../../src/theme';
import {
  ProviderCategory, categoryConfig, PixKeyType, pixKeyConfig,
  PaymentFrequency, frequencyConfig,
} from '../../src/types';
import { insertProvider } from '../../src/services/supabase';
import { supabase } from '../../src/services/supabase';
import { PrimaryButton } from '../../src/components';

export default function AddProviderScreen() {
  const router = useRouter();
  const [name, setName] = useState('');
  const [category, setCategory] = useState<ProviderCategory>('casa');
  const [pixKeyType, setPixKeyType] = useState<PixKeyType>('cpf');
  const [pixKey, setPixKey] = useState('');
  const [amount, setAmount] = useState('');
  const [frequency, setFrequency] = useState<PaymentFrequency>('mensal');
  const [dueDay, setDueDay] = useState('1');
  const [notes, setNotes] = useState('');
  const [saving, setSaving] = useState(false);

  const isValid = name.trim() && pixKey.trim() && parseFloat(amount) > 0;

  const handleSave = async () => {
    if (!isValid) return;
    setSaving(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      await insertProvider({
        user_id: user?.id ?? '',
        name: name.trim(),
        category,
        pix_key: pixKey.trim(),
        pix_key_type: pixKeyType,
        default_amount: parseFloat(amount.replace(',', '.')),
        frequency,
        due_day: parseInt(dueDay) || 1,
        notes: notes.trim() || undefined,
        is_active: true,
      });
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      router.back();
    } catch (e: any) {
      Alert.alert('Erro', e.message || 'Erro ao salvar prestador');
    } finally {
      setSaving(false);
    }
  };

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false} keyboardShouldPersistTaps="handled">
      {/* Name */}
      <Text style={styles.label}>Nome do prestador</Text>
      <TextInput
        style={styles.input}
        placeholder="Ex: João Jardineiro"
        placeholderTextColor={colors.textTertiary}
        value={name}
        onChangeText={setName}
      />

      {/* Category */}
      <Text style={styles.label}>Categoria</Text>
      <View style={styles.chipRow}>
        {(Object.keys(categoryConfig) as ProviderCategory[]).map((cat) => (
          <TouchableOpacity
            key={cat}
            style={[styles.chip, category === cat && styles.chipActive]}
            onPress={() => { setCategory(cat); Haptics.selectionAsync(); }}
          >
            <Text style={[styles.chipText, category === cat && styles.chipTextActive]}>
              {categoryConfig[cat].label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Pix Key Type */}
      <Text style={styles.label}>Tipo de chave Pix</Text>
      <View style={styles.chipRow}>
        {(Object.keys(pixKeyConfig) as PixKeyType[]).map((type) => (
          <TouchableOpacity
            key={type}
            style={[styles.chip, pixKeyType === type && styles.chipActive]}
            onPress={() => { setPixKeyType(type); Haptics.selectionAsync(); }}
          >
            <Text style={[styles.chipText, pixKeyType === type && styles.chipTextActive]}>
              {pixKeyConfig[type].label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Pix Key */}
      <Text style={styles.label}>Chave Pix</Text>
      <TextInput
        style={styles.input}
        placeholder={pixKeyConfig[pixKeyType].placeholder}
        placeholderTextColor={colors.textTertiary}
        keyboardType={pixKeyConfig[pixKeyType].keyboard}
        value={pixKey}
        onChangeText={setPixKey}
        autoCapitalize="none"
      />

      {/* Amount */}
      <Text style={styles.label}>Valor (R$)</Text>
      <View style={styles.moneyRow}>
        <Text style={styles.moneyPrefix}>R$</Text>
        <TextInput
          style={styles.moneyInput}
          placeholder="0,00"
          placeholderTextColor={colors.textTertiary}
          keyboardType="decimal-pad"
          value={amount}
          onChangeText={setAmount}
        />
      </View>

      {/* Frequency */}
      <Text style={styles.label}>Frequência</Text>
      <View style={styles.chipRow}>
        {(Object.keys(frequencyConfig) as PaymentFrequency[]).map((freq) => (
          <TouchableOpacity
            key={freq}
            style={[styles.chip, frequency === freq && styles.chipActive]}
            onPress={() => { setFrequency(freq); Haptics.selectionAsync(); }}
          >
            <Text style={[styles.chipText, frequency === freq && styles.chipTextActive]}>
              {frequencyConfig[freq].label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Due Day */}
      <Text style={styles.label}>Dia de vencimento</Text>
      <TextInput
        style={[styles.input, { width: 80 }]}
        placeholder="1"
        placeholderTextColor={colors.textTertiary}
        keyboardType="number-pad"
        value={dueDay}
        onChangeText={setDueDay}
        maxLength={2}
      />

      {/* Notes */}
      <Text style={styles.label}>Observações (opcional)</Text>
      <TextInput
        style={[styles.input, { height: 80 }]}
        placeholder="Ex: Pagar sempre pela manhã"
        placeholderTextColor={colors.textTertiary}
        value={notes}
        onChangeText={setNotes}
        multiline
        textAlignVertical="top"
      />

      {/* Save */}
      <PrimaryButton
        title="Salvar Prestador"
        icon="checkmark-circle"
        onPress={handleSave}
        isLoading={saving}
        disabled={!isValid}
        style={{ marginTop: spacing.lg, marginBottom: spacing.xxxl }}
      />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background, padding: spacing.md },
  label: { fontSize: 12, fontWeight: '500', color: colors.textSecondary, marginTop: spacing.lg, marginBottom: spacing.sm },
  input: {
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.border,
    paddingHorizontal: spacing.md,
    height: 52,
    fontSize: 16,
    color: colors.textPrimary,
  },
  chipRow: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
  chip: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    borderRadius: radius.full,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
  },
  chipActive: { backgroundColor: colors.accent, borderColor: colors.accent },
  chipText: { fontSize: 12, fontWeight: '500', color: colors.textSecondary },
  chipTextActive: { color: colors.white },
  moneyRow: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.border,
    paddingHorizontal: spacing.md,
    height: 52,
    gap: spacing.sm,
  },
  moneyPrefix: { fontSize: 16, fontWeight: '500', color: colors.textTertiary, fontVariant: ['tabular-nums'] },
  moneyInput: { flex: 1, fontSize: 20, fontWeight: '600', color: colors.textPrimary, fontVariant: ['tabular-nums'] },
});
