# Future Skills Klassifikator

## Hintergrund

Der Future Skill Classifier soll — nach letztem Stand — sechs technologische Kompetenzen anhand von Kurstiteln, Kursbeschreibungen und Lernzielen klassifizieren.

🚀 Franziska Weber hat einen [Future Skills-Classifier](http://srv-data01:30080/hex/future_skill_classification) trainiert, der per [API](http://srv-data01:30080/hex/future_skill_classifier_api) abrufbar ist. Leider können einzelne Dependencies nicht aufgelöst werden, verschiedene Klassen und Pakete nicht installiert werden, weshalb der Classifier nicht mehr zum Laufen gebracht werden konnte. Die entsprechenden Codes des Klassifikators sind ebenfalls (für Python-Novizen 😑) nicht ohne Weiteres nachvollziehbar.Da die wertvolle Vorarbeit von Franziska Weber also nicht mehr recht zugänglich ist, wird aus Effizienzgründen ein eigener Klassifikator trainiert, der allerdings – grosso modo – ihrer Vorgehensweise (SetFit-Approach) und ihren Parametereinstellungen folgt. Der Klassifikator soll jedoch dieses Mal in der Programmierung und Funktionsweise auch für Nicht-Informatiker\*innen möglichst leicht nachvollziehbar und über [huggingface.co](https://huggingface.co/) einfach abrufbar sein. Auf diese Weise soll eine möglichst barrierefreie Nutzung und ggf. anfallendes Debugging 🤯 auch für Nicht-Informatiker\*innen einfach und wenig zeitintensiv zu bewerkstelligen sein.

Dieser Maßgabe entsprechend werden die Codes des Klassifikators detailliert kommentiert und möglichst intuitiv programmiert.


##  SetFit: Few-Shot Classification für Future Skills

Im Anschluss an die Vorarbeit von Franziska Weber 🛠️ bleibt es Ziel, mit dem auf [`BERT`](https://medium.com/@shaikhrayyan123/a-comprehensive-guide-to-understanding-bert-from-beginners-to-advanced-2379699e2b51) basierenden [`SetFit`](https://huggingface.co/blog/setfit) 🤖 einen vortrainierten Sentence Transformer 🌐 *feinzutunen*, der Future Skills 📚 aus **Kurstiteln**, **Beschreibungen** oder **Lernzielen** vorhersagen kann. Für eine Übersicht des Vorgehens von Setfit eignen sich *Tunstall et al. 2022* 📖 im speziellen und *Alammar & Grootendorst 2024* 📚 im allgemeinen.

Da Trainings- und Testdaten 🧪 im Fall des FS-Frameworks knapp sind, ist das Few-Shot-Learning 🌟 eine vielversprechende Alternative zu klassischen Transformern. Das durch SetFit spezifizierte Few-Shot-Modell `paraphrase-multilingual-MiniLM-L12-v2`, ist in diesem Zusammenhang in der Lage, mit nur wenigen Beispielen pro Klasse ähnlich gute Ergebnisse zu erzielen wie herkömmliche Modelle, die auf umfangreichen, vollständig annotierten Datensätzen trainiert wurden.

## Daten

### Trainingsdaten

Yannic Hinrichs erzeugte Trainingsdaten, indem er per String-Match in den Kurstiteln und Kursbeschreibungen nach Schlagworten suchte, die auf Future Skills hinweisen. Die so vergebenen Labels wurden händisch korrigiert und in den Trainingsdatensatz aufgenommen. Außerdem wurden Fälle ergänzt, in denen das String-Matching keine Future Skills detektierte: Ein Teil dieser Fälle enthielt keine Kursbeschreibung, der andere enthielt eine Kursbeschreibung. Diese "negativen" Fälle wurden jedoch nicht händisch kontrolliert. Der entsprechende R-Code findet sich [hier](R/Create_Traindata_FS_Classifier_hya.R).

Alternativ liegen weiterhin die Trainingsdaten vor, die Franziska Weber für das Training ihres Classifiers verwendet hat. Diese werden derzeit aufgrund der besseren Klassifizierungsergebnisse des resultierenden Classifiers verwendet. Die Trainingsdaten von Franziska Weber wurden folgendermaßen erzeugt: Für die Few-Shot-Klassifikation wurden synthetische Beispielsätze erstellt, in denen ein einheitliches Satzmuster („Die Veranstaltung behandelt das Thema X“) verwendet wird. Die Beschreibung „X“ basiert auf dem Namen und Synonymen des Skills und wurde (teilweise) vom Felix Süßenbach überprüft. Diese Methode ermöglicht genügend Trainingsdaten pro Klasse zu erzeugen, obwohl sie eventuell von der realen Sprache in den HEX-Daten abweichen könnte. Für einen detaillierten Überblick über das Vorgehen siehe das folgende [README.md](http://srv-data01:30080/hex/future_skill_classification#example-data).

Die Trainingsdaten befinden sich [hier](https://stifterverband.sharepoint.com/sites/Dateiablage/SVDaten/Forms/AllItems.aspx?ct=1730716805420&or=Teams%2DHL&ga=1&LOF=1&id=%2Fsites%2FDateiablage%2FSVDaten%2FAbteilungen%2FPuF%2FHEX%2FAnalyse%2FDaten%2FMaltes%5FFS%5FClassifier%2Fdata&viewid=3315becc%2De761%2D4c82%2D9e01%2D08b652d83ffd) auf dem Sharepoint.


## Environment mit Anaconda

Die Verwendung von Environments sind in Python besonders beim Trainieren eines Classifiers sinnvoll, da sie dabei helfen, Abhängigkeiten zwischen verwendeten Paketen sauber zu verwalten und Konflikte zu vermeiden. Ein Environment isoliert die Bibliotheken, die wir für den Classifier benötigen, und stellt zeitgleich sicher, dass andere Python-Projekte davon unberührt bleiben. Dies verhindert Versionskonflikte und macht es einfacher, Projekte auf anderen Rechnern oder von anderen Mitarbeiter\*innen reproduzierbar zu machen.

Das Conda-Environment für die Erzeugung des Classifiers wird [hier](Gen_Conda_Environment.ipynb) erstellt. Die entsprechende `environment.yaml` befindet sich ebenfalls im Stammverzeichnis des Repositorys.

### Installation des Environments
 
1. Laden und Installieren von Miniconda: https://docs.anaconda.com/miniconda/
2. Das Arbeitsverzeichnis des Repositorys mit dem **Anaconda Prompt** öffenen.
3. Mit `conda env create -f environment.yaml` das Environment erzeugen.
4. Sollte es (z.B. aufgrund des Proxys) zu Fehlermeldungen bei der Installation kommen, können einzelne Pakete auch seperat nach installiert werden: Es muss sichergestellt werden, dass das Enviorment - so es installiert wurde - verwendet wird: Wir geben dafür ebenfalls im  **Anaconda Prompt** `conda info --envs` ein. Das Environment, das aktiv ist, ist mit einem Asterisk gekennzeichnet (`*`). Sollte nicht unser Environment aktiv sein, aktivieren wir es mit: `conda activate fs_skills_classifier_env`. Anschließend installieren wir die gewünschten Pakete mit `conda install <Paketname>` oder `pip install <Paketname>` nach
5. Anschließend sollte das Environment in VS Code bei der Verwendung eines Jupyter-Notebooks (z.B. `Py\notebooks\Use_Tiny_Few_Shot_Multi_Lable_Classifier.ipynb`) auswählbar sein.

# Aufbau des Repos

Das Repo ist folgendermaßen aufgebaut:

```bash
C:.
│   .gitignore
│   environment.yaml
│   Gen_Conda_Environment.ipynb
│   README.md
│
├───data
│       hex_classified_fs_without_lernziele.csv
│       hex_classified_fs_with_lernziele.csv
│       train_data_franziska.xlsx
│
├───Py
│   │
│   └───notebooks
│           gen_plot_datenportal_fs_skills.ipynb
│           Tiny_Few_Shot_Multi_Lable_Classifer.ipynb
│           Use_Tiny_Few_Shot_Multi_Lable_Classifier.ipynb
│
└───R
        Create_Traindata_FS_Classifier_hya.R
        plot_hex_skills.R
```

Im Idealfall muss für die Verwendung des Classifiers lediglich das Notebook `Py\notebooks\Use_Tiny_Few_Shot_Multi_Lable_Classifier.ipynb` verwendet werden. Ein Guide ist in das entsprechende Notebook eingearbeitet. Es kann daher intuitiv und selbsterklärend verwendet werden. Als Datengrundlagen sollen die jeweils aktuellen HEX-Daten gelten.

# Results

Das trainierte Model wurde sowohl lokal, als auch auf dem Hugging-Face-Hub abgelegt. 

Die lokale Version findet sich [hier](). Die Kopie auf Hugging Face kann [hier](https://huggingface.co/Chernoffface/fs-setfit-multilable-model) abgerufen werden. 

Für eine einfache Anwendung kann das Modell wie folgt für die prediction von Future Skills verwendet werden:

```python
from setfit import SetFitModel

# Download from the 🤗 Hub
model = SetFitModel.from_pretrained("Chernoffface/fs-setfit-multilable-model")
# Run inference
preds = model("Grundlagen der Programmierung mit C++")
```

## Ein- und weiterführende Literatur

Ein wunderbar intuitive Einführung in Large Language Models bieten *Alammar & Grootendorst 2024*[^6]. Eine kurze Einführung in `SetFit` bieten *Tunstall et al. 2022* [^2]. Für weiterreichende Details bzgl. Transformermodelle siehe *Vaswani et al. 2017*.[^3]. Für eine Überblick über BERT siehe *Reimers & Gurevych 2019*[^4]. Für die Nutzung bereits trainierter Transformer siehe *Chollet 2021* [^5]

## Quellen

[^1]: Figueroa, R.L., Zeng-Treitler, Q., Kandula, S. et al. (2012). Predicting sample size required for classification performance. BMC Med Inform Decis Mak 12, 8 (2012). https://doi.org/10.1186/1472-6947-12-8
[^2]: Tunstall, L., Reimers, N., Jo, U. E. S., Bates, L., Korat, D., Wasserblat, M., & Pereg, O. (2022). Efficient few-shot learning without prompts. arXiv preprint arXiv:2209.11055.
[^3]: Vaswani, A. (2017). Attention is all you need. Advances in Neural Information Processing Systems.
[^4]: Devlin, J. (2018). Bert: Pre-training of deep bidirectional transformers for language understanding. arXiv preprint arXiv:1810.04805.
[^5]: Pfeiffer, J., Kamath, A., Rücklé, A., Cho, K., & Gurevych, I. (2020). Adapterfusion: Non-destructive task composition for transfer learning. arXiv preprint arXiv:2005.00247.
[^6]: Alammar, J., & Grootendorst, M. (2024). Hands-On Large Language Models. " O'Reilly Media, Inc.".
