# Interactive Geospatial Sentiment Mapping for Around the World in 80 Days
#
# This file creates interactive maps and advanced geospatial visualizations
# combining sentiment analysis with geographic locations. It integrates with
# existing sentiment analysis and provides interactive features for exploration.
#
# Features:
# - Interactive Leaflet maps
# - Advanced geospatial statistics
# - Integration with existing sentiment analysis
# - Dynamic filtering and exploration
# - Export capabilities for further analysis
#
# Author: Interactive Geospatial Sentiment Analysis
# Last Modified: January 2025

## Load Libraries ----

pacman::p_load(tidyverse, tidytext, stopwords, leaflet, sf, maps, ggplot2, 
               plotly, DT, shiny, shinyWidgets, RColorBrewer, viridis)

# List of possible files (prioritize files with afinn_score)
candidates <- c(
  "data/extended_lexicon_scores.csv",
  "data/multiple_lexicon_scores.csv",
  "data/enhanced_sentiment_scores.csv"
)

# Pick the first that exists and has afinn_score
sentiment_data <- NULL
for (candidate in candidates) {
  if (file.exists(candidate)) {
    message("Trying to load: ", candidate)
    temp_data <- read.csv(candidate, check.names = FALSE)
    if ("afinn_score" %in% names(temp_data)) {
      sentiment_data <- temp_data
      message("✅ Loaded ", nrow(sentiment_data), " rows successfully from ", candidate)
      break
    } else {
      message("⚠️ ", candidate, " does not have 'afinn_score' column, trying next file...")
    }
  }
}

if (is.null(sentiment_data)) {
  stop("⚠️ No matching sentiment file with 'afinn_score' found in /data.")
}

# Verify load
if (!is.null(sentiment_data)) {
  cat("✅ Sentiment data loaded successfully.\n")
} else {
  cat("⚠️ No sentiment file found.\n")
}


#getwd()                              # confirm working directory
#list.files("data")                   # see what’s actually in /data


# If no usable data, create basic sentiment analysis
if (!exists("sentiment_data") || is.null(sentiment_data) || !("afinn_score" %in% names(sentiment_data))) {
  cat("No existing sentiment data found. Creating basic sentiment analysis...\n")
  
  # Load and preprocess data
  data <- read.csv("data/around_world_80_days.csv") %>%
    select(-X)
  
  # Basic preprocessing
  tidy_book_clean <- data %>%
    unnest_tokens(word, text, token = "words", to_lower = TRUE, 
                  strip_punct = TRUE, strip_numeric = TRUE) %>%
    filter(!is.na(word), str_length(word) > 2) %>%
    filter(!word %in% c(stopwords::stopwords("en", source = "snowball"), tidytext::stop_words$word)) %>%
    count(chapter, word, sort = TRUE)
  
  # Basic AFINN sentiment analysis
  afinn <- get_sentiments("afinn")
  sentiment_data <- tidy_book_clean %>%
    inner_join(afinn, by = "word") %>%
    group_by(chapter) %>%
    summarise(
      afinn_score = sum(n * value) / sum(n),
      total_words = sum(n),
      sentiment_words = n()
    ) %>%
    ungroup()
}

## Enhanced Location Database ----

# Comprehensive location database with enhanced metadata
loc_vec <- c(
  # England/UK - Detailed locations
  "London", "Saville Row", "Burlington Gardens", "Reform Club", "Pall Mall", 
  "Charing Cross", "Dover", "Calais", "Liverpool", "Glasgow", "Birmingham", "Manchester",
  
  # France
  "Paris", "Brindisi",
  
  # Italy
  "Turin", "Mont Cenis", "Rome", "Naples", "Venice", "Florence",
  
  # Egypt/Suez
  "Suez", "Cairo", "Egypt", "Red Sea", "Aden", "Port Said", "Alexandria",
  
  # India - Comprehensive
  "Bombay", "Calcutta", "India", "Allahabad", "Benares", "Goa", "Rothal",
  "Great Indian Peninsula Railway",
  
  # Asia
  "Singapore", "Hong Kong", "China", "Yokohama", "Japan", "Shanghai", "Beijing",
  
  # Pacific/America
  "San Francisco", "New York", "America", "United States", "California", "Nevada", "Utah",
  
  # Other locations
  "Madrid", "Constantinople", "Athens", "Mocha", "Steamer Point", "Bab-el-Mandeb",
  "Havre", "Gibraltar", "Malta", "Cyprus"
)

