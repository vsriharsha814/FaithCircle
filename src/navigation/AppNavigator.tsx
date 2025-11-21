import React, { useState, useEffect } from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { ActivityIndicator, View } from 'react-native';
import { theme } from '../constants/theme';
import { useAuth } from '../hooks/useAuth';

// Auth Screens
import { LoginScreen } from '../screens/auth/LoginScreen';

// Tab Screens
import { JournalTab } from '../screens/journal/JournalTab';
import { SermonsTab } from '../screens/sermons/SermonsTab';
import { VerseLockerTab } from '../screens/verses/VerseLockerTab';
import { GroupsTab } from '../screens/groups/GroupsTab';

const AuthStack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.textSecondary,
        tabBarStyle: {
          borderTopColor: theme.colors.border,
        },
      }}
    >
      <Tab.Screen 
        name="Journal" 
        component={JournalTab}
        options={{
          tabBarIcon: ({ color, size }) => null, // Add icons later
        }}
      />
      <Tab.Screen 
        name="Sermons" 
        component={SermonsTab}
        options={{
          tabBarIcon: ({ color, size }) => null,
        }}
      />
      <Tab.Screen 
        name="VerseLocker" 
        component={VerseLockerTab}
        options={{
          tabBarLabel: 'Verses',
          tabBarIcon: ({ color, size }) => null,
        }}
      />
      <Tab.Screen 
        name="Groups" 
        component={GroupsTab}
        options={{
          tabBarIcon: ({ color, size }) => null,
        }}
      />
    </Tab.Navigator>
  );
}

export function AppNavigator() {
  const { user, loading } = useAuth();

  // Add maximum loading time - show login after 3 seconds regardless
  const [forceShow, setForceShow] = React.useState(false);
  
  React.useEffect(() => {
    const timer = setTimeout(() => {
      if (loading) {
        console.log('⏰ Force showing login screen after 3s timeout');
        setForceShow(true);
      }
    }, 3000);

    return () => clearTimeout(timer);
  }, [loading]);

  if (loading && !forceShow) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
      </View>
    );
  }

  return (
    <>
      {user ? (
        <MainTabs />
      ) : (
        <AuthStack.Navigator screenOptions={{ headerShown: false }}>
          <AuthStack.Screen name="Login" component={LoginScreen} />
        </AuthStack.Navigator>
      )}
    </>
  );
}

