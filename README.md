
embeddingswsd
=============

The files in this repository accompany 
an evaluation of [spaCy](https://spacy.io) 
/ [scispaCy](https://allenai.github.io/scispacy) 
word vectors (embeddings) 
for biomedical word sense disambiguation. 
Assessments compare the performance of linear 
classifiers trained in manually labeled homonyms 
in [Pubmed](https://pubmed.ncbi.nlm.nih.gov/) abstracts
as well as in a subset of the [MSH WSD](https://lhncbc.nlm.nih.gov/ii/areas/WSD/collaboration.html) dataset. 

![thumbnail](https://user-images.githubusercontent.com/20538437/151448595-71390648-9f25-4ccc-835d-efa2f57dfd15.png)


## Contents
 * `annotations.csv`: annotations that disambiguate homonyms in manually labeled abstracts
 * `analyzevectors/`: [R scripts](https://www.r-project.org/) to train and evaluate classifiers in abstract-specific vector sets
 * `outputs/`: graphical and tabular results in .pdf and .csv format
 * `preparevectors/`: [Python scripts](https://www.python.org/) that compute word vectors from abstracts
 * `vectorsets/`: abstract-specific vector sets for different language models

## Setup and installation
 * [lxml](https://lxml.de/) for parsing Pubmed exports
 * [spaCy](https://spacy.io) for NLP functions
 * [en_core_web_md](https://github.com/explosion/spacy-models/releases/tag/en_core_web_md-3.0.0): general english language model with 20k vectors (300 dimensions)
 * [en_core_sci_lg](https://allenai.github.io/scispacy/): english language model with 600k vectors (200 dimensions) trained with biomedical texts

Tested with [Python 3.8](https://python.org/): 
```
pip3 install lxml spacy
pip3 install https://github.com/explosion/spacy-models/releases/download/en_core_web_md-3.0.0/en_core_web_md-3.0.0.tar.gz
pip3 install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.4.0/en_core_sci_lg-0.4.0.tar.gz
```

