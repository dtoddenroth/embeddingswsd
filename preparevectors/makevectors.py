#!/usr/bin/env python3

from lxml.etree import fromstring, tostring
import spacy

from pubmedcache import PubmedCache

langmodels = dict(sci="en_core_sci_lg",web="en_core_web_md")
nlppipelines = {k:spacy.load(v) for k,v in langmodels.items()}

def extractabstract(xmlfile):
	et = fromstring(open(xmlfile,"rb").read())
	try: 
		return " ".join(et.find(".//Abstract").itertext())
	except AttributeError:
		print("Error reading abstract from %s."%xmlfile)
		return ""

def stripstopwordspunct(doc):
	""" Strips stopwords and punctuation from tokens, 
	see https://stackoverflow.com/questions/45375488/how-to-filter-tokens-from-spacy-document. """
	from spacy.tokens import Doc
	remaining = [t.text for t in doc if not 
		(t.is_stop or t.is_punct or t.is_space)]
	return Doc(doc.vocab,words=remaining)

def getcsvstream(abstracts,pipeline,stripstopwords=False,sep=";"):
	ncols = pipeline.vocab.vectors.shape[1]
	csvrows = [sep.join(["pubmedid"]+["vec"+str(c) for c in range(ncols)])]
	for pmid,abstract in abstracts.items():
		vectors = (stripstopwordspunct(pipeline(abstract))
			if stripstopwords else pipeline(abstract)).vector
		csvrows += [sep.join([str(pmid)]+list(map(str,vectors)))]
	return "\n".join(csvrows)

def write2file(what,fn): 
	with open(fn,"w") as f: 
		_ = f.write(what)

pmids = open("pubmedids.txt").read().strip().split("\n")
xmlfiles = PubmedCache("./pubmedcache").fetch(pmids)
# format: {'32607211': './pubmedcache/32607211.xml' } # ...
abstracts = {k:extractabstract(v) for k,v in xmlfiles.items()}

if __name__=="__main__":
	fnpattern = "../vectorsets/vectors_%s.csv"
	write2file(getcsvstream(abstracts,nlppipelines["sci"],False),
		fnpattern % "sci_withstopwords")
	write2file(getcsvstream(abstracts,nlppipelines["web"],False),
		fnpattern % "web_withstopwords")
	write2file(getcsvstream(abstracts,nlppipelines["sci"],True),
		fnpattern % "sci_nostopwords")
	write2file(getcsvstream(abstracts,nlppipelines["web"],True),
		fnpattern % "web_nostopwords")

