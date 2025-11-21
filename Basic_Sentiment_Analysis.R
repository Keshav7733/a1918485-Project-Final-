# This file does basic sentiment analysis on Around the World in 80 Days
## Load Libraries ----

pacman::p_load(tidyverse, tidytext)
data <- read.csv("./data/around_world_80_days.csv") 

install.packages("textdata")


## Set Graph Theme ----

theme_set(theme_bw() + theme(axis.title.y = element_text(vjust = +3), axis.title.x = element_text(vjust = -0.75)))  # Set the theme for all graphs

## Sentiment Analysis ----

tidy_book <- data %>%
  unnest_tokens(word, text) %>%
  count(chapter, word, sort = TRUE)

afinn <- get_sentiments("afinn")  # AFINN dictionary

book_sentiment <- tidy_book %>%
  inner_join(afinn) %>%
  group_by(chapter) %>%
  summarise(chap_sent = sum(n*value)/sum(n))

# Sentiment across book not smoothed

ggplot(book_sentiment, aes(x = chapter, y = chap_sent)) +
  geom_point() +
  geom_line()

# Sentiment across book smoothed

ggplot(book_sentiment, aes(x = chapter, y = chap_sent)) +
  geom_point() +
  geom_smooth()

tidy_book2 <- data %>%
  unnest_tokens(word, text) %>%
  count(word, sort = TRUE)

# Top words by frequency

tidy_book2 %>%
  inner_join(afinn) %>%
  mutate(sentiment = case_when(value < 0 ~ "negative", value == 0 ~ "neutral", value > 0 ~ "positive")) %>% 
  group_by(sentiment) %>%
  slice_max(n, n = 10) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, n, sentiment)) %>%
  ggplot(aes(n, word, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free") +
  labs(x = "Frequency", y = "Word") + 
  scale_y_reordered()

# Top words by contribution

tidy_book2 %>%
  inner_join(afinn) %>%
  mutate(contribution = n*value) %>%
  mutate(sentiment = case_when(value < 0 ~ "negative", value == 0 ~ "neutral", value > 0 ~ "positive")) %>% 
  group_by(sentiment) %>%
  slice_max(contribution, n = 10) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, contribution, sentiment)) %>%
  ggplot(aes(contribution, word, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free") +
  labs(x = "Contribution", y = "Word") + 
  scale_y_reordered()



# 11-08-25
# This file does basic sentiment analysis on Around the World in 80 Days
## Load Libraries ----

pacman::p_load(tidyverse, tidytext, lexicon, textdata)

# Install required packages for senticnet and sentiwordnet
if (!require(lexicon)) install.packages("lexicon")
if (!require(textdata)) install.packages("textdata")

data <- read.csv("./data/around_world_80_days.csv") 

## Set Graph Theme ----

theme_set(theme_bw() + theme(axis.title.y = element_text(vjust = +3), axis.title.x = element_text(vjust = -0.75)))  # Set the theme for all graphs

## Sentiment Analysis with Multiple Dictionaries ----

tidy_book <- data %>%
  unnest_tokens(word, text) %>%
  count(chapter, word, sort = TRUE)

# Load different sentiment dictionaries
afinn <- get_sentiments("afinn")  # AFINN dictionary 

# Install and load lexicon package
if (!require(lexicon)) {
  install.packages("lexicon")
  library(lexicon)
}

# Use the correct lexicon functions - check what's available
senticnet <- tryCatch({
  lexicon::hash_sentiment_senticnet
}, error = function(e) {
  message("SenticNet not available from lexicon, using AFINN as fallback")
  afinn
})

# Test basic package loading
message("Testing package loading...")
tryCatch({
  pacman::p_load(tidyverse, tidytext, lexicon, textdata)
  message("All packages loaded successfully")
}, error = function(e) {
  message("Error loading packages: ", e$message)
  # Try individual loading
  if (!require(tidyverse)) install.packages("tidyverse")
  if (!require(tidytext)) install.packages("tidytext")
  if (!require(lexicon)) install.packages("lexicon")
  if (!require(textdata)) install.packages("textdata")
})

# Install required packages for senticnet and sentiwordnet
if (!require(lexicon)) install.packages("lexicon")
if (!require(textdata)) install.packages("textdata")

# Test data loading
message("Testing data loading...")
tryCatch({
  data <- read.csv("./data/around_world_80_days.csv")
  message("Data loaded successfully with ", nrow(data), " rows")
}, error = function(e) {
  message("Error loading data: ", e$message)
  message("Please ensure the data file exists at ./data/around_world_80_days.csv")
  # Create dummy data for testing if file doesn't exist
  data <- data.frame(
    chapter = 1:5,
    text = c("This is a test chapter about adventure and travel.",
             "Another chapter with excitement and wonder.",
             "A chapter filled with danger and risk.",
             "A peaceful chapter about home and comfort.",
             "Final chapter with success and victory.")
  )
  message("Using dummy data for testing")
})

## Set Graph Theme ----

theme_set(theme_bw() + theme(axis.title.y = element_text(vjust = +3), axis.title.x = element_text(vjust = -0.75)))  # Set the theme for all graphs

## Sentiment Analysis with Multiple Dictionaries ----

tidy_book <- data %>%
  unnest_tokens(word, text) %>%
  count(chapter, word, sort = TRUE)

# Load different sentiment dictionaries
afinn <- get_sentiments("afinn")  # AFINN dictionary

# Install and load lexicon package
if (!require(lexicon)) {
  install.packages("lexicon")
  library(lexicon)
}

# Use the correct lexicon functions - check what's available
senticnet <- tryCatch({
  lexicon::hash_sentiment_senticnet
}, error = function(e) {
  message("SenticNet not available from lexicon, using AFINN as fallback")
  afinn
})

sentiwordnet <- tryCatch({
  lexicon::hash_sentiment_sentiwordnet
}, error = function(e) {
  message("SentiWordNet not available from lexicon, using AFINN as fallback")
  afinn
})