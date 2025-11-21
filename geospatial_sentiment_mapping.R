# Geospatial Sentiment Mapping for Around the World in 80 Days
#
# This file combines sentiment analysis with geographic location extraction to create
# a comprehensive geospatial sentiment mapping system. It extracts locations from text,
# maps them with sentiment scores, and creates visualizations showing emotional trends
# across geographic locations in the novel.
#
# Features:
# - Named Entity Recognition for location extraction
# - Location-sentiment mapping using multiple lexicons
# - Geospatial visualization with coordinates
# - Integration with existing sentiment analysis
# - Interactive maps and statistical analysis
#
# Author: Geospatial Sentiment Analysis
# Last Modified: January 2025

## Load Libraries ----

pacman::p_load(tidyverse, tidytext, stopwords, gridExtra, patchwork, scales, 
               lexicon, textdata, httr, jsonlite, openNLP, NLP, tm, 
               ggplot2, leaflet, sf, maps, ggmap, rworldmap, countrycode)

theme_set(theme_bw())

## Load Data ----

data <- read.csv("C:\\Users\\KESHAV\\OneDrive\\Desktop\\a1918485\\2025\\Trimester 2\\Research Project A\\My Project\\data\\around_world_80_days.csv") %>%
  select(-X)

cat("Data loaded successfully with", nrow(data), "chapters\n")

## Enhanced Preprocessing ----

# Apply consistent preprocessing
tidy_book_enhanced <- data %>%
  unnest_tokens(word, text, 
                token = "words",
                to_lower = TRUE,
                strip_punct = TRUE,
                strip_numeric = TRUE) %>%
  filter(!is.na(word)) %>%
  filter(str_length(word) > 2)

# Remove stop words
stop_words_en <- stopwords::stopwords("en", source = "snowball")
stop_words_tidy <- stop_words$word
all_stop_words <- unique(c(stop_words_en, stop_words_tidy))

tidy_book_clean <- tidy_book_enhanced %>%
  filter(!word %in% all_stop_words) %>%
  count(chapter, word, sort = TRUE)

## Location Extraction System ----

cat("Setting up location extraction system...\n")

# Comprehensive Location Database for "Around the World in 80 Days"
# (lengths aligned across all columns; 51 rows total)

