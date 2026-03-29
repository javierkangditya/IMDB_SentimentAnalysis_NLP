# ============================================================
# 2. Exploratory Data Analysis
# IMDb Sentiment Analysis Project
# ============================================================

# -----------------------------
# Load Libraries
# -----------------------------
library(tidyverse)
library(tidytext)
library(stringr)

# -----------------------------
# Load Dataset
# -----------------------------
imdb_data <- read_csv("Data/Raw/IMDB_dataset.csv")

glimpse(imdb_data)
head(imdb_data)

# -----------------------------
# Basic Inspection
# -----------------------------
# Check missing values
colSums(is.na(imdb_data))

# Check sentiment distribution (SAFE VERSION)
sentiment_dist <- imdb_data %>%
  dplyr::count(sentiment, name = "n")

print(sentiment_dist)

# Save table
write_csv(sentiment_dist, "Outputs/Tables/sentiment_distribution.csv")

# -----------------------------
# Visualization - Sentiment Distribution
# -----------------------------
p1 <- ggplot(sentiment_dist, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_col() +
  theme_minimal() +
  labs(
    title = "Sentiment Distribution",
    x = "Sentiment",
    y = "Count"
  ) +
  theme(legend.position = "none")
ggsave("Outputs/Figures/sentiment_distribution.png", p1, width = 6, height = 4)
print(p1)

# -----------------------------
# Feature Engineering - Review Length
# -----------------------------
imdb_data <- imdb_data %>%
  mutate(review_length = str_count(review, "\\w+"))

length_stats <- imdb_data %>%
  group_by(sentiment) %>%
  summarise(
    avg_length = mean(review_length),
    median_length = median(review_length),
    max_length = max(review_length),
    min_length = min(review_length),
    .groups = "drop"
  )

write_csv(length_stats, "Outputs/Tables/review_length_stats.csv")

# Visualization
p2 <- ggplot(imdb_data, aes(x = review_length, fill = sentiment)) +
  geom_histogram(bins = 50, alpha = 0.5, position = "identity") +
  theme_minimal() +
  labs(
    title = "Review Length Distribution",
    x = "Word Count",
    y = "Frequency"
  )
ggsave("Outputs/Figures/review_length_distribution.png", p2, width = 7, height = 5)
print(p2)

# -----------------------------
# Text Analysis - Top Words
# -----------------------------
top_words <- imdb_data %>%
  unnest_tokens(word, review) %>%
  dplyr::count(word, sort = TRUE)

write_csv(top_words, "Outputs/Tables/top_words_raw.csv")

p3 <- top_words %>%
  slice_head(n = 20) %>%
  ggplot(aes(x = reorder(word, n), y = n)) +
  geom_col() +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Top Words in Reviews",
    x = "Words",
    y = "Frequency"
  )
ggsave("Outputs/Figures/top_words_raw.png", p3, width = 7, height = 5)
print(p3)

# -----------------------------
# Top Words by Sentiment
# -----------------------------
top_words_sentiment <- imdb_data %>%
  unnest_tokens(word, review) %>%
  dplyr::count(word, sentiment, sort = TRUE)

write_csv(top_words_sentiment, "Outputs/Tables/top_words_by_sentiment.csv")

p4 <- top_words_sentiment %>%
  group_by(sentiment) %>%
  slice_max(order_by = n, n = 10) %>%
  ggplot(aes(x = reorder(word, n), y = n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free") +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Top Words by Sentiment",
    x = "Words",
    y = "Frequency"
  )
ggsave("Outputs/Figures/top_words_by_sentiment.png", p4, width = 8, height = 5)
print(p4)