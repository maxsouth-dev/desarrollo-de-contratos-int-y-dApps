# AcademicCredentials

Contrato ERC-721 soulbound para emitir títulos académicos verificables on-chain, con control de acceso por roles. Desplegado en Base Sepolia.

## Setup

```bash
git clone https://github.com/maxsouth-dev/desarrollo-de-contratos-int-y-dApps.git
cd desarrollo-de-contratos-int-y-dApps
forge install
forge build
forge test
forge coverage
```

## Comandos

```bash
forge build              # compilar
forge test               # tests
forge test -vvv          # tests con detalle
forge coverage           # cobertura
anvil                    # nodo local
```

## Deploy a Base Sepolia

Copiar `.env.example` a `.env` y completar `PRIVATE_KEY` con la clave de una wallet descartable fondeada en el faucet de Base Sepolia.

```bash
source .env

forge script script/Deploy.s.sol \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## Emitir una credencial

```bash
source .env
export ADDR=<dirección del contrato>
export STUDENT=<wallet del estudiante>

cast send $ADDR \
  "issueCredential(address,uint256,string,bytes32,bytes32,string)" \
  $STUDENT 1 "Licenciatura en Sistemas" \
  $(cast keccak "Juan Perez") \
  $(cast keccak "pdf-bytes-placeholder") \
  "ipfs://bafy.../credential-1.json" \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY
```

## Verificar una credencial

```bash
cast call $ADDR "verify(uint256)" 1 --rpc-url $BASE_SEPOLIA_RPC_URL
```

## Eventos

| Evento | Cuándo se emite |
|--------|-----------------|
| `CredentialIssued(student, tokenId, degreeName, studentNameHash)` | Al emitir una credencial |
| `CredentialRevoked(tokenId, by, reason)` | Al revocar una credencial |
| `IssuerGranted(account, by)` | Al otorgar `ISSUER_ROLE` |
| `IssuerRevoked(account, by)` | Al revocar `ISSUER_ROLE` |

## Tests

34 tests, incluye 3 fuzz tests, con 100% de cobertura sobre `src/AcademicCredentials.sol`.

```bash
forge test
forge coverage
```

## Funciones del contrato

| Función | Rol requerido | Descripción |
|---------|--------------|-------------|
| `grantIssuer(address)` | `DEFAULT_ADMIN_ROLE` | Otorga `ISSUER_ROLE` a un emisor |
| `revokeIssuer(address)` | `DEFAULT_ADMIN_ROLE` | Revoca `ISSUER_ROLE` de un emisor |
| `issueCredential(student, tokenId, degreeName, studentNameHash, documentHash, metadataURI)` | `ISSUER_ROLE` | Emite una credencial y almacena todos los campos |
| `revoke(tokenId, reason)` | `ISSUER_ROLE` | Revoca una credencial con motivo |
| `verify(tokenId)` | Cualquiera | Retorna `(Credential, isValid)` |

## Frontend

Next.js 14 + wagmi v2 + RainbowKit, en [`frontend/`](frontend/). Verificador público por `tokenId` y formulario de emisión para wallets con `ISSUER_ROLE`.

```bash
cd frontend
npm install
npm run dev   # http://localhost:3000
```

Configuración:

1. Crear `frontend/.env.local` con `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=<id de https://cloud.reown.com/>`
2. `CREDENTIALS_ADDRESS` en `frontend/contracts/credentials.ts` ya viene configurada con el contrato deployado en Base Sepolia

## Seguridad

Análisis de Slither y análisis propio en [SECURITY.md](SECURITY.md).
