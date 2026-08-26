"""
build_fx_monthly.py — Phase 1 task 2.

Pulls daily USD/JPY reference rates from the Frankfurter API (ECB data),
from 2015-01-01 to today, and aggregates to one row per month:

    year_month | usd_jpy_avg | usd_jpy_eom | trading_days

  usd_jpy_avg  = mean of that month's daily rates
  usd_jpy_eom  = last available rate in the month (end-of-month close)
  trading_days = how many daily observations backed those numbers

Output: data/clean/fx_monthly.csv

Usage:
    python scripts/build_fx_monthly.py
"""

from datetime import date
from pathlib import Path

import pandas as pd
import requests

START = date(2015, 1, 1)
END = date.today()
OUT = Path("data/clean/fx_monthly.csv")

BASE = "https://api.frankfurter.app"


def fetch_range(start: date, end: date) -> dict:
    """One API call for a date range. Returns {date_str: rate}."""
    url = f"{BASE}/{start.isoformat()}..{end.isoformat()}"
    r = requests.get(url, params={"from": "USD", "to": "JPY"}, timeout=30)
    r.raise_for_status()
    payload = r.json()
    return {d: v["JPY"] for d, v in payload["rates"].items()}


def fetch_all(start: date, end: date) -> pd.Series:
    """Fetch year by year so no single request gets unwieldy."""
    rates = {}
    for year in range(start.year, end.year + 1):
        chunk_start = max(start, date(year, 1, 1))
        chunk_end = min(end, date(year, 12, 31))
        print(f"  fetching {chunk_start} .. {chunk_end}")
        rates.update(fetch_range(chunk_start, chunk_end))

    s = pd.Series(rates, name="usd_jpy")
    s.index = pd.to_datetime(s.index)
    return s.sort_index()


def to_monthly(daily: pd.Series) -> pd.DataFrame:
    """Collapse the daily series into monthly avg / end-of-month / count."""
    g = daily.groupby(daily.index.to_period("M"))

    out = pd.DataFrame({
        "usd_jpy_avg": g.mean().round(3),
        "usd_jpy_eom": g.last().round(3),   # sorted index, so last == latest date
        "trading_days": g.size(),
    })
    # year_month as the first day of the month — matches the Postgres schema
    out.index = out.index.to_timestamp()
    out.index.name = "year_month"
    return out.reset_index()


def sanity_check(df: pd.DataFrame) -> None:
    problems = []
    if df["year_month"].duplicated().any():
        problems.append("duplicate months")
    if df[["usd_jpy_avg", "usd_jpy_eom"]].isna().any().any():
        problems.append("null rates")
    thin = df[df["trading_days"] < 15]
    if len(thin):
        problems.append(f"{len(thin)} month(s) with <15 trading days (check the latest one)")

    expected = pd.period_range(
        df["year_month"].min(), df["year_month"].max(), freq="M"
    )
    got = pd.PeriodIndex(df["year_month"], freq="M")
    missing = expected.difference(got)
    if len(missing):
        problems.append(f"missing months: {list(missing)}")

    print("\nsanity check:")
    if problems:
        for p in problems:
            print(f"  !! {p}")
    else:
        print("  all clear")


def main():
    print(f"Fetching USD/JPY {START} .. {END}")
    daily = fetch_all(START, END)
    print(f"  {len(daily)} daily observations")

    monthly = to_monthly(daily)
    sanity_check(monthly)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    monthly.to_csv(OUT, index=False)
    print(f"\nwrote {len(monthly)} rows -> {OUT}")
    print(monthly.head())
    print("...")
    print(monthly.tail())


if __name__ == "__main__":
    main()
