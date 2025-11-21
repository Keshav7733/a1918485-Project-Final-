# This file does basic sentiment analysis on Around the World in 80 Days
#
# Author: Ashley Dennis-Henderson
# Last Modified: July 2025

## Load Libraries ----

pacman::p_load(tidyverse, tidytext)


## Load Data ----

data <- read.csv("around_world_80_days.csv") %>% select(-X)


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

