"""
inspect_jnto.py — profile the raw JNTO workbook before writing any cleaning logic.

Reads with header=None so pandas doesn't guess wrong, then reports everything
you need to decide: which row is the real header, where the data starts,
which rows are subtotals, and what junk lives in the numeric columns.

Usage:
    python scripts/inspect_jnto.py data/raw/20260715_1615-5.xlsx
"""

import sys
import re
import pandas as pd

PREVIEW_ROWS = 30
SUBTOTAL_HINTS = [
    "total", "grand", "asia", "europe", "africa", "oceania",
    "america", "middle east", "計", "合計", "総数", "その他",
]


def profile_sheet(path, sheet):
    print("=" * 70)
    print(f"SHEET: {sheet!r}")
    print("=" * 70)

    df = pd.read_excel(path, sheet_name=sheet, header=None, dtype=object)
    print(f"shape (rows x cols): {df.shape}\n")

    # --- 1. Raw top rows, so you can eyeball the header block -------------
    print(f"--- first {PREVIEW_ROWS} rows, raw (no header assumed) ---")
    with pd.option_context("display.max_columns", 40, "display.width", 250):
        print(df.head(PREVIEW_ROWS).to_string())
    print()

    # --- 2. Last rows, where footnotes hide -------------------------------
    print("--- last 10 rows (footnote territory) ---")
    with pd.option_context("display.max_columns", 40, "display.width", 250):
        print(df.tail(10).to_string())
    print()

    # --- 3. Header-row candidates -----------------------------------------
    # A header row is mostly text and mostly non-null. A data row has numbers.
    print("--- header-row candidates (row idx: %non-null, %text) ---")
    for i in range(min(15, len(df))):
        row = df.iloc[i]
        filled = row.notna().mean()
        texty = row.apply(lambda v: isinstance(v, str)).mean()
        flag = "  <-- likely header" if filled > 0.5 and texty > 0.7 else ""
        print(f"  row {i:>2}: non-null {filled:5.0%}, text {texty:5.0%}{flag}")
    print()

    # --- 4. Subtotal / region rows in the first text column ---------------
    first_text_col = None
    for c in df.columns:
        if df[c].apply(lambda v: isinstance(v, str)).sum() > len(df) * 0.3:
            first_text_col = c
            break

    if first_text_col is not None:
        print(f"--- label column appears to be column {first_text_col} ---")
        labels = df[first_text_col].dropna().astype(str)
        hits = [v for v in labels if any(h in v.lower() for h in SUBTOTAL_HINTS)]
        print(f"rows matching subtotal/region hints ({len(hits)}):")
        for v in dict.fromkeys(hits):
            print(f"    {v!r}")
        print()
        print(f"unique labels ({labels.nunique()}) — first 60:")
        for v in list(dict.fromkeys(labels))[:60]:
            print(f"    {v!r}")
        print()

    # --- 5. Non-numeric junk sitting in value cells ------------------------
    print("--- non-numeric values found in cells (provisional markers etc.) ---")
    junk = {}
    for c in df.columns:
        for v in df[c].dropna():
            if isinstance(v, str):
                # anything that is a number wearing a costume
                if re.search(r"\d", v):
                    junk.setdefault(v, 0)
                    junk[v] += 1
    for v, n in sorted(junk.items(), key=lambda kv: -kv[1])[:30]:
        print(f"    {v!r}  x{n}")
    print()


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: python inspect_jnto.py <path-to-xlsx>")
    path = sys.argv[1]

    xl = pd.ExcelFile(path)
    print(f"FILE: {path}")
    print(f"SHEETS ({len(xl.sheet_names)}): {xl.sheet_names}\n")

    for sheet in xl.sheet_names:
        profile_sheet(path, sheet)


if __name__ == "__main__":
    main()
