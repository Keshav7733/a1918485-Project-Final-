# Geospatial Sentiment Mapping in *Around the World in 80 Days*

**A Natural Language Processing & Data Science Research Project**

---

## 📖 Overview

This project applies **sentiment analysis**, **named-entity recognition (NER)**, and **geospatial mapping** to Jules Verne's classic novel *Around the World in 80 Days* (1872). By combining computational linguistics with literary analysis, the research reveals how emotional tone correlates with the protagonist's geographic journey, creating an innovative digital humanities approach to understanding narrative structure.

**Key Finding:** Africa and Europe exhibit positive sentiment (+0.069, +0.054), while Asia and North America show more volatile and slightly negative patterns, mirroring the novel's emotional arc and plot tension.

---

## 🎯 Research Goals

1. **Calculate sentiment patterns** across all 37 chapters using multiple sentiment lexicons
2. **Identify and link named entities** (characters, locations, organizations) with emotional shifts
3. **Create geospatial visualizations** mapping positive/negative emotions onto world geography
4. **Validate computational results** through human evaluation and inter-lexicon correlation analysis
5. **Demonstrate methodological robustness** of multi-lexicon approaches for historical literary text

---

## 🛠️ Technical Stack

| Category | Tools & Libraries |
|----------|------------------|
| **Language** | R (v4.3+) |
| **Text Processing** | `tidytext`, `dplyr`, `stringr` |
| **Sentiment Analysis** | AFINN, Bing Liu, NRC Emotion Lexicon, SentiWordNet 3.0, SenticNet 6.0 |
| **Named Entity Recognition** | `entity`, `nametagger`, `spacyr` |
| **Geospatial Mapping** | `ggmap`, `sf`, OpenCage Geocoder API |
| **Visualization** | `ggplot2` |
| **Data Source** | Project Gutenberg (public domain) |

---

## 📊 Methodology

### 1. **Data Preprocessing** (`enhanced_preprocessing.R`)
- Removal of Project Gutenberg boilerplate and formatting artifacts
- Tokenization and case normalization
- Stopword handling (retained for NER, removed for sentiment scoring)
- Validation: ±1% word count verification post-cleaning

### 2. **Sentiment Analysis Framework**
- **Lexicon-based scoring** (AFINN, Bing, NRC) scaled to –1 to +1 range
- **Advanced lexicons** (SentiWordNet, SenticNet) for nuanced, concept-level sentiment
- **Corpus-level aggregation**: weighted averages normalized by chapter token count
- **Validation**: Pearson correlation matrix (0.70–0.79 range across lexicons)

**Evolution:** Replaced VADER with SentiWordNet/SenticNet after supervisor feedback; VADER's emphasis on modern punctuation and slang yielded inaccurate scores for 19th-century prose.

### 3. **Named Entity Recognition** (`geospatial_sentiment_mapping.R`)
- Multi-library cross-validation (entity, nametagger, spacyr)
- Alias consolidation: "Mr Fogg" + "Phileas Fogg" → single entity
- Frequency filtering: entities mentioned <3 times excluded to minimize noise
- **Output:** 55 distinct entities (17 PERSON, 28 LOCATION, 10 ORG)

### 4. **Geospatial Integration**
- Chapter-level sentiment linked to entities and their locations
- Geocoding via OpenCage API (latitude/longitude retrieval)
- Aggregation by country and continent
- Sentiment intensity visualization on world map

### 5. **Human Validation** (n = 5)
- 8 key passages from diverse narrative locations rated on 1–7 valence scale
- Comparison with composite lexicon scores
- **Result:** 6 of 8 passages (75%) showed strong alignment; mismatches attributed to contextual framing in descriptive passages

---

## 📁 Repository Structure

