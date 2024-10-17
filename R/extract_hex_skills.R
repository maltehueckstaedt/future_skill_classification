library(readr)
library(tidyverse)
df <- read_csv("GitHub/future_skill_classification/output_large.csv")

colnames(df)

df <- df %>%
  mutate(FS_Skill = na_if(FS_Skill, "Keine"))

table(df$jahr)
length(unique(df$faechergruppe))
table(df$faechergruppe)

df <- df %>%
  mutate(
    mint_faechergruppe = case_when(
      grepl("Mathematik|Naturwissenschaften", faechergruppe) ~ "MINT",  # Priorität 1: Mathe, Naturwissenschaften
      grepl("Ingenieurwissenschaften", faechergruppe) ~ "MINT",  # Priorität 2: Ingenieurwissenschaften
      grepl("Humanmedizin|Gesundheitswissenschaften", faechergruppe) ~ "nicht MINT",  # Priorität 3: Humanmedizin
      grepl("Agrar-, Forst- und Ernährungswissenschaften|Veterinärmedizin", faechergruppe) ~ "nicht MINT",  # Priorität 4: Agrarwissenschaften
      grepl("Geisteswissenschaften", faechergruppe) ~ "nicht MINT",  # Priorität 5: Geisteswissenschaften
      grepl("Kunst|Kunstwissenschaft", faechergruppe) ~ "nicht MINT",  # Priorität 6: Kunst
      grepl("Rechts-, Wirtschafts- und Sozialwissenschaften", faechergruppe) ~ "nicht MINT",  # Priorität 7: Rechts- und Wirtschaftswissenschaften
      grepl("Sport", faechergruppe) ~ "nicht MINT",  # Priorität 8: Sport
      TRUE ~ NA_character_  # Unklare Fälle als NA
    )
  ) %>% filter(!is.na(mint_faechergruppe))

library(ggplot2)

df %>%
  mutate(jahr_num = as.numeric(jahr)) %>% 
  filter(jahr_num > 2016 & jahr_num < 2023) %>% 
  group_by(jahr_num, mint_faechergruppe) %>%
  summarise(
    count_non_na = sum(!is.na(FS_Skill)),  # Anzahl der Kurse mit FS_Skill
    total_count = n()  # Gesamtzahl der Kurse pro Gruppe
  ) %>%
  mutate(anteil_fs_skill = count_non_na / total_count*100) %>%  # Anteil berechnen
  ggplot(aes(x = jahr_num, y = anteil_fs_skill, color = mint_faechergruppe, group = mint_faechergruppe)) +
  geom_line() +
  geom_point() +  # Optional: Punkte an den Datenpunkten anzeigen
  labs(title = "Anteil der Kurse mit FS_Skill pro Jahr und mint_faechergruppe",
       x = "Jahr", 
       y = "Anteil der Kurse mit FS_Skill",
       color = "Fächergruppe") +
  theme_minimal()
