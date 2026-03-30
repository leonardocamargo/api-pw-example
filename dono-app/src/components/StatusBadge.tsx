import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { PaymentStatus, statusConfig } from '../types';

interface Props {
  status: PaymentStatus;
}

export function StatusBadge({ status }: Props) {
  const config = statusConfig[status];
  return (
    <View style={[styles.badge, { backgroundColor: config.bgColor }]}>
      <Text style={[styles.text, { color: config.color }]}>{config.label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  badge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 999,
  },
  text: {
    fontSize: 12,
    fontWeight: '500',
  },
});
