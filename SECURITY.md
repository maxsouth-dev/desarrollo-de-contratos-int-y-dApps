# SECURITY.md, AcademicCredentials

## Evidencia de ejecución de Slither

```
slither-analyzer 0.11.5
python3 -m slither .
22 contratos analizados, 101 detectores, 48 resultados
```

Comando ejecutado desde la raíz del repositorio:
```bash
python3 -m slither .
```

---

## Findings de Slither

| # | Finding | Severidad | Archivo | ¿Real? | Resolución / Justificación |
|---|---------|-----------|---------|--------|---------------------------|
| 1 | `incorrect-exp`, operador `^` (XOR) en lugar de `**` (exponenciación) | High | `lib/openzeppelin-contracts/contracts/utils/math/Math.sol:256` | No | Falso positivo. OpenZeppelin usa XOR intencionalmente en el algoritmo de inversión modular de `mulDiv`. No es código propio. |
| 2 | `divide-before-multiply`, multiplicación sobre resultado de división | Medium | `lib/openzeppelin-contracts/contracts/utils/math/Math.sol:239-271` | No | Falso positivo. Patrón matemático intencional en el algoritmo de `mulDiv` de OZ para aritmética de 512 bits. No es código propio. |
| 3 | `timestamp`, uso de timestamp en comparaciones | Low | `src/AcademicCredentials.sol:128,144` | No | Falso positivo. Las funciones `revoke` y `verify` comparan el campo booleano `active`, no timestamps. `block.timestamp` solo se usa para almacenar `issueDate` en el momento de emisión, nunca para comparaciones de control. |
| 4 | `assembly`, uso de ensamblador inline | Informational | `lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Utils.sol` | No | Código estándar de OZ para detectar si un receptor es un contrato. No es código propio. |
| 5 | `solc-version`, pragmas demasiado amplios (`>=0.4.16`, `>=0.5.0`, `>=0.6.2`) | Informational | Interfaces de OZ | No | Las interfaces de OZ usan pragmas amplios por compatibilidad. El contrato propio usa `^0.8.20`, que es la versión recomendada con protección nativa contra overflow. |
| 6 | `too-many-digits`, literales con muchos dígitos | Informational | `lib/openzeppelin-contracts/contracts/utils/Bytes.sol`, `Math.sol` | No | Constantes hexadecimales de bitmasks en utilidades de OZ. No es código propio. |
| 7 | `pragma`, distintas versiones de Solidity en el proyecto (`^0.8.20`, `>=0.8.4`, `>=0.4.16`, `>=0.6.2`) | Informational | Imports de OpenZeppelin y forge-std | No | Falso positivo para el código propio. Las versiones amplias provienen de las librerías importadas. `AcademicCredentials.sol` usa `^0.8.20` de forma consistente. |

**Resumen:** ninguno de los findings afecta código propio del contrato. Los detectores apuntan exclusivamente a librerías de OpenZeppelin, que son código auditado y de referencia en la industria.

---

## Checklist de seguridad

| Ítem | Estado | Detalle |
|------|--------|---------|
| Solidity ^0.8.20, protección nativa contra overflow | ✅ | `pragma solidity ^0.8.20` |
| `AccessControl` correctamente aplicado | ✅ | `ISSUER_ROLE` y `DEFAULT_ADMIN_ROLE` definidos y usados |
| Eventos en todas las mutaciones de estado | ✅ | `CredentialIssued`, `CredentialRevoked`, `IssuerGranted`, `IssuerRevoked` |
| Validación de inputs: no `address(0)` | ✅ | `require(student != address(0), ...)` en `issueCredential` |
| Validación de inputs: no hashes vacíos | ✅ | Checks en `studentNameHash` y `documentHash` |
| Validación de inputs: no nombre de grado vacío | ✅ | `require(bytes(degreeName).length > 0, ...)` |
| Soulbound correctamente implementado | ✅ | `_update` revierte si `from != 0 && to != 0` |
| No uso de `selfdestruct` | ✅ | No presente en el contrato |
| No uso de `delegatecall` arbitrario | ✅ | No presente en el contrato |
| No uso de `tx.origin` para autenticación | ✅ | No presente en el contrato |
| `documentHash` como `bytes32`, no como string | ✅ | Eficiencia de gas e integridad garantizada |

---

## Análisis de seguridad propio

### 1. Pérdida de la wallet con `DEFAULT_ADMIN_ROLE`

**Escenario:** el rector pierde acceso a la wallet que desplegó el contrato (pérdida de clave privada, robo, fallecimiento).

**Impacto:** nadie puede otorgar ni revocar `ISSUER_ROLE`. Los emisores actuales siguen funcionando pero no se pueden agregar nuevos ni remover comprometidos.

**Situación en el contrato:** no hay mecanismo de recuperación. `DEFAULT_ADMIN_ROLE` queda bloqueado permanentemente.

**Mitigación recomendada:** al desplegar, otorgar `DEFAULT_ADMIN_ROLE` a al menos dos wallets institucionales (ej. rector y secretaria general). En producción, usar un multisig (Gnosis Safe) como titular del rol admin.

---

### 2. Compromiso de una wallet con `ISSUER_ROLE`

**Escenario:** un atacante obtiene la clave privada de un emisor (decano).

**Impacto:** puede emitir credenciales falsas indefinidamente hasta que el admin revoque el rol. Cada credencial falsa queda registrada en blockchain con trazabilidad permanente, lo que facilita la auditoría posterior.

**Situación en el contrato:** el admin puede ejecutar `revokeIssuer(address)` para detener la emisión maliciosa. Las credenciales falsas ya emitidas deben ser revocadas una por una con `revoke(tokenId, reason)`.

**Mitigación recomendada:** monitorear eventos `CredentialIssued` on-chain. Usar multisig para el rol issuer también, requiriendo firma de al menos 2 de 3.

---

### 3. Corrección de credenciales emitidas incorrectamente

**Escenario:** se emite una credencial con datos erróneos (nombre mal escrito, grado incorrecto).

**Impacto:** el estudiante tiene un NFT inválido. No se puede "editar" porque blockchain es inmutable.

**Situación en el contrato:** el emisor puede llamar `revoke(tokenId, "Datos incorrectos")` y luego emitir un nuevo tokenId con los datos correctos. Ambas transacciones quedan registradas, preservando la auditabilidad.

**Sin pérdida de auditabilidad:** el evento `CredentialRevoked` incluye el motivo, quedando evidencia de la corrección.

---

### 4. Riesgo de front-running en mempool

**Escenario:** un atacante monitorea el mempool y ve una transacción de `issueCredential` pendiente. Intenta replicarla con el mismo `tokenId` antes de que se mine.

**Impacto real:** bajo. El atacante necesitaría tener `ISSUER_ROLE` para ejecutar `issueCredential`. Sin ese rol, la transacción revertirá. El front-running solo es posible entre emisores autorizados, escenario improbable en una institución.

---

### 5. Ataque de diccionario contra `studentNameHash`

**Escenario:** `studentNameHash` es el `keccak256` del nombre del estudiante. Un atacante con acceso al hash puede intentar un ataque de diccionario probando nombres comunes hasta encontrar una coincidencia.

**Impacto:** los nombres son un espacio finito y predecible (especialmente en Argentina). Un ataque de diccionario podría revelar el nombre del titular del diploma.

**Mitigación recomendada:** en lugar de `keccak256(nombre)` puro, usar `keccak256(abi.encodePacked(nombre, salt))` donde `salt` es un valor aleatorio conocido solo por la institución. Esto hace el hash resistente a ataques de diccionario sin cambiar la interfaz pública del contrato.
