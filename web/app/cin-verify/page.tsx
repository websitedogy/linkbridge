"use client";

import { FormEvent, useState } from "react";

const cinPattern = /^([LU])(\d{5})([A-Z]{2})(\d{4})([A-Z]{3})(\d{6})$/;

const states: Record<string, string> = {
  AP: "Andhra Pradesh",
  AR: "Arunachal Pradesh",
  AS: "Assam",
  BR: "Bihar",
  CG: "Chhattisgarh",
  CH: "Chandigarh",
  DL: "Delhi",
  GA: "Goa",
  GJ: "Gujarat",
  HR: "Haryana",
  HP: "Himachal Pradesh",
  JH: "Jharkhand",
  JK: "Jammu and Kashmir",
  KA: "Karnataka",
  KL: "Kerala",
  LA: "Ladakh",
  MH: "Maharashtra",
  ML: "Meghalaya",
  MN: "Manipur",
  MP: "Madhya Pradesh",
  MZ: "Mizoram",
  NL: "Nagaland",
  OD: "Odisha",
  OR: "Odisha",
  PB: "Punjab",
  PY: "Puducherry",
  RJ: "Rajasthan",
  SK: "Sikkim",
  TN: "Tamil Nadu",
  TG: "Telangana",
  TS: "Telangana",
  TR: "Tripura",
  UK: "Uttarakhand",
  UP: "Uttar Pradesh",
  WB: "West Bengal",
};

const companyTypes: Record<string, string> = {
  PTC: "Private limited company",
  PLC: "Public limited company",
  OPC: "One person company",
  NPL: "Section 8 company",
  FTC: "Subsidiary of a foreign company",
  GAP: "General association public",
  GAT: "General association private",
  GOI: "Government of India company",
  SGC: "State government company",
  ULL: "Public unlimited company",
  ULT: "Private unlimited company",
};

type CinResult = {
  cin: string;
  listing: string;
  nic: string;
  state: string;
  year: string;
  type: string;
  registration: string;
};

export default function CinVerifyPage() {
  const [cin, setCin] = useState("");
  const [error, setError] = useState("");
  const [result, setResult] = useState<CinResult | null>(null);

  function onSubmit(event: FormEvent) {
    event.preventDefault();
    const value = cin.toUpperCase().replace(/[^A-Z0-9]/g, "");
    const match = cinPattern.exec(value);

    if (!match) {
      setResult(null);
      setError("Enter a 21-character CIN, such as U72900TG2020PTC123456.");
      return;
    }

    const [, listing, nic, state, year, type, registration] = match;
    setError("");
    setCin(value);
    setResult({
      cin: value,
      listing: listing === "L" ? "Listed company" : "Unlisted company",
      nic,
      state: states[state] ? `${states[state]} (${state})` : state,
      year,
      type: companyTypes[type] ? `${companyTypes[type]} (${type})` : type,
      registration,
    });
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="text-3xl font-semibold text-[#0F3D2F]">CIN Verify</h1>
      <p className="mt-2 text-sm text-[#1F2937]/70">
        Check the shape of an Indian Corporate Identification Number and read the parts encoded in it.
      </p>
      <form onSubmit={onSubmit} className="mt-6 rounded-2xl bg-white p-5 shadow-[0_8px_24px_rgba(31,41,55,0.06)]">
        <label className="block text-sm font-medium" htmlFor="cin">
          Corporate Identification Number
        </label>
        <input
          id="cin"
          value={cin}
          onChange={(event) => setCin(event.target.value.toUpperCase())}
          placeholder="U72900TG2020PTC123456"
          maxLength={21}
          className="mt-2 w-full rounded-xl border border-[#0F3D2F]/20 px-3 py-3 tracking-wide text-[#1F2937] uppercase outline-none focus:border-[#0F3D2F]"
        />
        <button type="submit" className="mt-4 rounded-xl bg-[#0F3D2F] px-4 py-2.5 text-sm font-semibold text-[#FBF8F1]">
          Verify CIN
        </button>
        {error ? <p className="mt-3 text-sm text-[#1F2937]">{error}</p> : null}
      </form>
      {result ? (
        <dl className="mt-5 grid gap-3 rounded-2xl bg-[#0F3D2F] p-5 text-[#FBF8F1] sm:grid-cols-2">
          <Item label="CIN" value={result.cin} />
          <Item label="Listing" value={result.listing} />
          <Item label="NIC code" value={result.nic} />
          <Item label="State" value={result.state} />
          <Item label="Year" value={result.year} />
          <Item label="Company type" value={result.type} />
          <Item label="Registration number" value={result.registration} />
        </dl>
      ) : null}
    </div>
  );
}

function Item({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <dt className="text-xs tracking-wide text-[#d4af37]">{label}</dt>
      <dd className="mt-1 text-sm font-medium">{value}</dd>
    </div>
  );
}
