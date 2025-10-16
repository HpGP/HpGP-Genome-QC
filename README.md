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

# conda activate bacgen3

#source /Users/wangdi/apps/anaconda3/bin/activate bacgen3
source /data/wangdi/bin/anaconda3/bin/activate bacgen3

LIST=$1

echo "## Complete BUSCOs (C)" > ${LIST}.busco.sum.txt
echo "## Complete and single-copy BUSCOs (S)" >> ${LIST}.busco.sum.txt
echo "## Complete and duplicated BUSCOs (D)" >> ${LIST}.busco.sum.txt
echo "## Fragmented BUSCOs (F)" >> ${LIST}.busco.sum.txt
echo "## Missing BUSCOs (M)" >> ${LIST}.busco.sum.txt
echo "## Total BUSCO groups searched" >> ${LIST}.busco.sum.txt
echo "## strain,C,S,D,F,M,n" >> ${LIST}.busco.sum.txt

## loop list
for f in `cat $LIST`
do

## copy fasta
cat ./fna/${f}.fasta > ${f}.fna

echo "== $f =="

##
## download busco db
##
## https://busco-data.ezlab.org/v5/data/lineages/campylobacterales_odb10.2020-03-06.tar.gz
busco -m genome -i ${f}.fna -o ${f} -l campylobacterales_odb10

## length
len=$(seqlen.sh ${f}.fna | awk '{print $2}')

## combine all
line=$(grep "C:" ${f}/short_summary.specific.campylobacterales_odb10.${f}.txt | sed 's/\[/,/; s/\]//' | sed 's/C://; s/S://; s/D://; s/F://; s/M://; s/n://'| awk '{print $1}')
echo "$f,$len,$line" >> ${LIST}.busco.sum.txt

rm -rf ${f}.fna

done
```

Then make it executable and run:

```bash
chmod +x run.busco.sh
./run.busco.sh
```

---

## Outputs

- `short_summary_*.txt` — BUSCO completeness summary  
- `run_*/full_table.tsv` — detailed per-gene results  
- `plots/` — optional summary plots (if generated)  

HpGP BUSCO completeness results

<img width="1053" height="836" alt="Screenshot 2025-10-16 at 2 06 32 PM" src="https://github.com/user-attachments/assets/f3f6b641-23c8-462c-9f40-5147ca2f4783" />


---

## References

- **Gepard:** Krumsiek et al. *Bioinformatics* (2007)  
- **BUSCO:** Manni et al. *Bioinformatics* (2021)  

---

## Example Folder Structure

```
project/
│
├── fna/sample.fna
├── run.busco.sh
├── busco_dbs/
│   └── lineages/
│       └── campylobacterales_odb10/
├── Gepard-1.40.jar
├── HpGP-1012set.busco.xlsx
└── README.md
```

---

## Example Results

| Metric | Value |
|--------|--------|
| Complete BUSCOs | 98.2% |
| Fragmented BUSCOs | 1.1% |
| Missing BUSCOs | 0.7% |

---

## Citation

If you use this pipeline, please cite:

> Krumsiek et al., 2007. Gepard: a rapid and sensitive tool for creating dotplots on genome scale. *Bioinformatics* 23(8):1026–1028. [https://doi.org/10.1093/bioinformatics/btm039](https://doi.org/10.1093/bioinformatics/btm039) 
>
> Simão et al., 2015. BUSCO: assessing genome assembly and annotation completeness with single-copy orthologs. *Bioinformatics* 31(19), 3210–3212. [https://doi.org/10.1093/bioinformatics/btv351](https://doi.org/10.1093/bioinformatics/btv351)
>
> Thorell et al., 2023. The Helicobacter pylori Genome Project: insights into H. pylori population structure from analysis of a worldwide collection of complete genomes. *Nature Communications*, 14, 8184. [https://doi.org/10.1038/s41467-023-43971-3](https://doi.org/10.1038/s41467-023-43971-3)

---
