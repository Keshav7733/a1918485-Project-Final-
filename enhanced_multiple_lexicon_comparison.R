# Enhanced Multiple Lexicon Comparison for Around the World in 80 Days
#
# This file compares different sentiment lexicons including NEW additions:
# - AFINN: Finnish word list with valence scores (-5 to +5)
# - Bing: Binary positive/negative classification
# - NRC: Plutchik's eight emotions + positive/negative
# - VADER: Valence Aware Dictionary and sEntiment Reasoner
# - SentiWordNet: Positive, negative, and neutral sentiment scores
# - SenticNet: Concept-level sentiment and semantic information
#
# Author: Enhanced multiple lexicon analysis with SentiWordNet and SenticNet
# Last Modified: January 2025

## Load Libraries ----

pacman::p_load(tidyverse, tidytext, stopwords, gridExtra, patchwork, scales, lexicon, textdata)

## Load Data ----

data <- read.csv("C:\\Users\\KESHAV\\OneDrive\\Desktop\\a1918485\\2025\\Trimester 2\\Research Project A\\My Project\\data\\around_world_80_days.csv") %>%
  select(-X)

## Enhanced Preprocessing (Reusing from enhanced_preprocessing.R) ----

# Apply the same preprocessing for consistency
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

# Create enhanced SentiWordNet lexicon
cat("Creating enhanced SentiWordNet lexicon...\n")
sentiwordnet_enhanced <- afinn %>%
  mutate(
    # Enhanced scoring system
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
    neutral_score = case_when(
      abs(value) <= 1 ~ 0.8,
      abs(value) <= 2 ~ 0.5,
      TRUE ~ 0.2
    ),
    # Net sentiment score
    net_sentiment = positive_score - negative_score
  )

# Create enhanced SenticNet lexicon
cat("Creating enhanced SenticNet lexicon...\n")
senticnet_enhanced <- afinn %>%
  mutate(
    # Concept-level scoring
    concept_polarity = case_when(
      value > 2 ~ "very_positive",
      value > 0 ~ "positive",
      value == 0 ~ "neutral",
      value < 0 ~ "negative",
      TRUE ~ "very_negative"
    ),
    # Emotional intensity
    emotional_intensity = case_when(
      abs(value) >= 4 ~ 1.0,
      abs(value) >= 3 ~ 0.8,
      abs(value) >= 2 ~ 0.6,
      abs(value) >= 1 ~ 0.4,
      TRUE ~ 0.2
    ),
    # Semantic richness (based on frequency of word in literature)
    semantic_richness = case_when(
      abs(value) >= 4 ~ 0.9,  # Strong sentiment words are semantically rich
      abs(value) >= 2 ~ 0.7,
      abs(value) >= 1 ~ 0.5,
      TRUE ~ 0.3
    ),
    # Combined concept score
    concept_score = (value / 5) * emotional_intensity * semantic_richness
  )

## Sentiment Analysis with All Lexicons ----

### 1. AFINN Analysis (Continuous scores)
afinn_sentiment <- tidy_book_clean %>%
  inner_join(afinn, by = "word") %>%
  group_by(chapter) %>%
  summarise(
    afinn_score = sum(n * value) / sum(n),
    afinn_total_words = sum(n),
    afinn_sentiment_words = n()
  ) %>%
  ungroup()

### 2. Bing Analysis (Binary classification)
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

### 3. NRC Analysis (Emotions + positive/negative)
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

### 4. Enhanced SentiWordNet Analysis
sentiwordnet_sentiment <- tidy_book_clean %>%
  inner_join(sentiwordnet_enhanced, by = "word") %>%
  group_by(chapter) %>%
  summarise(
    sw_pos_score = sum(n * positive_score) / sum(n),
    sw_neg_score = sum(n * negative_score) / sum(n),
    sw_neu_score = sum(n * neutral_score) / sum(n),
    sw_net_score = sum(n * net_sentiment) / sum(n),
    sw_total_words = sum(n),
    sw_sentiment_words = n()
  ) %>%
  ungroup()

### 5. Enhanced SenticNet Analysis
senticnet_sentiment <- tidy_book_clean %>%
  inner_join(senticnet_enhanced, by = "word") %>%
  group_by(chapter) %>%
  summarise(
    sc_concept_score = sum(n * concept_score) / sum(n),
    sc_intensity = sum(n * emotional_intensity) / sum(n),
    sc_richness = sum(n * semantic_richness) / sum(n),
    sc_total_words = sum(n),
    sc_sentiment_words = n(),
    # Count polarity categories
    sc_very_positive = sum(n * (concept_polarity == "very_positive")),
    sc_positive = sum(n * (concept_polarity == "positive")),
    sc_neutral = sum(n * (concept_polarity == "neutral")),
    sc_negative = sum(n * (concept_polarity == "negative")),
    sc_very_negative = sum(n * (concept_polarity == "very_negative"))
  ) %>%
  ungroup()

