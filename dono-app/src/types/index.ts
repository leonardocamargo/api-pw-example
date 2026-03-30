// MARK: - Provider Category
export type ProviderCategory = 'casa' | 'saude' | 'profissional' | 'educacao' | 'veiculo' | 'pet' | 'outro';

export const categoryConfig: Record<ProviderCategory, { label: string; icon: string; color: string }> = {
  casa: { label: 'Casa', icon: 'home', color: '#C4756E' },
  saude: { label: 'Saúde', icon: 'heart', color: '#7A9E7E' },
  profissional: { label: 'Profissional', icon: 'briefcase', color: '#6BA3BE' },
  educacao: { label: 'Educação', icon: 'book', color: '#8B7EC8' },
  veiculo: { label: 'Veículo', icon: 'car', color: '#D4A574' },
  pet: { label: 'Pet', icon: 'paw', color: '#C4A06E' },
  outro: { label: 'Outro', icon: 'ellipsis-horizontal-circle', color: '#8C7E6F' },
};

// MARK: - Pix Key Type
export type PixKeyType = 'cpf' | 'email' | 'telefone' | 'aleatoria';

export const pixKeyConfig: Record<PixKeyType, { label: string; icon: string; placeholder: string; keyboard: 'numeric' | 'email-address' | 'default' }> = {
  cpf: { label: 'CPF', icon: 'person', placeholder: '000.000.000-00', keyboard: 'numeric' },
  email: { label: 'E-mail', icon: 'mail', placeholder: 'email@exemplo.com', keyboard: 'email-address' },
  telefone: { label: 'Telefone', icon: 'call', placeholder: '+55 11 99999-9999', keyboard: 'numeric' },
  aleatoria: { label: 'Chave Aleatória', icon: 'key', placeholder: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', keyboard: 'default' },
};

// MARK: - Payment Frequency
export type PaymentFrequency = 'semanal' | 'quinzenal' | 'mensal' | 'bimestral' | 'trimestral' | 'avulso';

export const frequencyConfig: Record<PaymentFrequency, { label: string }> = {
  semanal: { label: 'Semanal' },
  quinzenal: { label: 'Quinzenal' },
  mensal: { label: 'Mensal' },
  bimestral: { label: 'Bimestral' },
  trimestral: { label: 'Trimestral' },
  avulso: { label: 'Avulso' },
};

// MARK: - Payment Status
export type PaymentStatus = 'pending' | 'paid' | 'overdue' | 'skipped';

export const statusConfig: Record<PaymentStatus, { label: string; icon: string; color: string; bgColor: string }> = {
  pending: { label: 'Pendente', icon: 'time', color: '#D4A574', bgColor: '#F5EDE4' },
  paid: { label: 'Pago', icon: 'checkmark-circle', color: '#7A9E7E', bgColor: '#E8F0E9' },
  overdue: { label: 'Atrasado', icon: 'warning', color: '#C4756E', bgColor: '#F5E6E4' },
  skipped: { label: 'Pulado', icon: 'arrow-forward-circle', color: '#B5A99A', bgColor: '#F5F0EB' },
};

// MARK: - Provider
export interface Provider {
  id: string;
  user_id: string;
  name: string;
  category: ProviderCategory;
  pix_key: string;
  pix_key_type: PixKeyType;
  default_amount: number;
  frequency: PaymentFrequency;
  due_day: number;
  notes?: string;
  is_active: boolean;
  created_at: string;
}

// MARK: - Payment
export interface Payment {
  id: string;
  user_id: string;
  provider_id: string;
  amount: number;
  due_date: string;
  paid_at?: string;
  status: PaymentStatus;
  notes?: string;
  receipt_url?: string;
  created_at: string;
  // Joined
  provider?: Provider;
}

// MARK: - Bank App
export interface BankApp {
  id: string;
  name: string;
  urlScheme: string;
  icon: string;
  color: string;
}

export const allBanks: BankApp[] = [
  { id: 'nubank', name: 'Nubank', urlScheme: 'nubank://', icon: 'N', color: '#820AD1' },
  { id: 'itau', name: 'Itaú', urlScheme: 'itau://', icon: 'I', color: '#EC7000' },
  { id: 'bradesco', name: 'Bradesco', urlScheme: 'bradesco://', icon: 'B', color: '#CC092F' },
  { id: 'bb', name: 'Banco do Brasil', urlScheme: 'bb://', icon: 'B', color: '#FEDF00' },
  { id: 'inter', name: 'Inter', urlScheme: 'bancointer://', icon: 'I', color: '#FF7A00' },
  { id: 'c6', name: 'C6 Bank', urlScheme: 'c6bank://', icon: 'C', color: '#2A2A2A' },
  { id: 'santander', name: 'Santander', urlScheme: 'santander://', icon: 'S', color: '#EC0000' },
  { id: 'picpay', name: 'PicPay', urlScheme: 'picpay://', icon: 'P', color: '#21C25E' },
  { id: 'mercadopago', name: 'Mercado Pago', urlScheme: 'mercadopago://', icon: 'M', color: '#009EE3' },
  { id: 'caixa', name: 'Caixa', urlScheme: 'caixa://', icon: 'C', color: '#005CA9' },
  { id: 'sicoob', name: 'Sicoob', urlScheme: 'sicoob://', icon: 'S', color: '#003641' },
  { id: 'sicredi', name: 'Sicredi', urlScheme: 'sicredi://', icon: 'S', color: '#33B44A' },
];
