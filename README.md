# Clase 3 — MyToken (ERC-20 con OpenZeppelin)

Diplomatura Blockchain UNQ — Módulo 3.

## ¿Qué es esto?

Un token ERC-20 (`MyToken`, símbolo `MTK`) construido sobre OpenZeppelin con `Ownable` para mint, y burn público. Listo para compilar, testear y deployar con Foundry.

## Pre-requisitos

- Foundry (`forge`, `cast`, `anvil`) — si no lo tenés: `curl -L https://foundry.paradigm.xyz | bash && foundryup`
- Cuenta de MetaMask en **Sepolia** con ETH de testnet
- VS Code + extensión `juanblanco.solidity`

## Setup

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase3.git
cd diplo-unq-blockchain-clase3
forge install foundry-rs/forge-std --shallow
forge install OpenZeppelin/openzeppelin-contracts --shallow
forge build
forge test
```

Tienen que ver `14 passed; 0 failed`.

## Comandos clave

```bash
forge build              # compilar
forge test               # tests
forge test -vvv          # con detalle
anvil                    # blockchain local
```

### Deploy local (con anvil corriendo en otra terminal)

```bash
forge create src/MyToken.sol:MyToken \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

### Deploy a Sepolia

```bash
cast wallet import dev-wallet --interactive  # solo la primera vez

forge create src/MyToken.sol:MyToken \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet \
  --broadcast
```

## Estructura

```
.
├── foundry.toml
├── remappings.txt
├── src/
│   └── MyToken.sol           # ERC-20 + Ownable + mint + burn
├── test/
│   └── MyToken.t.sol         # 14 tests (transfers, mint, burn, fuzz)
└── script/
    └── Deploy.s.sol
```

## Tarea para clase 4

1. Hacer mint de tokens a otra address (alice de tu MetaMask)
2. Postear el address del MyToken deployado en Sepolia + el hash de la tx de mint en el foro del campus
3. Verificar el contrato en Etherscan con `forge verify-contract`