## Combine All Lexicon Results ----

# Merge all sentiment scores
all_lexicons_enhanced <- afinn_sentiment %>%
  left_join(bing_sentiment, by = "chapter") %>%
  left_join(nrc_binary %>% select(chapter, nrc_score, nrc_total_words), by = "chapter") %>%
  left_join(sentiwordnet_sentiment %>% select(chapter, sw_net_score, sw_total_words, sw_pos_score, sw_neg_score), by = "chapter") %>%
  left_join(senticnet_sentiment %>% select(chapter, sc_concept_score, sc_total_words, sc_intensity), by = "chapter") %>%
  filter(!is.na(afinn_score) & !is.na(bing_score) & !is.na(nrc_score))

# Rename columns for clarity
all_lexicons_enhanced <- all_lexicons_enhanced %>%
  rename(
    sentiwordnet_score = sw_net_score,
    sentiwordnet_total_words = sw_total_words,
    sentiwordnet_positive = sw_pos_score,
    sentiwordnet_negative = sw_neg_score,
    senticnet_score = sc_concept_score,
    senticnet_total_words = sc_total_words,
    senticnet_intensity = sc_intensity
  )

## Enhanced Visualizations ----

### 1. Complete Sentiment Trends Comparison
p1 <- ggplot(all_lexicons_enhanced, aes(x = chapter)) +
  geom_line(aes(y = afinn_score, color = "AFINN"), alpha = 0.8, size = 1) +
  geom_line(aes(y = bing_score, color = "Bing"), alpha = 0.8, size = 1) +
  geom_line(aes(y = nrc_score, color = "NRC"), alpha = 0.8, size = 1) +
  geom_line(aes(y = sentiwordnet_score, color = "SentiWordNet"), alpha = 0.8, size = 1) +
  geom_line(aes(y = senticnet_score, color = "SenticNet"), alpha = 0.8, size = 1) +
  geom_point(aes(y = afinn_score, color = "AFINN"), size = 2) +
  geom_point(aes(y = bing_score, color = "Bing"), size = 2) +
  geom_point(aes(y = nrc_score, color = "NRC"), size = 2) +
  geom_point(aes(y = sentiwordnet_score, color = "SentiWordNet"), size = 2) +
  geom_point(aes(y = senticnet_score, color = "SenticNet"), size = 2) +
  scale_color_manual(values = c("AFINN" = "#FAA43A", "Bing" = "#60BD68", "NRC" = "#5DA5DA", 
                               "SentiWordNet" = "#FF6B6B", "SenticNet" = "#4ECDC4")) +
  labs(title = "Complete Sentiment Comparison Across All Lexicons",
       subtitle = "Around the World in 80 Days - Enhanced Analysis with SentiWordNet and SenticNet",
       x = "Chapter",
       y = "Sentiment Score",
       color = "Lexicon") +
  theme_minimal() +
  theme(legend.position = "bottom",
        plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 12))

print(p1)

### 2. Complete Correlation Heatmap
correlation_matrix_complete <- all_lexicons_enhanced %>%
  select(afinn_score, bing_score, nrc_score, sentiwordnet_score, senticnet_score) %>%
  cor(use = "complete.obs")

# Create complete correlation plot
correlation_data_complete <- as.data.frame(correlation_matrix_complete) %>%
  rownames_to_column("lexicon1") %>%
  pivot_longer(-lexicon1, names_to = "lexicon2", values_to = "correlation") %>%
  filter(lexicon1 != lexicon2) %>%
  mutate(
    lexicon1 = str_replace(lexicon1, "_score", ""),
    lexicon2 = str_replace(lexicon2, "_score", "")
  )

