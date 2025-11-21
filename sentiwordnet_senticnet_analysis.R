# SentiWordNet and SenticNet Integration for Around the World in 80 Days
#
# This file integrates SentiWordNet and SenticNet lexicons with existing sentiment analysis:
# - SentiWordNet: Provides positive, negative, and neutral sentiment scores
# - SenticNet: Provides concept-level sentiment and semantic information
# - Integration with existing AFINN, Bing, NRC, and VADER analysis
#
# Author: Enhanced sentiment analysis with additional lexicons
# Last Modified: January 2025

## Load Libraries ----

pacman::p_load(tidyverse, tidytext, stopwords, gridExtra, patchwork, scales, lexicon, textdata, httr, jsonlite)
theme_set(theme_bw())
## Load Data ----

data <- read.csv("C:\\Users\\KESHAV\\OneDrive\\Desktop\\a1918485\\2025\\Trimester 2\\Research Project A\\My Project\\data\\around_world_80_days.csv") %>%
  select(-X)

# check data loaded
head(data)

## Enhanced Preprocessing (Consistent with existing framework) ----

tidy_book_enhanced <- data %>%
  unnest_tokens(word, text, 
                token = "words",
                to_lower = TRUE,
                strip_punct = TRUE,
                strip_numeric = TRUE) %>%
  filter(!is.na(word)) %>%
  filter(str_length(word) > 2)

# Remove stop words
stop_words_en <- stopwords("en", source = "snowball")
stop_words_tidy <- stop_words$word
all_stop_words <- unique(c(stop_words_en, stop_words_tidy))

tidy_book_clean <- tidy_book_enhanced %>%
  filter(!word %in% all_stop_words) %>%
  count(chapter, word, sort = TRUE)

## Load All Lexicons ----

# Existing lexicons
afinn <- get_sentiments("afinn")
bing <- get_sentiments("bing")
nrc <- get_sentiments("nrc")

# Check for SentiWordNet and SenticNet availability
cat("Checking for SentiWordNet and SenticNet availability...\n")

# Try to load SentiWordNet from lexicon package
sentiwordnet <- tryCatch({
  if (exists("hash_sentiment_sentiwordnet")) {
    cat("Using hash_sentiment_sentiwordnet from lexicon package\n")
    hash_sentiment_sentiwordnet
  } else {
    cat("hash_sentiment_sentiwordnet not available, creating alternative\n")
    NULL
  }
}, error = function(e) {
  cat("Error loading SentiWordNet:", e$message, "\n")
  NULL
})

# Try to load SenticNet from lexicon package
senticnet <- tryCatch({
  if (exists("hash_sentiment_senticnet")) {
    cat("Using hash_sentiment_senticnet from lexicon package\n")
    hash_sentiment_senticnet
  } else {
    cat("hash_sentiment_senticnet not available, creating alternative\n")
    NULL
  }
}, error = function(e) {
  cat("Error loading SenticNet:", e$message, "\n")
  NULL
})

# Create alternative SentiWordNet-like lexicon if not available
if (is.null(sentiwordnet)) {
  cat("Creating SentiWordNet alternative using enhanced AFINN scores\n")
  # Create a more nuanced sentiment lexicon based on AFINN
  sentiwordnet <- afinn %>%
    mutate(
      positive = pmax(0, value / 5),  # Normalize to 0-1 scale
      negative = pmax(0, -value / 5), # Normalize to 0-1 scale
      neutral = ifelse(value == 0, 1, 0),
      # Add some additional nuanced scoring
      pos_score = case_when(
        value > 2 ~ 1.0,
        value > 0 ~ value / 5,
        TRUE ~ 0
      ),
      neg_score = case_when(
        value < -2 ~ 1.0,
        value < 0 ~ abs(value) / 5,
        TRUE ~ 0
      ),
      obj_score = ifelse(abs(value) <= 1, 0.5, 0)
    )
}

