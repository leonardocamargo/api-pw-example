import React from 'react';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { colors } from '../src/theme';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="dark" />
      <Stack
        screenOptions={{
          headerStyle: { backgroundColor: colors.background },
          headerTintColor: colors.textPrimary,
          headerShadowVisible: false,
          contentStyle: { backgroundColor: colors.background },
        }}
      >
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="payment/[id]" options={{ presentation: 'modal', headerTitle: 'Pagamento' }} />
        <Stack.Screen name="provider/add" options={{ presentation: 'modal', headerTitle: 'Novo Prestador' }} />
        <Stack.Screen name="provider/[id]" options={{ headerTitle: 'Prestador' }} />
        <Stack.Screen name="onboarding/index" options={{ headerShown: false }} />
      </Stack>
    </>
  );
}
