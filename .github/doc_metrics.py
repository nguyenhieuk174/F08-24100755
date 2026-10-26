#!/usr/bin/env python3
"""Print a concise selection of metrics from a LibreLane metrics JSON file."""

import argparse
import json
from pathlib import Path


def flatten_metrics(value, prefix=""):
    if isinstance(value, dict):
        for key, child in value.items():
            name = f"{prefix}.{key}" if prefix else str(key)
            yield from flatten_metrics(child, name)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from flatten_metrics(child, f"{prefix}[{index}]")
    else:
        yield prefix, value


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("metrics_json", type=Path)
    args = parser.parse_args()

    with args.metrics_json.open(encoding="utf-8") as metrics_file:
        metrics = json.load(metrics_file)

    terms = ("area", "timing", "power", "instance", "cell", "core", "die")
    selected = [
        (key, value)
        for key, value in flatten_metrics(metrics)
        if any(term in key.lower() for term in terms)
    ]

    if not selected:
        print("No area/timing/power/cell metrics found in metrics.json.")
        return

    for key, value in sorted(selected):
        print(f"{key}: {value}")


if __name__ == "__main__":
    main()