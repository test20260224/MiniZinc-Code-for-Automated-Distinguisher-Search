# MiniZinc Code for Automated Distinguisher Search

This repository provides MiniZinc implementations for the automated search of cryptographic distinguishers, including **impossible differential** and **zero-correlation linear** distinguishers for block ciphers.

## Prerequisites
1. Install the **MiniZinc IDE** or the **MiniZinc command-line tools** from the official MiniZinc website.
2. Ensure the **Chuffed** solver is available (it is included in standard MiniZinc distributions by default).

## Running the Code
From a terminal/command prompt, run the following commands (replace the example filename with your target `.mzn` file):

```bash
minizinc --solver chuffed ID_MARS.mzn
minizinc --solver chuffed ZC_MARS.mzn
