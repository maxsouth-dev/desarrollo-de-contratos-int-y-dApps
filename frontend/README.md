# UNQ · Credenciales académicas — Frontend starter (TP final)

Starter del **frontend** del trabajo final de la diplomatura en Blockchain de UNQ. Está cableado con `wagmi v2` + `RainbowKit` + `Next.js 14` para que **no tengan que armar todo desde cero**: forkean, cambian dos cosas y arrancan.

## Lo que ya viene resuelto

- Conexión de wallet (MetaMask + cualquiera vía WalletConnect).
- Routing por rol (`hasRole(ISSUER_ROLE, ...)`) — la UI cambia según la wallet conectada.
- **Modo público (verificador)**: form para ingresar `tokenId` y mostrar la credencial, lee `verify(tokenId)` del contrato.
- **Modo issuer**: form para emitir credenciales (hashea el nombre + DNI en el navegador, manda solo el hash al contrato).
- Configurado para **Base Sepolia** (L2, chain ID `84532`).

## Lo que tienen que hacer ustedes

1. **Deployar el contrato** en Base Sepolia (parte 1, 2, 3 del TP).
2. **Pegar la address** en `contracts/credentials.ts` → constante `CREDENTIALS_ADDRESS`.
3. **Pegar el ABI** que les genera `forge build` en el mismo archivo (o dejen el que está si su contrato matchea las firmas).
4. **Crear un WalletConnect Project ID** en <https://cloud.reown.com/> y ponerlo en `.env.local`:

   ```
   NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=tu_id_aca
   ```

5. `npm install && npm run dev` → <http://localhost:3000>.

## Bonus (suman puntos en el TP)

- **Modo super-admin** (`DEFAULT_ADMIN_ROLE`): agregar un componente `IssuerAdmin` con form para asignar/quitar el rol `ISSUER_ROLE`.
- **Pinata/IPFS real**: en `IssueCredentialForm`, en lugar de mandar un `metadataURI` placeholder, subir el PDF a Pinata desde el navegador y mandar el CID real + el hash del PDF.
- **QR code** del verificador.
- **Indexer con The Graph** para listar todas las credenciales emitidas.

## Estructura

```
.
├── app/
│   ├── layout.tsx
│   ├── providers.tsx               # wagmi + RainbowKit + react-query
│   ├── page.tsx                    # routing por rol
│   └── components/
│       ├── Verifier.tsx            # modo público
│       └── IssueCredentialForm.tsx # modo issuer
├── contracts/
│   └── credentials.ts              # address + ABI + role hashes
└── wagmi.ts                        # config de chains + WalletConnect
```

## Deploy a producción (parte del TP)

Recomendado: **Vercel** (free tier, conectan el repo fork y deploya solo). Cualquier hosting de Next.js sirve. La URL pública del verificador es uno de los entregables — tiene que andar.

## Stack

| Lib | Versión | Para qué |
|---|---|---|
| Next.js | 14 (App Router) | Framework React |
| wagmi | 2.x | Hooks para leer/escribir on-chain |
| viem | 2.x | Cliente Ethereum (lo usa wagmi por debajo) |
| RainbowKit | 2.x | Botón de "Connect Wallet" listo |
| @tanstack/react-query | 5.x | Cache de lecturas (lo pide wagmi) |

## Spec del TP

<https://dpetrocelli.github.io/diplounq2026/tp-final.html>

## Si algo no anda

- `npm install` falla → `node --version` tiene que ser ≥ 18 (mejor 20). `nvm install 20` si hace falta.
- `WalletConnect Project ID is not valid` → revisar `.env.local`.
- "Wrong network" → MetaMask tiene que estar en Base Sepolia (chain ID `84532`). Lo agrega solo cuando hagas la primera tx.
- Verificación devuelve datos vacíos → `CREDENTIALS_ADDRESS` mal pegada o el contrato no fue deployado en Base Sepolia.

Lo demás, foro del campus.
