import { Linking, Platform } from 'react-native';
import * as Clipboard from 'expo-clipboard';
import * as Haptics from 'expo-haptics';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { BankApp, allBanks } from '../types';
import { generateBRCode } from './pix';

const PREFERRED_BANK_KEY = 'preferred_bank_id';
const BANK_OPENED_AT_KEY = 'last_bank_opened_at';

export async function detectInstalledBanks(): Promise<BankApp[]> {
  if (Platform.OS !== 'ios') return allBanks; // Android can't check

  const installed: BankApp[] = [];
  for (const bank of allBanks) {
    try {
      const canOpen = await Linking.canOpenURL(bank.urlScheme);
      if (canOpen) installed.push(bank);
    } catch {
      // ignore
    }
  }
  return installed;
}

export async function openBank(bank: BankApp): Promise<boolean> {
  try {
    const canOpen = await Linking.canOpenURL(bank.urlScheme);
    if (canOpen) {
      await AsyncStorage.setItem(BANK_OPENED_AT_KEY, new Date().toISOString());
      await Linking.openURL(bank.urlScheme);
      return true;
    }
  } catch {
    // ignore
  }
  return false;
}

export async function copyPixAndOpenBank(
  pixKey: string,
  merchantName: string,
  amount: number,
  bank?: BankApp
): Promise<boolean> {
  // 1. Generate BR Code
  const brCode = generateBRCode(pixKey, merchantName, 'SAO PAULO', amount);

  // 2. Copy to clipboard
  await Clipboard.setStringAsync(brCode);
  await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);

  // 3. Small delay
  await new Promise((r) => setTimeout(r, 300));

  // 4. Open bank
  const targetBank = bank ?? (await getPreferredBank());
  if (targetBank) {
    return openBank(targetBank);
  }

  return false;
}

export async function getPreferredBank(): Promise<BankApp | null> {
  const bankId = await AsyncStorage.getItem(PREFERRED_BANK_KEY);
  if (!bankId) return null;
  return allBanks.find((b) => b.id === bankId) ?? null;
}

export async function setPreferredBank(bank: BankApp): Promise<void> {
  await AsyncStorage.setItem(PREFERRED_BANK_KEY, bank.id);
}

export async function didReturnFromBank(): Promise<boolean> {
  const openedAt = await AsyncStorage.getItem(BANK_OPENED_AT_KEY);
  if (!openedAt) return false;

  const elapsed = (Date.now() - new Date(openedAt).getTime()) / 1000;
  return elapsed < 300 && elapsed > 3;
}

export async function clearBankOpenedMark(): Promise<void> {
  await AsyncStorage.removeItem(BANK_OPENED_AT_KEY);
}
