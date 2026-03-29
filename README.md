# IMDBSentimentAnalysis

## Project Overview
This project analyzes movie reviews from the IMDb dataset and builds a machine learning model to classify sentiment as positive or negative using Natural Language Processing (NLP) techniques.

## Folder Structure
- `Data/Raw` : original IMDb dataset  
- `Data/Processed` : cleaned and tokenized text data
(Dataset is not included due to size. Please download from Kaggle.)
- `Notebooks` : R Markdown notebook documenting the full workflow  
- `Scripts` : modular R scripts for each pipeline step  
- `Outputs/Figures` : visualizations from EDA and insights  
- `Outputs/Tables` : summary tables, predictions, and model metrics  
- `Outputs/Models` : trained machine learning models (RDS format)  

## Pipeline
1. **Data Loading & Cleaning** – inspect dataset, handle duplicates, basic validation  
2. **Exploratory Data Analysis (EDA)** – sentiment distribution, review length, word frequency  
3. **Text Preprocessing** – lowercasing, removing HTML, punctuation, stopwords, tokenization, lemmatization  
4. **Feature Engineering** – Bag-of-Words representation, feature restriction to top 5000 words, DTM creation  
5. **Modeling** – Logistic Regression using glmnet with regularization  
6. **Evaluation** – Confusion matrix, accuracy, precision, recall, F1-score  
7. **Insights** – feature importance (top positive and negative words)  

## How to Run
1. Open the project in RStudio  
2. Run the R Markdown notebook (`Notebooks.Rmd`) or execute scripts step-by-step  
3. Ensure required packages are installed:  
   `tidyverse`, `tidytext`, `stringr`, `textstem`, `tm`, `caret`, `glmnet`, `Matrix`, `pROC`  

## Key Insights
- The model achieved approximately **86% accuracy**, indicating strong performance in sentiment classification  
- Positive sentiment is strongly associated with words such as *“excellent”, “amazing”, “wonderful”*  
- Negative sentiment is strongly associated with words such as *“boring”, “worst”, “terrible”*  
- Text preprocessing significantly improves model performance by removing noise and focusing on meaningful words  
- Logistic Regression provides interpretable results, allowing clear understanding of feature importance  

## References
IMDb Dataset of 50K Movie Reviews on Kaggle