country_vec <- c(
  rep("United Kingdom", 12), rep("France", 2), rep("Italy", 6), rep("Egypt", 7),
  rep("India", 8), rep("Singapore", 1), rep("Hong Kong", 1), rep("China", 3), 
  rep("Japan", 2), rep("United States", 7), rep("Spain", 1), rep("Turkey", 1),
  rep("Greece", 1), rep("Yemen", 3), rep("France", 1), rep("United Kingdom", 3)
)

continent_vec <- c(
  rep("Europe", 20), rep("Africa", 7), rep("Asia", 15), rep("North America", 7),
  rep("Europe", 5)
)

lat_vec <- c(
  # UK
  51.5074, 51.5074, 51.5074, 51.5074, 51.5074, 51.5074, 51.1267, 50.9513, 53.4084, 55.8642, 52.4862, 53.4808,
  # France
  48.8566, 40.6363,
  # Italy
  45.0703, 45.0736, 41.9028, 40.8518, 45.4408, 43.7696,
  # Egypt
  29.9668, 30.0444, 26.0975, 20.0, 12.8275, 31.2653, 31.2001,
  # India
  19.0760, 22.5726, 20.5937, 25.4484, 25.3176, 15.2993, 25.4484, 25.4484,
  # Asia
  1.3521, 22.3193, 35.8617, 35.4437, 35.6762, 31.2304, 39.9042,
  # America
  37.7749, 40.7128, 39.8283, 37.0902, 36.7783, 38.4199, 39.3209,
  # Other
  40.4168, 41.0082, 37.9755, 13.3167, 12.8275, 12.8275, 49.4944, 36.1408, 35.8997, 35.1264
)

lon_vec <- c(
  # UK
  -0.1278, -0.1278, -0.1278, -0.1278, -0.1278, -0.1278, 1.3139, 1.8587, -2.9916, -4.2518, -1.8904, -2.2426,
  # France
  2.3522, 17.9441,
  # Italy
  7.6869, 6.8883, 12.4964, 14.2681, 12.3155, 11.2558,
  # Egypt
  32.5498, 31.2357, 31.2357, 40.0, 45.0339, 32.3019, 29.9187,
  # India
  72.8777, 88.3639, 78.9629, 81.8463, 82.9739, 74.1240, 81.8463, 81.8463,
  # Asia
  103.8198, 114.1694, 104.1954, 139.6380, 139.6503, 121.4737, 116.4074,
  # America
  -122.4194, -74.0060, -98.5795, -95.7129, -119.4179, -117.1219, -111.0937,
  # Other
  -3.7038, 28.9784, 23.7348, 43.7500, 45.0339, 45.0339, 0.1079, -5.3536, 14.5147, 33.4299
)

region_type_vec <- c(
  rep("City", 4), rep("Street", 1), rep("Institution", 1), rep("Station", 1), rep("Port", 2), rep("City", 4),
  rep("City", 2), rep("City", 2), rep("Pass", 1), rep("City", 3),
  rep("City", 2), rep("Country", 1), rep("Sea", 1), rep("City", 2), rep("Port", 2),
  rep("City", 3), rep("Country", 1), rep("City", 2), rep("Railway", 2),
  rep("City", 2), rep("Country", 1), rep("City", 2), rep("City", 2),
  rep("City", 2), rep("Country", 2), rep("State", 3),
  rep("City", 1), rep("City", 1), rep("City", 1), rep("City", 3), rep("Port", 1), rep("Territory", 3)
)

journey_order_vec <- c(
  # UK - Start of journey
  rep(1, 8), rep(2, 4),
  # France/Italy - Early Europe
  rep(3, 2), rep(4, 6),
  # Egypt - Suez crossing
  rep(5, 7),
  # India - Major destination
  rep(6, 8),
  # Asia - Eastward journey
  rep(7, 7),
  # America - Return journey
  rep(8, 7),
  # Other locations
  rep(9, 10)
)

