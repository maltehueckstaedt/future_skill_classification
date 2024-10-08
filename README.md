# Testdaten

Um die Qualität der Klassifkator zu bestimmen, müssen geeignete Testdaten erzeugt werden.

Folgende Punkte sollten berücksichtigt werden:

1. Sampling und Labeling: Zunächst muss eine repräsentative Stichprobe der Kursbeschreibungen gezogen werden, die manuell gelabelt wird. Für den Start könnten 500–1.000 Beispiele als eine ausreichend große Stichprobe dienen, insbesondere, wenn du viele Skills klassifizierst und sicherstellen möchtest, dass jede Skill ausreichend abgedeckt wird. Pro Skill sollten 50-100 möglichst variationsreiche Daten gelabelt vorliegen [^1].
2. Balance und Coverage: Sollten Skills in der GG ggf. seltener vorkommen, sollte diese dennoch in den Testdaten hinreichend häufig vertreten sein, um verzerrungen bei der Klassifikation zu vermeiden. Rule of Thumb: 50-100 Fälle pro Skill. 
3. Testgröße in Relation zur Modellgröße: Die Testdaten sollten 20% der Gesamtdaten ausmachen. 
4. Iteratives Labeling und Evaluierung: Es sollte iterativ vorgegangen werden: Begonnen wird mit einem kleineren, manuell gelabelten Testdatensatz, um den Klassifikator initial zu evaluieren. Sollte sich herausstellen, dass die Performance in bestimmten Bereichen stark schwankt oder die Varianz hoch ist, kann durch das Labeln weiterer Daten gezielt nachgesteuert werden. Auf diese Weise lässt sich das Modell schrittweise verbessern und validieren, um eine stabilere und genauere Klassifikation zu erreichen. 

[^1]: Figueroa, R.L., Zeng-Treitler, Q., Kandula, S. et al. Predicting sample size required for classification performance. BMC Med Inform Decis Mak 12, 8 (2012). https://doi.org/10.1186/1472-6947-12-8


# Hugging Face Modells

## Few Shot Classifier for Future Skills

https://huggingface.co/Chernoffface/fs-setfit-model


# ToDo

- [ ]  Klassifikator für multi-class optimieren: https://huggingface.co/docs/setfit/how_to/multilabel
