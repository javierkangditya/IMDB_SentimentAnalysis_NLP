# ============================================================
# 3. Text Preprocessing Pipeline
# IMDb Sentiment Analysis Project
# ============================================================

# -----------------------------
# Load required libraries
# -----------------------------
library(tidyverse)
library(tidytext)
library(stringr)
library(textstem)

# -----------------------------
# Text Cleaning
# -----------------------------
imdb_clean <- imdb_data %>%
  mutate(
    review_clean = review %>%
      str_to_lower() %>%                     # lowercase normalization
      str_replace_all("<.*?>", " ") %>%      # remove HTML tags
      str_replace_all("[^a-z\\s]", " ") %>%  # remove punctuation & numbers
      str_squish()                           # remove extra whitespace
  )

# -----------------------------
# Tokenization
# -----------------------------
imdb_tokens <- imdb_clean %>%
  unnest_tokens(word, review_clean)

# -----------------------------
# Stopwords Removal
# -----------------------------
data("stop_words")

imdb_tokens_clean <- imdb_tokens %>%
  anti_join(stop_words, by = "word")

# -----------------------------
# Lemmatization
# -----------------------------
imdb_tokens_clean <- imdb_tokens_clean %>%
  mutate(word = lemmatize_words(word))

# -----------------------------
# Word Frequency Analysis
# -----------------------------
imdb_tokens_clean %>%
  count(word, sort = TRUE) %>%
  head(20)

# -----------------------------
# Visualization (Top Words)
# -----------------------------
imdb_tokens_clean %>%
  count(word, sort = TRUE) %>%
  head(20) %>%
  ggplot(aes(x = reorder(word, n), y = n)) +
  geom_col(fill = "darkblue") +
  coord_flip() +
  labs(
    title = "Top 20 Most Frequent Words (IMDb Reviews)",
    x = "Words",
    y = "Frequency"
  ) +
  theme_minimal()

# -----------------------------
# Save Processed Data
# -----------------------------
write_csv(imdb_clean, "Data/Processed/imdb_clean.csv")
write_csv(imdb_tokens_clean, "Data/Processed/imdb_tokens_clean.csv")