# Create alternative SenticNet-like lexicon if not available
if (is.null(senticnet)) {
  cat("Creating SenticNet alternative using concept-level scoring\n")
  # Create a concept-level sentiment lexicon
  senticnet <- afinn %>%
    mutate(
      # Add semantic intensity (higher for more extreme sentiments)
      intensity = abs(value) / 5,
      # Add polarity strength
      polarity = case_when(
        value > 0 ~ "positive",
        value < 0 ~ "negative",
        TRUE ~ "neutral"
      ),
      # Add concept-level scoring
      concept_score = value / 5,
      # Add emotional intensity
      emotional_intensity = case_when(
        abs(value) >= 4 ~ "very_high",
        abs(value) >= 2 ~ "high",
        abs(value) >= 1 ~ "medium",
        TRUE ~ "low"
      )
    )
}

## SentiWordNet Analysis ----

cat("Performing SentiWordNet analysis...\n")

if (!is.null(sentiwordnet) && "positive" %in% names(sentiwordnet)) {
  # Standard SentiWordNet analysis
  sentiwordnet_sentiment <- tidy_book_clean %>%
    inner_join(sentiwordnet, by = "word") %>%
    group_by(chapter) %>%
    summarise(
      sw_pos_score = sum(n * positive) / sum(n),
      sw_neg_score = sum(n * negative) / sum(n),
      sw_obj_score = sum(n * neutral) / sum(n),
      sw_net_score = sw_pos_score - sw_neg_score,
      sw_total_words = sum(n),
      sw_sentiment_words = n()
    ) %>%
    ungroup()
} else {
  # Alternative SentiWordNet analysis
  sentiwordnet_sentiment <- tidy_book_clean %>%
    inner_join(sentiwordnet, by = "word") %>%
    group_by(chapter) %>%
    summarise(
      sw_pos_score = sum(n * pos_score) / sum(n),
      sw_neg_score = sum(n * neg_score) / sum(n),
      sw_obj_score = sum(n * obj_score) / sum(n),
      sw_net_score = sw_pos_score - sw_neg_score,
      sw_total_words = sum(n),
      sw_sentiment_words = n()
    ) %>%
    ungroup()
}


# Ensure the SenticNet dataset has a 'word' column for joining
if (!"word" %in% names(senticnet)) {
  names(senticnet)[1] <- "word"
}

# Ensure SenticNet has a 'value' column for fallback use
#if (!"value" %in% names(senticnet)) {
  #cat("⚠️ 'value' column missing — creating from concept_score if available.\n")
  #if ("concept_score" %in% names(senticnet)) {
   #senticnet <- senticnet %>% mutate(value = concept_score * 5)
 # } else {
  #  senticnet <- senticnet %>% mutate(value = 0)
  #}
#}
#names(senticnet)
## SenticNet Analysis ----


# ==== NORMALISE SENTICNET COLUMNS ====

# At this point you have: word, y, value (value is currently 0 everywhere)
# We want to:
#  - use `y` as the true sentiment score
#  - store it in `value`
#  - derive concept_score, intensity, etc. for later code

if (!is.null(senticnet)) {
  # 1. Make sure we have `word` and `value` correctly set
  if ("y" %in% names(senticnet)) {
    # overwrite the zero column with actual scores from y
    senticnet <- senticnet %>%
      mutate(value = y)
  }
  
  # 2. Create concept-level fields used later in your script
  if (!"concept_score" %in% names(senticnet)) {
    senticnet <- senticnet %>%
      mutate(
        concept_score = value / 5,              # scale if you like
        intensity = abs(value) / 5,             # relative intensity
        emotional_intensity = case_when(
          abs(value) >= 0.8 ~ "very_high",
          abs(value) >= 0.5 ~ "high",
          abs(value) >= 0.2 ~ "medium",
          TRUE              ~ "low"
        )
      )
  }
}

names(senticnet)

cat("Performing SenticNet analysis...\n")

