# ============================================================
# 5. Modeling
# IMDb Sentiment Analysis Project
# ============================================================

# -----------------------------
# Load Libraries
# -----------------------------
library(tidyverse)
library(tidytext)
library(caret)
library(glmnet)
library(tm)

# ------------------------------------------------------------
# LOAD DATA
# ------------------------------------------------------------
imdb_tokens <- read_csv("Data/Processed/imdb_tokens_clean.csv")

# ------------------------------------------------------------
# REBUILD DOC_ID 
# ------------------------------------------------------------
imdb_tokens <- imdb_tokens %>%
  group_by(review, sentiment) %>%
  mutate(doc_id = cur_group_id()) %>%
  ungroup()

# ------------------------------------------------------------
# LIMIT FEATURES (TOP 5000)
# ------------------------------------------------------------
top_words <- imdb_tokens %>%
  count(word, sort = TRUE) %>%
  slice_head(n = 5000) %>%
  pull(word)

imdb_tokens_filtered <- imdb_tokens %>%
  filter(word %in% top_words)

# ------------------------------------------------------------
# BUILD DTM
# ------------------------------------------------------------
tf_data <- imdb_tokens_filtered %>%
  count(doc_id, word)

dtm <- tf_data %>%
  cast_dtm(document = doc_id, term = word, value = n)

dtm <- removeSparseTerms(dtm, 0.99)

dtm <- as.matrix(dtm)

# ------------------------------------------------------------
# ALIGN LABELS
# ------------------------------------------------------------
labels <- imdb_tokens_filtered %>%
  distinct(doc_id, sentiment)

labels <- labels[match(rownames(dtm), labels$doc_id), ]

y <- as.factor(labels$sentiment)

stopifnot(nrow(dtm) == length(y))

# ------------------------------------------------------------
# TRAIN TEST SPLIT
# ------------------------------------------------------------
set.seed(123)

train_index <- createDataPartition(y, p = 0.8, list = FALSE)

x_train <- dtm[train_index, , drop = FALSE]
x_test  <- dtm[-train_index, , drop = FALSE]

y_train <- y[train_index]
y_test  <- y[-train_index]

stopifnot(ncol(x_train) == ncol(x_test))

# ------------------------------------------------------------
# MODEL
# ------------------------------------------------------------
model <- cv.glmnet(
  x = x_train,
  y = y_train,
  family = "binomial",
  alpha = 0,
  nfolds = 5
)

# ------------------------------------------------------------
# PREDICTION
# ------------------------------------------------------------
prob <- predict(model, x_test, s = "lambda.min", type = "response")

pred <- ifelse(prob > 0.5, "positive", "negative")
pred <- as.factor(pred)

# ------------------------------------------------------------
# EVALUATION
# ------------------------------------------------------------
conf_matrix <- confusionMatrix(pred, y_test)
print(conf_matrix)

# ------------------------------------------------------------
# SAVE OUTPUT
# ------------------------------------------------------------
dir.create("Outputs/Tables", recursive = TRUE, showWarnings = FALSE)
dir.create("Outputs/Models", recursive = TRUE, showWarnings = FALSE)

results <- data.frame(
  doc_id = rownames(x_test),
  actual = y_test,
  prediction = pred
)

write_csv(results, "Outputs/Tables/predictions.csv")

metrics <- data.frame(
  Accuracy  = conf_matrix$overall["Accuracy"],
  Precision = conf_matrix$byClass["Precision"],
  Recall    = conf_matrix$byClass["Recall"],
  F1        = conf_matrix$byClass["F1"]
)

write_csv(metrics, "Outputs/Tables/model_metrics.csv")

saveRDS(model, "Outputs/Models/glmnet_model.rds")

cat("MODEL COMPLETE - DOC_ID FIXED\n")