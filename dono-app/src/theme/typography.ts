import { TextStyle } from 'react-native';

export const typography: Record<string, TextStyle> = {
  displayLarge: {
    fontFamily: 'PlayfairDisplay-Bold',
    fontSize: 32,
    letterSpacing: -0.5,
  },
  displayMedium: {
    fontFamily: 'PlayfairDisplay-SemiBold',
    fontSize: 24,
    letterSpacing: -0.3,
  },
  displaySmall: {
    fontFamily: 'PlayfairDisplay-Medium',
    fontSize: 20,
  },
  headline: {
    fontSize: 17,
    fontWeight: '600',
  },
  body: {
    fontSize: 16,
    fontWeight: '400',
  },
  bodyMedium: {
    fontSize: 16,
    fontWeight: '500',
  },
  subheadline: {
    fontSize: 14,
    fontWeight: '400',
  },
  caption: {
    fontSize: 12,
    fontWeight: '400',
  },
  captionMedium: {
    fontSize: 12,
    fontWeight: '500',
  },
  moneyLarge: {
    fontSize: 32,
    fontWeight: '700',
    fontVariant: ['tabular-nums'],
  },
  moneyMedium: {
    fontSize: 20,
    fontWeight: '600',
    fontVariant: ['tabular-nums'],
  },
  moneySmall: {
    fontSize: 16,
    fontWeight: '500',
    fontVariant: ['tabular-nums'],
  },
};