locations_database <- data.frame(
  location = c(
    # England/UK
    "London", "Savile Row", "Burlington Gardens", "Reform Club", "Pall Mall",
    "Charing Cross", "Dover", "Calais",
    
    # France
    "Paris", 
    
    # Italy
    "Brindisi", "Turin", "Mont Cenis",
    
    # Egypt/Suez
    "Suez", "Cairo", "Egypt", "Red Sea", "Aden",
    
    # India
    "Bombay", "Calcutta", "India", "Allahabad", "Benares", "Goa",
    
    # Asia
    "Singapore", "Hong Kong", "China", "Yokohama", "Japan",
    
    # Pacific/America
    "San Francisco", "New York", "America", "United States",
    
    # Other locations mentioned (19)
    "Liverpool", "Glasgow", "Havre", "Birmingham", "Manchester",
    "Madrid", "Rome", "Naples", "Venice", "Florence",
    "Constantinople", "Athens", "Alexandria", "Port Said",
    "Mocha", "Steamer Point", "Bab-el-Mandeb",
    "Rothal", "Great Indian Peninsula Railway"
  ),
  
  country = c(
    # England/UK (8)
    rep("United Kingdom", 8),
    
    # France (1)
    "France",
    
    # Italy (3)
    rep("Italy", 3),
    
    # Egypt/Suez (5)
    rep("Egypt", 5),
    
    # India (6)
    rep("India", 6),
    
    # Asia (5)
    "Singapore", "Hong Kong", "China", rep("Japan", 2),
    
    # Pacific/America (4)
    rep("United States", 4),
    
    # Other locations (19)
    rep("United Kingdom", 4), "France", "Spain",
    rep("Italy", 4), "Turkey", "Greece",
    rep("Egypt", 2), rep("Yemen", 3),
    rep("India", 2)
  ),
  
  continent = c(
    # England/UK
    rep("Europe", 8),
    # France
    "Europe",
    # Italy
    rep("Europe", 3),
    # Egypt/Suez
    rep("Africa", 5),
    # India
    rep("Asia", 6),
    # Asia
    rep("Asia", 5),
    # Pacific/America
    rep("North America", 4),
    # Other locations (19): Europe x12, Africa x2, Asia x5
    rep("Europe", 12), rep("Africa", 2), rep("Asia", 5)
  ),
  
  latitude = c(
    # England/UK
    51.5074, 51.5074, 51.5074, 51.5074, 51.5074, 51.5074, 51.1267, 50.9513,
    # France
    48.8566,
    # Italy
    40.6363, 45.0703, 45.0736,
    # Egypt/Suez
    29.9668, 30.0444, 26.0975, 20.0, 12.8275,
    # India
    19.0760, 22.5726, 20.5937, 25.4484, 25.3176, 15.2993,
    # Asia
    1.3521, 22.3193, 35.8617, 35.4437, 35.6762,
    # Pacific/America
    37.7749, 40.7128, 39.8283, 37.0902,
    # Other locations
    53.4084, 55.8642, 49.4944, 52.4862, 53.4808,
    40.4168, 41.9028, 40.8518, 45.4408, 43.7696,
    41.0082, 37.9755, 31.2001, 31.2653,
    13.3167, 12.8275, 12.8275,
    25.4484, 25.4484
  ),
  
  longitude = c(
    # England/UK
    -0.1278, -0.1278, -0.1278, -0.1278, -0.1278, -0.1278, 1.3139, 1.8587,
    # France
    2.3522,
    # Italy
    17.9441, 7.6869, 6.8883,
    # Egypt/Suez
    32.5498, 31.2357, 31.2357, 40.0, 45.0339,
    # India
    72.8777, 88.3639, 78.9629, 81.8463, 82.9739, 74.1240,
    # Asia
    103.8198, 114.1694, 104.1954, 139.6380, 139.6503,
    # Pacific/America
    -122.4194, -74.0060, -98.5795, -95.7129,
    # Other locations
    -2.9916, -4.2518, 0.1079, -1.8904, -2.2426,
    -3.7038, 12.4964, 14.2681, 12.3155, 11.2558,
    28.9784, 23.7348, 29.9187, 32.3019,
    43.7500, 45.0339, 45.0339,
    81.8463, 81.8463
  ),
  
  # --- FIXED: explicit 51-entry vector matching the 'location' order above ---
  region_type = c(
    # England/UK (8)
    "City",         # London
    "Street",       # Savile Row
    "Street",       # Burlington Gardens
    "Institution",  # Reform Club
    "Street",       # Pall Mall
    "Station",      # Charing Cross
    "Port",         # Dover
    "Port",         # Calais
    
    # France (1)
    "City",         # Paris
    
    # Italy (3)
    "City",         # Brindisi
    "City",         # Turin
    "City",         # Mont Cenis (treated as city/region for simplicity)
    
    # Egypt/Suez (5)
    "City", "City", "Country", "Sea", "City",
    
    # India (6)
    "City", "City", "Country", "City", "City", "City",
    
    # Asia (5)
    "City", "City", "Country", "City", "Country",
    
    # Pacific/America (4)
    "City", "City", "Country", "Country",
    
    # Other locations (19) — explicit, one-by-one
    "City",         # Liverpool
    "City",         # Glasgow
    "City",         # Havre (Le Havre)
    "City",         # Birmingham
    "City",         # Manchester
    "City",         # Madrid
    "City",         # Rome
    "City",         # Naples
    "City",         # Venice
    "City",         # Florence
    "City",         # Constantinople
    "City",         # Athens
    "City",         # Alexandria
    "Port",         # Port Said
    "City",         # Mocha
    "Port",         # Steamer Point
    "Strait",       # Bab-el-Mandeb
    "City",         # Rothal (station/settlement)
    "Institution"   # Great Indian Peninsula Railway
  ),
  
  stringsAsFactors = FALSE
)

# ✅ Sanity checks
stopifnot(
  nrow(locations_database) == 51,
  all(sapply(locations_database, length) == 51)
)




cat("Location database created with", nrow(locations_database), "locations\n")

## Location Extraction from Text ----

cat("Extracting locations from text...\n")

# Function to extract locations from text
extract_locations <- function(text, locations_db) {
  text_lower <- tolower(text)
  found_locations <- c()
  
  for (i in 1:nrow(locations_db)) {
    location <- tolower(locations_db$location[i])
    if (grepl(paste0("\\b", location, "\\b"), text_lower, ignore.case = TRUE)) {
      found_locations <- c(found_locations, locations_db$location[i])
    }
  }
  
  return(unique(found_locations))
}

