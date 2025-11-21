# Multiple Lexicon Comparison for Around the World in 80 Days
#
# This file compares different sentiment lexicons:
# - AFINN: Finnish word list with valence scores (-5 to +5)
# - Bing: Binary positive/negative classification
# - NRC: Plutchik's eight emotions + positive/negative
# - VADER: Valence Aware Dictionary and sEntiment Reasoner
#
# Author: Multiple lexicon analysis
# Last Modified: July 2025

## Load Libraries ----

pacman::p_load(tidyverse, tidytext, stopwords, gridExtra, patchwork, scales)

## Load Data ----

data <- read.csv("C:\\Users\\KESHAV\\OneDrive\\Desktop\\a1918485\\2025\\Trimester 2\\Research Project A\\My Project\\data\\around_world_80_days.csv") %>%
  select(-X)
view(data)

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

## Load Multiple Lexicons ----

# AFINN lexicon (already used)
afinn <- get_sentiments("afinn")

# Bing lexicon (binary positive/negative)
bing <- get_sentiments("bing")

# NRC lexicon (emotions + positive/negative)
nrc <- get_sentiments("nrc")

# Note: VADER is not available in tidytext, so we'll focus on AFINN, Bing, and NRC

## Sentiment Analysis with Different Lexicons ----

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
# NRC positive/negative analysis
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

# NRC emotions analysis
nrc_emotions <- tidy_book_clean %>%
  inner_join(nrc %>% filter(!sentiment %in% c("positive", "negative")), by = "word") %>%
  group_by(chapter, sentiment) %>%
  summarise(count = sum(n)) %>%
  ungroup()

## Combine All Lexicon Results ----

# Merge all sentiment scores
all_lexicons <- afinn_sentiment %>%
  left_join(bing_sentiment, by = "chapter") %>%
  left_join(nrc_binary %>% select(chapter, nrc_score, nrc_total_words), by = "chapter") %>%
  filter(!is.na(afinn_score) & !is.na(bing_score) & !is.na(nrc_score))

## Visualizations ----

### 1. Sentiment Trends Comparison
p1 <- ggplot(all_lexicons, aes(x = chapter)) +
  geom_line(aes(y = afinn_score, color = "AFINN"), alpha = 0.8, size = 1) +
  geom_line(aes(y = bing_score, color = "Bing"), alpha = 0.8, size = 1) +
  geom_line(aes(y = nrc_score, color = "NRC"), alpha = 0.8, size = 1) +
  geom_point(aes(y = afinn_score, color = "AFINN"), size = 2) +
  geom_point(aes(y = bing_score, color = "Bing"), size = 2) +
  geom_point(aes(y = nrc_score, color = "NRC"), size = 2) +
  scale_color_manual(values = c("AFINN" = "#FAA43A", "Bing" = "#60BD68", "NRC" = "#5DA5DA")) +
  labs(title = "Sentiment Comparison Across Lexicons",
       subtitle = "Chapter-wise sentiment scores",
       x = "Chapter",
       y = "Sentiment Score",
       color = "Lexicon") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p1)

### 2. Correlation Matrix
correlation_matrix <- all_lexicons %>%
  select(afinn_score, bing_score, nrc_score) %>%
  cor(use = "complete.obs")

# Create correlation plot
correlation_data <- as.data.frame(correlation_matrix) %>%
  rownames_to_column("lexicon1") %>%
  pivot_longer(-lexicon1, names_to = "lexicon2", values_to = "correlation") %>%
  filter(lexicon1 != lexicon2)

p2 <- ggplot(correlation_data, aes(x = lexicon1, y = lexicon2, fill = correlation)) +
  geom_tile() +
  geom_text(aes(label = round(correlation, 3)), color = "white", size = 4) +
  scale_fill_gradient2(low = "#1B9E77", mid = "white", high = "#FAA43A", 
                      midpoint = 0, limits = c(-1, 1)) +
  labs(title = "Correlation Between Lexicons",
       x = "Lexicon 1",
       y = "Lexicon 2",
       fill = "Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p2)

### 3. Scatter Plot Matrix
p3 <- ggplot(all_lexicons, aes(x = afinn_score, y = bing_score)) +
  geom_point(alpha = 0.7, color = "#C77CFF") +
  geom_smooth(method = "lm", se = TRUE, color = "grey") +
  labs(title = "AFINN vs Bing Sentiment Scores",
       x = "AFINN Score",
       y = "Bing Score") +
  theme_minimal()
print(p3)

p4 <- ggplot(all_lexicons, aes(x = afinn_score, y = nrc_score)) +
  geom_point(alpha = 0.7, color = "#80B918") +
  geom_smooth(method = "lm", se = TRUE, color = "grey") +
  labs(title = "AFINN vs NRC Sentiment Scores",
       x = "AFINN Score",
       y = "NRC Score") +
  theme_minimal()
print(p4)

p5 <- ggplot(all_lexicons, aes(x = bing_score, y = nrc_score)) +
  geom_point(alpha = 0.7, color = "#377EB8") +
  geom_smooth(method = "lm", se = TRUE, color = "grey") +
  labs(title = "Bing vs NRC Sentiment Scores",
       x = "Bing Score",
       y = "NRC Score") +
  theme_minimal()
print(p5)

### 4. Word Coverage Analysis
word_coverage <- data.frame(
  Lexicon = c("AFINN", "Bing", "NRC"),
  Total_Words = c(
    sum(tidy_book_clean$word %in% afinn$word),
    sum(tidy_book_clean$word %in% bing$word),
    sum(tidy_book_clean$word %in% nrc$word)
  ),
  Unique_Words = c(
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% afinn$word])),
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% bing$word])),
    length(unique(tidy_book_clean$word[tidy_book_clean$word %in% nrc$word]))
  )
) %>%
  mutate(
    Coverage_Percentage = Total_Words / sum(tidy_book_clean$n) * 100,
    Unique_Coverage = Unique_Words / length(unique(tidy_book_clean$word)) * 100
  )