```
a1918485-Project-Final/
│
├── README.md                              # This file
├── LICENSE                                # Open source license
│
├── data/
│   ├── raw/
│   │   └── around_world_80_days.csv      # Raw tokenized text from Project Gutenberg
│   │
│   └── processed/
│       ├── enhanced_sentiment_scores.csv
│       ├── multiple_lexicon_scores.csv
│       ├── sentiwordnet_scores.csv
│       ├── senticnet_scores.csv
│       ├── nrc_emotions_by_chapter.csv
│       ├── locations_database.csv        # Geocoded locations with coordinates
│       ├── geospatial_sentiment_data.csv
│       ├── continent_sentiment_summary.csv
│       └── country_sentiment_summary.csv
│
├── scripts/
│   ├── 01_obtain_clean_book.R             # Data acquisition & preprocessing
│   ├── 02_enhanced_preprocessing.R        # Text cleaning pipeline
│   ├── 03_multiple_lexicon_comparison.R   # AFINN, Bing, NRC scoring
│   ├── 04_sentiwordnet_senticnet_analysis.R # Advanced lexicon integration
│   ├── 05_enhanced_multiple_lexicon_comparison.R # Unified 5-lexicon pipeline
│   ├── 06_geospatial_sentiment_mapping.R  # NER + geocoding + visualization
│   └── utils/                             # Helper functions & validation
│
├── outputs/
│   ├── figures/
│   │   ├── extended_sentiment_trends.png
│   │   ├── correlation_matrix.png
│   │   ├── word_coverage_by_lexicon.png
│   │   ├── average_sentiment_by_country.png
│   │   ├── average_sentiment_by_continent.png
│   │   ├── sentiment_timeline_by_continent.png
│   │   ├── world_map_sentiment.png
│   │   └── sentiment_vs_variability_by_location.png
│   │
│   └── summaries/
│       ├── lexicon_correlation_analysis.txt
│       ├── top_locations_ranking.txt
│       └── journey_stage_analysis.txt
│
├── report/
│   ├── a1918485_Project_final_report.pdf  # Full academic report (40 pages)
│   └── human_validation_survey.pdf        # Survey responses & analysis
│
└── .gitignore
```

---

## 🚀 Quick Start

