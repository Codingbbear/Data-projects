"""
Pulls daily USD/JPY from Frankfurter (ECB reference rates, no key needed) and
aggregates to monthly mean + end-of-month close, per the project plan.

Usage:
    python fetch_fx_rates.py                      # 2015-01-01 through today
    python fetch_fx_rates.py --start 2020-01-01
"""
import argparse
from pathlib import Path

import pandas as pd
import requests

BASE_URL = "https://api.frankfurter.dev/v1"


def fetch_daily(start: str, end: str | None = None) -> pd.DataFrame:
    """
    Frankfurter's own base is EUR, and it only carries currencies against EUR.
    Requesting base=USD works (it cross-divides for you), but to get the exact
    same numbers JNTO-adjacent reporting uses, going through EUR and dividing
    ourselves is more transparent and lets us sanity-check the math.
    """
    range_str = f"{start}..{end}" if end else f"{start}.."
    resp = requests.get(f"{BASE_URL}/{range_str}", params={"to": "USD,JPY"})
    resp.raise_for_status()
    data = resp.json()["rates"]

    rows = [
        {"date": date, "eur_usd": vals["USD"], "eur_jpy": vals["JPY"]}
        for date, vals in data.items()
    ]
    df = pd.DataFrame(rows)
    df["date"] = pd.to_datetime(df["date"])
    df = df.sort_values("date").reset_index(drop=True)

    # Cross rate: how many JPY per USD = (JPY per EUR) / (USD per EUR)
    df["usd_jpy"] = df["eur_jpy"] / df["eur_usd"]
    return df[["date", "usd_jpy"]]


def to_monthly(daily: pd.DataFrame) -> pd.DataFrame:
    daily = daily.set_index("date")
    monthly = daily.resample("MS").agg(
        usd_jpy_avg=("usd_jpy", "mean"),
        usd_jpy_eom=("usd_jpy", "last"),
    ).round(3)
    monthly = monthly.reset_index().rename(columns={"date": "year_month"})
    return monthly


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--start", default="2015-01-01")
    ap.add_argument("--end", default=None)
    ap.add_argument("-o", "--output", type=Path, default=Path("data/clean/fx_monthly.csv"))
    args = ap.parse_args()

    daily = fetch_daily(args.start, args.end)
    monthly = to_monthly(daily)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    monthly.to_csv(args.output, index=False)

    print(f"{len(daily):,} daily observations -> {len(monthly)} months -> {args.output}")
    print(monthly.head())
    print("...")
    print(monthly.tail())


if __name__ == "__main__":
    main()