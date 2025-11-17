import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { ScreenContainer } from '../../components/shared/ScreenContainer';
import { theme } from '../../constants/theme';

export function GroupsTab() {
  return (
    <ScreenContainer>
      <View style={styles.container}>
        <Text style={styles.title}>Groups</Text>
        <Text style={styles.subtitle}>Coming soon...</Text>
      </View>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    ...theme.typography.h2,
    color: theme.colors.text,
    marginBottom: theme.spacing.sm,
  },
  subtitle: {
    ...theme.typography.body,
    color: theme.colors.textSecondary,
  },
});

