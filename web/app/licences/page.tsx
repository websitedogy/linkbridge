import Link from "next/link";

const licences = [
  { name: "LLP", detail: "Limited Liability Partnership", count: "4 companies" },
  { name: "Pvt Ltd", detail: "Private limited company", count: "14 companies" },
  { name: "OPC", detail: "One Person Company", count: "4 companies" },
  { name: "Section 8 Company", detail: "Not-for-profit company", count: "4 companies" },
  { name: "Nidhi Company", detail: "Mutual benefit company", count: "4 companies" },
  { name: "Producer Company", detail: "Producer company", count: "4 companies" },
];

export default function LicencesPage() {
  return (
    <div>
      <h1 className="text-3xl font-semibold text-[#0F3D2F]">Licences</h1>
      <p className="mt-2 max-w-2xl text-sm text-[#1F2937]/70">
        Choose a company type. Each card opens the live marketplace with that keyword.
      </p>
      <div className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {licences.map((licence) => (
          <Link
            key={licence.name}
            href={`/buy?keyword=${encodeURIComponent(licence.name)}`}
            className="rounded-2xl bg-white p-5 shadow-[0_8px_24px_rgba(31,41,55,0.06)]"
          >
            <p className="text-lg font-semibold text-[#1F2937]">{licence.name}</p>
            <p className="mt-1 text-sm text-[#1F2937]/70">{licence.detail}</p>
            <p className="mt-3 text-sm font-medium text-[#0F3D2F]">{licence.count}</p>
          </Link>
        ))}
      </div>
    </div>
  );
}
