# Geospatial Sentiment Mapping for Around the World in 80 Days

## Overview

This comprehensive system combines sentiment analysis with geographic location extraction to create detailed geospatial sentiment maps of Jules Verne's "Around the World in 80 Days." The system extracts locations from the text, maps them with sentiment scores, and creates interactive visualizations showing emotional trends across geographic locations in Phileas Fogg's journey.

## Key Features

### 🌍 **Geographic Location Extraction**
- **Named Entity Recognition**: Extracts locations from text using pattern matching
- **Comprehensive Location Database**: 60+ locations with coordinates, countries, and metadata
- **Location Categorization**: Cities, countries, continents, institutions, and geographic features
- **Journey Order Mapping**: Locations mapped to journey progression stages

### 📊 **Advanced Sentiment Analysis**
- **Multiple Lexicons**: AFINN, Bing, NRC, SentiWordNet, and SenticNet
- **Enhanced Scoring**: Composite sentiment scores with importance weighting
- **Sentiment Categories**: Very Positive, Positive, Neutral, Negative, Very Negative
- **Sentiment Stability**: Measures sentiment variability across chapters

### 🗺️ **Interactive Visualizations**
- **Interactive Leaflet Maps**: Clickable world map with sentiment-colored locations
- **Journey Timeline**: Interactive timeline showing sentiment progression
- **Geographic Analysis**: Continent and country-level sentiment comparisons
- **Prominence Analysis**: Location importance vs sentiment relationships

### 📈 **Statistical Analysis**
- **Correlation Analysis**: Relationships between sentiment and geographic factors
- **Location Rankings**: Top locations by sentiment, mentions, and prominence
- **Journey Stage Analysis**: Sentiment trends across journey phases
- **Geographic Distribution**: Sentiment patterns across continents

## Files Created

### 1. `geospatial_sentiment_mapping.R`
- **Purpose**: Core geospatial sentiment mapping system
- **Features**:
  - Location extraction from text
  - Sentiment analysis integration
  - Basic geospatial visualizations
  - Statistical analysis and correlations

### 2. `interactive_geospatial_mapping.R`
- **Purpose**: Advanced interactive geospatial analysis
- **Features**:
  - Interactive Leaflet maps
  - Advanced location analysis with prominence scoring
  - Journey progression analysis
  - Comprehensive statistical analysis

## Data Structure

### Location Database
Each location includes:
- **Location Name**: City, country, or geographic feature
- **Country**: Primary country
- **Continent**: Geographic continent
- **Coordinates**: Latitude and longitude
- **Region Type**: City, Country, Institution, etc.
- **Journey Order**: Position in Fogg's journey (1-9)
- **Significance**: Very High, High, Medium, Low

### Sentiment Mapping
Each location-sentiment record includes:
- **Chapter**: Chapter number where location appears
- **Location**: Extracted location name
- **Sentiment Scores**: AFINN, Bing, NRC, SentiWordNet, SenticNet
- **Mentions**: Number of times location appears in chapter
- **Importance Weight**: Based on location significance
- **Journey Progress**: Chapter position as percentage of total

## How to Use

### Step 1: Run Basic Geospatial Analysis
```r
# Run the core geospatial sentiment mapping
source("geospatial_sentiment_mapping.R")
```

### Step 2: Run Interactive Analysis
```r
# Run the advanced interactive analysis
source("interactive_geospatial_mapping.R")
```

### Step 3: Explore Results
- **Interactive Map**: Click on locations to see sentiment details
- **Journey Timeline**: Hover over points to see chapter information
- **Statistical Analysis**: Review correlation and ranking results

## Key Insights

### Location Analysis
- **Most Positive Locations**: Locations with highest sentiment scores
- **Most Mentioned Locations**: Locations appearing most frequently
- **Most Prominent Locations**: Locations with highest importance scores
- **Sentiment Variability**: How consistent sentiment is across chapters

### Journey Analysis
- **Departure & Planning**: Early chapters in London
- **European Journey**: Travel through France and Italy
- **Suez Crossing**: Passage through Egypt
- **Indian Adventure**: Major destination in India
- **Asian Exploration**: Travel through Singapore, Hong Kong, Japan
- **American Journey**: Crossing the United States
- **Return to London**: Final journey home

### Geographic Patterns
- **Continent Sentiment**: Average sentiment by continent
- **Country Analysis**: Sentiment patterns by country
- **Regional Trends**: Geographic clustering of sentiment

## Output Files

### Data Files
- `geospatial_sentiment_data.csv`: Complete location-sentiment mapping
- `location_sentiment_summary.csv`: Location sentiment statistics
- `continent_sentiment_summary.csv`: Continent sentiment analysis
- `country_sentiment_summary.csv`: Country sentiment analysis
- `journey_timeline.csv`: Journey progression with sentiment
- `locations_database.csv`: Complete location database

