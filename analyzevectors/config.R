
# by Dennis Toddenroth, 2022

cols <- rev(brewer.pal(10,"Paired")[c(1:6,9,10)])
modelcaptions <- c(sci_nostopwords="biomedical language model with stopword filtering",
	sci_withstopwords="biomedical language model without stopword filtering",
	web_nostopwords="general language model with stopword filtering",
	web_withstopwords="general language model without stopword filtering")

languages <- c(javalang="Java",matlablang="Matlab",pythonlang="Python",rlang="R")
# spellcheck: names(languages) %in% annotations$label
languages <- sapply(languages,sprintf,fmt="%s (programming)")
homonyms <- c(javaisland="Java (Indonesia)",matlabregion="Matlab (Bangladesh)",
	pythonserpent="Python (serpent)",rcorrelation="R (correlation)")
# spellcheck: names(homonyms) %in% annotations$label
class.labels <- as.character(t(as.matrix(data.frame(names(languages),names(homonyms)))))
is.lang <- function(caption) caption %in% names(languages)
