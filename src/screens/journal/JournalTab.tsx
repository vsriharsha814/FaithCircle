import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { ScreenContainer } from '../../components/shared/ScreenContainer';
import { theme } from '../../constants/theme';
import { JournalTodayScreen } from './JournalTodayScreen';
import { JournalHistoryScreen } from './JournalHistoryScreen';
import { JournalDetailScreen } from './JournalDetailScreen';

const Stack = createNativeStackNavigator();

function JournalHomeScreen() {
  return (
    <ScreenContainer>
      <View style={styles.container}>
        <Text style={styles.title}>Bible Journal</Text>
        <Text style={styles.subtitle}>Coming soon...</Text>
      </View>
    </ScreenContainer>
  );
}

export function JournalTab() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: theme.colors.background,
        },
        headerTintColor: theme.colors.text,
        headerTitleStyle: {
          fontWeight: '600',
        },
      }}
    >
      <Stack.Screen 
        name="JournalHome" 
        component={JournalHomeScreen}
        options={{ title: 'Journal' }}
      />
      <Stack.Screen 
        name="JournalToday" 
        component={JournalTodayScreen}
        options={{ title: 'Today\'s Entry' }}
      />
      <Stack.Screen 
        name="JournalHistory" 
        component={JournalHistoryScreen}
        options={{ title: 'History' }}
      />
      <Stack.Screen 
        name="JournalDetail" 
        component={JournalDetailScreen}
        options={{ title: 'Entry' }}
      />
    </Stack.Navigator>
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