### Enhanced Data Files
- `geospatial_sentiment_enhanced.csv`: Enhanced location-sentiment data
- `location_analysis_comprehensive.csv`: Comprehensive location statistics
- `journey_analysis_detailed.csv`: Detailed journey analysis
- `journey_stage_analysis.csv`: Journey stage sentiment analysis
- `continent_analysis_enhanced.csv`: Enhanced continent analysis
- `locations_database_enhanced.csv`: Enhanced location database

### Summary Files
- `geospatial_analysis_summary.csv`: Key statistics summary

## Visualizations Created

### Static Visualizations
1. **World Map with Sentiment Colors**: Locations colored by sentiment category
2. **Sentiment by Continent**: Bar chart of average sentiment by continent
3. **Sentiment by Country**: Bar chart of average sentiment by country
4. **Sentiment vs Variability**: Scatter plot of sentiment vs variability
5. **Journey Timeline**: Line chart showing sentiment progression

### Interactive Visualizations
1. **Interactive Leaflet Map**: Clickable world map with popup information
2. **Interactive Journey Timeline**: Hover-enabled timeline with detailed information
3. **Advanced Scatter Plots**: Interactive plots with hover information

## Statistical Analysis

### Correlation Analysis
- Sentiment lexicon correlations
- Geographic factor correlations
- Journey progression correlations

### Location Rankings
- Top 10 most positive locations
- Top 10 most mentioned locations
- Top 10 most prominent locations

### Journey Analysis
- Sentiment by journey stage
- Geographic progression analysis
- Chapter-level sentiment trends

## Integration with Existing Analysis

### Compatibility
- **Existing Sentiment Data**: Integrates with existing lexicon analysis
- **Enhanced Preprocessing**: Uses consistent preprocessing pipeline
- **Multiple Lexicons**: Works with AFINN, Bing, NRC, SentiWordNet, SenticNet

### Extensions
- **Geographic Coordinates**: Adds latitude/longitude to all locations
- **Journey Mapping**: Maps sentiment to journey progression
- **Importance Weighting**: Incorporates location significance

## Technical Features

### Location Extraction
- **Pattern Matching**: Uses regex patterns to find location mentions
- **Case Insensitive**: Handles variations in capitalization
- **Context Aware**: Considers word boundaries for accurate matching
- **Mention Counting**: Tracks frequency of location mentions

### Sentiment Integration
- **Multiple Lexicons**: Combines results from all sentiment lexicons
- **Composite Scoring**: Creates unified sentiment scores
- **Weighted Analysis**: Incorporates location importance
- **Variability Analysis**: Measures sentiment consistency

### Geospatial Analysis
- **Coordinate Mapping**: Precise latitude/longitude coordinates
- **Distance Calculations**: Geographic distance analysis
- **Regional Grouping**: Continent and country-level analysis
- **Journey Progression**: Maps sentiment to journey stages

## Research Applications

### Digital Humanities
- **Literary Geography**: Mapping emotional landscapes in literature
- **Journey Analysis**: Understanding emotional progression in travel narratives
- **Cultural Geography**: Exploring cultural sentiment patterns

### Sentiment Analysis Research
- **Lexicon Comparison**: Comparing different sentiment analysis approaches
- **Geographic Sentiment**: Understanding location-based sentiment patterns
- **Temporal Analysis**: Sentiment trends across narrative progression

### Visualization Research
- **Interactive Mapping**: Creating engaging geographic visualizations
- **Data Storytelling**: Combining narrative and data visualization
- **User Experience**: Interactive exploration of literary data

## Future Enhancements

### Additional Features
- **Character Analysis**: Map character mentions to locations
- **Temporal Mapping**: Time-based sentiment analysis
- **Network Analysis**: Location connectivity analysis
- **Machine Learning**: Predictive sentiment modeling

### Integration Options
- **Web Application**: Shiny app for interactive exploration
- **API Development**: REST API for data access
- **Database Integration**: Store results in database
- **Export Formats**: Multiple export options (JSON, XML, etc.)

## Support and Troubleshooting

### Common Issues
1. **Package Dependencies**: Ensure all required packages are installed
2. **Data Paths**: Verify file paths are correct for your system
3. **Memory Usage**: Large datasets may require increased memory allocation
4. **Coordinate Accuracy**: Some locations may need coordinate verification

### Performance Optimization
- **Data Filtering**: Filter data early to reduce processing time
- **Parallel Processing**: Use parallel processing for large datasets
- **Memory Management**: Clear unused objects to free memory
- **Caching**: Cache intermediate results for faster processing

## Conclusion

This geospatial sentiment mapping system provides a comprehensive framework for analyzing emotional trends across geographic locations in literary texts. By combining advanced sentiment analysis with geographic information, it offers unique insights into how emotions vary across different locations and journey stages in Jules Verne's "Around the World in 80 Days."

The system is designed to be extensible and can be adapted for other literary works or geographic datasets. It provides both detailed analysis capabilities and interactive exploration tools, making it suitable for both research and educational purposes.

