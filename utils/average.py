import csv
import sys
import pandas as pd

def average_runs(input_csv, output_csv):
    cols = [
        "filename",
        "M",
        "N",
        "K",
        "B",
        "total_time",
        "xfer_on_time",
        "exec_time",
        "xfer_off_time",
        "power_xfer_on",
        "power_exec",
        "power_xfer_off",
        "total_energy",
        "energy_xfer_on",
        "energy_exec"
    ]

    df = pd.read_csv(input_csv, sep=",", usecols=cols)

    averages = []
    for filename in df['filename'].unique():
        subset = df[df['filename'] == filename]
        # Get unique combinations of columns M, N, K, B
        unique_combinations = subset[["M", "N", "K", "B"]].drop_duplicates()
        for index, row in unique_combinations.iterrows():
            subset_comb = subset[
                (subset["M"] == row["M"]) &
                (subset["N"] == row["N"]) &
                (subset["K"] == row["K"]) &
                (subset["B"] == row["B"])
            ]
            # Compute the average (mean) of each column across all rows
            averages_series = subset_comb.mean(numeric_only=True)
            averages_series.loc["filename"] = filename

            averages.append(averages_series)

    avg_df = pd.DataFrame(averages, columns=cols)
    avg_df[["M", "N", "K", "B"]] = avg_df[["M", "N", "K", "B"]].astype(int)
    avg_df.to_csv(output_csv, index=False, float_format='%.6f')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python average.py <input_file> <output_file>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]

    average_runs(input_file, output_file)
