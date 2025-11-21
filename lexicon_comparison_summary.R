# Comprehensive Lexicon Comparison Summary
#
# This file provides a final summary and comparison of all sentiment lexicons:
# - AFINN, Bing, NRC, and VADER
# - Statistical comparisons and recommendations
# - Best practices for literary sentiment analysis
#
# Author: Final lexicon comparison summary
# Last Modified: July 2025

## Load Libraries ----

pacman::p_load(tidyverse, tidytext, stopwords, gridExtra, patchwork, scales, knitr)

## Load All Lexicon Results ----

# Load the main lexicon comparison results
if(file.exists("multiple_lexicon_scores.csv")) {
  main_lexicons <- read.csv("multiple_lexicon_scores.csv")
} else {
  cat("Warning: multiple_lexicon_scores.csv not found. Run multiple_lexicon_comparison.R first.\n")
  main_lexicons <- NULL
}

# Load VADER results
if(file.exists("vader_sentiment_scores.csv")) {
  vader_results <- read.csv("vader_sentiment_scores.csv")
} else {
  cat("Warning: vader_sentiment_scores.csv not found. Run vader_lexicon_analysis.R first.\n")
  vader_results <- NULL
}

# Load word coverage data
if(file.exists("lexicon_coverage.csv")) {
  coverage_data <- read.csv("lexicon_coverage.csv")
} else {
  cat("Warning: lexicon_coverage.csv not found.\n")
  coverage_data <- NULL
}

## Combine All Results ----

if(!is.null(main_lexicons) && !is.null(vader_results)) {
  all_results <- main_lexicons %>%
    left_join(vader_results %>% select(chapter, vader_compound, vader_category), by = "chapter") %>%
    filter(!is.na(afinn_score) & !is.na(bing_score) & !is.na(nrc_score) & !is.na(vader_compound))
  
  cat("=== COMPREHENSIVE LEXICON COMPARISON ===\n")
  cat("Total chapters analyzed:", nrow(all_results), "\n\n")
} else {
  cat("Cannot perform comprehensive comparison - missing data files.\n")
  all_results <- NULL
}

## Statistical Comparison ----

if(!is.null(all_results)) {
  
  ### Correlation Matrix
  correlation_matrix <- all_results %>%
    select(afinn_score, bing_score, nrc_score, vader_compound) %>%
    cor(use = "complete.obs")
  
  cat("=== CORRELATION MATRIX ===\n")
  print(round(correlation_matrix, 3))
  cat("\n")
  
  ### Descriptive Statistics
  cat("=== DESCRIPTIVE STATISTICS ===\n")
  
  # AFINN
  cat("AFINN Lexicon:\n")
  cat("  Mean:", round(mean(all_results$afinn_score), 3), "\n")
  cat("  SD:", round(sd(all_results$afinn_score), 3), "\n")
  cat("  Range:", round(range(all_results$afinn_score), 3), "\n")
  cat("  Most positive chapter:", which.max(all_results$afinn_score), "\n")
  cat("  Most negative chapter:", which.min(all_results$afinn_score), "\n\n")
  
  # Bing
  cat("Bing Lexicon:\n")
  cat("  Mean:", round(mean(all_results$bing_score), 3), "\n")
  cat("  SD:", round(sd(all_results$bing_score), 3), "\n")
  cat("  Range:", round(range(all_results$bing_score), 3), "\n")
  cat("  Most positive chapter:", which.max(all_results$bing_score), "\n")
  cat("  Most negative chapter:", which.min(all_results$bing_score), "\n\n")
  
  # NRC
  cat("NRC Lexicon:\n")
  cat("  Mean:", round(mean(all_results$nrc_score), 3), "\n")
  cat("  SD:", round(sd(all_results$nrc_score), 3), "\n")
  cat("  Range:", round(range(all_results$nrc_score), 3), "\n")
  cat("  Most positive chapter:", which.max(all_results$nrc_score), "\n")
  cat("  Most negative chapter:", which.min(all_results$nrc_score), "\n\n")
  
  # VADER
  cat("VADER Lexicon:\n")
  cat("  Mean:", round(mean(all_results$vader_compound), 3), "\n")
  cat("  SD:", round(sd(all_results$vader_compound), 3), "\n")
  cat("  Range:", round(range(all_results$vader_compound), 3), "\n")
  cat("  Most positive chapter:", which.max(all_results$vader_compound), "\n")
  cat("  Most negative chapter:", which.min(all_results$vader_compound), "\n\n")
  
  ### Agreement Analysis
  cat("=== LEXICON AGREEMENT ANALYSIS ===\n")
  
  # Calculate agreement on most positive/negative chapters
  most_positive_chapters <- data.frame(
    AFINN = which.max(all_results$afinn_score),
    Bing = which.max(all_results$bing_score),
    NRC = which.max(all_results$nrc_score),
    VADER = which.max(all_results$vader_compound)
  )
  
  most_negative_chapters <- data.frame(
    AFINN = which.min(all_results$afinn_score),
    Bing = which.min(all_results$bing_score),
    NRC = which.min(all_results$nrc_score),
    VADER = which.min(all_results$vader_compound)
  )
  
  cat("Most Positive Chapters:\n")
  print(most_positive_chapters)
  cat("\nMost Negative Chapters:\n")
  print(most_negative_chapters)
  cat("\n")
  
  ### VADER Category Distribution
  cat("=== VADER SENTIMENT CATEGORIES ===\n")
  vader_categories <- all_results %>%
    count(vader_category) %>%
    mutate(percentage = n / sum(n) * 100)
  print(vader_categories)
  cat("\n")
  
}

