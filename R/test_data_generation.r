# Lade Pakete ------------------------------------------------------

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, openxlsx, janitor) # janitor for cleaning  names

# Lade Daten ------------------------------------------------------
setwd("C:/Users/Hueck/OneDrive/Dokumente/GitHub/future_skill_classification/")
f_skills_tdf <- read.xlsx("data/Nachcodierung_Future_Skill_Classification.xlsx") |> clean_names() 
db_hex <- read_rds("data/db_hex.rds") 

# Datenpräperation ------------------------------------------------------

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Comment: Filtere Kurstitel und Beschreibung je na FS aus
# f_skills_tdf. Verwende die extrahierten Stringpattern zum filtern
# der db_hex um gelabelte Daten zu erhalten.
#.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

data_analytics_ki <- f_skills_tdf |>
    filter(data_analytics_ki==1) |> pull(sentence)

softwareentwicklung <- f_skills_tdf |>
    filter(softwareentwicklung==1) |> pull(sentence)
     
nutzerzentriertes_design <- f_skills_tdf |>
    filter(nutzerzentriertes_design==1) |> pull(sentence)

it_architektur <- f_skills_tdf |>
    filter(it_architektur==1) |> pull(sentence)

hardware_robotikentwicklung <- f_skills_tdf |>
    filter(hardware_robotikentwicklung==1) |> pull(sentence)

quantencomputing <- f_skills_tdf |>
    filter(quantencomputing==1) |> pull(sentence)


db_hex <- db_hex |> 
  mutate(fs_lable = case_when(
    map_lgl(titel, ~ any(str_detect(.x, fixed(data_analytics_ki)))) ~ "Data Analytics",
    map_lgl(titel, ~ any(str_detect(.x, fixed(softwareentwicklung)))) ~ "Softwareentwicklung",
    map_lgl(titel, ~ any(str_detect(.x, fixed(nutzerzentriertes_design)))) ~ "Nutzerzentriertes Design",
    map_lgl(titel, ~ any(str_detect(.x, fixed(it_architektur)))) ~ "IT-Architektur",
    map_lgl(titel, ~ any(str_detect(.x, fixed(hardware_robotikentwicklung)))) ~ "Hardware/Robotikentwicklung",
    map_lgl(titel, ~ any(str_detect(.x, fixed(quantencomputing)))) ~ "Quantencomputing",
    TRUE ~ NA_character_
  ))

table(db_hex$fs_lable)
colnames(db_hex)


fs_test_data <- db_hex |> 
    filter(!is.na(fs_lable)) |> 
    # rename(text = titel, label_text = fs_lable)  |> 
    # mutate(lable = as.numeric(as.factor(label_text))) |> 
    select(titel, kursbeschreibung, fs_lable) |> 
    distinct(titel, .keep_all = TRUE)

# text	label	label_text

fs_test_data <- fs_test_data %>% 
  mutate(text = case_when(
    !is.na(kursbeschreibung) ~ kursbeschreibung,
    TRUE ~ titel                                                                   
  )) %>% 
  rename(label_text=fs_lable) %>%
  mutate(label = as.numeric(factor(label_text))) %>% 
  select(text,label,label_text)

 

write.xlsx(fs_test_data, "data/fs_test_data.xlsx")
# Datenexport ------------------------------------------------------
table(fs_test_data$fs_lable)/nrow(fs_test_data)*100