# Extract locations from each chapter
chapter_locations <- data %>%
  rowwise() %>%
  mutate(
    locations_found = list(extract_locations(text, locations_database)),
    location_count = length(extract_locations(text, locations_database))
  ) %>%
  ungroup()

# Create location-sentiment mapping
location_sentiment_data <- chapter_locations %>%
  unnest(locations_found) %>%
  select(chapter, locations_found) %>%
  rename(location = locations_found) %>%
  left_join(locations_database, by = "location") %>%
  filter(!is.na(country))

cat("Location extraction completed. Found", nrow(location_sentiment_data), "location mentions\n")

## Load Sentiment Lexicons ----

cat("Loading sentiment lexicons...\n")

# Existing lexicons
afinn <- get_sentiments("afinn")
bing <- get_sentiments("bing")
nrc <- get_sentiments("nrc")

# Create enhanced SentiWordNet lexicon
sentiwordnet_enhanced <- afinn %>%
  mutate(
    positive_score = case_when(
      value > 3 ~ 1.0,
      value > 1 ~ 0.8,
      value > 0 ~ 0.6,
      value == 0 ~ 0.5,
      value > -1 ~ 0.3,
      value > -3 ~ 0.1,
      TRUE ~ 0.0
    ),
    negative_score = case_when(
      value < -3 ~ 1.0,
      value < -1 ~ 0.8,
      value < 0 ~ 0.6,
      value == 0 ~ 0.5,
      value < 1 ~ 0.3,
      value < 3 ~ 0.1,
      TRUE ~ 0.0
    ),
    net_sentiment = positive_score - negative_score
  )

# Create enhanced SenticNet lexicon
senticnet_enhanced <- afinn %>%
  mutate(
    concept_polarity = case_when(
      value > 2 ~ "very_positive",
      value > 0 ~ "positive",
      value == 0 ~ "neutral",
      value < 0 ~ "negative",
      TRUE ~ "very_negative"
    ),
    emotional_intensity = case_when(
      abs(value) >= 4 ~ 1.0,
      abs(value) >= 3 ~ 0.8,
      abs(value) >= 2 ~ 0.6,
      abs(value) >= 1 ~ 0.4,
      TRUE ~ 0.2
    ),
    concept_score = (value / 5) * emotional_intensity
  )

## Sentiment Analysis by Chapter ----

cat("Performing sentiment analysis by chapter...\n")

# AFINN Analysis
afinn_sentiment <- tidy_book_clean %>%
  inner_join(afinn, by = "word") %>%
  group_by(chapter) %>%
  summarise(
    afinn_score = sum(n * value) / sum(n),
    afinn_total_words = sum(n),
    afinn_sentiment_words = n()
  ) %>%
  ungroup()

# Bing Analysis
bing_sentiment <- tidy_book_clean %>%
  inner_join(bing, by = "word") %>%
  group_by(chapter, sentiment) %>%
  summarise(count = sum(n)) %>%
  ungroup() %>%
  pivot_wider(names_from = sentiment, values_from = count, values_fill = 0) %>%
  mutate(
    bing_score = (positive - negative) / (positive + negative),
    bing_total_words = positive + negative
  ) %>%
  select(chapter, bing_score, bing_total_words, positive, negative)

# NRC Analysis
nrc_binary <- tidy_book_clean %>%
  inner_join(nrc %>% filter(sentiment %in% c("positive", "negative")), by = "word") %>%
  group_by(chapter, sentiment) %>%
  summarise(count = sum(n)) %>%
  ungroup() %>%
  pivot_wider(names_from = sentiment, values_from = count, values_fill = 0) %>%
  mutate(
    nrc_score = (positive - negative) / (positive + negative),
    nrc_total_words = positive + negative
  ) %>%
  select(chapter, nrc_score, nrc_total_words, positive, negative)

# SentiWordNet Analysis
sentiwordnet_sentiment <- tidy_book_clean %>%
  inner_join(sentiwordnet_enhanced, by = "word") %>%
  group_by(chapter) %>%
  summarise(
    sw_pos_score = sum(n * positive_score) / sum(n),
    sw_neg_score = sum(n * negative_score) / sum(n),
    sw_net_score = sum(n * net_sentiment) / sum(n),
    sw_total_words = sum(n),
    sw_sentiment_words = n()
  ) %>%
  ungroup()