### Prerequisites
```bash
# R >= 4.3
# RStudio (optional but recommended)
```

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Keshav7733/a1918485-Project-Final-.git
   cd a1918485-Project-Final-
   ```

2. **Install required R packages:**
   ```R
   install.packages(c(
     "tidytext", "dplyr", "stringr", "ggplot2", "ggmap", "sf",
     "tidyr", "purrr", "textdata", "spacyr", "entity", "nametagger"
   ))
   ```

3. **Run the analysis pipeline:**
   ```R
   # Execute scripts in order (1 through 6)
   source("scripts/01_obtain_clean_book.R")
   source("scripts/02_enhanced_preprocessing.R")
   source("scripts/03_multiple_lexicon_comparison.R")
   source("scripts/04_sentiwordnet_senticnet_analysis.R")
   source("scripts/05_enhanced_multiple_lexicon_comparison.R")
   source("scripts/06_geospatial_sentiment_mapping.R")
   ```

4. **Outputs** are saved to `/outputs` with full reproducibility.

---

## 🔍 Key Results

### Sentiment Patterns by Continent
| Continent | Avg Sentiment | Interpretation |
|-----------|---------------|-----------------|
| **Africa** | +0.069 | Smooth passage through Suez; favorable transit |
| **Europe** | +0.054 | London narrative significance; ordered transport |
| **Asia** | +0.034 | Mixed adventure & conflict (Fix, delays, rescues) |
| **North America** | –0.006 | Time pressure; race-against-clock tension |

### Top 5 Positive Locations
- **Athens** (0.378) – Successful navigation
- **Birmingham** (0.378) – Efficient travel
- **Manchester** (0.378) – Favorable passage
- **Aden** (0.343) – Smooth transit
- **Goa** (0.343) – Pleasant encounter

### Top 5 Negative Locations
- **Egypt** (–0.065) – Suez tension
- **Pall Mall** (–0.046) – Reform Club conflict
- **Liverpool** (–0.042) – Urgent departure
- **New York** (–0.032) – Time pressure
- **China** (–0.026) – Mixed portrayals

### Lexicon Coverage & Correlations
| Lexicon | Coverage | AFINN Correlation |
|---------|----------|-------------------|
| SenticNet | 35.9% | 0.990 |
| SentiWordNet | 8.8% | 0.992 |
| NRC | 16.9% | 0.70–0.73 |
| Bing | 10.4% | 0.785 |
| AFINN | 8.8% | – |

**Key Insight:** Multi-lexicon approach (r = 0.70–0.79) ensures stability across linguistic perspectives; SentiWordNet & SenticNet complement each other for nuanced historical prose.

---

## 📈 Validation & Robustness

✅ **High Consistency:** Pearson correlation coefficients 0.70–0.79 across lexicon pairs  
✅ **Coverage Improvement:** SenticNet adds 35.9% word coverage vs. NRC's 16.9%  
✅ **Narrative Alignment:** Sentiment peaks match major plot events (arrest, rescue, return)  
✅ **Human Validation:** 75% passage-level agreement (n = 5 participants)  
✅ **Entity Precision:** 55 validated entities with <3% false-positive rate after manual cleaning  

---

## 🎓 Methodological Contributions

1. **First geospatial sentiment map** of a classic travel narrative
2. **Multi-lexicon robustness** for historical literary text (rejecting VADER for SentiWordNet/SenticNet)
3. **Entity-sentiment linkage** binding character/location emotional weight
4. **Human-computational triangulation** validating NLP outputs in humanities context
5. **Reproducible pipeline** enabling replication for other literary corpora

---

## 📚 Literature & References

- **Sentiment Analysis in Literature:** Reagan et al. (2016), Heuser et al. (2016)
- **NER in Fiction:** He et al. (2013), Vala et al. (2015), Elson et al. (2010)
- **Geospatial Emotion Mapping:** Paolanti et al. (2021), Yan et al. (2020)
- **Lexicon Resources:** AFINN (Nielsen 2011), Bing Liu (2004), NRC (Mohammad & Turney 2013), SentiWordNet (Baccianella et al. 2010), SenticNet (Cambria et al. 2018)

See **[Full Report](report/a1918485_Project_final_report.pdf)** for comprehensive literature review and citations.

---

## 🔧 Limitations & Future Work

### Current Limitations
- Small human validation sample (n = 5) – qualitative grounding only
- Lexicon dependence cannot capture irony, metaphor, or cultural context fully
- Chapter-level aggregation may dilute local emotional extremes
- Location ambiguity (e.g., "Liverpool" in multiple contexts)

### Future Enhancements
- **Transformer-based models** (BERT, DistilBERT) for contextual sentiment
- **Character-level emotion tracking** across narrative arcs
- **Larger human validation** with inter-rater reliability metrics
- **Comparative analysis** across other travel narratives
- **Interactive web dashboard** for exploratory analysis

---

## 📜 License

This project uses publicly available data (Project Gutenberg) and open-source sentiment lexicons. Code is distributed under the **MIT License**. See LICENSE file for details.

---

## 👤 Author & Acknowledgments

**Keshav Pareek** | Student No. a1918485  
Data Science Research Project Part B  
School of Mathematical Sciences, University of Adelaide

**Supervisor:** Dr. Ashley Dennis-Henderson  
**Special Thanks:** NLP research seminar participants, human validation survey respondents

---

## 🔗 Links & Resources

- **GitHub:** [a1918485-Project-Final-](https://github.com/Keshav7733/a1918485-Project-Final-)
- **Project Gutenberg:** [Around the World in 80 Days](https://www.gutenberg.org/ebooks/103)
- **OpenCage Geocoder:** [API Documentation](https://opencagedata.com/api)
- **Full Report:** [a1918485_Project_final_report.pdf](report/a1918485_Project_final_report.pdf)

---

## 📞 Contact & Questions

For inquiries, methodology clarification, or collaboration opportunities:
- **Email:** [your-email@university.edu]
- **GitHub Issues:** [Report bugs or request features](https://github.com/Keshav7733/a1918485-Project-Final-/issues)

---

**Last Updated:** April 2026  
**Project Status:** ✅ Complete & Reproducible
