# Preprocessing Comparison: Original vs Enhanced
#
# This file compares the sentiment analysis results between:
# - Original preprocessing (basic tokenization)
# - Enhanced preprocessing (lowercase, no punctuation/numbers, no stop words)
#
# Author: Comparison analysis
# Last Modified: July 2025

## Load Libraries ----

pacman::p_load(tidyverse, tidytext, stopwords, gridExtra)

## Load Data ----

data <- read.csv("around_world_80_days.csv") %>% select(-X)

## Original Preprocessing (from wk6_code.R) ----

# Original tokenization (preserves case, punctuation, numbers)
tidy_book_original <- data %>%
  unnest_tokens(word, text) %>%
  count(chapter, word, sort = TRUE)

# Original sentiment analysis
afinn <- get_sentiments("afinn")
book_sentiment_original <- tidy_book_original %>%
  inner_join(afinn) %>%
  group_by(chapter) %>%
  summarise(chap_sent = sum(n*value)/sum(n))

## Enhanced Preprocessing ----

# Enhanced tokenization (lowercase, no punctuation, no numbers)
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

# Enhanced sentiment analysis
book_sentiment_enhanced <- tidy_book_clean %>%
  inner_join(afinn, by = "word") %>%
  group_by(chapter) %>%
  summarise(
    chap_sent = sum(n * value) / sum(n),
    total_words = sum(n),
    sentiment_words = n()
  ) %>%
  ungroup()

## Comparison Analysis ----

# Combine results for comparison
comparison_data <- book_sentiment_original %>%
  rename(original_sentiment = chap_sent) %>%
  left_join(book_sentiment_enhanced %>% 
            select(chapter, enhanced_sentiment = chap_sent), 
            by = "chapter")

# Calculate correlation
correlation <- cor(comparison_data$original_sentiment, 
                  comparison_data$enhanced_sentiment, 
                  use = "complete.obs")

## Visualizations ----

# 1. Side-by-side sentiment comparison
p1 <- ggplot(comparison_data, aes(x = chapter)) +
  geom_line(aes(y = original_sentiment, color = "Original"), alpha = 0.7) +
  geom_line(aes(y = enhanced_sentiment, color = "Enhanced"), alpha = 0.7) +
  geom_point(aes(y = original_sentiment, color = "Original"), size = 2) +
  geom_point(aes(y = enhanced_sentiment, color = "Enhanced"), size = 2) +
  scale_color_manual(values = c("Original" = "blue", "Enhanced" = "red")) +
  labs(title = "Sentiment Comparison: Original vs Enhanced Preprocessing",
       x = "Chapter",
       y = "Sentiment Score",
       color = "Preprocessing") +
  theme_minimal() +
  theme(legend.position = "bottom")

# 2. Correlation plot
p2 <- ggplot(comparison_data, aes(x = original_sentiment, y = enhanced_sentiment)) +
  geom_point(alpha = 0.7) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(title = paste("Correlation: r =", round(correlation, 3)),
       x = "Original Sentiment Score",
       y = "Enhanced Sentiment Score") +
  theme_minimal()

# 3. Difference analysis
comparison_data <- comparison_data %>%
  mutate(sentiment_diff = enhanced_sentiment - original_sentiment)

p3 <- ggplot(comparison_data, aes(x = chapter, y = sentiment_diff)) +
  geom_col(aes(fill = sentiment_diff > 0), alpha = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_fill_manual(values = c("TRUE" = "green", "FALSE" = "red")) +
  labs(title = "Difference in Sentiment Scores (Enhanced - Original)",
       x = "Chapter",
       y = "Sentiment Difference",
       fill = "Enhanced > Original") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Display all plots
grid.arrange(p1, p2, p3, ncol = 2)

## Word Analysis Comparison ----

# Original word frequencies
original_words <- data %>%
  unnest_tokens(word, text) %>%
  count(word, sort = TRUE)

# Enhanced word frequencies
enhanced_words <- data %>%
  unnest_tokens(word, text, 
                token = "words",
                to_lower = TRUE,
                strip_punct = TRUE,
                strip_numeric = TRUE) %>%
  filter(!is.na(word)) %>%
  filter(str_length(word) > 2) %>%
  filter(!word %in% all_stop_words) %>%
  count(word, sort = TRUE)

# Compare top words
cat("=== WORD ANALYSIS COMPARISON ===\n")
cat("Original preprocessing - Top 10 words:\n")
print(head(original_words, 10))

cat("\nEnhanced preprocessing - Top 10 words:\n")
print(head(enhanced_words, 10))

# Sentiment word coverage
original_sentiment_words <- original_words %>%
  inner_join(afinn, by = "word") %>%
  nrow()

enhanced_sentiment_words <- enhanced_words %>%
  inner_join(afinn, by = "word") %>%
  nrow()

cat("\n=== SENTIMENT COVERAGE ===\n")
cat("Original preprocessing - Words with sentiment scores:", original_sentiment_words, "\n")
cat("Enhanced preprocessing - Words with sentiment scores:", enhanced_sentiment_words, "\n")
cat("Percentage change:", round((enhanced_sentiment_words - original_sentiment_words) / original_sentiment_words * 100, 1), "%\n")

## Summary Statistics ----

cat("\n=== SUMMARY STATISTICS ===\n")
cat("Correlation between original and enhanced sentiment scores:", round(correlation, 3), "\n")
cat("Mean absolute difference:", round(mean(abs(comparison_data$sentiment_diff), na.rm = TRUE), 4), "\n")
cat("Chapters where enhanced > original:", sum(comparison_data$sentiment_diff > 0, na.rm = TRUE), "\n")
cat("Chapters where original > enhanced:", sum(comparison_data$sentiment_diff < 0, na.rm = TRUE), "\n")

## Save Comparison Results ----

write.csv(comparison_data, "preprocessing_comparison.csv")