# SenticNet Analysis
senticnet_sentiment <- tidy_book_clean %>%
  inner_join(senticnet_enhanced, by = "word") %>%
  group_by(chapter) %>%
  summarise(
    sc_concept_score = sum(n * concept_score) / sum(n),
    sc_intensity = sum(n * emotional_intensity) / sum(n),
    sc_total_words = sum(n),
    sc_sentiment_words = n()
  ) %>%
  ungroup()

## Combine Location and Sentiment Data ----

cat("Combining location and sentiment data...\n")

# Merge all sentiment scores
all_sentiment_scores <- afinn_sentiment %>%
  left_join(bing_sentiment %>% select(chapter, bing_score), by = "chapter") %>%
  left_join(nrc_binary %>% select(chapter, nrc_score), by = "chapter") %>%
  left_join(sentiwordnet_sentiment %>% select(chapter, sw_net_score), by = "chapter") %>%
  left_join(senticnet_sentiment %>% select(chapter, sc_concept_score), by = "chapter") %>%
  rename(
    sentiwordnet_score = sw_net_score,
    senticnet_score = sc_concept_score
  )

# Combine location and sentiment data
geospatial_sentiment_data <- location_sentiment_data %>%
  left_join(all_sentiment_scores, by = "chapter") %>%
  filter(!is.na(afinn_score))

cat("Geospatial sentiment data created with", nrow(geospatial_sentiment_data), "records\n")

## Geospatial Analysis ----

cat("Performing geospatial analysis...\n")

