# Future Skill Classification

This repo allows to train a classification model that can identify future skills taught in courses from the HEX data. It uses some artificially created and some manually coded examples as training data. The model is a multilingual SetFit few shot model. 

## Data 

### Level of Analysis
The data will be analyzed on the sentence level because SetFit is pretrained and works on this level. Thus, the text from each variable needs to be split into sentences. In this script, we will use SpaCy for the sentence splitting since it is easy to use and has efficient models for multiple languages (including a multi-language model). For well-written and formatted text, the sentence splitting should work well, for anything else there might be some issues. However, even if the sentences are not split perfectly, this is not necessarily an issue for the analysis as long as they make sense in some way. The skills will be aggregated to the course level anyway. The TextUtils and SentenceData class for preprocessing originates from the [sv_py_utils package](http://srv-data01:30080/fwe/svutils).

### Example data
Few Shot classification can work with only eight examples per class. Thus, for each skill, we created eight sentences describing that skill. The approach was to use a (German) sentence template to have a full sentence. The template is: "Die Veranstaltung behandelt das Thema X". The substitutions for X are created in the following way:
1. Use the name of the skill. If there are two or more parts, split them.
2. Use the descriptions of the skill in short parts.
3. Perform a google search for synonyms and core content of each skill.
4. Have Felix Süßenbach check each skill and adapt the description since he is the expert.

These synthetical skill descriptions will be used as training data. This has the advantage that it is comparatively easy to have anough examples per class and that the content of the class (i.e., skill) is captured entirely. The disadvantage may be that this synthetic template is too different from the real wording of the HEX data. Alternative approaches would be to manually code a few courses. However, this may result in imbalanced training data or a lot of manual coding work since some skills are likely to be mentioned very few times only and it might not capture all aspects of the skill. 

The training data has to contain the columns "label" (a numerical zero-indexed id for each skill) and "text", the actual sentence. 

We have eight example sentences per skill, therefore, each sentence has a single skill label. However, in practice, a sentence might contain multiple skill labels later. Thus we need to transform the label to a one-hot encoded vector to have the correct format for multi-label classification. Here is an example:
- our training data contains the following skills and their corresponding labels: 0 - Digital Literacy, 1 -  Digitale Kollaborationen, 2 - Digiatl Ethics, ...
- Example sentences and their labels could be: 
    - "Die Veranstaltung beschäftigt sich mit dem Thema Digital Literacy" - 0  
    - "Die Veranstaltung beschäftigt sich mit dem Thema Digiatl Ethics" - 2
- However, a real description from the HEX data could be: "Die Studierenden erlernen Skills auf den Gebieten Digital Literacy und Digital Ethics" Since this course teaches two future skills, the model should identify two future skills and not only one. Accordingly, there could be a sentence like:  "Im Kurs beschäftigen wir uns mit Kräuterkunde" - a sentence without any of the future skills. So each sentence can contain any number of skills from none to all 21. 
- Multi-label classification converts the single-number label into a one-hot vector. Each element of the vector can be either 0 or 1 and corresponds to one skill. The index of each skill is the original label value. Thus, once a sentence contains the skill with the label i, the vector at position i will be 1. If the sentence does not contain the label i, the vector at position i will be 0. 
- Going back to our examples, this would be the multi-label labels: 
    - "Die Studierenden erlernen Skills auf den Gebieten Digital Literacy und Digital Ethics" - [1, 0, 1, ...]  
    - "Im Kurs beschäftigen wir uns mit Kräuterkunde" - [0, 0, 0, ...]


## Few-Shot Classification with SetFit
Our goal is to finetune a deep learning network that can predict all the future skills mentioned in a course title, description, or learning goals.These numerical models require numerical input, so the text has to be converted first. First, each token (usually a wordpiece) is mapped to a unique id. This vector will then be encoded, i.e., transformed in the network (or more specifically: in the encoder part of the network) to create embedding from this vector that represents the semantic content of the text in a numerical feature space. The model can learn which words might be synonyms and thus closer in the feature space or even which two words are homonyms, i.e., the same, but have a different meaning and should be further apart in the feature space (i.e., "close" as in closing a door and "close" as in standing close to a person). What is close and what is not depends on the training task, the loss function, ... Note: You can simply give the text as is to the trainer. One of the huge advantages of these language models is their ability to understand context and relations of words in text inputs, so you don't need to lemmatize or stem anything. The tokenization mentioned earlier will also be done under the hood. For complex use cases, you could overwrite some functions (e.g. of the trainer class), but this is probably not necessary for our use cases.

However, training such a network typically requires huge amounts of training data. This can be limited by using a pretrained language model which already has been trained on huge amopunts of data and already provides a basic understanding of language, i.e., generates meaningful embeddings of a text. This model can be used as a base and has to be adapted to the individual use case, which usually requires finetuning the language model and training a decoder. Finetuning means adapting the weights of the language model with respect to the individual use case, e.g., the domain of course descriptions and the focus on future skills since the language used here might not be exactly the same as in the data the model was originally trained on. Training a decoder means training additional layers to perform the final task. In our case, when we have a semantically meaningful embedding, the decoder will transform this embedding vector to a classification output telling us which future skills are found in this vector. Finetuning instead of training from scratch massively reduces the amount of training data that is required to a few hundred examples per class.

Traditional finetuning for a classification task teaches the model what the content of a class is. It takes the training sentence and adapts the model's weights such that as many sentences as possible will be correctly classified. As mentioned, this still requires a few hundred examples per class. Since training data often is scarce, methods like few shot learning are on the rise. Few shot learning aims to not teach the model how a class looks, but which examples are similar and which are not, helping the model to learn the class boundaries even without a precise understanding of the meaning of a class. SetFit is an example for a few shot learning model. It enlarges its training data by creating data triplets from only a few examples of a sentence, another sentence from the same class and another sentence from a different class. With only ~10 examples per class, it has demonstrated performances comparable to the regular finetuning approach with hundreds of training examples. Therefore, it is definitely worth a try for our future skill classification!For more information, see [this blog post](https://huggingface.co/blog/setfit) by (some of) the setfit authors or the original paper.

### Papers to Read
To understand the methodology used here, these are the main papers to pay attention (lol) to (in this order).
1. [Vaswani et al. 2017, Attention Is All You Need](https://proceedings.neurips.cc/paper_files/paper/2017/file/3f5ee243547dee91fbd053c1c4a845aa-Paper.pdf)
2. [Devlin et al., 2019, BERT](https://aclanthology.org/N19-1423.pdf)
3. [Reimers and Gurevych, 2019, Sentence-BERT](https://aclanthology.org/D19-1410.pdf)
4. [Tunstall et al., 2022, Efficient Few-Shot Learning Without Prompts](https://arxiv.org/pdf/2209.11055.pdf)

## Results
The result of this repository is a finetuned classification model for future skills that will be saved in the same folder. [Another repo](http://srv-data01:30080/hex/future_skill_classifier_api) creates an API that can be used for the prediction of new sentences . 

## Running the Code
You can run the training both locally and on the development server (srv-data02). All examples assume you are working from the future_skill_classification folder since the examples include relative paths.

### Local Training
Set the mode parameter in src/main.py (line 8, e.g. using a text editor) to use the proper file structure, proxies, and database access parameters.
```
mode = "local"
```
#### Setting up a conda virtual environment

You must have python installed on your computer to execute the code locally, it is also strongly advised to have Virtual Studio Code installed. Installation works with [anaconda](https://docs.anaconda.com/free/anaconda/install/windows/), so install this too (no IT needed, wow)!

You must have CNTLM installed and running to use http://localhost:3128 as proxy. See [here](https://sourceforge.net/projects/cntlm/) and [here](https://gist.github.com/goude/edecda33699fcad5d66e) or check the readme of svDev.

Then, put a file names `.condarc` in `C:/users/<YOUR_KUERZEL>` with the following content: 
```
proxy_servers:
    http: http://localhost:3128
    https: http://localhost:3128
```

It's best to run the code in a virtual environment. You can use [conda](https://docs.anaconda.com/free/anaconda/install/windows/) to create your environment and it will work for everything you do for HEX in python. Alternatively, you can also use [venv](https://docs.python.org/3/library/venv.html) and pip, but the requirements file used here works for conda envs only, plus there are issues installing HDBSCAN for python with pip. 

Open an **anaconda** (!) command line in this directory here and run the following code, which will create a virtual environment and install all required packages into it:
```
# create environment
conda env create --name hexenv -f=hexenv.yml

# activate the environment
conda activate hexenv

# deactivate the environment
conda deactivate
```
While the environment is activated, you can install stuff from the anaconda prompt:
```
# install a package with pip
pip install --proxy "http://localhost:3128" pandas
# install a package with conda
conda install anaconda::pandas
# install a language model
python -m spacy download xx_sent_ud_sm
```

#### Running the Code from Virtual Studio Code
You need to point the interpreter in virtual studio code to your python executable in the conda environment before you can run the code by clickling the run (or debug) button or STRG+P and then select hexenv as the interpreter. If you don't do this or use a different interpreter, you will not have the packages installed that are required.

If the code is in a jupyter notebook, you must install the kernel from the **activated** environment you created:
```
conda install -c anaconda ipykernel
python -m ipykernel install --user --name=hexenv
```
Now you can select hexenv as the kernel on the upper right.
#### Running the Code from the Command Line
The code can be executed from the activated virtualenv and from the main folder of future_skill_classification like this:
```
python ./src/main.py
```


### Training on the Development Server

On the server, the code runs in a docker container. 
To set up the container, push all your code to the server. There might also be a working version under /home/hex. 
To copy the entire future_skill_classification directory to the server, use one of the following versions (careful, this will replace existing directories):
```
# in your personal directory
scp -r . <user>@srv-data02:.
# in the shared hex directory (you need extra permissions)
scp -r .<user>@srv-data02:../hex
```

Set the mode parameter in src/main.py (line 8) to use the proper file structure, proxies, and database access parameters.
```
mode = "server"
```

To build the image and start the container (which will eventually execute src/main.py), run the following two commands:
```
docker build -t hex/ml_analysis:v1.0 --build-arg HTTP_PROXY_AUTH=  --progress=plain .
docker compose up
```
If you want to check the status of the container, run the following command to get the container id:
```
docker ps -a
```
If the container is still running, you can use the following code:
```
docker attach <container-id>
```
If the container exited, you can check the logs in the logs folder or using the following statement:
```
docker logs <container-id>
```

If everything went fine, you can download the results from a command line in the local future_skill_classification folder (not on the server) using the following command (careful, this will replace the entire local results folder, make sure you saved older results which are not in the directory on the server somewhere else as well):
```
scp -r <user>@srv-data02:future_skill_classification/results .
```

## Training Parameters
Beside the mode parameter, you can choose the (name of) the sentence transformer base model, the number of iterations to use in the setfit training example generation (n_iterations, default=20) and the number of epochs to train the model (n_epochs, default=2). Change these settings in `src/main.py`.

