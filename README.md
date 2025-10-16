# Genome Quality and Dotplot Analysis Pipeline

This repository provides a quick setup and reproducible workflow for:
1. Generating **dotplots** using [Gepard v1.40](https://cube.univie.ac.at/gepard)
2. Assessing genome completeness using **BUSCO v5.1.3**
3. Running the **Campylobacterales ODB10** lineage database

---

## Requirements

- **Java ≥ 8** (for Gepard)
- **Conda (Miniconda or Anaconda)**
- **wget** and **tar**
- Linux or macOS environment recommended

---

## 0. Dotplot using Gepard-1.40.jar

**Install & run:**

```bash
# Download Gepard
wget https://cube.univie.ac.at/downloads/gepard-1.40.jar

# Launch GUI (allocate sufficient memory)
java -Xmx4G -jar Gepard-1.40.jar
```

**Usage:**
1. Load *Sequence 1* and *Sequence 2* (FASTA files)
2. Adjust word length and matrix options if needed
3. Click **Plot** to generate dotplot

Output will be an image showing sequence similarity.

---

## 1. Install BUSCO v5.1.3

```bash
# Create and activate a clean conda environment
conda create -y -n busco-5.1.3 -c bioconda -c conda-forge   busco=5.1.3 augustus hmmer blast prodigal

conda activate busco-5.1.3
```

### Configure Augustus

BUSCO requires a writable Augustus config path:

```bash
mkdir -p $HOME/augustus_config
cp -r $(dirname $(which augustus))/../config/* $HOME/augustus_config/
export AUGUSTUS_CONFIG_PATH="$HOME/augustus_config"
```

---

## 2. Download BUSCO Database

```bash
mkdir -p $HOME/busco_dbs/lineages
cd $HOME/busco_dbs/lineages

# Download the Campylobacterales lineage
wget https://busco-data.ezlab.org/v5/data/lineages/campylobacterales_odb10.2020-03-06.tar.gz
tar -xzf campylobacterales_odb10.2020-03-06.tar.gz
```

---

## 3. Run BUSCO

Save the following as `run.busco.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# ---- user inputs ----
IN_FA="sample.fna"                             # Input assembly
LINEAGE_DIR="$HOME/busco_dbs/lineages"         # Lineage folder
LINEAGE_NAME="campylobacterales_odb10"
THREADS="${THREADS:-8}"
OUTPREFIX="busco_${LINEAGE_NAME}_$(date +%Y%m%d)"
# ---------------------

# Load conda environment
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate busco-5.1.3

# Ensure Augustus config is writable
: "${AUGUSTUS_CONFIG_PATH:?Set AUGUSTUS_CONFIG_PATH}"

busco   -i "$IN_FA"   -o "$OUTPREFIX"   -m genome   -l "$LINEAGE_NAME"   --offline   --download_path "$LINEAGE_DIR"   --cpu "$THREADS"   --force

echo "✅ BUSCO completed. Results in: ${OUTPREFIX}"
```

Then make it executable and run:

```bash
chmod +x run.busco.sh
./run.busco.sh
```

---

## 📊 Outputs

- `short_summary_*.txt` — BUSCO completeness summary  
- `run_*/full_table.tsv` — detailed per-gene results  
- `plots/` — optional summary plots (if generated)  

---

## 🧾 References

- **Gepard:** Krumsiek et al. *Bioinformatics* (2007)  
- **BUSCO:** Manni et al. *Bioinformatics* (2021)  

---

## 🛠 Example Folder Structure

```
project/
│
├── sample.fna
├── run.busco.sh
├── busco_dbs/
│   └── lineages/
│       └── campylobacterales_odb10/
├── Gepard-1.40.jar
└── README.md
```

---

## 🧪 Example Results

| Metric | Value |
|--------|--------|
| Complete BUSCOs | 98.2% |
| Fragmented BUSCOs | 1.1% |
| Missing BUSCOs | 0.7% |

---

## 🔍 Citation

If you use this pipeline, please cite:

> Krumsiek et al., 2007. Gepard: a rapid and sensitive tool for creating dotplots on genome scale. *Bioinformatics* 23(8):1026–1028.  
> Manni et al., 2021. BUSCO Update: novel and streamlined workflows along with broader and deeper phylogenetic coverage for scoring of eukaryotic, prokaryotic, and viral genomes. *Bioinformatics* 37(12): 3137–3143.

---