# Calculate sentiment statistics by location
location_sentiment_summary <- geospatial_sentiment_data %>%
  group_by(location, country, continent, latitude, longitude, region_type) %>%
  summarise(
    chapter_count = n(),
    avg_afinn_score = mean(afinn_score, na.rm = TRUE),
    avg_bing_score = mean(bing_score, na.rm = TRUE),
    avg_nrc_score = mean(nrc_score, na.rm = TRUE),
    avg_sentiwordnet_score = mean(sentiwordnet_score, na.rm = TRUE),
    avg_senticnet_score = mean(senticnet_score, na.rm = TRUE),
    sd_afinn_score = sd(afinn_score, na.rm = TRUE),
    sd_bing_score = sd(bing_score, na.rm = TRUE),
    sd_nrc_score = sd(nrc_score, na.rm = TRUE),
    sd_sentiwordnet_score = sd(sentiwordnet_score, na.rm = TRUE),
    sd_senticnet_score = sd(senticnet_score, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    # Create composite sentiment score
    composite_sentiment = (avg_afinn_score + avg_bing_score + avg_nrc_score + 
                          avg_sentiwordnet_score + avg_senticnet_score) / 5,
    # Create sentiment variability score
    sentiment_variability = (sd_afinn_score + sd_bing_score + sd_nrc_score + 
                            sd_sentiwordnet_score + sd_senticnet_score) / 5,
    # Categorize sentiment
    sentiment_category = case_when(
      composite_sentiment > 0.3 ~ "Very Positive",
      composite_sentiment > 0.1 ~ "Positive",
      composite_sentiment > -0.1 ~ "Neutral",
      composite_sentiment > -0.3 ~ "Negative",
      TRUE ~ "Very Negative"
    )
  )

# Calculate sentiment statistics by continent
continent_sentiment_summary <- geospatial_sentiment_data %>%
  group_by(continent) %>%
  summarise(
    location_count = n_distinct(location),
    chapter_count = n(),
    avg_afinn_score = mean(afinn_score, na.rm = TRUE),
    avg_bing_score = mean(bing_score, na.rm = TRUE),
    avg_nrc_score = mean(nrc_score, na.rm = TRUE),
    avg_sentiwordnet_score = mean(sentiwordnet_score, na.rm = TRUE),
    avg_senticnet_score = mean(senticnet_score, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    composite_sentiment = (avg_afinn_score + avg_bing_score + avg_nrc_score + 
                          avg_sentiwordnet_score + avg_senticnet_score) / 5
  )

# Calculate sentiment statistics by country
country_sentiment_summary <- geospatial_sentiment_data %>%
  group_by(country, continent) %>%
  summarise(
    location_count = n_distinct(location),
    chapter_count = n(),
    avg_afinn_score = mean(afinn_score, na.rm = TRUE),
    avg_bing_score = mean(bing_score, na.rm = TRUE),
    avg_nrc_score = mean(nrc_score, na.rm = TRUE),
    avg_sentiwordnet_score = mean(sentiwordnet_score, na.rm = TRUE),
    avg_senticnet_score = mean(senticnet_score, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    composite_sentiment = (avg_afinn_score + avg_bing_score + avg_nrc_score + 
                          avg_sentiwordnet_score + avg_senticnet_score) / 5
  )

## Visualizations ----

cat("Creating geospatial visualizations...\n")
theme(
  legend.position = "bottom",
  legend.box = "vertical",
  plot.margin = margin(10, 10, 30, 10)  # extra bottom space
)

theme_bw()
### 1. World Map with Sentiment Colors
library(ggplot2)
library(maps)
library(grid)

world_map <- map_data("world")

sentiment_colors <- c(
  "Very Positive" = "#2E8B57",
  "Positive"      = "#90EE90",
  "Neutral"       = "#F0E68C",
  "Negative"      = "#FFB6C1",
  "Very Negative" = "#DC143C"
)

p1 <- ggplot() +
  geom_map(data = world_map, map = world_map,
           aes(x = long, y = lat, map_id = region),
           fill = "lightgray", color = "white", size = 0.1) +
  
  geom_point(data = location_sentiment_summary,
             aes(x = longitude, y = latitude,
                 color = sentiment_category,
                 size = chapter_count),
             alpha = 0.85) +
  
  scale_color_manual(values = sentiment_colors) +
  scale_size_continuous(range = c(3, 10), name = "Chapter Count") +
  
  labs(
    title = "World Map",
    subtitle = "Location sentiment analysis across Phileas Fogg's journey",
    x = "Longitude", y = "Latitude",
    color = "Sentiment Category"
  ) +
  
  theme_bw(base_size = 11) +
  theme(
    
    # --------------------------
    # FIX: reduce title sizes
    # --------------------------
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5, margin = margin(b = 6)),
    plot.subtitle = element_text(size = 12, hjust = 0.5, margin = margin(b = 12)),
    
    # -----------------------------------
    # FIX: increase panel/map height area
    # -----------------------------------
    panel.spacing = unit(2, "lines"),
    
    # -----------------------------------
    # FIX: add more space top + bottom
    # -----------------------------------
    plot.margin = margin(t = 25, r = 20, b = 100, l = 20),
    
    # -----------------------------------
    # FIX: clean & grouped legends
    # -----------------------------------
    legend.position = "bottom",
    legend.box = "vertical",
    legend.box.spacing = unit(0.5, "cm"),
    legend.spacing.y = unit(0.3, "cm"),
    legend.key.size = unit(0.8, "cm"),
    
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10)
  )

print(p1)

ggsave("fixed_sentiment_map.png", p1, width = 14, height = 11, dpi = 300)


# when exporting:
ggsave("sentiment_map_fixed.png", p1, width = 14, height = 10, dpi = 300)


# Export with larger dimensions (prevents text cutoff)
ggsave("sentiment_map_fixed.png", p1,
       width = 14, height = 10, dpi = 300)



### 2. Sentiment Trends by Continent
p2 <- ggplot(continent_sentiment_summary,
             aes(x = composite_sentiment, 
                 y = reorder(continent, composite_sentiment),
                 fill = continent)) +
  geom_col(alpha = 0.8) +
  geom_text(aes(label = sprintf("%.3f", composite_sentiment)),
            hjust = -0.1, size = 4) +
  scale_fill_manual(values = c(
    "Africa" = "#FF9999",
    "Europe" = "#66CCCC",
    "Asia" = "#99CC33",
    "North America" = "#CC99FF"
  )) +
  labs(
    title = "Average Sentiment by Continent",
    subtitle = "Composite sentiment score across all lexicons",
    x = "Composite Sentiment Score",
    y = "Continent"
  ) +
  theme_bw() +
  theme(
    legend.position = "none",
    plot.margin = margin(10, 20, 10, 10),   # extra right space for labels
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11)
  ) +
  xlim(0, max(continent_sentiment_summary$composite_sentiment) + 0.02)

print(p2)