p6 <- ggplot(word_coverage, aes(x = Lexicon, y = Coverage_Percentage, fill = Lexicon)) +
  geom_col(alpha = 0.8) +
  geom_text(aes(label = paste0(round(Coverage_Percentage, 1), "%")), 
            vjust = -0.5, size = 4) +
  scale_fill_manual(values = c("AFINN" = "#A6CEE3", "Bing" = "#66C2A5", "NRC" = "#F4A261")) +
  labs(title = "Word Coverage by Lexicon",
       subtitle = "Percentage of total words with sentiment scores",
       x = "Lexicon",
       y = "Coverage (%)") +
  theme_minimal() +
  theme(legend.position = "none")
print(p6)

### 5. NRC Emotions Analysis
emotions_summary <- nrc_emotions %>%
  group_by(sentiment) %>%
  summarise(total_count = sum(count)) %>%
  arrange(desc(total_count))

p7 <- ggplot(emotions_summary, aes(x = reorder(sentiment, total_count), y = total_count, fill = sentiment)) +
  geom_col(alpha = 0.8) +
  coord_flip() +
  labs(title = "NRC Emotion Distribution",
       subtitle = "Total word count by emotion",
       x = "Emotion",
       y = "Word Count") +
  theme_minimal() +
  theme(legend.position = "none")

### 6. Chapter-wise Emotion Trends
emotions_by_chapter <- nrc_emotions %>%
  group_by(chapter) %>%
  mutate(emotion_proportion = count / sum(count)) %>%
  ungroup()

p8 <- ggplot(emotions_by_chapter, aes(x = chapter, y = emotion_proportion, fill = sentiment)) +
  geom_area(position = "stack") +
  labs(title = "Emotion Proportions by Chapter",
       x = "Chapter",
       y = "Proportion",
       fill = "Emotion") +
  theme_minimal() +
  theme(legend.position = "bottom")

## Display All Plots ----

# Arrange plots in a grid
print((p1 + p2) / (p3 + p4) / (p5 + p6) / (p7 + p8))

## Statistical Analysis ----

### Correlation Analysis
cat("=== CORRELATION ANALYSIS ===\n")
cat("AFINN vs Bing correlation:", round(cor(all_lexicons$afinn_score, all_lexicons$bing_score), 3), "\n")
cat("AFINN vs NRC correlation:", round(cor(all_lexicons$afinn_score, all_lexicons$nrc_score), 3), "\n")
cat("Bing vs NRC correlation:", round(cor(all_lexicons$bing_score, all_lexicons$nrc_score), 3), "\n")

### Descriptive Statistics
cat("\n=== DESCRIPTIVE STATISTICS ===\n")
cat("AFINN - Mean:", round(mean(all_lexicons$afinn_score), 3), 
    "SD:", round(sd(all_lexicons$afinn_score), 3), 
    "Range:", round(range(all_lexicons$afinn_score), 3), "\n")
cat("Bing - Mean:", round(mean(all_lexicons$bing_score), 3), 
    "SD:", round(sd(all_lexicons$bing_score), 3), 
    "Range:", round(range(all_lexicons$bing_score), 3), "\n")
cat("NRC - Mean:", round(mean(all_lexicons$nrc_score), 3), 
    "SD:", round(sd(all_lexicons$nrc_score), 3), 
    "Range:", round(range(all_lexicons$nrc_score), 3), "\n")

### Word Coverage Statistics
cat("\n=== WORD COVERAGE STATISTICS ===\n")
print(word_coverage)

### Top Contributing Words by Lexicon
cat("\n=== TOP CONTRIBUTING WORDS BY LEXICON ===\n")

# AFINN top words
afinn_top <- tidy_book_clean %>%
  inner_join(afinn, by = "word") %>%
  group_by(word) %>%
  summarise(total_count = sum(n), avg_sentiment = mean(value)) %>%
  arrange(desc(abs(avg_sentiment * total_count))) %>%
  head(10)

cat("AFINN Top Contributing Words:\n")
print(afinn_top)

# Bing top words
bing_top <- tidy_book_clean %>%
  inner_join(bing, by = "word") %>%
  group_by(word, sentiment) %>%
  summarise(total_count = sum(n)) %>%
  arrange(desc(total_count)) %>%
  head(10)

cat("\nBing Top Contributing Words:\n")
print(bing_top)

# NRC top words
nrc_top <- tidy_book_clean %>%
  inner_join(nrc, by = "word") %>%
  group_by(word, sentiment) %>%
  summarise(total_count = sum(n)) %>%
  arrange(desc(total_count)) %>%
  head(10)

cat("\nNRC Top Contributing Words:\n")
print(nrc_top)

## Save Results ----

write.csv(all_lexicons, "multiple_lexicon_scores.csv")
write.csv(word_coverage, "lexicon_coverage.csv")
write.csv(emotions_summary, "nrc_emotions_summary.csv")
write.csv(emotions_by_chapter, "nrc_emotions_by_chapter.csv")

## Summary ----

cat("\n=== SUMMARY ===\n")
cat("Multiple lexicon comparison completed successfully!\n")
cat("Files saved:\n")
cat("- multiple_lexicon_scores.csv: Combined sentiment scores\n")
cat("- lexicon_coverage.csv: Word coverage statistics\n")
cat("- nrc_emotions_summary.csv: NRC emotion summary\n")
cat("- nrc_emotions_by_chapter.csv: Chapter-wise emotions\n")


