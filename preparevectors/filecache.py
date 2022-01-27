#!/usr/bin/env python3

import os,os.path
from urllib.request import urlopen
from urllib.error import URLError

# consider parallelization via https://docs.python.org/3/library/threading.html

class FileCache(object):
	def __init__(self,remotepattern,localpattern,verbose=True):
		self.remotepattern = remotepattern
		self.localpattern = localpattern
		self.verbose = verbose
	def query(self,parm):
		localfile = self.localpattern % parm \
			if type(self.localpattern) is str \
			else self.localpattern(parm)
		if not os.path.isfile(localfile):
			url = self.remotepattern % parm \
				if type(self.remotepattern) is str \
				else self.remotepattern(parm)
			if self.verbose:
				print("Querying '%s'..." % url)
			try:
				content = urlopen(url).read()
			except URLError:
				print("Error fetching '%s'..." % url)
				return None
			if len(content):
				with open(localfile,"wb") as f:
					f.write(content)
		else: 
			if self.verbose:
				print("'%s' exists..." % localfile)
		return localfile