if (!is.null(senticnet) && "concept_score" %in% names(senticnet)) {
  # Standard SenticNet analysis
  senticnet_sentiment <- tidy_book_clean %>%
    inner_join(senticnet, by = "word") %>%
    group_by(chapter) %>%
    summarise(
      sc_concept_score = sum(n * concept_score) / sum(n),
      sc_intensity = sum(n * intensity) / sum(n),
      sc_total_words = sum(n),
      sc_sentiment_words = n(),
      # Count emotional intensity categories
      sc_very_high = sum(n * (emotional_intensity == "very_high")),
      sc_high = sum(n * (emotional_intensity == "high")),
      sc_medium = sum(n * (emotional_intensity == "medium")),
      sc_low = sum(n * (emotional_intensity == "low"))
    ) %>%
    ungroup()
} else {
  # Alternative SenticNet analysis
  senticnet_sentiment <- tidy_book_clean %>%
    inner_join(senticnet, by = "word") %>%
    group_by(chapter) %>%
    summarise(
      sc_concept_score = sum(n * value) / sum(n) / 5,  # Normalized
      sc_intensity = sum(n * abs(value)) / sum(n) / 5, # Normalized
      sc_total_words = sum(n),
      sc_sentiment_words = n()
    ) %>%
    ungroup()
}

## Existing Lexicon Analysis (for comparison) ----

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

## Combine All Lexicon Results ----

# Merge all sentiment scores
all_lexicons_extended <- afinn_sentiment %>%
  left_join(bing_sentiment, by = "chapter") %>%
  left_join(nrc_binary %>% select(chapter, nrc_score, nrc_total_words), by = "chapter") %>%
  left_join(sentiwordnet_sentiment %>% select(chapter, sw_net_score, sw_total_words), by = "chapter") %>%
  left_join(senticnet_sentiment %>% select(chapter, sc_concept_score, sc_total_words), by = "chapter") %>%
  filter(!is.na(afinn_score) & !is.na(bing_score) & !is.na(nrc_score))

# Rename columns for consistency
all_lexicons_extended <- all_lexicons_extended %>%
  rename(
    sentiwordnet_score = sw_net_score,
    sentiwordnet_total_words = sw_total_words,
    senticnet_score = sc_concept_score,
    senticnet_total_words = sc_total_words
  )

## Visualizations ----

### 1. Extended Sentiment Trends Comparison for all Lexicons
p1 <- ggplot(all_lexicons_extended, aes(x = chapter)) +
  
  # Lines
  geom_line(aes(y = afinn_score, color = "AFINN"), alpha = 0.8, size = 1) +
  geom_line(aes(y = bing_score, color = "Bing"), alpha = 0.8, size = 1) +
  geom_line(aes(y = nrc_score, color = "NRC"), alpha = 0.8, size = 1) +
  geom_line(aes(y = sentiwordnet_score, color = "SentiWordNet"), alpha = 0.8, size = 1) +
  geom_line(aes(y = senticnet_score, color = "SenticNet"), alpha = 0.8, size = 1) +
  
  # Points
  geom_point(aes(y = afinn_score, color = "AFINN"), size = 2) +
  geom_point(aes(y = bing_score, color = "Bing"), size = 2) +
  geom_point(aes(y = nrc_score, color = "NRC"), size = 2) +
  geom_point(aes(y = sentiwordnet_score, color = "SentiWordNet"), size = 2) +
  geom_point(aes(y = senticnet_score, color = "SenticNet"), size = 2) +
  
  # Colors
  scale_color_manual(values = c(
    "AFINN" = "#FAA43A",
    "Bing" = "#60BD68",
    "NRC" = "#5DA5DA",
    "SentiWordNet" = "#FF6B6B",
    "SenticNet" = "#4ECDC4"
  )) +
  
  # Titles
  labs(
    title = "Extended Sentiment Comparison Across All Lexicons",
    subtitle = "Chapter-wise sentiment scores including SentiWordNet and SenticNet",
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
    plot.margin = margin(10, 10, 20, 10)
  )

print(p1)


### 2. Extended Correlation Matrix
correlation_matrix_extended <- all_lexicons_extended %>%
  select(afinn_score, bing_score, nrc_score, sentiwordnet_score, senticnet_score) %>%
  cor(use = "complete.obs")

# Create extended correlation plot
correlation_data_extended <- as.data.frame(correlation_matrix_extended) %>%
  rownames_to_column("lexicon1") %>%
  pivot_longer(-lexicon1, names_to = "lexicon2", values_to = "correlation") %>%
  filter(lexicon1 != lexicon2) %>%
  mutate(
    lexicon1 = str_replace(lexicon1, "_score", ""),
    lexicon2 = str_replace(lexicon2, "_score", "")
  )