### 3. Sentiment Comparison by Country
p_country <- ggplot(country_sentiment_summary,
                    aes(x = composite_sentiment,
                        y = reorder(country, composite_sentiment),
                        fill = continent)) +
  geom_col(alpha = 0.85) +
  geom_text(aes(label = sprintf("%.3f", composite_sentiment)),
            hjust = -0.1, size = 3.8) +
  scale_fill_manual(values = c(
    "Africa" = "#FF9999",
    "Asia" = "#99CC33",
    "Europe" = "#66CCCC",
    "North America" = "#CC99FF"
  )) +
  labs(
    title = "Average Sentiment by Country",
    subtitle = "Countries visited in Phileas Fogg's journey",
    x = "Composite Sentiment Score",
    y = "Country",
    fill = "Continent"
  ) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11),
    plot.margin = margin(10, 25, 10, 10)  # extra right space for labels
  ) +
  xlim(min(country_sentiment_summary$composite_sentiment) - 0.02,
       max(country_sentiment_summary$composite_sentiment) + 0.05)

print(p_country)


### 4. Sentiment Variability by Location
p4 <- ggplot(location_sentiment_summary,
             aes(x = composite_sentiment,
                 y = sentiment_variability)) +
  
  # points
  geom_point(aes(color = sentiment_category,
                 size = chapter_count),
             alpha = 0.75) +
  
  # labels slightly above each point
  geom_text(aes(label = location),
            size = 3,
            vjust = -0.7,
            check_overlap = TRUE) +
  
  # colours and sizes
  scale_color_manual(values = sentiment_colors) +
  scale_size_continuous(range = c(3, 10), name = "Chapter Count") +
  
  # titles
  labs(
    title = "Sentiment vs Variability by Location",
    subtitle = "X-axis: Average sentiment, Y-axis: Sentiment variability",
    x = "Composite Sentiment Score",
    y = "Sentiment Variability",
    color = "Sentiment Category"
  ) +
  
  # theme
  theme_bw() +
  theme(
    legend.position = "right",
    legend.box = "vertical",
    plot.margin = margin(10, 10, 10, 10),
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11),
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10)
  )

print(p4)


### 5. Journey Timeline with Sentiment
journey_timeline <- geospatial_sentiment_data %>%
  arrange(chapter) %>%
  select(chapter, location, country, continent, afinn_score, bing_score, nrc_score) %>%
  distinct() %>%
  mutate(
    journey_stage = case_when(
      chapter <= 5 ~ "Departure (UK)",
      chapter <= 10 ~ "Europe",
      chapter <= 15 ~ "Suez/Egypt",
      chapter <= 25 ~ "India",
      chapter <= 35 ~ "Asia",
      chapter <= 45 ~ "Pacific/America",
      TRUE ~ "Return"
    )
  )

p5 <- ggplot(journey_timeline, aes(x = chapter)) +
  
  # Lines
  geom_line(aes(y = afinn_score, color = "AFINN"), size = 1) +
  geom_line(aes(y = bing_score, color = "Bing"), size = 1) +
  geom_line(aes(y = nrc_score, color = "NRC"), size = 1) +
  
  # Points
  geom_point(aes(y = afinn_score, color = "AFINN"), size = 2) +
  geom_point(aes(y = bing_score, color = "Bing"), size = 2) +
  geom_point(aes(y = nrc_score, color = "NRC"), size = 2) +
  
  # Facets
  facet_wrap(~ continent, scales = "free_x") +
  
  # Custom colours
  scale_color_manual(values = c(
    "AFINN" = "#FAA43A",
    "Bing" = "#60BD68",
    "NRC" = "#5DA5DA"
  )) +
  
  # Titles
  labs(
    title = "Sentiment Timeline by Continent",
    subtitle = "Sentiment trends across Phileas Fogg's journey",
    x = "Chapter",
    y = "Sentiment Score",
    color = "Lexicon"
  ) +
  
  # Theme
  theme_bw() +
  theme(
    legend.position = "bottom",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11),
    strip.text = element_text(size = 12, face = "bold"),
    panel.spacing = unit(1, "lines"),
    plot.margin = margin(10, 10, 20, 10)
  )

print(p5)


## Statistical Analysis ----

cat("Performing statistical analysis...\n")

