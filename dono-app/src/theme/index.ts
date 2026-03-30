export { colors } from './colors';
export { typography } from './typography';
export { spacing, radius } from './spacing';

export function formatBRL(amount: number): string {
  return amount.toLocaleString('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  });
}
