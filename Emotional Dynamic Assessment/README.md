# Emotional Dynamics in Narrative Reading: Survey Analysis (EDA + Stats + NLP + ML)

This repository analyzes survey responses to two short fictional stories (“Story A” and “Story B”) to understand how readers’ **emotional trajectories** (valence and arousal), **prediction certainty**, **surprise**, and **engagement** relate to belief formation and interpretation.

The workflow combines:
- **Descriptive visualization** of emotional change distributions and relationships
- **Inferential statistics** (correlations, OLS regressions, ANOVA)
- **Lightweight NLP** (text cleaning, word clouds, frequency analysis of belief statements)
- **Baseline machine learning** (standardized linear regression prediction of belief elaboration length)

---

## Research Questions (What this project tests)

1. **Do emotional changes across chapters differ between Story A and Story B?**
   - Valence change (emotional tone: negative → positive)
   - Arousal change (emotional energy: calm → energetic)

2. **How does prediction certainty relate to experienced surprise?**
   - Correlation and OLS regression for Story A and Story B

3. **Do reader characteristics (e.g., favorite genre) predict surprise or emotional change?**
   - One-way ANOVA across favorite genre groups

4. **How do engagement and emotional intensity relate to belief elaboration?**
   - Scatter/regression visualizations using engagement ratio and an emotional intensity index

5. **What language patterns appear in participants’ written belief statements? (NLP)**
   - Word clouds + top-word frequency lists for Story A vs Story B beliefs

6. **Can we predict belief elaboration length from emotional and engagement features? (ML)**
   - Train/test split + standardized linear regression, report **R²** and **RMSE**

---

## Data Source

The notebook loads a cleaned CSV directly from GitHub:

- `survey_data_cleaned.csv`  
  Pulled from:  
  `https://raw.githubusercontent.com/yumnahussain444/survey_data_cleaned/refs/heads/main/survey_data_cleaned.csv`