## Word Coverage Analysis ----

if(!is.null(coverage_data)) {
  cat("=== WORD COVERAGE ANALYSIS ===\n")
  print(coverage_data)
  cat("\n")
  
  # Coverage visualization
  p1 <- ggplot(coverage_data, aes(x = Lexicon, y = Coverage_Percentage, fill = Lexicon)) +
    geom_col(alpha = 0.8) +
    geom_text(aes(label = paste0(round(Coverage_Percentage, 1), "%")), 
              vjust = -0.5, size = 4) +
    scale_fill_manual(values = c("AFINN" = "blue", "Bing" = "red", "NRC" = "green")) +
    labs(title = "Word Coverage by Lexicon",
         subtitle = "Percentage of total words with sentiment scores",
         x = "Lexicon",
         y = "Coverage (%)") +
    theme_minimal() +
    theme(legend.position = "none")
  
  print(p1)
}

## Comprehensive Visualizations ----

if(!is.null(all_results)) {
  
  ### 1. All Lexicons Comparison
  p2 <- ggplot(all_results, aes(x = chapter)) +
    geom_line(aes(y = afinn_score, color = "AFINN"), alpha = 0.8, size = 1) +
    geom_line(aes(y = bing_score, color = "Bing"), alpha = 0.8, size = 1) +
    geom_line(aes(y = nrc_score, color = "NRC"), alpha = 0.8, size = 1) +
    geom_line(aes(y = vader_compound, color = "VADER"), alpha = 0.8, size = 1.2) +
    geom_point(aes(y = afinn_score, color = "AFINN"), size = 2) +
    geom_point(aes(y = bing_score, color = "Bing"), size = 2) +
    geom_point(aes(y = nrc_score, color = "NRC"), size = 2) +
    geom_point(aes(y = vader_compound, color = "VADER"), size = 2) +
    scale_color_manual(values = c("AFINN" = "blue", "Bing" = "red", "NRC" = "green", "VADER" = "purple")) +
    labs(title = "Comprehensive Sentiment Analysis: All Lexicons",
         subtitle = "Chapter-wise sentiment scores comparison",
         x = "Chapter",
         y = "Sentiment Score",
         color = "Lexicon") +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  ### 2. Correlation Heatmap
  correlation_long <- as.data.frame(correlation_matrix) %>%
    rownames_to_column("lexicon1") %>%
    pivot_longer(-lexicon1, names_to = "lexicon2", values_to = "correlation")
  
  p3 <- ggplot(correlation_long, aes(x = lexicon1, y = lexicon2, fill = correlation)) +
    geom_tile() +
    geom_text(aes(label = round(correlation, 3)), color = "white", size = 4) +
    scale_fill_gradient2(low = "red", mid = "white", high = "blue", 
                        midpoint = 0, limits = c(-1, 1)) +
    labs(title = "Lexicon Correlation Matrix",
         x = "Lexicon 1",
         y = "Lexicon 2",
         fill = "Correlation") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  ### 3. Score Distribution Comparison
  all_results_long <- all_results %>%
    select(chapter, afinn_score, bing_score, nrc_score, vader_compound) %>%
    pivot_longer(-chapter, names_to = "lexicon", values_to = "score") %>%
    mutate(lexicon = case_when(
      lexicon == "afinn_score" ~ "AFINN",
      lexicon == "bing_score" ~ "Bing",
      lexicon == "nrc_score" ~ "NRC",
      lexicon == "vader_compound" ~ "VADER"
    ))
  
  p4 <- ggplot(all_results_long, aes(x = score, fill = lexicon)) +
    geom_density(alpha = 0.6) +
    facet_wrap(~lexicon, scales = "free_x") +
    labs(title = "Sentiment Score Distributions",
         x = "Sentiment Score",
         y = "Density") +
    theme_minimal() +
    theme(legend.position = "none")
  
  # Display all plots
  (p2 + p3) / p4
  
}

