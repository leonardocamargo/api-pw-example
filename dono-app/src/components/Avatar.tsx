import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors } from '../theme';

const avatarColors = [colors.accent, colors.success, colors.warning, '#8B7EC8', '#6BA3BE'];

interface Props {
  name: string;
  size?: number;
}

export function Avatar({ name, size = 48 }: Props) {
  const initial = name.charAt(0).toUpperCase();
  const colorIndex = Math.abs(hashCode(name)) % avatarColors.length;
  const bgColor = avatarColors[colorIndex];

  return (
    <View style={[styles.container, { width: size, height: size, backgroundColor: bgColor + '26' }]}>
      <Text style={[styles.initial, { fontSize: size * 0.4, color: bgColor }]}>{initial}</Text>
    </View>
  );
}

function hashCode(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash = (hash << 5) - hash + str.charCodeAt(i);
    hash |= 0;
  }
  return hash;
}

const styles = StyleSheet.create({
  container: {
    borderRadius: 999,
    alignItems: 'center',
    justifyContent: 'center',
  },
  initial: {
    fontWeight: '600',
  },
});