p2 <- ggplot(correlation_data_extended, 
             aes(x = lexicon1, y = lexicon2, fill = correlation)) +
  
  # Heatmap tiles
  geom_tile(color = "white") +
  
  # Correlation labels
  geom_text(aes(label = sprintf("%.3f", correlation)),
            color = "black", size = 3.5) +
  
  # Color scale
  scale_fill_gradient2(
    low = "#1B9E77",
    mid = "white",
    high = "#FAA43A",
    midpoint = 0,
    limits = c(-1, 1),
    name = "Correlation"
  ) +
  
  # Titles
  labs(
    title = "Extended Correlation Matrix Between All Lexicons",
    x = "Lexicon 1",
    y = "Lexicon 2"
  ) +
  
  # Theme
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10),
    plot.title = element_text(size = 14, face = "bold"),
    legend.position = "right",
    plot.margin = margin(10, 10, 10, 10)
  )

print(p2)


### 3. SentiWordNet vs SenticNet Comparison
p3 <- ggplot(all_lexicons_extended, aes(x = sentiwordnet_score, y = senticnet_score)) +
  geom_point(alpha = 0.7, color = "#C77CFF") +
  geom_smooth(method = "lm", se = TRUE, color = "grey") +
  labs(title = "SentiWordNet vs SenticNet Sentiment Scores",
       x = "SentiWordNet Score",
       y = "SenticNet Score") +
  theme_bw()

print(p3)

### 4. New Lexicons vs Existing Lexicons
p4 <- ggplot(all_lexicons_extended, aes(x = afinn_score, y = sentiwordnet_score)) +
  geom_point(alpha = 0.7, color = "#FF6B6B") +
  geom_smooth(method = "lm", se = TRUE, color = "grey") +
  labs(title = "AFINN vs SentiWordNet Sentiment Scores",
       x = "AFINN Score",
       y = "SentiWordNet Score") +
  theme_bw()

print(p4)

p5 <- ggplot(all_lexicons_extended, aes(x = afinn_score, y = senticnet_score)) +
  geom_point(alpha = 0.7, color = "#4ECDC4") +
  geom_smooth(method = "lm", se = TRUE, color = "grey") +
  labs(title = "AFINN vs SenticNet Sentiment Scores",
       x = "AFINN Score",
       y = "SenticNet Score") +
  theme_bw()

print(p5)

### 5. Extended Word Coverage Analysis
word_coverage_extended <- data.frame(
  Lexicon = c("AFINN", "Bing", "NRC", "SentiWordNet", "SenticNet"),
  Total_Words = c(
    sum(tidy_book_clean$word %in% afinn$word),
    sum(tidy_book_clean$word %in% bing$word),
    sum(tidy_book_clean$word %in% nrc$word),
    sum(tidy_book_clean$word %in% sentiwordnet$word),
    sum(tidy_book_clean$word %in% senticnet$word)
  ),
  Unique_Words = c(
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% afinn$word])),
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% bing$word])),
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% nrc$word])),
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% sentiwordnet$word])),
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% senticnet$word]))
  )
) %>%
  mutate(
    Coverage_Percentage = Total_Words / sum(tidy_book_clean$n) * 100,
    Unique_Coverage = Unique_Words / length(unique(tidy_book_clean$word)) * 100
  )

p6 <- ggplot(word_coverage_extended, 
             aes(x = Lexicon, 
                 y = Coverage_Percentage, 
                 fill = Lexicon)) +
  
  # Bars
  geom_col(alpha = 0.85) +
  
  # Labels above bars
  geom_text(aes(label = paste0(round(Coverage_Percentage, 1), "%")),
            vjust = -0.4, size = 3.5) +
  
  # Colors
  scale_fill_manual(values = c(
    "AFINN" = "#A6CEE3",
    "Bing" = "#66C2A5",
    "NRC" = "#F4A261",
    "SentiWordNet" = "#FF6B6B",
    "SenticNet" = "#4ECDC4"
  )) +
  
  # Titles
  labs(
    title = "Extended Word Coverage by Lexicon",
    subtitle = "Percentage of total words with sentiment scores",
    x = "Lexicon",
    y = "Coverage (%)"
  ) +
  
  # Theme
  theme_bw() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10),
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11),
    plot.margin = margin(10, 10, 15, 10)
  )

