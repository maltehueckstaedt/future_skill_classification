library(dplyr)
library(stringr)

# Erstelle eine Funktion, um Skills zu erkennen
detect_skills <- function(title, description) {
  skills <- list(
    "Data Analytics & KI" = str_detect(title, regex("Data Analytics|KI|Machine Learning|Big Data|Datenanalyse|Künstliche Intelligenz", ignore_case = TRUE)) |
      str_detect(description, regex("Data Analytics|KI|Machine Learning|Big Data|Datenanalyse|Künstliche Intelligenz|Modellierung|Algorithmen|Vorhersagemodelle", ignore_case = TRUE)),
      
    "Softwareentwicklung" = str_detect(title, regex("Softwareentwicklung|Frontend|Backend|IoT|Programmierung|C#|Java|Python|App-Entwicklung|embedded", ignore_case = TRUE)) |
      str_detect(description, regex("Softwareentwicklung|Frontend|Backend|IoT|Programmierung|C#|Java|Python|App-Entwicklung|embedded|API|Datenbanken|Architektur", ignore_case = TRUE)),
      
    "Nutzerzentriertes Design" = str_detect(title, regex("UX|User Experience|Usability|Interaktionsdesign|User Interface|UI", ignore_case = TRUE)) |
      str_detect(description, regex("UX|User Experience|Usability|Interaktionsdesign|User Interface|UI|Nutzerfeedback|Prototyping|Design Thinking", ignore_case = TRUE)),
      
    "IT-Architektur" = str_detect(title, regex("IT-Architektur|Cloud|Blockchain|Netzwerk|Systemintegration|Sicherheit|Infrastruktur", ignore_case = TRUE)) |
      str_detect(description, regex("IT-Architektur|Cloud|Blockchain|Netzwerk|Systemintegration|Sicherheit|Infrastruktur|Server|Datenbankarchitektur", ignore_case = TRUE)),
      
    "Hardware-/Robotikentwicklung" = str_detect(title, regex("Hardware|Robotik|IoT|Elektronik|Mikrocontroller|Mechatronik", ignore_case = TRUE)) |
      str_detect(description, regex("Hardware|Robotik|IoT|Elektronik|Mikrocontroller|Mechatronik|Sensoren|Aktoren|Automatisierung", ignore_case = TRUE)),
      
    "Quantencomputing" = str_detect(title, regex("Quantencomputing|Quantum|Quantencomputer|Qubit", ignore_case = TRUE)) |
      str_detect(description, regex("Quantencomputing|Quantum|Quantencomputer|Qubit|Superposition|Verschränkung|Quantum Algorithmen", ignore_case = TRUE))
  )
  
  # Filtere die erkannte Skills
  return(names(skills)[unlist(skills)])
}

# Beispiel-DataFrame
df <- data.frame(
  title = c("Data Analytics & Softwareentwicklung", "Design und UX für IoT-Anwendungen", "Quantum Computing Basics"),
  description = c(
    "Entwicklung von KI-gestützten Systemen zur Datenanalyse und Softwareentwicklung",
    "Benutzerfreundlichkeit und Interaktionsdesign in IoT-Systemen",
    "Einführung in die Quantenalgorithmen und ihre Anwendungsbereiche"
  )
)

# Anwenden der Funktion auf den DataFrame
df <- df %>%
  rowwise() %>%
  mutate(skills = list(detect_skills(title, description)))

df
