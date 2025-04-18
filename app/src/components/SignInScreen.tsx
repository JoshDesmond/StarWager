import { View, Text } from 'react-native';

export function SignInScreen() {
  return (
    <View className={styles.container}>
      <Text className={styles.title}>StarWager</Text>
      <Text className={styles.subtitle}>Sign in to continue</Text>
      {/* Google Sign In Button will go here */}
    </View>
  );
}

const styles = {
  container: `flex-1 items-center justify-center p-5`,
  title: `text-2xl font-bold mb-2.5`,
  subtitle: `text-base text-gray-600 mb-5`,
}; 