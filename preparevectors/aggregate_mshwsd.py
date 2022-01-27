#!/usr/bin/env python3

"""
Aggregate labels and abstracts from a set of .arff files 
in the MSH WSD dataset into a single .json file. 
"""

corpusdir = "/Users/toddends/Desktop/coding/mshwsd/MSHCorpus"

from glob import glob
from json import dumps

def readarff(fn):
	labels = []
	arffsource = open(fn).read()
	relation = arffsource.split("\n")[0].split(" ")[-1]
	datarows = arffsource.strip().split("@DATA\n")[1].split("\n")
	for row in datarows:
		pmid, label = row.split(",")[0],row.split(",")[-1]
		abstract = row.split("\"")[1]
		abstract = abstract.replace("<e>","").replace("</e>","")	
		assert len(abstract)
		labels += [dict(pmid=pmid,label=label,
			relation=relation,abstract=abstract)]
	return labels

selected_relations = dict(
	Cilia="C0008778_C0015422", #  organelle vs. eyelash
	Follicle="C0221971_C0018120", # hair vs. ovar
	Moles="C0324740_C0027960", # insectivore vs. nevus
	Plaque="C0333463_C0011389", # gray matter vs. teeth
)

if __name__=="__main__":
	labels = []
	for fn in glob("{}/*.arff".format(sourcedir)):
		labels += readarff(fn)
		# print("{}: {} labels".format(fn.split("\\")[-1],len(readarff(fn))))
	with open("{}/../mshwsd.json".format(corpusdir),"w") as f: 
		_ = f.write(dumps(labels))
	labels_subset = [label for label in labels
		if label["relation"] in selected_relations.values()]
	with open("{}/../mshwsd_subset.json".format(corpusdir),"w") as f: 
		_ = f.write(dumps(labels_subset))

