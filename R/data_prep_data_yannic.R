library(readr)
library(tidyverse)
library(openxlsx)
train_data <- read_csv("C:/Users/Hueck/Downloads/Trainingsdata Future Skills Classifier.csv") %>%
  select(6:13) %>%
  mutate(sentence = paste(titel, kursbeschreibung, sep = ": ")) %>% 
  select(3:9) 

# Entfernen der alphanumerischen und numerischen Codes mit Punkten und Bindestrichen
train_data <- train_data %>%
  mutate(sentence = str_replace_all(sentence, "\\b[[:alnum:]]+([.-][[:alnum:]]+)+\\b"," "))

# Entfernen von übrig gebliebenen isolierten Sonderzeichen
train_data <- train_data %>%
  mutate(sentence = str_replace_all(sentence, "[\\s[:punct:]]{2,}"," ")) %>% 
  
  mutate(sentence = str_squish(sentence)) 


view(train_data)

write.xlsx(train_data, file = "train_data_yannic_clean.xlsx")
getwd()
