library(tidyverse)
library(readr)
library(readxl)
library(openxlsx)

# Load hex dataset
db_hex <- readRDS("~/HEX/HEX Future Skill Classification/Create Dataset for Classifier Validation/db_hex.rds")

# sample
set.seed(19)
db_hex_sub <- sample_n(db_hex, 200000)

# Erstelle eine Funktion, um Skills zu erkennen
detect_skills <- function(title, description) {
  skills <- list(
    "Data Analytics & KI" = str_detect(title, regex("Data Analytics|\\bKI\\b|\\bAI\\b|Machine Learn|Maschinenlernen|Maschinell\\w* Lern|Big Data|Künstliche\\w* Intelligenz|Prediction Model|Vorhersagemodel", ignore_case = TRUE)) |
      str_detect(description, regex("Data Analytics|\\bKI\\b|\\bAI\\b|Machine Learn|Maschinenlernen|Maschinell\\w* Lern|Big Data|Künstliche\\w* Intelligenz|Prediction Model|Vorhersagemodel", ignore_case = TRUE)),
    
    "Softwareentwicklung" = str_detect(title, regex("Softwareentwicklung|Software.*develop|develop.*software|Frontend|Backend|\\bIoT\\b|Programmierung|programming|C#|\\bJava\\b|\\b(app|application)\\b.*entwickl|entwick.*\\b(app|application)\\b|\\b(app|application)\\b.*develop|develop.*\\b(app|application)\\b|\\bapi\\b|docker|kubernetes", ignore_case = TRUE)) |
      str_detect(description, regex("Softwareentwicklung|Software.*develop|develop.*software|Frontend|Backend|\\bIoT\\b|Programmierung|programming|C#|\\bJava\\b|\\b(app|application)\\b.*entwickl|entwick.*\\b(app|application)\\b|\\b(app|application)\\b.*develop|develop.*\\b(app|application)\\b|\\bapi\\b|docker|kubernetes", ignore_case = TRUE)),
    
    "Nutzerzentriertes Design" = str_detect(title, regex("\\bUX\\b|User Experience|User Research|Usability|User Flow|Benutzeroberfläche|\\bUI\\b(?!/)|User Interface|Nutzerzentriert\\w* Design|Interaktionsdesign|Nutzerfeedback|User feedback", ignore_case = TRUE)) |
      str_detect(description, regex("\\bUX\\b|User Experience|User Research|Usability|User Flow|Benutzeroberfläche|\\bUI\\b(?!/)|User Interface|Nutzerzentriert\\w* Design|Interaktionsdesign|Nutzerfeedback|User feedback", ignore_case = TRUE)),
    
    "IT-Architektur" = str_detect(title, regex("\\bIT(-|\\s)?Architektur|IT(-|\\s)?Architecture|\\bIT(-|\\s)?Security|\\bIT(-|\\s)?Design|\\bIT(-|\\s)?Sicherheit|Cloud|Blockchain|Systemintegration|Digital\\w* Sicherheit|Cyber(-|\\s)?Sicherheit|Cyber(-|\\s)?Security|Digital\\w* Security|Digital\\w* Infrastru|Datenbankarchitekt|Informationsarchitekt", ignore_case = TRUE)) |
      str_detect(description, regex("\\bIT(-|\\s)?Architektur|IT(-|\\s)?Architecture|\\bIT(-|\\s)?Security|\\bIT(-|\\s)?Design|\\bIT(-|\\s)?Sicherheit|Cloud|Blockchain|Systemintegration|Digital\\w* Sicherheit|Cyber(-|\\s)?Sicherheit|Cyber(-|\\s)?Security|Digital\\w* Security|Digital\\w* Infrastru|Datenbankarchitekt|Informationsarchitekt", ignore_case = TRUE)),
    
    "Hardware-/Robotikentwicklung" = str_detect(title, regex("Hardware|Robot|\\bIoT\\b|Internet of Things|eingebettet\\w* System|embedded System|Elektronik|Electronics|Mikrocontrol|Micro Control|Mechatroni|connected system|intelligent\\w* system|intelligent system|\\baktori|\\bactuat|edge comput|automation technolog|automatisierungstechn", ignore_case = TRUE)) |
      str_detect(description, regex("Hardware|Robot|\\bIoT\\b|Internet of Things|eingebettet\\w* System|embedded System|Elektronik|Electronics|Mikrocontrol|Micro Control|Mechatroni|connected system|intelligent\\w* system|intelligent system|\\baktori|\\bactuat|edge comput|automation technolog|automatisierungstechn", ignore_case = TRUE)),
    
    "Quantencomputing" = str_detect(title, regex("(\\bquanten|\\bquantum)\\s?(comput|tech|bit|simul|crypto|krypto|parallel|supremati|verschränk|entangle|algorith)|Superposition|Qubit", ignore_case = TRUE)) |
      str_detect(description, regex("(\\bquanten|\\bquantum)\\s?(comput|tech|bit|simul|crypto|krypto|parallel|supremati|verschränk|entangle|algorith)|Superposition|Qubit", ignore_case = TRUE))
  )
  detected_skills <- names(skills)[unlist(skills)]
  
  if (length(detected_skills) == 0) {
    return(NA)
  } else {
    return(str_c(detected_skills, collapse = ","))
  }
}