significance_vec <- c(
  # UK - Very significant (start/end)
  rep("Very High", 4), rep("High", 4), rep("Medium", 4),
  # France/Italy - High significance
  rep("High", 2), rep("Medium", 6),
  # Egypt - Very high (key crossing)
  rep("Very High", 3), rep("High", 2), rep("Medium", 2),
  # India - Very high (major destination)
  rep("Very High", 3), rep("High", 3), rep("Medium", 2),
  # Asia - High significance
  rep("High", 2), rep("Medium", 5),
  # America - High significance
  rep("Very High", 2), rep("High", 2), rep("Medium", 3),
  # Other - Low to medium
  rep("Low", 3), rep("Medium", 7)
)

# Align lengths to avoid mismatches
len_vec <- c(length(loc_vec), length(country_vec), length(continent_vec), length(lat_vec), length(lon_vec), length(region_type_vec), length(journey_order_vec), length(significance_vec))
min_len <- min(len_vec)
if (length(loc_vec) != min_len || length(country_vec) != min_len || length(continent_vec) != min_len || length(lat_vec) != min_len || length(lon_vec) != min_len || length(region_type_vec) != min_len || length(journey_order_vec) != min_len || length(significance_vec) != min_len) {
  message("⚠️ locations_database vectors had differing lengths (", paste(len_vec, collapse=","), "). Truncating all to ", min_len, ".")
}

locations_database <- data.frame(
  location = loc_vec[seq_len(min_len)],
  country = country_vec[seq_len(min_len)],
  continent = continent_vec[seq_len(min_len)],
  latitude = lat_vec[seq_len(min_len)],
  longitude = lon_vec[seq_len(min_len)],
  region_type = region_type_vec[seq_len(min_len)],
  journey_order = journey_order_vec[seq_len(min_len)],
  significance = significance_vec[seq_len(min_len)],
  stringsAsFactors = FALSE
)

## Location Extraction and Mapping ----

cat("Extracting locations and mapping with sentiment...\n")

# Enhanced location extraction function
extract_locations_enhanced <- function(text, locations_db) {
  if (is.null(text) || is.na(text) || nchar(text) == 0) {
    return(data.frame(
      locations = character(0),
      mentions = integer(0),
      stringsAsFactors = FALSE
    ))
  }
  
  text_lower <- tolower(text)
  found_locations <- c()
  location_mentions <- c()
  
  for (i in 1:nrow(locations_db)) {
    location <- tolower(locations_db$location[i])
    pattern <- paste0("\\b", gsub("([()])", "\\\\\\1", location), "\\b")
    matches <- gregexpr(pattern, text_lower, ignore.case = TRUE)[[1]]
    
    if (length(matches) > 0 && matches[1] != -1) {
      found_locations <- c(found_locations, locations_db$location[i])
      location_mentions <- c(location_mentions, length(matches))
    }
  }
  
  if (length(found_locations) == 0) {
    return(data.frame(
      locations = character(0),
      mentions = integer(0),
      stringsAsFactors = FALSE
    ))
  }
  
  return(data.frame(
    locations = found_locations,
    mentions = location_mentions,
    stringsAsFactors = FALSE
  ))
}

# Load main data
data <- read.csv("data/around_world_80_days.csv", stringsAsFactors = FALSE, row.names = NULL)
# Remove any row names column (usually named "X" or empty string)
if ("X" %in% names(data)) {
  data <- data %>% select(-X)
}
# Remove empty first column if it exists (row names from CSV)
if (names(data)[1] == "" || names(data)[1] == "X") {
  data <- data[, -1, drop = FALSE]
}
cat("Loaded", nrow(data), "chapters from data file.\n")
cat("Columns:", paste(names(data), collapse = ", "), "\n")

# Extract locations from each chapter
cat("Extracting locations from chapters...\n")
chapter_locations_enhanced <- data %>%
  rowwise() %>%
  mutate(
    locations_info = list(extract_locations_enhanced(text, locations_database))
  ) %>%
  ungroup()

