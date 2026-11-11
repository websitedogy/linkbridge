export function formatMoney(minor: number | null | undefined, currency = "INR"): string {
  if (minor == null) {
    return "Undisclosed";
  }

  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency,
    maximumFractionDigits: 0,
  }).format(minor / 100);
}

export function formatRange(min: number | null, max: number | null, currency = "INR"): string {
  if (min == null && max == null) {
    return "Undisclosed";
  }

  if (min != null && max != null) {
    return `${formatMoney(min, currency)} – ${formatMoney(max, currency)}`;
  }

  return formatMoney(min ?? max, currency);
}
