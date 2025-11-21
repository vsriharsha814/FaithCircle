import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { ScreenContainer } from '../../components/shared/ScreenContainer';
import { PrimaryButton } from '../../components/shared/PrimaryButton';
import { ErrorMessage } from '../../components/shared/ErrorMessage';
import { useAuth } from '../../hooks/useAuth';
import { theme } from '../../constants/theme';

export function LoginScreen() {
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { signInWithGoogle } = useAuth();

  const handleGoogleSignIn = async () => {
    setError('');
    setLoading(true);

    try {
      console.log('🔵 LoginScreen: Starting Google sign-in...');
      await signInWithGoogle();
      console.log('🔵 LoginScreen: Sign-in successful!');
    } catch (err: any) {
      console.error('🔴 LoginScreen: Sign-in error caught:', err);
      console.error('   Error message:', err?.message);
      console.error('   Error code:', err?.code);
      console.error('   Original error:', err?.originalError);
      
      const errorMessage = err?.message || err?.originalError?.message || 'Sign in failed. Please try again.';
      setError(errorMessage);
      
      // Also log to help with debugging
      if (__DEV__) {
        console.error('Full error details:', err);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScreenContainer scrollable style={styles.content}>
      <View style={styles.header}>
        <Text style={styles.title}>Faith Circle</Text>
        <Text style={styles.subtitle}>Sign in to continue</Text>
      </View>

      <View style={styles.form}>
        {error ? <ErrorMessage message={error} /> : null}

        <TouchableOpacity
          style={[styles.googleButton, loading && styles.googleButtonDisabled]}
          onPress={handleGoogleSignIn}
          disabled={loading}
          activeOpacity={0.7}
        >
          <View style={styles.googleIconContainer}>
            <Text style={styles.googleIconText}>G</Text>
          </View>
          <Text style={styles.googleButtonText}>
            {loading ? 'Signing in...' : 'Continue with Google'}
          </Text>
        </TouchableOpacity>

        <View style={styles.footer}>
          <Text style={styles.footerText}>
            By signing in, you agree to our terms of service and privacy policy
          </Text>
        </View>
      </View>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  content: {
    justifyContent: 'center',
    paddingHorizontal: theme.spacing.lg,
  },
  header: {
    alignItems: 'center',
    marginBottom: theme.spacing.xxl,
  },
  title: {
    ...theme.typography.h1,
    color: theme.colors.primary,
    marginBottom: theme.spacing.sm,
  },
  subtitle: {
    ...theme.typography.body,
    color: theme.colors.textSecondary,
    textAlign: 'center',
  },
  form: {
    width: '100%',
  },
  googleButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: theme.colors.background,
    borderWidth: 1,
    borderColor: theme.colors.border,
    borderRadius: theme.borderRadius.md,
    paddingVertical: theme.spacing.md,
    paddingHorizontal: theme.spacing.lg,
    minHeight: 56,
    ...theme.shadows.sm,
  },
  googleButtonDisabled: {
    opacity: 0.6,
  },
  googleIconContainer: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: '#4285F4', // Google blue
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: theme.spacing.md,
  },
  googleIconText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
  googleButtonText: {
    ...theme.typography.bodyBold,
    color: theme.colors.text,
  },
  footer: {
    marginTop: theme.spacing.xl,
    paddingHorizontal: theme.spacing.md,
  },
  footerText: {
    ...theme.typography.small,
    color: theme.colors.textSecondary,
    textAlign: 'center',
    lineHeight: 18,
  },
});

