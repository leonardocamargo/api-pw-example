import React from 'react';
import { View, TouchableOpacity, StyleSheet, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
import { colors, spacing } from '../theme';

interface TabBarProps {
  state: any;
  descriptors: any;
  navigation: any;
}

const TAB_ICONS: Record<string, { active: string; inactive: string }> = {
  calendar: { active: 'calendar', inactive: 'calendar-outline' },
  history: { active: 'time', inactive: 'time-outline' },
  providers: { active: 'people', inactive: 'people-outline' },
  profile: { active: 'person', inactive: 'person-outline' },
};

export function CustomTabBar({ state, descriptors, navigation }: TabBarProps) {
  const router = useRouter();

  const handleAddPress = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    router.push('/provider/add');
  };

  // Split tabs into left (0,1) and right (2,3) around the center button
  const leftTabs = state.routes.slice(0, 2);
  const rightTabs = state.routes.slice(2, 4);

  const renderTab = (route: any, index: number, offsetIndex: number) => {
    const { options } = descriptors[route.key];
    const isFocused = state.index === offsetIndex;
    const iconConfig = TAB_ICONS[route.name] || { active: 'ellipse', inactive: 'ellipse-outline' };
    const iconName = isFocused ? iconConfig.active : iconConfig.inactive;

    const onPress = () => {
      const event = navigation.emit({ type: 'tabPress', target: route.key, canPreventDefault: true });
      if (!isFocused && !event.defaultPrevented) {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
        navigation.navigate(route.name);
      }
    };

    return (
      <TouchableOpacity
        key={route.key}
        style={styles.tab}
        onPress={onPress}
        accessibilityRole="button"
        accessibilityState={isFocused ? { selected: true } : {}}
        accessibilityLabel={options.tabBarAccessibilityLabel}
      >
        <Ionicons
          name={iconName as any}
          size={24}
          color={isFocused ? colors.accent : colors.textTertiary}
        />
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.wrapper}>
      <View style={styles.container}>
        {/* Left tabs */}
        {leftTabs.map((route: any, i: number) => renderTab(route, i, i))}

        {/* Center + button spacer */}
        <View style={styles.centerSpacer} />

        {/* Right tabs */}
        {rightTabs.map((route: any, i: number) => renderTab(route, i, i + 2))}
      </View>

      {/* Floating center + button */}
      <TouchableOpacity
        style={styles.centerButton}
        onPress={handleAddPress}
        activeOpacity={0.85}
      >
        <View style={styles.centerButtonInner}>
          <Ionicons name="add" size={32} color={colors.white} />
        </View>
      </TouchableOpacity>
    </View>
  );
}

const TAB_BAR_HEIGHT = 80;
const CENTER_BUTTON_SIZE = 64;

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    alignItems: 'center',
  },
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.white,
    height: TAB_BAR_HEIGHT,
    paddingBottom: Platform.OS === 'ios' ? 20 : 8,
    paddingHorizontal: spacing.lg,
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: -4 },
    shadowOpacity: 0.06,
    shadowRadius: 12,
    elevation: 12,
  },
  tab: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingTop: spacing.sm,
  },
  centerSpacer: {
    width: CENTER_BUTTON_SIZE + spacing.md,
  },
  centerButton: {
    position: 'absolute',
    top: -CENTER_BUTTON_SIZE / 2 + 8,
    alignSelf: 'center',
  },
  centerButtonInner: {
    width: CENTER_BUTTON_SIZE,
    height: CENTER_BUTTON_SIZE,
    borderRadius: CENTER_BUTTON_SIZE / 2,
    backgroundColor: colors.accent,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: colors.accent,
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.35,
    shadowRadius: 12,
    elevation: 10,
  },
});