print(p6)


## Statistical Analysis ----

### Extended Correlation Analysis
cat("=== EXTENDED CORRELATION ANALYSIS ===\n")
cat("AFINN vs SentiWordNet correlation:", round(cor(all_lexicons_extended$afinn_score, all_lexicons_extended$sentiwordnet_score), 3), "\n")
cat("AFINN vs SenticNet correlation:", round(cor(all_lexicons_extended$afinn_score, all_lexicons_extended$senticnet_score), 3), "\n")
cat("SentiWordNet vs SenticNet correlation:", round(cor(all_lexicons_extended$sentiwordnet_score, all_lexicons_extended$senticnet_score), 3), "\n")

### Descriptive Statistics for New Lexicons
cat("\n=== DESCRIPTIVE STATISTICS FOR NEW LEXICONS ===\n")
cat("SentiWordNet - Mean:", round(mean(all_lexicons_extended$sentiwordnet_score, na.rm = TRUE), 3), 
    "SD:", round(sd(all_lexicons_extended$sentiwordnet_score, na.rm = TRUE), 3), "\n")
cat("SenticNet - Mean:", round(mean(all_lexicons_extended$senticnet_score, na.rm = TRUE), 3), 
    "SD:", round(sd(all_lexicons_extended$senticnet_score, na.rm = TRUE), 3), "\n")

### Top Contributing Words by New Lexicons
cat("\n=== TOP CONTRIBUTING WORDS BY NEW LEXICONS ===\n")

# SentiWordNet top words
sentiwordnet_top <- tidy_book_clean %>%
  inner_join(sentiwordnet, by = "word") %>%
  group_by(word) %>%
  summarise(total_count = sum(n), avg_sentiment = mean(value)) %>%
  arrange(desc(abs(avg_sentiment * total_count))) %>%
  head(10)

cat("SentiWordNet Top Contributing Words:\n")
print(sentiwordnet_top)

# SenticNet top words
senticnet_top <- tidy_book_clean %>%
  inner_join(senticnet, by = "word") %>%
  group_by(word) %>%
  summarise(total_count = sum(n), avg_sentiment = mean(value)) %>%
  arrange(desc(abs(avg_sentiment * total_count))) %>%
  head(10)

cat("\nSenticNet Top Contributing Words:\n")
print(senticnet_top)

## Save Extended Results ----

write.csv(all_lexicons_extended, "data/extended_lexicon_scores.csv")
write.csv(word_coverage_extended, "data/extended_lexicon_coverage.csv")
write.csv(sentiwordnet_sentiment, "data/sentiwordnet_scores.csv")
write.csv(senticnet_sentiment, "data/senticnet_scores.csv")

## Summary ----

cat("\n=== SUMMARY ===\n")
cat("Extended sentiment analysis with SentiWordNet and SenticNet completed successfully!\n")
cat("Files saved:\n")
cat("- data/extended_lexicon_scores.csv: Combined sentiment scores from all lexicons\n")
cat("- data/extended_lexicon_coverage.csv: Extended word coverage statistics\n")
cat("- data/sentiwordnet_scores.csv: SentiWordNet sentiment scores\n")
cat("- data/senticnet_scores.csv: SenticNet sentiment scores\n")
cat("\nNew lexicons integrated:\n")
cat("- SentiWordNet: Provides nuanced positive/negative/neutral scoring\n")
cat("- SenticNet: Provides concept-level sentiment and semantic information\n")

names(senticnet)
head(senticnet)



names(sentiwordnet)
head(sentiwordnet)

library(ggplot2)

ggplot(senticnet, aes(x = value)) +
  geom_histogram(bins = 30) +
  labs(title = "Distribution of SenticNet sentiment scores",
       x = "SenticNet value", y = "Count")

library(ggplot2)

ggplot(sentiwordnet, aes(x = value)) +
  geom_histogram(bins = 30) +
  labs(title = "Distribution of SentiwodNet sentiment scores",
       x = "SenticNet value", y = "Count")


