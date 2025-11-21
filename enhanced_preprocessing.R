# Enhanced Preprocessing for Around the World in 80 Days Sentiment Analysis
#
# This file implements additional preprocessing steps:
# - Lowercasing
# - Removal of numbers and punctuation
# - Stop word removal
# - Enhanced sentiment analysis with better preprocessing
#
# Author: Enhanced version based on Ashley's work
# Last Modified: July 2025

## Load Libraries ----

pacman::p_load(tidyverse, tidytext, stopwords)

pacman::p_load(dplyr)

## Load Data ----

library(dplyr)

data <- read.csv("C:\\Users\\KESHAV\\OneDrive\\Desktop\\a1918485\\2025\\Trimester 2\\Research Project A\\My Project\\data\\around_world_80_days.csv") %>%
  select(-X)
view(data)

## Set Graph Theme ----

theme_set(theme_bw() + theme(axis.title.y = element_text(vjust = +3), 
                            axis.title.x = element_text(vjust = -0.75)))


## Enhanced Preprocessing ----

# Step 1: Tokenization with enhanced preprocessing
tidy_book_enhanced <- data %>%
  unnest_tokens(word, text, 
                token = "words",           # Word tokenization
                to_lower = TRUE,           # Convert to lowercase
                strip_punct = TRUE,        # Remove punctuation
                strip_numeric = TRUE) %>%  # Remove numbers
  filter(!is.na(word)) %>%                # Remove any NA values
  filter(str_length(word) > 2)            # Remove very short words (likely typos)

# Step 2: Remove stop words
# Get stop words from multiple sources for comprehensive removal
stop_words_en <- stopwords("en", source = "snowball")
stop_words_tidy <- stop_words$word

# Combine stop word lists and remove them
all_stop_words <- unique(c(stop_words_en, stop_words_tidy))

tidy_book_clean <- tidy_book_enhanced %>%
  filter(!word %in% all_stop_words)

# Step 3: Count words by chapter
tidy_book_counted <- tidy_book_clean %>%
  count(chapter, word, sort = TRUE)

## Enhanced Sentiment Analysis ----

# Load AFINN lexicon
afinn <- get_sentiments("afinn")

# Calculate sentiment scores with enhanced preprocessing
book_sentiment_enhanced <- tidy_book_counted %>%
  inner_join(afinn, by = "word") %>%
  group_by(chapter) %>%
  summarise(
    chap_sent = sum(n * value) / sum(n),  # Average sentiment per word
    total_words = sum(n),                  # Total words in chapter
    sentiment_words = n(),                 # Words with sentiment scores
    positive_words = sum(value > 0),       # Count of positive words
    negative_words = sum(value < 0)        # Count of negative words
  ) %>%
  ungroup()

## Visualizations ----

# 1. Enhanced sentiment trend across chapters
ggplot(book_sentiment_enhanced, aes(x = chapter, y = chap_sent)) +
  geom_point(aes(size = total_words), alpha = 0.7) +
  geom_line(alpha = 0.5) +
  geom_smooth(method = "loess", se = TRUE, color = "red") +
  labs(title = "Sentiment Analysis: Around the World in 80 Days",
       subtitle = "Enhanced preprocessing with stop word removal",
       x = "Chapter",
       y = "Average Sentiment Score",
       size = "Total Words") +
  theme_minimal()

# 2. Sentiment distribution by chapter
ggplot(book_sentiment_enhanced, aes(x = chapter)) +
  geom_col(aes(y = positive_words, fill = "Positive"), alpha = 0.7) +
  geom_col(aes(y = -negative_words, fill = "Negative"), alpha = 0.7) +
  scale_fill_manual(values = c("Positive" = "green", "Negative" = "red")) +
  labs(title = "Positive vs Negative Words by Chapter",
       x = "Chapter",
       y = "Word Count",
       fill = "Sentiment") +
  theme_minimal()

# 3. Word coverage analysis
ggplot(book_sentiment_enhanced, aes(x = chapter, y = sentiment_words/total_words)) +
  geom_point() +
  geom_line() +
  labs(title = "Proportion of Words with Sentiment Scores",
       x = "Chapter",
       y = "Proportion of Sentiment Words") +
  theme_minimal()

## Top Contributing Words Analysis ----

# Overall word frequency with enhanced preprocessing
tidy_book_overall <- tidy_book_clean %>%
  count(word, sort = TRUE)

# Top words by frequency (after preprocessing)
top_words_freq <- tidy_book_overall %>%
  inner_join(afinn, by = "word") %>%
  mutate(sentiment = case_when(value < 0 ~ "negative", 
                              value == 0 ~ "neutral", 
                              value > 0 ~ "positive")) %>%
  group_by(sentiment) %>%
  slice_max(n, n = 10) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, n, sentiment))

# Top words by sentiment contribution (after preprocessing)
top_words_contribution <- tidy_book_overall %>%
  inner_join(afinn, by = "word") %>%
  mutate(contribution = n * value) %>%
  mutate(sentiment = case_when(value < 0 ~ "negative", 
                              value == 0 ~ "neutral", 
                              value > 0 ~ "positive")) %>%
  group_by(sentiment) %>%
  slice_max(contribution, n = 10) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, contribution, sentiment))

## Print Summary Statistics ----

cat("=== ENHANCED PREPROCESSING SUMMARY ===\n")
cat("Total chapters analyzed:", nrow(book_sentiment_enhanced), "\n")
cat("Average sentiment score:", mean(book_sentiment_enhanced$chap_sent), "\n")
cat("Most positive chapter:", which.max(book_sentiment_enhanced$chap_sent), "\n")
cat("Most negative chapter:", which.min(book_sentiment_enhanced$chap_sent), "\n")
cat("Total unique words (after preprocessing):", nrow(tidy_book_overall), "\n")
cat("Words with sentiment scores:", sum(tidy_book_overall$word %in% afinn$word), "\n")

## Save Enhanced Results ----

write.csv(book_sentiment_enhanced, "enhanced_sentiment_scores.csv")
write.csv(tidy_book_counted, "enhanced_word_counts.csv")

