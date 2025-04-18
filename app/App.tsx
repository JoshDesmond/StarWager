import { SignInScreen } from '~/components/SignInScreen';
import { StatusBar } from 'expo-status-bar';

import './global.css';

export default function App() {
  return (
    <>
      <SignInScreen />
      <StatusBar style="auto" />
    </>
  );
}
