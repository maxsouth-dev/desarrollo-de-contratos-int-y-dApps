// Replace with the address you deployed on Base Sepolia.
export const CREDENTIALS_ADDRESS = '0x0000000000000000000000000000000000000000' as const;

export const ISSUER_ROLE =
  '0x114e74f6ea3bd819998f78687bfcb11b140da08e9b7d222fa9c1f1ba1f2aa122' as const; // keccak256("ISSUER_ROLE")
export const DEFAULT_ADMIN_ROLE =
  '0x0000000000000000000000000000000000000000000000000000000000000000' as const;

export const CREDENTIALS_ABI = [
  // ----- Roles (AccessControl) -----
  {
    name: 'hasRole',
    type: 'function',
    stateMutability: 'view',
    inputs: [
      { name: 'role', type: 'bytes32' },
      { name: 'account', type: 'address' },
    ],
    outputs: [{ type: 'bool' }],
  },
  {
    name: 'grantIssuer',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [{ name: 'account', type: 'address' }],
    outputs: [],
  },
  {
    name: 'revokeIssuer',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [{ name: 'account', type: 'address' }],
    outputs: [],
  },

  // ----- Issue / Revoke -----
  {
    name: 'issueCredential',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'student', type: 'address' },
      { name: 'tokenId', type: 'uint256' },
      { name: 'degreeName', type: 'string' },
      { name: 'studentNameHash', type: 'bytes32' },
      { name: 'documentHash', type: 'bytes32' },
      { name: 'metadataURI', type: 'string' },
    ],
    outputs: [],
  },
  {
    name: 'revoke',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'tokenId', type: 'uint256' },
      { name: 'reason', type: 'string' },
    ],
    outputs: [],
  },

  // ----- Verify -----
  {
    name: 'verify',
    type: 'function',
    stateMutability: 'view',
    inputs: [{ name: 'tokenId', type: 'uint256' }],
    outputs: [
      {
        name: 'record',
        type: 'tuple',
        components: [
          { name: 'degreeName', type: 'string' },
          { name: 'studentNameHash', type: 'bytes32' },
          { name: 'issueDate', type: 'uint256' },
          { name: 'documentHash', type: 'bytes32' },
          { name: 'active', type: 'bool' },
        ],
      },
      { name: 'isValidCredential', type: 'bool' },
    ],
  },

  // ----- ERC-721 standard reads -----
  {
    name: 'ownerOf',
    type: 'function',
    stateMutability: 'view',
    inputs: [{ name: 'tokenId', type: 'uint256' }],
    outputs: [{ type: 'address' }],
  },
  {
    name: 'tokenURI',
    type: 'function',
    stateMutability: 'view',
    inputs: [{ name: 'tokenId', type: 'uint256' }],
    outputs: [{ type: 'string' }],
  },

  // ----- Events -----
  {
    name: 'CredentialIssued',
    type: 'event',
    inputs: [
      { name: 'student', type: 'address', indexed: true },
      { name: 'tokenId', type: 'uint256', indexed: true },
      { name: 'degreeName', type: 'string', indexed: false },
      { name: 'studentNameHash', type: 'bytes32', indexed: false },
    ],
  },
  {
    name: 'CredentialRevoked',
    type: 'event',
    inputs: [
      { name: 'tokenId', type: 'uint256', indexed: true },
      { name: 'by', type: 'address', indexed: true },
      { name: 'reason', type: 'string', indexed: false },
    ],
  },
] as const;
