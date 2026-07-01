import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { baseSepolia } from 'wagmi/chains';

// Free WalletConnect / Reown Cloud project — replace before deploying.
const projectId = process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || 'YOUR_WALLETCONNECT_PROJECT_ID';

export const config = getDefaultConfig({
  appName: 'UNQ Academic Credentials',
  projectId,
  chains: [baseSepolia],
  ssr: true,
});
