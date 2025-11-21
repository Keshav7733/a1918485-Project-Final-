# This file downloads the book 'Around the World in 80 Days'
# from Project Gutenberg, does basic cleaning of the book,
# and saves the data in a csv file
#
# Author: Ashley Dennis-Henderson
# Last Modified: 10 June 2025

## Load Libraries ----

pacman::p_load(tidyverse, tidytext, gutenbergr)


## Load Book from Project Gutenberg ----

book <- gutenberg_download(103, mirror = "http://mirror.csclub.uwaterloo.ca/gutenberg/")


## Cleaning: Remove Header and Footer ----

book_text_only <- book %>%
  tail(nrow(book) - 53)

# If need to remove footer, then use above with %>% head(n) where n is the last line of the text


## Cleaning: Separate Book by Chapters ----

# Determine chapter number for each line:

book_chapters <- book_text_only %>%
  mutate(linenumber = row_number(),
         chapter = cumsum(str_detect(text, 
                                     regex("^chapter [\\divxlc]",
                                           ignore_case = TRUE)))) %>%
  ungroup()

# If the book also has parts we can similarly get a part number for each line

# Remove empty lines:

book_chapters_clean <- book_chapters %>% 
  filter(!(text == ""))

# Remove chapter headings:

ch <- 0  # Initiate chapter number

rows <- c()  # Initiate empty string of rows to be removed

for (i in 1:nrow(book_chapters_clean)){  # For every row of our data
  
  temp_ch <- book_chapters_clean[i,4]  # Get the chapter number for that row
  
  if (!(temp_ch == ch)){  # If the chapter number for our row is not equal to the previous chapter number (i.e. we have moved to a new chapter)
    
    ch <- temp_ch  # Set the new chapter number
    
    rows <- c(rows, i)  # Add row to those to be removed
    
  }
  else if (temp_ch == ch) {  # Otherwise
    
    if(str_detect(book_chapters_clean[i,2], "^([[:upper:]]|[[:digit:]]|[[:punct:]]|[[:blank:]])+$")){  # The chapter headings are in all caps
      
      rows <- c(rows, i)  # Add row to those to be removed
    }
  }
  
}

rows <- unique(rows)  # Get a list of unique rows to be removed

# Remove those rows:

book_chapters_clean2 <- book_chapters_clean %>%
  filter(!row_number() %in% rows)  

# Combine text for each chapter:

book_chapters_clean3 <- book_chapters_clean2 %>%
  select(chapter, text) %>%
  group_by(chapter) %>%
  mutate(text = paste0(text, collapse = " ")) %>%
  slice(1) %>%
  ungroup()


## Save Data as CSV ----

write.csv(book_chapters_clean3, "around_world_80_days.csv")
