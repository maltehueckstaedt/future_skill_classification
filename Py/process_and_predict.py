# %%
import pyreadr
import pandas as pd
# RDS-Datei laden
df = pyreadr.read_r( "data/classify_hex_db_test_df.rds")

# Extrahieren des ersten Objekts aus dem OrderedDict in Pandas-df
df = next(iter(result.values()))  # Annahme: Das erste Objekt ist ein DataFrame

df.columns

# %%
import pandas as pd
from tqdm import tqdm
from setfit import SetFitModel  # Stelle sicher, dass das benötigte Modul installiert ist

def process_and_predict(df, model_path, fs_labels):
    """
    Diese Funktion führt die Datenvorbereitung, Prädiktion und Label-Konvertierung aus und erstellt Dummy-Variablen.
    
    Args:
        df (pd.DataFrame): Eingabedaten mit den Spalten 'titel', 'kursbeschreibung', 'lernziele'.
        model_path (str): Pfad zum vortrainierten Modell.
        fs_labels (list): Liste der Future Skills Labels.
    
    Returns:
        pd.DataFrame: DataFrame mit den Spalten 'sentence', 'Pred_Tensor', 'FS_Skill' und Dummy-Variablen.
    """
    tqdm.pandas()

    # 1. Shuffle der Daten
    df_sample = df.sample(frac=1)

    # 2. NAs durch leere Strings ersetzen
    for col in ['titel', 'kursbeschreibung', 'lernziele']:
        df_sample[col] = df_sample[col].fillna('')

    # 3. Satz erstellen
    df_sample['sentence'] = df_sample.apply(
        lambda row: row['titel']
                    + (": " + row['kursbeschreibung'] if row['kursbeschreibung'] else "")
                    + (". Lernziele: " + row['lernziele'] if row['lernziele'] else ""),
        axis=1
    )

    # 4. Modell laden
    model = SetFitModel.from_pretrained(model_path)

    # 5. Prädiktion durchführen
    def predict_course_description(description):
        if isinstance(description, str):
            preds = model(description)
            return preds
        return []

    df_sample["Pred_Tensor"] = df_sample["sentence"].progress_apply(predict_course_description)

    # 6. Tensor in Labels umwandeln
    def convert_tensor_to_labels(tensor):
        if isinstance(tensor, float) and pd.isna(tensor):
            return None
        if len(tensor) != len(fs_labels):
            print(f"Warnung: Unerwartete Tensorgröße {len(tensor)}, erwartet: {len(fs_labels)}")
            return 'Fehlerhafte Vorhersage'
        selected_labels = [fs_labels[i] for i, val in enumerate(tensor) if val == 1]
        return ', '.join(selected_labels) if selected_labels else None

    df_sample["FS_Skill"] = df_sample["Pred_Tensor"].progress_apply(lambda x: convert_tensor_to_labels(x))

    # 7. Dummy-Variablen für FS erstellen
    for label in fs_labels:
        df_sample[label] = df_sample["FS_Skill"].apply(lambda x: 1 if isinstance(x, str) and label in x else 0)

    # 8. Entferne die Hilfsspalten
    df_sample = df_sample.drop(columns=['sentence', 'Pred_Tensor', 'FS_Skill'])

    return df_sample



# Definiere Labels: 
fs_labels = ['Data Analytics & KI', 'Softwareentwicklung', 'Nutzerzentriertes Design', 
             'IT-Architektur', 'Hardware/Robotikentwicklung', 'Quantencomputing']


# %%
df_processed = process_and_predict(df, "models", fs_labels)

# %%
df_processed.columns