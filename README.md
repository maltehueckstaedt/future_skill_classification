# Future Skills Klassifikator

## Hintergrund

Franziska Weber hat einen [Future Skills-Classifier](http://srv-data01:30080/hex/future_skill_classification) trainiert, der per [API](http://srv-data01:30080/hex/future_skill_classifier_api) abrufbar ist. Leider können einzelne Dependencies nicht aufgelöst, verschiedene Klassen und Pakete nicht installiert werden, weshalb der Classifier nicht mehr zum laufen gebracht werden konnte. Die entsprechenden Codes des Klassifikators sind ebenfalls (für Python-Novizen 😑) nicht ohne Weiteres nachvollziehbar. Da die Vorarbeit von Franziska Weber also wenig zugänglich ist, werden aus Effizienzgründen eigene Klassifikatoren trainiert, die allerdings grosso modo ihrer Vorgehensweise (SetFit-Approach) und ihren Tunings folgt. Die Klassifikatoren sollen jedoch dieses Mal in der Programmierung und Funktionsweise auch für Außenstehende leicht nachvollziehbar, und über [huggingface.co](https://huggingface.co/) einfach abrufbar sein, um eine einfache Nutzung und vermutlich irgendwann anfallendes debugging 😊 auch für Nicht-Informatiker\*innen zu gewährleisten.

Dieser Maßgabe entsprechen werden die Codes der Klassifikatoren detalliert kommentiert und (für R-User, Soziolog\*innen und Psycholog\*innen) möglichst intuitiv programmiert.

##  SetFit: Few-Shot Classification für Future Skills

Im Anschluss an die Vorarbeit von Franziska Weber bleibt es Ziel, mit dem auf [`BERT`](https://medium.com/@shaikhrayyan123/a-comprehensive-guide-to-understanding-bert-from-beginners-to-advanced-2379699e2b51) basierenden [`SetFit`](https://huggingface.co/blog/setfit) einen vortrainierten Sentence Transformer *feinzutunen*, der Future Skills aus **Kurstiteln**, **Beschreibungen** oder **Lernzielen** vorhersagen kann:

SetFit verwendet einen vorab trainierten Sentence Transformer wie Sentence-BERT. Das Modell ist dafür zuständig, kontextuelle Text-Embeddings zu generieren.


Anstatt das Modell von Grund auf zu trainieren, nutzen wir mit `SetFit` ein vortrainiertes Sprachmodell, das bereits grundlegende Embeddings aufweist. Dieses Modell wird dann auf unseren spezifischen Anwendungsfall (FS Skills) feinabgestimmt. 

Da Trainings- und Testdaten in jedem Fall in den Anwendungsfall des FS-Frameworks knapp sind, ist das Few-Shot-Learning eine vielversprechende Alternative zu klassischen Transformern. SetFit, ein Beispiel für Few-Shot-Learning, kann mit nur wenigen Beispielen pro Klasse ähnliche Ergebnisse erzielen wie traditionelles Finetuning mit vielen Daten.

## Literatur

Eine kurze Einführung in SetFit bieten Tunstall et al. 2022 [^2]. Für weitere Details bzgl. Transformermodelle siehe Vaswani et al. 2017.[^3]. Für eine Überblick über BERT siehe Reimers & Gurevych 2019[^4]. Für die Nutzung bereits Trainierter Transformer siehe Chollet 2021 [^5]

## Daten

### Testdaten

Um die Qualität der Classifier zu bestimmen, müssen geeignete Testdaten erzeugt werden. Folgende Punkte sollten berücksichtigt werden:

1. Sampling und Labeling: Zunächst muss eine repräsentative Stichprobe der Kursbeschreibungen gezogen werden, die manuell gelabelt wird. Für den Start könnten 500–1.000 Beispiele als eine ausreichend große Stichprobe dienen, insbesondere, wenn du viele Skills klassifizierst und sicherstellen möchtest, dass jede Skill ausreichend abgedeckt wird. Pro Skill sollten 50-100 möglichst variationsreiche Daten gelabelt vorliegen [^1].
2. Balance und Coverage: Sollten Skills in der GG ggf. seltener vorkommen, sollte diese dennoch in den Testdaten hinreichend häufig vertreten sein, um verzerrungen bei der Klassifikation zu vermeiden. Rule of Thumb: 50-100 Fälle pro Skill. 
3. Testgröße in Relation zur Modellgröße: Die Testdaten sollten 20% der Gesamtdaten ausmachen. 
4. Iteratives Labeling und Evaluierung: Es sollte iterativ vorgegangen werden: Begonnen wird mit einem kleineren, manuell gelabelten Testdatensatz, um den Klassifikator initial zu evaluieren. Sollte sich herausstellen, dass die Performance in bestimmten Bereichen stark schwankt oder die Varianz hoch ist, kann durch das Labeln weiterer Daten gezielt nachgesteuert werden. Auf diese Weise lässt sich das Modell schrittweise verbessern und validieren, um eine stabilere und genauere Klassifikation zu erreichen. 

# Results

https://huggingface.co/Chernoffface/fs-setfit-model


# ToDos

- [ ]  Accuracy durch Satzsplitting verbessern mit `SpaCy` 
- [ ]  Klassifikator für multi-class optimieren: https://huggingface.co/docs/setfit/how_to/multilabel
- [ ]  Enviorment erzeugen für das konstanthalten der Arbeitsumgebung

 


[^1]: Figueroa, R.L., Zeng-Treitler, Q., Kandula, S. et al. (2012). Predicting sample size required for classification performance. BMC Med Inform Decis Mak 12, 8 (2012). https://doi.org/10.1186/1472-6947-12-8
[^2]: Tunstall, L., Reimers, N., Jo, U. E. S., Bates, L., Korat, D., Wasserblat, M., & Pereg, O. (2022). Efficient few-shot learning without prompts. arXiv preprint arXiv:2209.11055.
[^3]: Vaswani, A. (2017). Attention is all you need. Advances in Neural Information Processing Systems.
[^4]: Devlin, J. (2018). Bert: Pre-training of deep bidirectional transformers for language understanding. arXiv preprint arXiv:1810.04805.
[^5]: Pfeiffer, J., Kamath, A., Rücklé, A., Cho, K., & Gurevych, I. (2020). Adapterfusion: Non-destructive task composition for transfer learning. arXiv preprint arXiv:2005.00247.
