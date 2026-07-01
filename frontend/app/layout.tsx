import { Providers } from './providers';

export const metadata = {
  title: 'UNQ Academic Credentials',
  description: 'Sistema de verificación de títulos UNQ on-chain (Base Sepolia)',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body
        style={{
          margin: 0,
          fontFamily:
            '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
          background: '#FAF9F6',
          color: '#1F2937',
        }}
      >
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
