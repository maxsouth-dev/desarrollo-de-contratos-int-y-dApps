'use client';

import { useState } from 'react';
import { useReadContract } from 'wagmi';
import { CREDENTIALS_ADDRESS, CREDENTIALS_ABI } from '../../contracts/credentials';

/** Public verifier — no wallet required to use. */
export function Verifier() {
  const [tokenIdInput, setTokenIdInput] = useState('');
  const [queryId, setQueryId] = useState<bigint | null>(null);

  const { data, isLoading, error } = useReadContract({
    address: CREDENTIALS_ADDRESS,
    abi: CREDENTIALS_ABI,
    functionName: 'verify',
    args: queryId !== null ? [queryId] : undefined,
    query: { enabled: queryId !== null },
  });

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    try {
      setQueryId(BigInt(tokenIdInput));
    } catch {
      setQueryId(null);
    }
  }

  const record = data?.[0];
  const isValid = data?.[1];

  return (
    <section
      style={{
        background: '#fff',
        border: '1px solid #E5E7EB',
        borderLeft: '5px solid #A6192E',
        borderRadius: 8,
        padding: '1.5rem',
        marginBottom: '1.5rem',
      }}
    >
      <h2 style={{ marginTop: 0, color: '#A6192E' }}>Verificar credencial</h2>
      <p style={{ color: '#6B7280', marginTop: 0 }}>
        Cualquier persona (empleador, oficina pública, etc) puede consultar un{' '}
        <code>tokenId</code> y ver si la UNQ emitió ese título.
      </p>

      <form onSubmit={handleSubmit} style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
        <input
          type="number"
          value={tokenIdInput}
          onChange={(e) => setTokenIdInput(e.target.value)}
          placeholder="Token ID (ej. 1)"
          style={{ flex: 1, padding: '0.5rem', border: '1px solid #ccc', borderRadius: 4 }}
        />
        <button
          type="submit"
          style={{
            padding: '0.5rem 1.5rem',
            background: '#A6192E',
            color: '#fff',
            border: 'none',
            borderRadius: 4,
            cursor: 'pointer',
            fontWeight: 600,
          }}
        >
          Verificar
        </button>
      </form>

      {isLoading && <p>Consultando blockchain…</p>}
      {error && <p style={{ color: 'crimson' }}>Error: {error.message}</p>}

      {record && (
        <div
          style={{
            background: isValid ? '#F0FDF4' : '#FEF2F2',
            border: `1px solid ${isValid ? '#86EFAC' : '#FCA5A5'}`,
            borderRadius: 6,
            padding: '1rem',
            marginTop: 8,
          }}
        >
          <h3 style={{ margin: 0, color: isValid ? '#15803D' : '#B91C1C' }}>
            {isValid ? '✅ Credencial válida' : '❌ Credencial NO válida'}
          </h3>
          <dl style={{ marginTop: 12, marginBottom: 0 }}>
            <Row label="Título" value={record.degreeName} />
            <Row
              label="Fecha de emisión"
              value={new Date(Number(record.issueDate) * 1000).toLocaleDateString('es-AR')}
            />
            <Row label="Hash del nombre" value={record.studentNameHash} mono />
            <Row label="Hash del PDF" value={record.documentHash} mono />
            <Row label="Estado" value={record.active ? 'Activa' : 'Revocada'} />
          </dl>
        </div>
      )}
    </section>
  );
}

function Row({ label, value, mono }: { label: string; value: string; mono?: boolean }) {
  return (
    <div style={{ display: 'flex', gap: 8, padding: '4px 0', fontSize: 14 }}>
      <dt style={{ width: 160, fontWeight: 600, color: '#6B7280' }}>{label}</dt>
      <dd
        style={{
          margin: 0,
          fontFamily: mono ? '"SF Mono", Menlo, monospace' : 'inherit',
          fontSize: mono ? 12 : 14,
          wordBreak: 'break-all',
        }}
      >
        {value}
      </dd>
    </div>
  );
}
