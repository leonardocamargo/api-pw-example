import { createClient } from '@supabase/supabase-js';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Provider, Payment } from '../types';

// TODO: Substituir pelas suas credenciais do Supabase
const SUPABASE_URL = 'https://placeholder.supabase.co';
const SUPABASE_KEY = 'placeholder-anon-key';

export const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

// MARK: - Providers

export async function fetchProviders(): Promise<Provider[]> {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return [];

  const { data, error } = await supabase
    .from('providers')
    .select('*')
    .eq('user_id', user.id)
    .eq('is_active', true)
    .order('name');

  if (error) throw error;
  return data ?? [];
}

export async function insertProvider(provider: Omit<Provider, 'id' | 'created_at'>): Promise<void> {
  const { error } = await supabase.from('providers').insert(provider);
  if (error) throw error;
}

export async function updateProvider(id: string, updates: Partial<Provider>): Promise<void> {
  const { error } = await supabase.from('providers').update(updates).eq('id', id);
  if (error) throw error;
}

export async function deleteProvider(id: string): Promise<void> {
  const { error } = await supabase.from('providers').update({ is_active: false }).eq('id', id);
  if (error) throw error;
}

// MARK: - Payments

export async function fetchPayments(month?: Date): Promise<Payment[]> {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return [];

  let query = supabase
    .from('payments')
    .select('*, provider:providers(*)')
    .eq('user_id', user.id);

  if (month) {
    const start = new Date(month.getFullYear(), month.getMonth(), 1).toISOString().split('T')[0];
    const end = new Date(month.getFullYear(), month.getMonth() + 1, 1).toISOString().split('T')[0];
    query = query.gte('due_date', start).lt('due_date', end);
  }

  const { data, error } = await query.order('due_date');
  if (error) throw error;
  return data ?? [];
}

export async function fetchPendingPayments(): Promise<Payment[]> {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return [];

  const { data, error } = await supabase
    .from('payments')
    .select('*, provider:providers(*)')
    .eq('user_id', user.id)
    .eq('status', 'pending')
    .order('due_date');

  if (error) throw error;
  return data ?? [];
}

export async function markPaymentAsPaid(id: string): Promise<void> {
  const { error } = await supabase
    .from('payments')
    .update({ status: 'paid', paid_at: new Date().toISOString() })
    .eq('id', id);
  if (error) throw error;
}

export async function markPaymentAsSkipped(id: string): Promise<void> {
  const { error } = await supabase
    .from('payments')
    .update({ status: 'skipped' })
    .eq('id', id);
  if (error) throw error;
}

export async function insertPayment(payment: Omit<Payment, 'id' | 'created_at' | 'provider'>): Promise<void> {
  const { error } = await supabase.from('payments').insert(payment);
  if (error) throw error;
}
