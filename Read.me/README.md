# Sentiment Analysis of "Around the World in 80 Days"

## Project Overview

This project performs sentiment analysis on Jules Verne's "Around the World in 80 Days" using Natural Language Processing (NLP) techniques. The analysis tracks emotional tone throughout the novel by chapter, identifying key positive and negative contributing words.

## Project Status: ✅ COMPLETE

### ✅ Completed Components

1. **Proposal** - Defined aim to perform sentiment analysis using NLP techniques
2. **Background and Literature Review** - Reviewed key works in sentiment analysis, text mining, and geospatial text analytics
3. **Data Acquisition** - Downloaded the full novel from Project Gutenberg
4. **Initial Cleaning** - Removed headers, footers, split into chapters, removed empty lines and chapter headings
5. **Basic Sentiment Analysis** - Applied AFINN lexicon for chapter-wise sentiment scores
6. **Enhanced Preprocessing** - Implemented comprehensive text preprocessing pipeline

## Files Overview

### Core Analysis Files

- **`obtain_clean_book.R`** - Original data acquisition and basic cleaning
  - Downloads book from Project Gutenberg
  - Removes headers and footers
  - Splits text into chapters
  - Removes empty lines and chapter headings
  - Saves cleaned data as CSV

- **`wk6_code.R`** - Original sentiment analysis implementation
  - Basic tokenization
  - AFINN lexicon application
  - Chapter-wise sentiment calculation
  - Basic visualizations

### Enhanced Analysis Files

- **`enhanced_preprocessing.R`** - Comprehensive preprocessing pipeline
  - ✅ **Lowercasing** - Converts all text to lowercase
  - ✅ **Punctuation Removal** - Strips all punctuation marks
  - ✅ **Number Removal** - Removes numeric characters
  - ✅ **Stop Word Removal** - Removes common words (the, and, is, etc.)
  - ✅ **Short Word Filtering** - Removes words with ≤2 characters
  - Enhanced sentiment analysis with better metrics
  - Advanced visualizations
  - Summary statistics

- **`preprocessing_comparison.R`** - Comparison analysis
  - Side-by-side comparison of original vs enhanced preprocessing
  - Correlation analysis
  - Word coverage analysis
  - Impact assessment of preprocessing steps

### Multiple Lexicon Analysis Files

- **`multiple_lexicon_comparison.R`** - Comprehensive lexicon comparison
  - ✅ **AFINN Lexicon** - Finnish word list with valence scores (-5 to +5)
  - ✅ **Bing Lexicon** - Binary positive/negative classification
  - ✅ **NRC Lexicon** - Plutchik's eight emotions + positive/negative
  - ✅ **VADER Lexicon** - Valence Aware Dictionary and sEntiment Reasoner
  - Correlation analysis between all lexicons
  - Word coverage comparison
  - Emotion analysis (NRC)
  - Statistical comparisons

- **`vader_lexicon_analysis.R`** - VADER-specific analysis
  - Custom VADER lexicon implementation
  - Compound score calculation
  - Intensifier and negator handling
  - Sentiment categorization
  - Comparison with other lexicons

- **`lexicon_comparison_summary.R`** - Final comprehensive summary
  - All lexicon results combined
  - Statistical recommendations
  - Best practices for literary analysis
  - Lexicon-specific recommendations
  - Final insights and conclusions

### Output Files

- **`around_world_80_days.csv`** - Cleaned chapter data
- **`enhanced_sentiment_scores.csv`** - Enhanced sentiment results
- **`enhanced_word_counts.csv`** - Enhanced word frequency data
- **`preprocessing_comparison.csv`** - Comparison results
- **`multiple_lexicon_scores.csv`** - All lexicon sentiment scores
- **`lexicon_coverage.csv`** - Word coverage statistics
- **`nrc_emotions_summary.csv`** - NRC emotion analysis
- **`nrc_emotions_by_chapter.csv`** - Chapter-wise emotions
- **`vader_sentiment_scores.csv`** - VADER sentiment scores
- **`vader_top_words.csv`** - Top VADER contributing words
- **`vader_lexicon.csv`** - Custom VADER lexicon
- **`comprehensive_lexicon_results.csv`** - All results combined
- **`lexicon_correlations.csv`** - Correlation matrix

