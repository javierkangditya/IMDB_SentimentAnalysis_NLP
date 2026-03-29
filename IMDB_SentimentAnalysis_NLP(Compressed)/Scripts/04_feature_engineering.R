# ============================================================
# 4. Feature Engineering
# IMDb Sentiment Analysis Project
# ============================================================

# -----------------------------
# Load Libraries
# -----------------------------
library(tidyverse)
library(tidytext)

# -----------------------------
# Load Processed Data
# -----------------------------
imdb_tokens_clean <- read_csv("Data/Processed/imdb_tokens_clean.csv")

glimpse(imdb_tokens_clean)

# -----------------------------
# Create Document ID
# -----------------------------

imdb_tokens_clean <- imdb_tokens_clean %>%
  group_by(review, sentiment) %>%
  mutate(doc_id = cur_group_id()) %>%
  ungroup()

# -----------------------------
# Term Frequency (TF)
# -----------------------------
tf_data <- imdb_tokens_clean %>%
  count(doc_id, word, sort = TRUE)

# -----------------------------
# TF-IDF Calculation
# -----------------------------
tfidf_data <- tf_data %>%
  bind_tf_idf(term = word, document = doc_id, n = n)

# Save TF-IDF (long format)
write_csv(tfidf_data, "Data/Processed/imdb_tfidf_long.csv")

# -----------------------------
# Document-Term Matrix (DTM)
# -----------------------------
dtm <- tf_data %>%
  cast_dtm(document = doc_id, term = word, value = n)

# -----------------------------
# Inspect Matrix
# -----------------------------
dim(dtm)

# -----------------------------
# Top TF-IDF Words
# -----------------------------
top_tfidf <- tfidf_data %>%
  arrange(desc(tf_idf)) %>%
  slice_head(n = 20)

write_csv(top_tfidf, "Outputs/Tables/top_tfidf_words.csv")

top_tfidf %>%
  ggplot(aes(x = reorder(word, tf_idf), y = tf_idf)) +
  geom_col() +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Top TF-IDF Words",
    x = "Words",
    y = "TF-IDF Score"
  )

ggsave("Outputs/Figures/top_tfidf_words.png", width = 7, height = 5)

# -----------------------------
# Save DTM
# -----------------------------
saveRDS(dtm, "Data/Processed/imdb_dtm.rds")

