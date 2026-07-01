'use client';

import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useAccount, useReadContract } from 'wagmi';
import {
  CREDENTIALS_ADDRESS,
  CREDENTIALS_ABI,
  ISSUER_ROLE,
} from '../contracts/credentials';
import { Verifier } from './components/Verifier';
import { IssueCredentialForm } from './components/IssueCredentialForm';

export default function Home() {
  const { address, isConnected } = useAccount();

  const { data: isIssuer } = useReadContract({
    address: CREDENTIALS_ADDRESS,
    abi: CREDENTIALS_ABI,
    functionName: 'hasRole',
    args: address ? [ISSUER_ROLE, address] : undefined,
  });

  return (
    <main style={{ maxWidth: 880, margin: '0 auto', padding: '2rem 1.5rem' }}>
      <header style={{ marginBottom: '2rem' }}>
        <h1 style={{ color: '#A6192E', margin: 0 }}>UNQ · Credenciales académicas</h1>
        <p style={{ color: '#6B7280', marginTop: 4 }}>
          Verificación de títulos universitarios sobre Base Sepolia (L2). El rol
          de la wallet conectada determina lo que ves abajo.
        </p>
        <div style={{ marginTop: 16 }}>
          <ConnectButton />
        </div>
      </header>

      {/* Modo público — verificador (siempre visible, sin wallet) */}
      <Verifier />

      {/* Modo issuer — solo si la wallet conectada tiene ISSUER_ROLE */}
      {isConnected && isIssuer && <IssueCredentialForm />}

      {isConnected && !isIssuer && (
        <p style={{ color: '#6B7280', fontSize: 14 }}>
          La wallet conectada no tiene <code>ISSUER_ROLE</code>. Solo podés
          verificar credenciales. Si sos issuer, pedile al admin que te asigne
          el rol con <code>grantIssuer(tuAddress)</code>.
        </p>
      )}

      <footer style={{ marginTop: '3rem', fontSize: 13, color: '#9CA3AF' }}>
        UNQ · Diplomatura en Blockchain · Trabajo final · Starter repo
      </footer>
    </main>
  );
}