## Key Enhancements Made

### 1. Comprehensive Preprocessing Pipeline

**Before (Original):**
```r
tidy_book <- data %>%
  unnest_tokens(word, text) %>%
  count(chapter, word, sort = TRUE)
```

**After (Enhanced):**
```r
tidy_book_enhanced <- data %>%
  unnest_tokens(word, text, 
                token = "words",
                to_lower = TRUE,           # ✅ Lowercasing
                strip_punct = TRUE,        # ✅ Remove punctuation
                strip_numeric = TRUE) %>%  # ✅ Remove numbers
  filter(!is.na(word)) %>%
  filter(str_length(word) > 2) %>%        # ✅ Remove short words
  filter(!word %in% all_stop_words)       # ✅ Remove stop words
```

### 2. Enhanced Sentiment Analysis

- **Better Metrics**: Total words, sentiment words, positive/negative counts
- **Improved Visualizations**: Multiple plot types with better aesthetics
- **Statistical Summary**: Comprehensive output statistics

### 3. Comparison Framework

- **Correlation Analysis**: Measures relationship between original and enhanced results
- **Impact Assessment**: Quantifies the effect of preprocessing steps
- **Word Coverage Analysis**: Shows improvement in sentiment word detection

## Key Findings

### Preprocessing Impact
- **Stop word removal** significantly improves sentiment analysis quality
- **Lowercasing** ensures consistent word matching
- **Punctuation/number removal** reduces noise in analysis
- **Enhanced preprocessing** provides more accurate sentiment scores

### Sentiment Analysis Results
- Tracks emotional progression throughout the novel
- Identifies chapters with highest positive/negative sentiment
- Reveals key contributing words to overall sentiment
- Shows sentiment distribution patterns

## Technical Implementation

### Libraries Used
- `tidyverse` - Data manipulation and visualization
- `tidytext` - Text mining and sentiment analysis
- `gutenbergr` - Project Gutenberg data access
- `stopwords` - Stop word removal
- `gridExtra` - Plot arrangement

### Sentiment Lexicon
- **AFINN**: Finnish word list with valence scores (-5 to +5)
- Provides continuous sentiment scores rather than binary classification
- Well-suited for literary text analysis

## Usage Instructions

1. **Run Data Acquisition**: Execute `obtain_clean_book.R` to download and clean the book
2. **Run Original Analysis**: Execute `wk6_code.R` for basic sentiment analysis
3. **Run Enhanced Analysis**: Execute `enhanced_preprocessing.R` for comprehensive analysis
4. **Run Comparison**: Execute `preprocessing_comparison.R` to compare approaches
5. **Run Multiple Lexicon Analysis**: Execute `multiple_lexicon_comparison.R` for lexicon comparison
6. **Run VADER Analysis**: Execute `vader_lexicon_analysis.R` for VADER-specific analysis
7. **Run Final Summary**: Execute `lexicon_comparison_summary.R` for comprehensive results

## Next Steps (Optional Enhancements)

1. **✅ Multiple Lexicon Comparison**: Compare AFINN with Bing, NRC, or VADER lexicons
2. **Geospatial Analysis**: Map sentiment to geographical locations in the story
3. **Character Analysis**: Analyze sentiment around specific characters
4. **Time Series Analysis**: Apply time series methods to sentiment trends
5. **Machine Learning**: Train custom sentiment models on literary text

## Project Value

This project demonstrates:
- **Text preprocessing best practices** in NLP
- **Sentiment analysis methodology** for literary texts
- **Comparative analysis** of different preprocessing approaches
- **Data visualization** techniques for text analysis
- **Reproducible research** practices in computational linguistics

The enhanced preprocessing pipeline significantly improves the quality and reliability of sentiment analysis results, making it suitable for academic research and literary analysis applications.
