'use client';

import { useState } from 'react';
import { keccak256, toHex } from 'viem';
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { CREDENTIALS_ADDRESS, CREDENTIALS_ABI } from '../../contracts/credentials';

/**
 * Issuer-only form to mint a new credential.
 *
 * The frontend hashes the student's full name + DNI on the client so the
 * cleartext never hits the chain. Same for the PDF: the issuer pastes the
 * IPFS CID of the file, and we hash a known representation off-chain.
 */
export function IssueCredentialForm() {
  const [studentAddress, setStudentAddress] = useState('');
  const [tokenId, setTokenId] = useState('');
  const [degreeName, setDegreeName] = useState('Licenciatura en Sistemas de Información');
  const [studentName, setStudentName] = useState('');
  const [studentDni, setStudentDni] = useState('');
  const [pdfHashInput, setPdfHashInput] = useState('');
  const [metadataURI, setMetadataURI] = useState('');

  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: confirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();

    const studentNameHash = keccak256(toHex(`${studentName}|${studentDni}`));
    const documentHash = keccak256(toHex(pdfHashInput || metadataURI));

    writeContract({
      address: CREDENTIALS_ADDRESS,
      abi: CREDENTIALS_ABI,
      functionName: 'issueCredential',
      args: [
        studentAddress as `0x${string}`,
        BigInt(tokenId),
        degreeName,
        studentNameHash,
        documentHash,
        metadataURI,
      ],
    });
  }

  return (
    <section
      style={{
        background: '#fff',
        border: '1px solid #E5E7EB',
        borderLeft: '5px solid #54533F',
        borderRadius: 8,
        padding: '1.5rem',
        marginBottom: '1.5rem',
      }}
    >
      <h2 style={{ marginTop: 0, color: '#54533F' }}>Emitir credencial (issuer)</h2>

      <form onSubmit={handleSubmit} style={{ display: 'grid', gap: 12 }}>
        <Field
          label="Address del estudiante"
          value={studentAddress}
          onChange={setStudentAddress}
          placeholder="0x…"
        />
        <Field
          label="Token ID"
          type="number"
          value={tokenId}
          onChange={setTokenId}
          placeholder="1"
        />
        <Field
          label="Título"
          value={degreeName}
          onChange={setDegreeName}
        />
        <Field
          label="Nombre completo del estudiante (se hashea en el browser)"
          value={studentName}
          onChange={setStudentName}
          placeholder="Juan Pérez"
        />
        <Field
          label="DNI (se hashea en el browser)"
          value={studentDni}
          onChange={setStudentDni}
          placeholder="12345678"
        />
        <Field
          label="Identificador del PDF (CID o filename)"
          value={pdfHashInput}
          onChange={setPdfHashInput}
          placeholder="bafy…/titulo.pdf"
        />
        <Field
          label="Metadata URI (IPFS)"
          value={metadataURI}
          onChange={setMetadataURI}
          placeholder="ipfs://bafy…/credential.json"
        />

        <button
          type="submit"
          disabled={isPending || confirming}
          style={{
            padding: '0.75rem',
            background: '#54533F',
            color: '#fff',
            border: 'none',
            borderRadius: 4,
            cursor: isPending || confirming ? 'wait' : 'pointer',
            fontWeight: 600,
            fontSize: 15,
          }}
        >
          {isPending
            ? 'Confirmá en la wallet…'
            : confirming
              ? 'Esperando confirmación…'
              : 'Emitir credencial'}
        </button>
      </form>

      {isSuccess && (
        <p style={{ color: 'green', marginTop: 12 }}>
          ✅ Credencial emitida. Tx{' '}
          <a
            href={`https://sepolia.basescan.org/tx/${hash}`}
            target="_blank"
            rel="noopener noreferrer"
          >
            {hash?.slice(0, 14)}…
          </a>
        </p>
      )}
      {error && (
        <p style={{ color: 'crimson', marginTop: 12 }}>Error: {error.message}</p>
      )}
    </section>
  );
}

function Field({
  label,
  value,
  onChange,
  type = 'text',
  placeholder,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  type?: string;
  placeholder?: string;
}) {
  return (
    <label style={{ display: 'block', fontSize: 14, color: '#374151' }}>
      <span style={{ display: 'block', marginBottom: 4, fontWeight: 600 }}>{label}</span>
      <input
        type={type}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        style={{ width: '100%', padding: '0.5rem', border: '1px solid #ccc', borderRadius: 4 }}
      />
    </label>
  );
}