# Check if we have any locations
if (nrow(chapter_locations_enhanced) == 0) {
  stop("No chapters found in data. Please check the data file.")
}

# Unnest locations (this will drop rows with no locations, which is fine)
# Try with keep_empty parameter, fall back to basic unnest if not supported
tryCatch({
  chapter_locations_enhanced <- chapter_locations_enhanced %>%
    unnest(locations_info, keep_empty = FALSE)
}, error = function(e) {
  # Fallback for older tidyr versions
  chapter_locations_enhanced <<- chapter_locations_enhanced %>%
    unnest(locations_info)
})

cat("Found", nrow(chapter_locations_enhanced), "location mentions across chapters.\n")

# Check if we have any locations after unnesting
if (nrow(chapter_locations_enhanced) == 0) {
  stop("No locations found in any chapters. Please check the location database.")
}

# Create comprehensive location-sentiment mapping
cat("Creating geospatial sentiment mapping...\n")
geospatial_sentiment_enhanced <- chapter_locations_enhanced %>%
  left_join(locations_database, by = c("locations" = "location")) %>%
  left_join(sentiment_data, by = "chapter") %>%
  filter(!is.na(country)) %>%
  mutate(
    # Enhanced sentiment calculations
    sentiment_intensity = abs(afinn_score),
    sentiment_direction = ifelse(afinn_score > 0, "Positive", "Negative"),
    # Journey progression
    journey_progress = chapter / max(chapter, na.rm = TRUE),
    # Location importance weighting
    importance_weight = case_when(
      significance == "Very High" ~ 3,
      significance == "High" ~ 2,
      significance == "Medium" ~ 1.5,
      significance == "Low" ~ 1,
      TRUE ~ 1
    )
  )

# Verify geospatial_sentiment_enhanced was created
if (!exists("geospatial_sentiment_enhanced") || nrow(geospatial_sentiment_enhanced) == 0) {
  stop("Failed to create geospatial_sentiment_enhanced. Check that locations match the database and sentiment data exists for all chapters.")
}

cat("Created geospatial_sentiment_enhanced with", nrow(geospatial_sentiment_enhanced), "records.\n")

## Advanced Geospatial Analysis ----

cat("Performing advanced geospatial analysis...\n")

