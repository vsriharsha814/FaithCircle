import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AuthProvider } from './src/hooks/useAuth';
import { AppNavigator } from './src/navigation/AppNavigator';

// Global error handler to catch any unhandled errors
if (__DEV__) {
  const originalError = console.error;
  console.error = (...args: any[]) => {
    originalError.apply(console, args);
    // Also log to help debug
    if (args[0]?.toString().includes('Error') || args[0]?.message) {
      console.log('🚨 Unhandled error detected:', args);
    }
  };

  // Catch unhandled promise rejections
  if (typeof global !== 'undefined') {
    const rejectionHandler = (event: any) => {
      console.error('🚨 Unhandled promise rejection:', event.reason);
      console.error('   Stack:', event.reason?.stack);
    };
    // @ts-ignore
    if (global.addEventListener) {
      // @ts-ignore
      global.addEventListener('unhandledrejection', rejectionHandler);
    }
  }
}

export default function App() {
  console.log('🚀 App starting...');
  
  return (
    <SafeAreaProvider>
      <AuthProvider>
        <NavigationContainer>
          <AppNavigator />
        </NavigationContainer>
      </AuthProvider>
    </SafeAreaProvider>
  );
}