# Anwenden der Funktion auf den DataFrame
df <- db_hex_sub %>%
  mutate(skills = map2_chr(titel, kursbeschreibung, detect_skills))


# count skills
df %>%
  separate_rows(skills, sep = ",") %>%
  group_by(skills) %>%
  summarise(total_count = n(), .groups = "drop") %>%  
  arrange(desc(total_count))

#########################################################

# Manual Selection was done in Excel ####################

#########################################################

# Data Preparation Manually selected dataset -------------
df_manually_selected <- read_delim("Manually selected Dataset.csv", 
                                   delim = ";", escape_double = FALSE, trim_ws = TRUE)

# Correct future skills names
df_manually_selected <- df_manually_selected %>%
  mutate(skills = str_replace_all(skills, c(
    " Softwareentwicklung" = "Softwareentwicklung",
    " Hardware-/Robotikentwicklung" = "Hardware-/Robotikentwicklung",
    " Nutzerzentriertes Design" = "Nutzerzentriertes Design",
    " IT-Architektur" = "IT-Architektur",
    " Data Analytics & KI" = "Data Analytics & KI")))

# Overview included Skills 
df_manually_selected %>%
  separate_rows(skills, sep = ",") %>%
  group_by(skills) %>%
  summarise(total_count = n(), .groups = "drop") %>%  
  arrange(desc(total_count))

# Remove 'select' and 'random' columns
df_manually_selected <- df_manually_selected %>%
  select(-"Select", -"Random") 

###########################################################################
# Add negative cases -------------
# i.e. rows that have no future skills label
# They should come from various faechergruppen to increase heterogeneity

# 1. Cases where course description is missing
missing_course_descriptions <- df %>% 
  filter(is.na(skills)) %>% 
  filter(is.na(kursbeschreibung)) %>% 
  group_by(faechergruppe) %>%
  sample_n(size = min(3, n())) %>% # select all cases of faechergruppe up to 3
  ungroup() %>%
  select(colnames(df_manually_selected)[-1]) %>% # without ID
  distinct() %>% 
  sample_n(50)

# 2. Cases with course description, but no FS label
courses_without_FS <- df %>%
  filter(is.na(skills)) %>% 
  filter(!is.na(kursbeschreibung)) %>% 
  group_by(faechergruppe) %>%
  sample_n(size = min(3, n())) %>% # select all cases of faechergruppe up to 3
  ungroup() %>%
  select(colnames(df_manually_selected)[-1]) %>% 
  distinct() 

# Bind them
merged_train_data <- df_manually_selected %>% 
  bind_rows(missing_course_descriptions) %>% 
  bind_rows(courses_without_FS)


############################################################################
# One hot Encoding
train_data_one_hot_encoded <- merged_train_data %>% 
  mutate(skills = ifelse(is.na(skills), "NA", skills)) %>%
  separate_rows(skills, sep = ",") %>%
  mutate(value = 1) %>%
  pivot_wider(names_from = skills, values_from = value, values_fill = 0) %>% 
  select(-'NA')

# New format
train_data <- train_data_one_hot_encoded %>%
  select(5:12) %>%
  mutate(sentence = paste(titel, kursbeschreibung, sep = ": ")) %>% 
  select(3:9)

# Save as xlsx
write.xlsx(train_data, file = "Train data with negative cases one hot encoded.xlsx")

###############################################################################

# Feed manually corrected cases back into training dataset
# A classfier was trained on the above training data. The output (FS labels)
# was manually corrected in Excel. The manually corrected cases are now added
# to the training data

# load previous dataset
train_data <- read_excel("Train data with negative cases one hot encoded.xlsx")

# load manually corrected cases
manually_corrected_cases <- read_delim("Classification Output manually corrected cases.csv", 
                                       delim = ";", escape_double = FALSE, trim_ws = TRUE)

# Correct future skills names
manually_corrected_cases <- manually_corrected_cases %>%
  mutate(`Correct FS_Skill` = str_replace_all(`Correct FS_Skill`, c(
    " Softwareentwicklung" = "Softwareentwicklung",
    " Hardware-/Robotikentwicklung" = "Hardware-/Robotikentwicklung",
    " Nutzerzentriertes Design" = "Nutzerzentriertes Design",
    " IT-Architektur" = "IT-Architektur",
    " Data Analytics & KI" = "Data Analytics & KI")))

# Overview included Skills 
manually_corrected_cases %>%
  separate_rows(`Correct FS_Skill`, sep = ",") %>%
  group_by(`Correct FS_Skill`) %>%
  summarise(total_count = n(), .groups = "drop") %>%  
  arrange(desc(total_count))

# One hot Encoding
manually_corrected_cases_one_hot_encoded <- manually_corrected_cases %>% 
  mutate(`Correct FS_Skill` = ifelse(is.na(`Correct FS_Skill`), "NA", `Correct FS_Skill`)) %>%
  separate_rows(`Correct FS_Skill`, sep = ",") %>%
  mutate(value = 1) %>%
  pivot_wider(names_from = `Correct FS_Skill`, values_from = value, values_fill = 0) %>% 
  mutate("Quantencomputing" = 0) %>% 
  select(-'NA')

# Merge with existing dataset
train_data_merged <- manually_corrected_cases_one_hot_encoded %>% 
  select(40:45, 37) %>% 
  bind_rows(train_data)

# Save as xlsx
write.xlsx(train_data_merged, file = "Train data with manually corrected cases.xlsx")