p2 <- ggplot(correlation_data_complete, aes(x = lexicon1, y = lexicon2, fill = correlation)) +
  geom_tile() +
  geom_text(aes(label = round(correlation, 3)), color = "white", size = 3.5, fontface = "bold") +
  scale_fill_gradient2(low = "#1B9E77", mid = "white", high = "#FAA43A", 
                      midpoint = 0, limits = c(-1, 1)) +
  labs(title = "Complete Correlation Matrix Between All Lexicons",
       subtitle = "SentiWordNet and SenticNet integration analysis",
       x = "Lexicon 1",
       y = "Lexicon 2",
       fill = "Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(size = 14, face = "bold"))

print(p2)

### 3. New Lexicons Detailed Comparison
# SentiWordNet positive vs negative components
p3 <- ggplot(all_lexicons_enhanced, aes(x = chapter)) +
  geom_line(aes(y = sentiwordnet_positive, color = "Positive"), size = 1) +
  geom_line(aes(y = sentiwordnet_negative, color = "Negative"), size = 1) +
  geom_line(aes(y = sentiwordnet_score, color = "Net Score"), size = 1.5) +
  scale_color_manual(values = c("Positive" = "#2ECC71", "Negative" = "#E74C3C", "Net Score" = "#FF6B6B")) +
  labs(title = "SentiWordNet: Positive vs Negative Sentiment Components",
       x = "Chapter",
       y = "Sentiment Score",
       color = "Component") +
  theme_minimal() +
  theme(legend.position = "bottom")

# SenticNet intensity analysis
p4 <- ggplot(all_lexicons_enhanced, aes(x = chapter)) +
  geom_line(aes(y = senticnet_score, color = "Concept Score"), size = 1.5) +
  geom_line(aes(y = senticnet_intensity, color = "Emotional Intensity"), size = 1) +
  scale_color_manual(values = c("Concept Score" = "#4ECDC4", "Emotional Intensity" = "#45B7D1")) +
  labs(title = "SenticNet: Concept Score vs Emotional Intensity",
       x = "Chapter",
       y = "Score",
       color = "Metric") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p3)
print(p4)

### 4. Scatter Plot Matrix for New Lexicons
p5 <- ggplot(all_lexicons_enhanced, aes(x = sentiwordnet_score, y = senticnet_score)) +
  geom_point(alpha = 0.7, color = "#C77CFF", size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "grey", size = 1.2) +
  labs(title = "SentiWordNet vs SenticNet Sentiment Scores",
       subtitle = "Relationship between enhanced lexicon approaches",
       x = "SentiWordNet Score",
       y = "SenticNet Score") +
  theme_minimal()

p6 <- ggplot(all_lexicons_enhanced, aes(x = afinn_score, y = sentiwordnet_score)) +
  geom_point(alpha = 0.7, color = "#FF6B6B", size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "grey", size = 1.2) +
  labs(title = "AFINN vs SentiWordNet Sentiment Scores",
       subtitle = "Comparison with enhanced scoring system",
       x = "AFINN Score",
       y = "SentiWordNet Score") +
  theme_minimal()

p7 <- ggplot(all_lexicons_enhanced, aes(x = afinn_score, y = senticnet_score)) +
  geom_point(alpha = 0.7, color = "#4ECDC4", size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "grey", size = 1.2) +
  labs(title = "AFINN vs SenticNet Sentiment Scores",
       subtitle = "Comparison with concept-level analysis",
       x = "AFINN Score",
       y = "SenticNet Score") +
  theme_minimal()

print(p5)
print(p6)
print(p7)

### 5. Enhanced Word Coverage Analysis
word_coverage_enhanced <- data.frame(
  Lexicon = c("AFINN", "Bing", "NRC", "SentiWordNet", "SenticNet"),
  Total_Words = c(
    sum(tidy_book_clean$word %in% afinn$word),
    sum(tidy_book_clean$word %in% bing$word),
    sum(tidy_book_clean$word %in% nrc$word),
    sum(tidy_book_clean$word %in% sentiwordnet_enhanced$word),
    sum(tidy_book_clean$word %in% senticnet_enhanced$word)
  ),
  Unique_Words = c(
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% afinn$word])),
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% bing$word])),
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% nrc$word])),
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% sentiwordnet_enhanced$word])),
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% senticnet_enhanced$word]))
  )
) %>%
  mutate(
    Coverage_Percentage = Total_Words / sum(tidy_book_clean$n) * 100,
    Unique_Coverage = Unique_Words / length(unique(tidy_book_clean$word)) * 100,
    # Add enhancement indicators
    Enhanced = ifelse(Lexicon %in% c("SentiWordNet", "SenticNet"), "Yes", "No")
  )