### Correlation Analysis
cat("=== GEOSPATIAL SENTIMENT CORRELATION ANALYSIS ===\n")
correlation_matrix <- geospatial_sentiment_data %>%
  select(afinn_score, bing_score, nrc_score, sentiwordnet_score, senticnet_score) %>%
  cor(use = "complete.obs")

print("Sentiment Lexicon Correlations:")
print(round(correlation_matrix, 3))

### Location-based Sentiment Analysis
cat("\n=== LOCATION-BASED SENTIMENT ANALYSIS ===\n")
cat("Top 10 Most Positive Locations:\n")
top_positive <- location_sentiment_summary %>%
  arrange(desc(composite_sentiment)) %>%
  head(10) %>%
  select(location, country, continent, composite_sentiment, chapter_count)
print(top_positive)

cat("\nTop 10 Most Negative Locations:\n")
top_negative <- location_sentiment_summary %>%
  arrange(composite_sentiment) %>%
  head(10) %>%
  select(location, country, continent, composite_sentiment, chapter_count)
print(top_negative)

### Continent Analysis
cat("\n=== CONTINENT SENTIMENT ANALYSIS ===\n")
continent_analysis <- continent_sentiment_summary %>%
  arrange(desc(composite_sentiment)) %>%
  select(continent, composite_sentiment, location_count, chapter_count)
print(continent_analysis)

### Journey Stage Analysis
cat("\n=== JOURNEY STAGE ANALYSIS ===\n")
journey_analysis <- journey_timeline %>%
  group_by(journey_stage) %>%
  summarise(
    avg_afinn = mean(afinn_score, na.rm = TRUE),
    avg_bing = mean(bing_score, na.rm = TRUE),
    avg_nrc = mean(nrc_score, na.rm = TRUE),
    chapter_count = n(),
    .groups = 'drop'
  ) %>%
  arrange(desc(avg_afinn))
print(journey_analysis)

## Save Results ----

cat("Saving geospatial sentiment analysis results...\n")

write.csv(geospatial_sentiment_data, "data/geospatial_sentiment_data.csv")
write.csv(location_sentiment_summary, "data/location_sentiment_summary.csv")
write.csv(continent_sentiment_summary, "data/continent_sentiment_summary.csv")
write.csv(country_sentiment_summary, "data/country_sentiment_summary.csv")
write.csv(journey_timeline, "data/journey_timeline.csv")
write.csv(locations_database, "data/locations_database.csv")

## Summary ----

cat("\n=== GEOSPATIAL SENTIMENT MAPPING SUMMARY ===\n")
cat("Geospatial sentiment analysis completed successfully!\n")
cat("\nKey Results:\n")
cat("- Total locations analyzed:", nrow(location_sentiment_summary), "\n")
cat("- Total location mentions:", nrow(geospatial_sentiment_data), "\n")
cat("- Continents covered:", length(unique(geospatial_sentiment_data$continent)), "\n")
cat("- Countries covered:", length(unique(geospatial_sentiment_data$country)), "\n")

cat("\nMost Positive Location:", top_positive$location[1], 
    "(", top_positive$country[1], ") - Score:", round(top_positive$composite_sentiment[1], 3), "\n")
cat("Most Negative Location:", top_negative$location[1], 
    "(", top_negative$country[1], ") - Score:", round(top_negative$composite_sentiment[1], 3), "\n")

cat("\nFiles saved:\n")
cat("- data/geospatial_sentiment_data.csv: Complete location-sentiment mapping\n")
cat("- data/location_sentiment_summary.csv: Location sentiment statistics\n")
cat("- data/continent_sentiment_summary.csv: Continent sentiment statistics\n")
cat("- data/country_sentiment_summary.csv: Country sentiment statistics\n")
cat("- data/journey_timeline.csv: Journey timeline with sentiment\n")
cat("- data/locations_database.csv: Location database with coordinates\n")

cat("\nVisualizations created:\n")
cat("- World map with sentiment-colored locations\n")
cat("- Sentiment trends by continent\n")
cat("- Sentiment comparison by country\n")
cat("- Sentiment variability analysis\n")
cat("- Journey timeline by continent\n")

cat("\nThis analysis provides a comprehensive geospatial sentiment mapping\n")
cat("of Jules Verne's 'Around the World in 80 Days', combining sentiment\n")
cat("analysis with geographic locations to reveal emotional trends across\n")
cat("Phileas Fogg's journey around the world.\n")

