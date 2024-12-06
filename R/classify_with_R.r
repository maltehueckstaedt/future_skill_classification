library(reticulate)

# Setze Pfad zu miniconda
Sys.setenv(RETICULATE_MINICONDA_PATH = "C:/Users/Hueck/miniconda3")
# Aktiviere Enviorment
use_condaenv("classify_fs", required = TRUE)

# Python-Funktion definieren
process_and_predict <- py_run_string("
from tqdm import tqdm
import pandas as pd
from setfit import SetFitModel
import warnings

warnings.filterwarnings('ignore')

def process_and_predict(df, model_path, fs_labels):
    tqdm.pandas()

    # Index in Strings umwandeln (um FutureWarning zu vermeiden)
    df.index = df.index.astype(str)

    # 1. NAs durch leere Strings ersetzen
    for col in ['titel', 'kursbeschreibung', 'lernziele']:
        df[col] = df[col].fillna('')

    # 2. Satz erstellen
    df['sentence'] = df.apply(
        lambda row: row['titel']
                    + (': ' + row['kursbeschreibung'] if row['kursbeschreibung'] else '')
                    + ('. Lernziele: ' + row['lernziele'] if row['lernziele'] else ''),
        axis=1
    )

    # 3. Modell laden
    model = SetFitModel.from_pretrained(model_path)

    # 4. Prädiktion durchführen
    def predict_course_description(description):
        if isinstance(description, str):
            preds = model(description)
            return preds
        return []

    df['Pred_Tensor'] = df['sentence'].progress_apply(predict_course_description)

    # 5. Tensor in Labels umwandeln
    def convert_tensor_to_labels(tensor):
        if isinstance(tensor, float) and pd.isna(tensor):
            return None
        if len(tensor) != len(fs_labels):
            print(f'Warnung: Unerwartete Tensorgröße {len(tensor)}, erwartet: {len(fs_labels)}')
            return 'Fehlerhafte Vorhersage'
        selected_labels = [fs_labels[i] for i, val in enumerate(tensor) if val == 1]
        return ', '.join(selected_labels) if selected_labels else None

    df['FS_Skill'] = df['Pred_Tensor'].progress_apply(lambda x: convert_tensor_to_labels(x))

    # 6. Dummy-Variablen für FS erstellen
    for label in fs_labels:
        df[label] = df['FS_Skill'].apply(lambda x: 1 if isinstance(x, str) and label in x else 0)

    # 7. Entferne die Hilfsspalten
    df = df.drop(columns=['sentence', 'Pred_Tensor', 'FS_Skill'])

    return df
")$process_and_predict


db_hex <- readRDS("data/classify_hex_db_test_df.rds")

# Future Skills Labels
fs_labels <- c("Data Analytics & KI", "Softwareentwicklung", "Nutzerzentriertes Design", 
               "IT-Architektur", "Hardware/Robotikentwicklung", "Quantencomputing")

# Python DataFrame aus R-Daten erstellen
py$pd <- import("pandas")
db_hex_py <- py$pd$DataFrame(db_hex)

# Modellpfad definieren
model_path <- "Chernoffface/fs-setfit-multilable-model"

# Funktion aufrufen
db_hex <- process_and_predict(db_hex_py, model_path, fs_labels)