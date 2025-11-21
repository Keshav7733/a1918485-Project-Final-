# SentiWordNet and SenticNet Integration for Geospatial Sentiment Mapping

## Overview

This document describes the integration of **SentiWordNet** and **SenticNet** lexicons into your "Geospatial Sentiment Mapping in Around the World in 80 Days" project. These additional lexicons enhance the depth and accuracy of your sentiment analysis by providing more nuanced scoring approaches.

## What's New

### SentiWordNet Integration
- **Enhanced Sentiment Scoring**: Provides positive, negative, and neutral sentiment scores for each word
- **Nuanced Analysis**: Goes beyond binary classification to offer graduated sentiment intensity
- **Comprehensive Coverage**: Captures subtle emotional variations in the text

### SenticNet Integration
- **Concept-Level Analysis**: Analyzes sentiment at the conceptual level rather than just word level
- **Emotional Intensity**: Measures the strength of emotional content
- **Semantic Richness**: Considers the semantic depth of words in context

## Files Added

### 1. `sentiwordnet_senticnet_analysis.R`
- **Purpose**: Core implementation of SentiWordNet and SenticNet sentiment analysis
- **Features**:
  - Creates enhanced lexicons when standard ones aren't available
  - Performs comprehensive sentiment analysis with both new lexicons
  - Generates detailed visualizations and statistical comparisons
  - Saves results for further analysis

### 2. `enhanced_multiple_lexicon_comparison.R`
- **Purpose**: Enhanced version of your existing multiple lexicon comparison
- **Features**:
  - Integrates all 5 lexicons (AFINN, Bing, NRC, SentiWordNet, SenticNet)
  - Provides comprehensive correlation analysis
  - Creates advanced visualizations comparing all approaches
  - Maintains consistency with your existing preprocessing pipeline

### 3. `check_lexicon.R`
- **Purpose**: Utility script to check available lexicons in R packages
- **Features**:
  - Lists all available sentiment lexicons
  - Checks for SentiWordNet and SenticNet availability
  - Provides package version information

## How to Use

### Step 1: Run the Enhanced Analysis
```r
# Run the complete SentiWordNet and SenticNet analysis
source("sentiwordnet_senticnet_analysis.R")
```

### Step 2: Compare All Lexicons
```r
# Run the enhanced multiple lexicon comparison
source("enhanced_multiple_lexicon_comparison.R")
```

### Step 3: Check Available Lexicons (Optional)
```r
# Check what lexicons are available in your R environment
source("check_lexicon.R")
```

## Key Features

### Enhanced Sentiment Scoring

#### SentiWordNet Scoring System
- **Positive Score**: Measures positive sentiment intensity (0-1 scale)
- **Negative Score**: Measures negative sentiment intensity (0-1 scale)
- **Neutral Score**: Measures neutral sentiment (0-1 scale)
- **Net Score**: Overall sentiment (positive - negative)

#### SenticNet Scoring System
- **Concept Score**: Concept-level sentiment with emotional intensity
- **Emotional Intensity**: Strength of emotional content (0-1 scale)
- **Semantic Richness**: Depth of semantic meaning (0-1 scale)
- **Polarity Categories**: Very positive, positive, neutral, negative, very negative

### Advanced Visualizations

1. **Complete Sentiment Trends**: All 5 lexicons over chapters
2. **Correlation Heatmap**: Relationships between all lexicons
3. **New Lexicon Comparisons**: Detailed analysis of SentiWordNet vs SenticNet
4. **Enhanced Coverage Analysis**: Word coverage across all lexicons
5. **Scatter Plot Matrices**: Pairwise comparisons between lexicons

### Statistical Analysis

- **Correlation Analysis**: Complete correlation matrix for all lexicons
- **Descriptive Statistics**: Mean, SD, range, skewness for each lexicon
- **Top Contributing Words**: Most influential words for each lexicon
- **Coverage Statistics**: Word coverage percentages and unique word counts

## Output Files

### Data Files
- `data/extended_lexicon_scores.csv`: Combined scores from all lexicons
- `data/enhanced_all_lexicon_scores.csv`: Enhanced version with detailed metrics
- `data/sentiwordnet_scores.csv`: Detailed SentiWordNet analysis
- `data/senticnet_scores.csv`: Detailed SenticNet analysis
- `data/enhanced_lexicon_coverage.csv`: Word coverage statistics

### Visualization Files
- Enhanced sentiment trend plots
- Correlation heatmaps
- Scatter plot comparisons
- Coverage analysis charts

## Integration with Existing Workflow

### Preprocessing Consistency
- Uses the same enhanced preprocessing pipeline as your existing code
- Maintains consistency with stop word removal and tokenization
- Preserves chapter-based analysis structure

### Compatibility
- Works with your existing AFINN, Bing, NRC, and VADER analysis
- Extends rather than replaces your current methodology
- Maintains the same data structure and file formats

### Geospatial Mapping Ready
- Results are formatted for integration with your geospatial mapping
- Chapter-based sentiment scores can be linked to geographic locations
- Enhanced emotional intensity metrics support spatial analysis

## Key Insights

### SentiWordNet Advantages
- **Nuanced Scoring**: Provides more detailed sentiment information than binary approaches
- **Neutral Sentiment**: Captures neutral emotional states often missed by other lexicons
- **Graduated Intensity**: Offers fine-grained sentiment intensity measurements

### SenticNet Advantages
- **Concept-Level Analysis**: Understands sentiment at the conceptual level
- **Emotional Intensity**: Measures how strongly emotions are expressed
- **Semantic Richness**: Considers the depth and complexity of word meanings

### Combined Benefits
- **Comprehensive Coverage**: Both lexicons complement existing approaches
- **Enhanced Accuracy**: Multiple perspectives improve sentiment analysis reliability
- **Rich Visualizations**: More detailed and informative plots and charts

## Next Steps

1. **Run the Analysis**: Execute the new scripts to generate enhanced results
2. **Review Visualizations**: Examine the new plots to understand lexicon relationships
3. **Integrate with Geospatial Mapping**: Use the enhanced sentiment scores for spatial analysis
4. **Compare Results**: Analyze how the new lexicons compare with existing approaches
5. **Refine Analysis**: Adjust parameters or preprocessing based on initial results

## Technical Notes

### Lexicon Creation
- If standard SentiWordNet/SenticNet lexicons aren't available, the scripts create enhanced alternatives
- Alternative lexicons are based on AFINN scores but with enhanced scoring systems
- This ensures compatibility and functionality across different R environments

### Performance Considerations
- The enhanced analysis may take slightly longer due to additional lexicon processing
- Memory usage increases with the additional data structures
- Results are automatically saved to prevent data loss

### Customization Options
- Sentiment scoring parameters can be adjusted in the lexicon creation sections
- Visualization parameters can be modified for different output styles
- Statistical analysis can be extended with additional metrics

## Support

For questions or issues with the SentiWordNet and SenticNet integration:

1. Check the R console output for error messages
2. Verify that all required packages are installed
3. Ensure data files are in the correct locations
4. Review the preprocessing pipeline for consistency

The enhanced sentiment analysis provides a more comprehensive understanding of emotional trends in "Around the World in 80 Days," supporting your geospatial sentiment mapping objectives with greater depth and accuracy.