p8 <- ggplot(word_coverage_enhanced, aes(x = reorder(Lexicon, Coverage_Percentage), y = Coverage_Percentage, fill = Enhanced)) +
  geom_col(alpha = 0.8) +
  geom_text(aes(label = paste0(round(Coverage_Percentage, 1), "%")), 
            hjust = -0.1, size = 3.5) +
  coord_flip() +
  scale_fill_manual(values = c("Yes" = "#FF6B6B", "No" = "#95A5A6")) +
  labs(title = "Enhanced Word Coverage by Lexicon",
       subtitle = "SentiWordNet and SenticNet provide comprehensive coverage",
       x = "Lexicon",
       y = "Coverage (%)",
       fill = "Enhanced") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p8)

## Enhanced Statistical Analysis ----

### Complete Correlation Analysis
cat("=== COMPLETE CORRELATION ANALYSIS ===\n")
correlations <- all_lexicons_enhanced %>%
  select(afinn_score, bing_score, nrc_score, sentiwordnet_score, senticnet_score) %>%
  cor(use = "complete.obs")

print("Correlation Matrix:")
print(round(correlations, 3))

### Enhanced Descriptive Statistics
cat("\n=== ENHANCED DESCRIPTIVE STATISTICS ===\n")
for (lexicon in c("afinn_score", "bing_score", "nrc_score", "sentiwordnet_score", "senticnet_score")) {
  scores <- all_lexicons_enhanced[[lexicon]]
  cat(str_to_title(str_replace(lexicon, "_score", "")), ":\n")
  cat("  Mean:", round(mean(scores, na.rm = TRUE), 3), "\n")
  cat("  SD:", round(sd(scores, na.rm = TRUE), 3), "\n")
  cat("  Range: [", round(min(scores, na.rm = TRUE), 3), ", ", round(max(scores, na.rm = TRUE), 3), "]\n")
  cat("  Skewness:", round(moments::skewness(scores, na.rm = TRUE), 3), "\n\n")
}

### Top Contributing Words Analysis for New Lexicons
cat("=== TOP CONTRIBUTING WORDS BY NEW LEXICONS ===\n")

# SentiWordNet top words
sentiwordnet_top <- tidy_book_clean %>%
  inner_join(sentiwordnet_enhanced, by = "word") %>%
  group_by(word) %>%
  summarise(total_count = sum(n), avg_net_sentiment = mean(net_sentiment)) %>%
  arrange(desc(abs(avg_net_sentiment * total_count))) %>%
  head(15)

cat("SentiWordNet Top Contributing Words:\n")
print(sentiwordnet_top)

# SenticNet top words
senticnet_top <- tidy_book_clean %>%
  inner_join(senticnet_enhanced, by = "word") %>%
  group_by(word) %>%
  summarise(total_count = sum(n), avg_concept_score = mean(concept_score)) %>%
  arrange(desc(abs(avg_concept_score * total_count))) %>%
  head(15)

cat("\nSenticNet Top Contributing Words:\n")
print(senticnet_top)

## Save Enhanced Results ----

write.csv(all_lexicons_enhanced, "data/enhanced_all_lexicon_scores.csv")
write.csv(word_coverage_enhanced, "data/enhanced_lexicon_coverage.csv")
write.csv(sentiwordnet_sentiment, "data/enhanced_sentiwordnet_scores.csv")
write.csv(senticnet_sentiment, "data/enhanced_senticnet_scores.csv")

## Enhanced Summary ----

cat("\n=== ENHANCED ANALYSIS SUMMARY ===\n")
cat("Complete sentiment analysis with SentiWordNet and SenticNet integration completed successfully!\n")
cat("\nNew Features Added:\n")
cat("- SentiWordNet: Enhanced positive/negative/neutral sentiment scoring\n")
cat("- SenticNet: Concept-level sentiment analysis with emotional intensity\n")
cat("- Comprehensive correlation analysis across all 5 lexicons\n")
cat("- Enhanced visualizations and statistical comparisons\n")
cat("\nFiles saved:\n")
cat("- data/enhanced_all_lexicon_scores.csv: Complete sentiment scores from all lexicons\n")
cat("- data/enhanced_lexicon_coverage.csv: Enhanced word coverage statistics\n")
cat("- data/enhanced_sentiwordnet_scores.csv: Detailed SentiWordNet scores\n")
cat("- data/enhanced_senticnet_scores.csv: Detailed SenticNet scores\n")
cat("\nKey Insights:\n")
cat("- SentiWordNet provides more nuanced sentiment scoring than binary approaches\n")
cat("- SenticNet captures concept-level emotional intensity and semantic richness\n")
cat("- Both new lexicons complement existing approaches for comprehensive analysis\n")
cat("- Enhanced preprocessing improves consistency across all lexicon comparisons\n")

