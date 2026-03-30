import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  View,
  ViewStyle,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { colors, spacing, radius } from '../theme';

interface PrimaryButtonProps {
  title: string;
  onPress: () => void;
  icon?: keyof typeof Ionicons.glyphMap;
  isLoading?: boolean;
  disabled?: boolean;
  style?: ViewStyle;
}

export function PrimaryButton({ title, onPress, icon, isLoading, disabled, style }: PrimaryButtonProps) {
  const handlePress = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    onPress();
  };

  return (
    <TouchableOpacity
      style={[styles.primary, disabled && styles.disabled, style]}
      onPress={handlePress}
      disabled={isLoading || disabled}
      activeOpacity={0.85}
    >
      {isLoading ? (
        <ActivityIndicator color={colors.white} />
      ) : (
        <View style={styles.row}>
          {icon && <Ionicons name={icon} size={18} color={colors.white} style={{ marginRight: spacing.sm }} />}
          <Text style={styles.primaryText}>{title}</Text>
        </View>
      )}
    </TouchableOpacity>
  );
}

export function SecondaryButton({ title, onPress, icon, style }: Omit<PrimaryButtonProps, 'isLoading'>) {
  return (
    <TouchableOpacity
      style={[styles.secondary, style]}
      onPress={() => { Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light); onPress(); }}
      activeOpacity={0.85}
    >
      <View style={styles.row}>
        {icon && <Ionicons name={icon} size={16} color={colors.accent} style={{ marginRight: spacing.sm }} />}
        <Text style={styles.secondaryText}>{title}</Text>
      </View>
    </TouchableOpacity>
  );
}

export function GhostButton({ title, onPress, icon }: Omit<PrimaryButtonProps, 'isLoading'>) {
  return (
    <TouchableOpacity onPress={onPress} style={styles.ghost}>
      <View style={styles.row}>
        {icon && <Ionicons name={icon} size={14} color={colors.textSecondary} style={{ marginRight: spacing.xs }} />}
        <Text style={styles.ghostText}>{title}</Text>
      </View>
    </TouchableOpacity>
  );
}

export function PayButton({ bankName, amount, onPress, isLoading }: { bankName: string; amount: number; onPress: () => void; isLoading?: boolean }) {
  const formatted = amount.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

  return (
    <TouchableOpacity
      style={styles.payButton}
      onPress={() => { Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium); onPress(); }}
      disabled={isLoading}
      activeOpacity={0.85}
    >
      <View style={styles.row}>
        <Ionicons name="clipboard-outline" size={18} color={colors.white} style={{ marginRight: spacing.sm }} />
        <Text style={styles.payButtonText}>Copiar Pix e abrir {bankName}</Text>
      </View>
      <Text style={[styles.payButtonAmount]}>{formatted}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center' },
  primary: {
    backgroundColor: colors.accent,
    height: 56,
    borderRadius: radius.lg,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primaryText: { color: colors.white, fontSize: 17, fontWeight: '600' },
  disabled: { opacity: 0.5 },
  secondary: {
    backgroundColor: colors.accentSubtle,
    height: 56,
    borderRadius: radius.lg,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: colors.accent + '33',
  },
  secondaryText: { color: colors.accent, fontSize: 16, fontWeight: '500' },
  ghost: { alignItems: 'center', padding: spacing.sm },
  ghostText: { color: colors.textSecondary, fontSize: 16, fontWeight: '500' },
  payButton: {
    backgroundColor: colors.accent,
    height: 72,
    borderRadius: radius.xl,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: colors.accent,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.3,
    shadowRadius: 16,
    elevation: 8,
  },
  payButtonText: { color: colors.white, fontSize: 17, fontWeight: '600' },
  payButtonAmount: { color: colors.white, fontSize: 16, fontWeight: '500', opacity: 0.8, marginTop: 2, fontVariant: ['tabular-nums'] },
});
