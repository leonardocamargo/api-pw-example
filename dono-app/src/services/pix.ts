// Pix BR Code Generator — EMV Standard (BCB)

function buildEMVField(tag: string, value: string): string {
  const length = value.length.toString().padStart(2, '0');
  return tag + length + value;
}

function sanitize(text: string, maxLength: number): string {
  return text
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toUpperCase()
    .replace(/[^A-Z0-9 ]/g, '')
    .substring(0, maxLength);
}

function calculateCRC16(payload: string): string {
  const polynomial = 0x1021;
  let crc = 0xffff;

  for (let i = 0; i < payload.length; i++) {
    crc ^= payload.charCodeAt(i) << 8;
    for (let j = 0; j < 8; j++) {
      if (crc & 0x8000) {
        crc = ((crc << 1) ^ polynomial) & 0xffff;
      } else {
        crc = (crc << 1) & 0xffff;
      }
    }
  }

  return crc.toString(16).toUpperCase().padStart(4, '0');
}

export function generateBRCode(
  pixKey: string,
  merchantName: string,
  merchantCity: string = 'SAO PAULO',
  amount?: number,
  txid?: string
): string {
  let payload = '';

  // Payload Format Indicator
  payload += buildEMVField('00', '01');

  // Merchant Account Info
  const gui = buildEMVField('00', 'br.gov.bcb.pix');
  const key = buildEMVField('01', pixKey);
  payload += buildEMVField('26', gui + key);

  // Merchant Category Code
  payload += buildEMVField('52', '0000');

  // Transaction Currency (986 = BRL)
  payload += buildEMVField('53', '986');

  // Transaction Amount
  if (amount && amount > 0) {
    payload += buildEMVField('54', amount.toFixed(2));
  }

  // Country Code
  payload += buildEMVField('58', 'BR');

  // Merchant Name
  payload += buildEMVField('59', sanitize(merchantName, 25));

  // Merchant City
  payload += buildEMVField('60', sanitize(merchantCity, 15));

  // Additional Data
  const txidField = buildEMVField('05', txid ? txid.substring(0, 25) : '***');
  payload += buildEMVField('62', txidField);

  // CRC16 placeholder
  payload += '6304';

  // Calculate and append CRC16
  const crc = calculateCRC16(payload);
  payload += crc;

  return payload;
}

export function detectPixKeyType(key: string): 'cpf' | 'email' | 'telefone' | 'aleatoria' {
  const cleaned = key.trim();

  if (/^\d{11}$|^\d{3}\.\d{3}\.\d{3}-\d{2}$/.test(cleaned)) return 'cpf';
  if (/^\+?55?\d{10,11}$/.test(cleaned)) return 'telefone';
  if (/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(cleaned)) return 'email';
  if (/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(cleaned)) return 'aleatoria';

  return 'aleatoria';
}
