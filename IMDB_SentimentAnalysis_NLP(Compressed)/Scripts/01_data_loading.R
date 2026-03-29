# ============================================================
# 1. Data Loading & Inspection
# IMDb Sentiment Analysis Project
# ============================================================

# -----------------------------
# Load required libraries
# -----------------------------
library(tidyverse)
library(readr)

# -----------------------------
# Load dataset
# -----------------------------
imdb_data <- read_csv("Data/Raw/IMDB_dataset.csv")

# -----------------------------
# Initial data overview
# -----------------------------
glimpse(imdb_data)
head(imdb_data)

dim(imdb_data)
colnames(imdb_data)
str(imdb_data)

# -----------------------------
# Data quality checks
# -----------------------------

# Missing values check
colSums(is.na(imdb_data))

# Duplicate review check 
sum(duplicated(imdb_data$review))

# -----------------------------
# Target variable analysis (sentiment)
# -----------------------------

# Class distribution (count)
table(imdb_data$sentiment)

# Class distribution (percentage)
prop.table(table(imdb_data$sentiment)) * 100

# -----------------------------
# Visualization of sentiment distribution
# -----------------------------
ggplot(imdb_data, aes(x = sentiment)) +
  geom_bar(fill = "steelblue") +
  labs(
    title = "Sentiment Distribution - IMDb Dataset",
    x = "Sentiment",
    y = "Count"
  ) +
  theme_minimal()

# -----------------------------
# Label Quality Check (NLP sanity check)
# -----------------------------

# Manual sampling for validation
set.seed(123)
imdb_data %>%
  sample_n(10) %>%
  select(review, sentiment)

# -----------------------------
# Heuristic mismatch detection 
# -----------------------------

positive_words <- c("good", "great", "excellent", "amazing", "best", "love", "wonderful")
negative_words <- c("bad", "worst", "boring", "awful", "poor", "hate", "terrible")

imdb_check <- imdb_data %>%
  mutate(
    review_lower = tolower(review),
    pos_score = str_count(review_lower, paste(positive_words, collapse = "|")),
    neg_score = str_count(review_lower, paste(negative_words, collapse = "|"))
  )

# Flag potential mislabeled samples
imdb_suspect <- imdb_check %>%
  filter(
    (sentiment == "positive" & neg_score > pos_score) |
      (sentiment == "negative" & pos_score > neg_score)
  )

head(imdb_suspect)

# -----------------------------
# Text length analysis
# -----------------------------

imdb_data <- imdb_data %>%
  mutate(review_length = nchar(review))

summary(imdb_data$review_length)

ggplot(imdb_data, aes(x = review_length)) +
  geom_histogram(bins = 50, fill = "darkgreen") +
  labs(
    title = "Distribution of Review Length",
    x = "Number of Characters",
    y = "Frequency"
  ) +
  theme_minimal()