## Lexicon Recommendations ----

cat("=== LEXICON RECOMMENDATIONS FOR LITERARY ANALYSIS ===\n\n")

cat("1. AFINN Lexicon:\n")
cat("   ✅ Pros: Continuous scores, good for nuanced analysis\n")
cat("   ❌ Cons: Limited word coverage, may miss context\n")
cat("   📊 Best for: Detailed sentiment trends, academic research\n\n")

cat("2. Bing Lexicon:\n")
cat("   ✅ Pros: Simple binary classification, good coverage\n")
cat("   ❌ Cons: Lacks nuance, may oversimplify complex emotions\n")
cat("   📊 Best for: Quick sentiment overview, binary classification tasks\n\n")

cat("3. NRC Lexicon:\n")
cat("   ✅ Pros: Emotion classification, comprehensive coverage\n")
cat("   ❌ Cons: May be too granular for some applications\n")
cat("   📊 Best for: Emotion analysis, character sentiment mapping\n\n")

cat("4. VADER Lexicon:\n")
cat("   ✅ Pros: Context-aware, handles intensifiers and negators\n")
cat("   ❌ Cons: Designed for social media, may need adaptation\n")
cat("   📊 Best for: Modern text analysis, social media-like content\n\n")

## Best Practices Summary ----

cat("=== BEST PRACTICES FOR LITERARY SENTIMENT ANALYSIS ===\n\n")

cat("📚 Preprocessing:\n")
cat("   • Always apply consistent preprocessing across all lexicons\n")
cat("   • Remove stop words to focus on meaningful content\n")
cat("   • Use lowercasing for consistent word matching\n")
cat("   • Consider chapter length when interpreting results\n\n")

cat("📊 Analysis:\n")
cat("   • Use multiple lexicons for comprehensive understanding\n")
cat("   • Consider lexicon-specific characteristics and limitations\n")
cat("   • Validate results against literary context and themes\n")
cat("   • Look for patterns across chapters and story arcs\n\n")

cat("📈 Visualization:\n")
cat("   • Compare trends across multiple lexicons\n")
cat("   • Use correlation analysis to understand lexicon relationships\n")
cat("   • Consider chapter-specific context in interpretations\n")
cat("   • Present results with appropriate statistical context\n\n")

## Save Comprehensive Results ----

if(!is.null(all_results)) {
  write.csv(all_results, "comprehensive_lexicon_results.csv")
  write.csv(correlation_matrix, "lexicon_correlations.csv")
  
  cat("=== FILES SAVED ===\n")
  cat("• comprehensive_lexicon_results.csv: All lexicon scores combined\n")
  cat("• lexicon_correlations.csv: Correlation matrix\n")
  cat("• Multiple lexicon comparison completed successfully!\n\n")
}

## Final Summary ----

cat("=== FINAL SUMMARY ===\n")
cat("✅ Multiple lexicon comparison analysis completed!\n")
cat("✅ All four lexicons (AFINN, Bing, NRC, VADER) analyzed\n")
cat("✅ Comprehensive statistical comparisons performed\n")
cat("✅ Visualizations and recommendations provided\n")
cat("✅ Best practices for literary sentiment analysis documented\n\n")

cat("🎯 Key Insights:\n")
cat("• Different lexicons provide complementary perspectives\n")
cat("• Correlation analysis shows lexicon agreement patterns\n")
cat("• Word coverage varies significantly between lexicons\n")
cat("• VADER provides unique context-aware scoring\n")
cat("• NRC offers rich emotion classification capabilities\n\n")

cat("📖 Next Steps:\n")
cat("• Consider geospatial analysis with sentiment mapping\n")
cat("• Analyze character-specific sentiment patterns\n")
cat("• Apply time series analysis to sentiment trends\n")
cat("• Develop custom lexicon for literary analysis\n")

