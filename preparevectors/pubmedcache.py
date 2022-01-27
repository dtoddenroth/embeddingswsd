#!/usr/bin/env python3

"""These helpers aim to simplify fetching from Pubmed..."""

# TODO: error handling when offline (do not write empty files)

from lxml.etree import fromstring,tostring
from time import sleep
import os,os.path
from tempfile import gettempdir

from filecache import FileCache

class PubmedCache(object):
	"""Chunk-wise download of XML representations for sets of Pubmed-IDs."""
	_pm_base = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=%s&retmode=xml"
	def __init__(self,targetpath,chunksize=10,sleeptime=.0):
		self.targetpath = targetpath
		self.chunksize = chunksize
		self.sleeptime = sleeptime
		self.cache = FileCache(self._pm_base,
			gettempdir()+"/%s.xml")
	def _target_filename(self,pmid):
		return self.targetpath + "/%s.xml" % pmid
	def _fetch_chunk(self,chunk):
		localf = self.cache.query(",".join(map(str,chunk)))
		result = dict()
		pmidset_et = fromstring(open(localf,"rb").read())
		for pmid_el in pmidset_et.findall("PubmedArticle"):
			pmid = pmid_el.find(".//PMID").text
			targetfile = self._target_filename(pmid)
			with open(targetfile,"wb") as f: 
				f.write(tostring(pmid_el))
			result[pmid] = targetfile
		sleep(self.sleeptime)
		return result
	def fetch(self,pmidlist):
		# assert/ensure pmidlist contains unique entries?
		chunk, result = [], dict()
		for pmid in pmidlist: 
			targetfile = self._target_filename(pmid)
			if os.path.isfile(targetfile):
				print(targetfile,"exists.")
				result[pmid] = targetfile
			else:
				chunk += [pmid]
			if (pmid==pmidlist[-1] and len(chunk))\
				or len(chunk)==self.chunksize:
				result.update(**self._fetch_chunk(chunk))
				chunk = []
		return result

if __name__=="__main__":
	pm_cache = PubmedCache("persist/pubmed")
	pmidlist = [27789415,29444536,27919398,27886718,27786335]
	for k,v in pm_cache.fetch(pmidlist).items():
		print(k,v)

