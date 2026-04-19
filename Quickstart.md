# Quick Start Guide

Get up and running with the Geospatial Sentiment Mapping project in **5 minutes**.

---

## 🚀 Installation (Copy & Paste)

### Step 1: Clone Repository
```bash
git clone https://github.com/Keshav7733/a1918485-Project-Final-.git
cd a1918485-Project-Final-
```

### Step 2: Install Dependencies
Open R or RStudio and paste:

```r
# Core packages
install.packages(c(
  "tidytext", "dplyr", "stringr", "tidyr", "ggplot2", 
  "ggmap", "sf", "maps", "mapdata", "purrr", "readr", "scales"
))

# Sentiment analysis
install.packages("textdata")

# NER (optional - requires Python setup)
# install.packages(c("spacyr", "entity", "nametagger"))
```

### Step 3: Run Analysis
In R console:
```r
setwd("path/to/a1918485-Project-Final-")

# Run scripts sequentially (each takes 2-10 minutes)
source("scripts/01_obtain_clean_book.R")
source("scripts/02_enhanced_preprocessing.R")
source("scripts/03_multiple_lexicon_comparison.R")
source("scripts/04_sentiwordnet_senticnet_analysis.R")
source("scripts/05_enhanced_multiple_lexicon_comparison.R")
source("scripts/06_geospatial_sentiment_mapping.R")
```

**✅ Done!** Outputs saved to `/outputs` folder.

---

## 📊 What You Get

### Visualizations (in `/outputs/figures/`)
- `extended_sentiment_trends.png` – Sentiment across all 5 lexicons
- `average_sentiment_by_country.png` – Which countries were happiest/saddest
- `world_map_sentiment.png` – Geographic heat map of emotions
- `sentiment_timeline_by_continent.png` – How emotion changed by region

### Data Tables (in `/outputs/summaries/`)
- `top_locations_ranking.txt` – Best/worst places in the novel
- `lexicon_correlation_analysis.txt` – How well different tools agreed
- `journey_stage_analysis.txt` – Emotional arc across the journey

### CSV Files (in `/data/processed/`)
- `enhanced_sentiment_scores.csv` – Full chapter-by-chapter sentiment
- `geospatial_sentiment_data.csv` – Sentiment linked to locations
- `continent_sentiment_summary.csv` – Continental analysis

---

## 🔍 Key Findings at a Glance

### 📍 Emotional Geography
| Region | Mood | Why |
|--------|------|-----|
| **Africa** 🟩 | Happy (+0.069) | Smooth passage through Suez |
| **Europe** 🟩 | Happy (+0.054) | London, structured transit |
| **Asia** 🟨 | Mixed (+0.034) | Adventure + conflict + delays |
| **North America** 🟥 | Tense (–0.006) | Racing against time |

### 🏙️ Happiest Places
1. **Athens, Greece** (0.378) ✨
2. **Birmingham, UK** (0.378) ✨
3. **Aden, Yemen** (0.343) ✨

### 😟 Toughest Places
1. **Egypt** (–0.065)
2. **Pall Mall, London** (–0.046)
3. **New York** (–0.032)

---

## 📚 Project Structure (Quick Reference)

```
scripts/
├── 01_obtain_clean_book.R ........... Download & prep text
├── 02_enhanced_preprocessing.R ...... Clean & tokenize
├── 03_multiple_lexicon_comparison.R  Run 3 basic lexicons
├── 04_sentiwordnet_senticnet_analysis.R  Advanced lexicons
├── 05_enhanced_multiple_lexicon_comparison.R  Merge all 5
└── 06_geospatial_sentiment_mapping.R .... Maps & visuals

data/
├── raw/
│   └── around_world_80_days.csv ............. Raw text
└── processed/
    ├── enhanced_sentiment_scores.csv
    ├── geospatial_sentiment_data.csv
    └── [8 other analysis tables]

outputs/
├── figures/ ........................... [8 visualizations]
└── summaries/ ......................... [3 analysis tables]
```

---

## 🎯 Common Tasks

### "I want to see the results without running anything"
```r
# Load pre-computed results
sentiment_data <- read.csv("data/processed/enhanced_sentiment_scores.csv")
geospatial_data <- read.csv("data/processed/geospatial_sentiment_data.csv")

# Quick plot
library(ggplot2)
ggplot(sentiment_data, aes(x = Chapter, y = Composite_Sentiment)) +
  geom_line() + geom_point() + theme_minimal()
```

### "I want to analyze a different novel"
1. Replace `around_world_80_days.csv` with your text
2. Update chapter boundaries in `01_obtain_clean_book.R`
3. Run scripts 02-06 (same pipeline works for any novel!)

### "I want to use different sentiment lexicons"
Edit lines in `03_multiple_lexicon_comparison.R` and `05_enhanced_*`:
```r
# Add custom lexicon
my_lexicon <- read.csv("path/to/my_lexicon.csv")
```

### "I want interactive visualizations"
Install Shiny and create a dashboard:
```r
install.packages("shiny")
# See examples/shiny_dashboard.R (coming soon!)
```

---

## ⚠️ Troubleshooting

| Problem | Solution |
|---------|----------|
| "Package not found" | Run `install.packages("package_name")` |
| "Cannot download lexicons" | Check internet; manually download from textdata GitHub |
| "Out of memory" | Process by chapter; see DEPENDENCIES.md |
| "Geocoding API failed" | Get free key at opencagedata.com; set in `.Renviron` |
| "Scripts run slowly" | Normal (can take 30-60 min for full pipeline); use `Sys.time()` to track |

---

## 📖 Learn More

| Topic | File |
|-------|------|
| Full technical details | **[README.md](README.md)** |
| Install dependencies properly | **[DEPENDENCIES.md](DEPENDENCIES.md)** |
| Academic report (40 pages) | **[report/a1918485_Project_final_report.pdf](report/a1918485_Project_final_report.pdf)** |
| How to contribute | **[CONTRIBUTING.md](CONTRIBUTING.md)** |

---

## 🎓 For Your Resume

**Use this project to demonstrate:**
- ✅ **NLP & Sentiment Analysis** (5 lexicons, 37 chapters)
- ✅ **Data Visualization** (ggplot2, geospatial mapping)
- ✅ **Named Entity Recognition** (3-library cross-validation)
- ✅ **Research Methodology** (validation surveys, correlation analysis)
- ✅ **Reproducible Science** (fully documented, Git-tracked pipeline)

**Talking Points:**
- "Improved lexicon coverage from 17% to 36% by integrating advanced tools"
- "Achieved 0.70–0.79 inter-lexicon correlation, validating methodological robustness"
- "Designed geospatial mapping linking sentiment to geography, revealing emotional–narrative alignment"
- "Conducted human validation study (n=5) with 75% passage-level agreement"

---

## 📞 Questions?

- **GitHub Issues:** [Create issue](https://github.com/Keshav7733/a1918485-Project-Final-/issues)
- **Email:** [keshav.pareek.work@gmail.com]
- **Full Report:** [PDF](report/a1918485_Project_final_report.pdf)

---

**Happy analyzing! 🚀**