# Calculate comprehensive location statistics
location_analysis <- geospatial_sentiment_enhanced %>%
  group_by(locations, country, continent, latitude, longitude, region_type, 
           journey_order, significance) %>%
  summarise(
    chapter_count = n(),
    total_mentions = sum(mentions, na.rm = TRUE),
    avg_sentiment = mean(afinn_score, na.rm = TRUE),
    median_sentiment = median(afinn_score, na.rm = TRUE),
    sentiment_std = sd(afinn_score, na.rm = TRUE),
    min_sentiment = min(afinn_score, na.rm = TRUE),
    max_sentiment = max(afinn_score, na.rm = TRUE),
    sentiment_range = max_sentiment - min_sentiment,
    weighted_sentiment = sum(afinn_score * importance_weight, na.rm = TRUE) / sum(importance_weight, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    # Enhanced categorization
    sentiment_category = case_when(
      avg_sentiment > 0.5 ~ "Very Positive",
      avg_sentiment > 0.2 ~ "Positive", 
      avg_sentiment > -0.2 ~ "Neutral",
      avg_sentiment > -0.5 ~ "Negative",
      TRUE ~ "Very Negative"
    ),
    # Sentiment stability
    sentiment_stability = case_when(
      sentiment_std < 0.2 ~ "Very Stable",
      sentiment_std < 0.5 ~ "Stable",
      sentiment_std < 1.0 ~ "Variable",
      TRUE ~ "Highly Variable"
    ),
    # Location prominence
    prominence_score = (chapter_count * 0.4) + (total_mentions * 0.3) + (importance_weight * 0.3)
  )

# Verify location_analysis was created
if (!exists("location_analysis") || nrow(location_analysis) == 0) {
  stop("Failed to create location_analysis. Check that geospatial_sentiment_enhanced has valid data.")
}

cat("Created location_analysis with", nrow(location_analysis), "locations.\n")

# Journey analysis with geographic progression
journey_analysis <- geospatial_sentiment_enhanced %>%
  arrange(chapter) %>%
  group_by(chapter) %>%
  summarise(
    primary_location = locations[which.max(mentions)],
    primary_country = country[which.max(mentions)],
    primary_continent = continent[which.max(mentions)],
    avg_sentiment = mean(afinn_score, na.rm = TRUE),
    location_count = n_distinct(locations),
    total_mentions = sum(mentions, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    journey_stage = case_when(
      chapter <= 5 ~ "Departure & Planning",
      chapter <= 10 ~ "European Journey",
      chapter <= 15 ~ "Suez Crossing",
      chapter <= 25 ~ "Indian Adventure",
      chapter <= 35 ~ "Asian Exploration",
      chapter <= 45 ~ "American Journey",
      TRUE ~ "Return to London"
    ),
    distance_from_london = sqrt((latitude - 51.5074)^2 + (longitude - (-0.1278))^2)
  ) %>%
  left_join(locations_database %>% select(location, latitude, longitude), 
            by = c("primary_location" = "location"))

## Interactive Visualizations ----

cat("Creating interactive visualizations...\n")

### 1. Interactive Leaflet Map
create_interactive_map <- function(location_data) {
  # Color palette for sentiment
  sentiment_palette <- colorFactor(
    palette = c("#DC143C", "#FFB6C1", "#F0E68C", "#90EE90", "#2E8B57"),
    domain = c("Very Negative", "Negative", "Neutral", "Positive", "Very Positive")
  )
  
  # Create popup content
  popup_content <- paste0(
    "<strong>", location_data$locations, "</strong><br/>",
    "Country: ", location_data$country, "<br/>",
    "Continent: ", location_data$continent, "<br/>",
    "Sentiment: ", round(location_data$avg_sentiment, 3), "<br/>",
    "Category: ", location_data$sentiment_category, "<br/>",
    "Chapters: ", location_data$chapter_count, "<br/>",
    "Mentions: ", location_data$total_mentions, "<br/>",
    "Significance: ", location_data$significance
  )
  
  # Create interactive map
  map <- leaflet(location_data) %>%
    addTiles() %>%
    addCircleMarkers(
      lng = ~longitude,
      lat = ~latitude,
      radius = ~sqrt(chapter_count) * 3,
      color = ~sentiment_palette(sentiment_category),
      fillOpacity = 0.7,
      stroke = TRUE,
      weight = 2,
      popup = popup_content
    ) %>%
    addLegend(
      "bottomright",
      pal = sentiment_palette,
      values = ~sentiment_category,
      title = "Sentiment Category",
      opacity = 1
    ) %>%
    setView(lng = 0, lat = 20, zoom = 2)
  
  return(map)
}

# Create the interactive map
interactive_map <- create_interactive_map(location_analysis)
print(interactive_map)

### 2. Interactive Journey Timeline
create_journey_timeline <- function(journey_data) {
  p <- plot_ly(journey_data, x = ~chapter, y = ~avg_sentiment,
               color = ~primary_continent,
               size = ~total_mentions,
               text = ~paste("Chapter:", chapter, "<br>",
                            "Location:", primary_location, "<br>",
                            "Country:", primary_country, "<br>",
                            "Sentiment:", round(avg_sentiment, 3), "<br>",
                            "Stage:", journey_stage),
               hoverinfo = "text",
               type = "scatter",
               mode = "markers+lines") %>%
    layout(
      title = "Interactive Journey Timeline: Sentiment Across Phileas Fogg's Route",
      xaxis = list(title = "Chapter"),
      yaxis = list(title = "Average Sentiment Score"),
      hovermode = "closest"
    )
  
  return(p)
}

# Create journey timeline
journey_timeline_plot <- create_journey_timeline(journey_analysis)
print(journey_timeline_plot)

### 3. Sentiment Distribution by Continent
continent_analysis <- location_analysis %>%
  group_by(continent) %>%
  summarise(
    location_count = n(),
    avg_sentiment = mean(avg_sentiment, na.rm = TRUE),
    total_chapters = sum(chapter_count, na.rm = TRUE),
    total_mentions = sum(total_mentions, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  arrange(desc(avg_sentiment))

p1 <- ggplot(continent_analysis, aes(x = reorder(continent, avg_sentiment), 
                                    y = avg_sentiment, fill = continent)) +
  geom_col(alpha = 0.8) +
  geom_text(aes(label = round(avg_sentiment, 3)), hjust = -0.1, size = 4) +
  coord_flip() +
  labs(title = "Average Sentiment by Continent",
       subtitle = "Based on location mentions in Around the World in 80 Days",
       x = "Continent", y = "Average Sentiment Score") +
  theme_minimal() +
  theme(legend.position = "none")

print(p1)

### 4. Sentiment vs Location Prominence
p2 <- ggplot(location_analysis, aes(x = prominence_score, y = avg_sentiment)) +
  geom_point(aes(color = sentiment_category, size = chapter_count), alpha = 0.7) +
  geom_text(aes(label = locations), size = 3, hjust = 0.5, vjust = -0.5) +
  scale_color_manual(values = c("Very Negative" = "#DC143C", "Negative" = "#FFB6C1", 
                               "Neutral" = "#F0E68C", "Positive" = "#90EE90", 
                               "Very Positive" = "#2E8B57")) +
  labs(title = "Sentiment vs Location Prominence",
       subtitle = "X-axis: Prominence Score, Y-axis: Average Sentiment",
       x = "Prominence Score", y = "Average Sentiment Score",
       color = "Sentiment Category", size = "Chapter Count") +
  theme_minimal()

print(p2)

### 5. Journey Stages Analysis
journey_stage_analysis <- journey_analysis %>%
  group_by(journey_stage) %>%
  summarise(
    avg_sentiment = mean(avg_sentiment, na.rm = TRUE),
    chapter_count = n(),
    total_locations = sum(location_count, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  arrange(desc(avg_sentiment))

p3 <- ggplot(journey_stage_analysis, aes(x = reorder(journey_stage, avg_sentiment), 
                                        y = avg_sentiment, fill = journey_stage)) +
  geom_col(alpha = 0.8) +
  geom_text(aes(label = round(avg_sentiment, 3)), hjust = -0.1, size = 4) +
  coord_flip() +
  labs(title = "Average Sentiment by Journey Stage",
       subtitle = "Sentiment progression through Phileas Fogg's journey",
       x = "Journey Stage", y = "Average Sentiment Score") +
  theme_minimal() +
  theme(legend.position = "none")

print(p3)

## Advanced Statistical Analysis ----

cat("Performing advanced statistical analysis...\n")

### Correlation Analysis
cat("=== ADVANCED GEOSPATIAL CORRELATION ANALYSIS ===\n")
correlation_vars <- geospatial_sentiment_enhanced %>%
  select(afinn_score, mentions, importance_weight, journey_progress, 
         chapter, latitude, longitude) %>%
  cor(use = "complete.obs")

print("Correlation Matrix:")
print(round(correlation_vars, 3))

### Location Ranking Analysis
cat("\n=== TOP LOCATIONS BY VARIOUS METRICS ===\n")

cat("Top 10 Most Positive Locations:\n")
top_positive <- location_analysis %>%
  arrange(desc(avg_sentiment)) %>%
  head(10) %>%
  select(locations, country, continent, avg_sentiment, chapter_count, significance)
print(top_positive)

cat("\nTop 10 Most Mentioned Locations:\n")
top_mentioned <- location_analysis %>%
  arrange(desc(total_mentions)) %>%
  head(10) %>%
  select(locations, country, continent, total_mentions, avg_sentiment, significance)
print(top_mentioned)

cat("\nTop 10 Most Prominent Locations:\n")
top_prominent <- location_analysis %>%
  arrange(desc(prominence_score)) %>%
  head(10) %>%
  select(locations, country, continent, prominence_score, avg_sentiment, significance)
print(top_prominent)

### Journey Analysis
cat("\n=== JOURNEY STAGE ANALYSIS ===\n")
journey_summary <- journey_stage_analysis %>%
  select(journey_stage, avg_sentiment, chapter_count, total_locations)
print(journey_summary)

### Geographic Distribution
cat("\n=== GEOGRAPHIC DISTRIBUTION ===\n")
geo_summary <- location_analysis %>%
  group_by(continent) %>%
  summarise(
    locations = n(),
    avg_sentiment = mean(avg_sentiment, na.rm = TRUE),
    total_chapters = sum(chapter_count, na.rm = TRUE),
    total_mentions = sum(total_mentions, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  arrange(desc(avg_sentiment))
print(geo_summary)

## Export Results ----

cat("Exporting comprehensive geospatial analysis results...\n")

# Save all analysis results
write.csv(geospatial_sentiment_enhanced, "data/geospatial_sentiment_enhanced.csv")
write.csv(location_analysis, "data/location_analysis_comprehensive.csv")
write.csv(journey_analysis, "data/journey_analysis_detailed.csv")
write.csv(journey_stage_analysis, "data/journey_stage_analysis.csv")
write.csv(continent_analysis, "data/continent_analysis_enhanced.csv")
write.csv(locations_database, "data/locations_database_enhanced.csv")

# Create summary report
summary_report <- list(
  total_locations = nrow(location_analysis),
  total_location_mentions = sum(location_analysis$total_mentions, na.rm = TRUE),
  continents_covered = length(unique(location_analysis$continent)),
  countries_covered = length(unique(location_analysis$country)),
  most_positive_location = location_analysis$locations[which.max(location_analysis$avg_sentiment)],
  most_mentioned_location = location_analysis$locations[which.max(location_analysis$total_mentions)],
  most_prominent_location = location_analysis$locations[which.max(location_analysis$prominence_score)],
  average_sentiment = mean(location_analysis$avg_sentiment, na.rm = TRUE),
  sentiment_range = range(location_analysis$avg_sentiment, na.rm = TRUE)
)

# Save summary report
write.csv(data.frame(summary_report), "data/geospatial_analysis_summary.csv")

## Final Summary ----

cat("\n=== INTERACTIVE GEOSPATIAL SENTIMENT MAPPING SUMMARY ===\n")
cat("Comprehensive geospatial sentiment analysis completed successfully!\n")

cat("\nKey Results:\n")
cat("- Total locations analyzed:", summary_report$total_locations, "\n")
cat("- Total location mentions:", summary_report$total_location_mentions, "\n")
cat("- Continents covered:", summary_report$continents_covered, "\n")
cat("- Countries covered:", summary_report$countries_covered, "\n")
cat("- Most positive location:", summary_report$most_positive_location, "\n")
cat("- Most mentioned location:", summary_report$most_mentioned_location, "\n")
cat("- Most prominent location:", summary_report$most_prominent_location, "\n")
cat("- Overall average sentiment:", round(summary_report$average_sentiment, 3), "\n")
cat("- Sentiment range:", round(summary_report$sentiment_range[1], 3), "to", round(summary_report$sentiment_range[2], 3), "\n")

cat("\nInteractive Features Created:\n")
cat("- Interactive Leaflet map with sentiment-colored locations\n")
cat("- Interactive journey timeline with hover information\n")
cat("- Advanced geospatial statistics and correlations\n")
cat("- Comprehensive location analysis with prominence scoring\n")

cat("\nFiles Saved:\n")
cat("- data/geospatial_sentiment_enhanced.csv: Complete enhanced location-sentiment data\n")
cat("- data/location_analysis_comprehensive.csv: Comprehensive location statistics\n")
cat("- data/journey_analysis_detailed.csv: Detailed journey progression analysis\n")
cat("- data/journey_stage_analysis.csv: Journey stage sentiment analysis\n")
cat("- data/continent_analysis_enhanced.csv: Enhanced continent analysis\n")
cat("- data/locations_database_enhanced.csv: Enhanced location database\n")
cat("- data/geospatial_analysis_summary.csv: Summary statistics\n")

cat("\nThis analysis provides a complete geospatial sentiment mapping system\n")
cat("for Jules Verne's 'Around the World in 80 Days', combining advanced\n")
cat("sentiment analysis with geographic location extraction and interactive\n")
cat("visualization capabilities for comprehensive exploration of emotional\n")
cat("trends across Phileas Fogg's journey around the world.\n")
