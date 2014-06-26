m4_include(inst.m4)m4_dnl
\documentclass[twoside]{artikel3}
\pagestyle{headings}
\usepackage{pdfswitch}
\usepackage{figlatex}
\usepackage{makeidx}
\renewcommand{\indexname}{General index}
\makeindex
\newcommand{\thedoctitle}{m4_doctitle}
\newcommand{\theauthor}{m4_author}
\newcommand{\thesubject}{m4_subject}
\newcommand{\NLP}{\textsc{nlp}}
\title{\thedoctitle}
\author{\theauthor}
\date{m4_docdate}
m4_include(texinclusions.m4)m4_dnl
\begin{document}
\maketitle
\begin{abstract}
  This document constructs a client for the VU-NLP system to perform
  \NLP{} processing on supercomputer Lisa. Features are: 1) Single
  source document that is easy to distribute; 2) automatic processing
  of the files in a directory.
\end{abstract}
\tableofcontents

\section{Introduction}
\label{sec:Introduction}

Natural Language Processing (\NLP) is an important tool to extract the
meaning from text documents. It enables a methodologic jump in many
scientific disciplines, because it enables to analyse all the
documents that are available for a given subject instead of only a
fraction of them that a scientist is capable to read in a limited
time.

To analyse a document, a computer has to perform a sequence of parsing
steps that can be resource-intensive e.g. because machine-learning is
involved. Complete parsing of a single document (e.g, news-article)
may take up several minutes of processing-time. To investigate a
scientific or scholar problem it can be necessary to analyse
hundred-thousands of documents.  Therefore, supercomputing facilities
are needed. 

The VU-University has made a facility to enable processing large
quantities of documents on supercomputer Lisa, of which the
VU-University is co-owner. There is a web-service that enables
scientist to upload documents and download the parsed results.

This document describes and implements client software that makes it
easy to utilize the VU-nlp service.


\section{Technique}
\label{sec:technique}

\subsection{The webservice}
\label{sec:webservice}

The webservice is a so-called ``restful
web-server''. Table~\ref{tab:webservicerequests} lists the requests
that it supports.

\begin{table}[hbtp]
  \centering
  \begin{tabular}{llll}
    \textbf{request} & \textbf{type} & \textbf{function} & \textbf{default} \\
    \texttt{hello}             & get  & Laten zien dat er iets werkt.    &                  \\
    \texttt{parsers}           & get  & Welke parsers zijn er?           & Alpino, Stanford \\
    \texttt{batch}             & post & Register a new batch             &                  \\
    \texttt{batch/status}      & get  & Test the status of a batch       &                  \\
    \texttt{batch/start}       & put  & Start processing a batch         &                  \\
    \texttt{batch/text}        & post & Upload a text                    &                  \\
    \texttt{batch/text/status} & get  & Get info about processing status &                  \\
    \texttt{batch/text/text}   & get  & Get text back                    &                  \\
    \texttt{batch/text/log}    & head & Get info about presence logfile  &                  \\
    \texttt{batch/text/log}    & get  & Get logfile                      &                  \\
    \texttt{batch/text/parse}  & get  & Get parse                        &                  \\
  \end{tabular}
  \caption{Web-service requests}
  \label{tab:webservicerequests}
\end{table}

@d default settings @{@%
# Templates for API calls, should be instantiated with .format(url=".."[,filename=".."])
REQUEST_ID =         "{url}/batch"
REQUEST_UPLOAD =     "{url}/batch/{batchid}/text"
REQUEST_STARTBATCH = "{url}/batch/{batchid}/start"
REQUEST_STATUS=      "{url}/batch/{batchid}/text/{textid}/status"
REQUEST_LOGCHECK=      "{url}/batch/{batchid}/text/{textid}/log"
REQUEST_RETRIEVE =   "{url}/getparse/{batchid}/{filename}"
REQUEST_LOGRETRIEVE =   "{url}/batch/{batchid}/text/{textid}/log"
#vunlp.REQUEST_IDCHECK =    "{url}/batch/{batchid}/status"
@|REQUEST_ID REQUEST_UPLOAD REQUEST_STARTBATCH REQUEST_STATUS
REQUEST_LOGCHECK REQUEST_RETRIEVE REQUEST_LOGRETRIEVE @}

Currently, the client runs on a test-webserver on the local computer
of the developer.

@d user-controllable settings @{@%
DEFAULT_URL = m4_defaulturl
@|DEFAULT_URL @}


\subsection{The client}
\label{sec:client}

The client has the following properties:

\begin{enumerate}
\item It is a Python script. Python is present on any decent computer.
\item It does not need special VUNLP libraries. However, it may need
  Python libraries that are generally available but have to be
  installed on your computer.
\item One of its functions is, that it can be included in a directory
  with documents to be processed and then takes care to process the documents.
\item Another function is, that it can be used as a library or as a
  utility for other applications.
\end{enumerate}

The client contains a ``client'' Python class, that can by used by
other python modules. There are two versions of the client. One
version performs automatic processing. The other version functions as
a utility that can be called from the command line or by other scripts.

The description in the script:

@d description of the script @{@%
 The VU NLP eLab offers a web service to facilitate natural language preprocessing
 by running the preprocessing jobs, e.g. on a computer cluster like SARA's lisa.

 This module contains a class Client to facilitate talking to the web service
 for parsing files.

 Command line usage:
  - python client.py init recipe
  - python client.py start batchid
  - python client.py COMMAND batchid textid [< text]

  COMMAND :== "upload" | "check" | "getlog" | "download"   

   - init:     Start a new batch with the given recipe and
             return a batch-id to use as a label.
   - upload:   upload the text to be parsed, providing textid 
             as a unique label within the batch.
   - start:    Start the batch.
   - check:    check the status of the text with the given batchid/textid.
   - getlog:   retrieve the log of the parser wrt. the text with
             the given batchid/textid.
   - download: retrieve the parser output of the text with the given 
             batchid/textid and remove text, parse and log from the database.

 @@file:   client.py

 @@author: Wouter van Atteveldt <wouter@@vanatteveldt.com> and Paul Huygen <paul.huygen@@huygen.nl>

 @@copyright:   GNU Affero General Public License 

@| @}

\subsection{The Client class}
\label{sec:client}

Develop a Class ``Client'' that takes care of the communication with
the webservice. All operations are performed via methods of this class.

@d description of class Client @{@%
Class that communicates with the vu nlp web service to upload, check,
and retrieve parses.
Since each Connection has a unique id, use the same connection object
for all actions on a file.
@| @}


@d class Client @{@%
class Client():
    """
    @< description of class Client @>
    """

    @< methods of class Client @>


@| Client @}

On instantion, a Client object needs to obtain the \URL{} of the
webservice. Furthermore, it is possible that the object is
instantiated to handle an ongoing batch process. In that case it has
to obtain the ID of the batch. Finally, we may enable or disable the
capacity to download a logfile for each document.

@d methods of class Client @{@%
def __init__(self, url=DEFAULT_URL, batchid = None, logfiles = True):
  """

  @@param url: the url of the web service
  @@param batchid: An existing batch id or None
  @@param logfiles: If True, download logfiles as well
  """

  log.debug("Execute init method")
  self.url = url
  self._id = batchid
  self.downloadlogfiles = logfiles
@|_init__ url id downloadlogfiles logfiles@}

The class supports the following methods to process a batch of documents on the
webservice:

\begin{description}
\item[batchstatus:] Get status of a running batch.
\item[existing\_batchid:] Find out whether a given ID is known as batchid.
\item[initbatch:] Initialize a new batch and provide a recipe.
\item[upload:] Upload a document for a given batch.
\item[start\_batch:] 
\item[check:] Check the parse status of a given document.
\item[logfile\_available:] Check whether a logfile is available and not empty.
\item[download:] Retrieve a processed document.
\end{description}

@%\begin{table}[hbtp]
@%  \centering
@%  \begin{tabular}{lll}
@%    \textbf{method}    & \textbf{arguments} & \textbf{description} \\
@%    batchstatus        & batchID   & Get batch status. \\
@%    existing\_batchid  & batchID   & Check whether batchid is known. \\
@%    initbatch          & recipe & Set up a new batch. \\
@%    upload             & document content, handle, (batchid).\\
@%    start\_batch        & batchid & Start processing.
@%    check              & text-handle, (batchid). & Check processing state
@%    logfile\_available & text-handle, (batchid) & Check presence of logfile
@%    download           & textid, tray, (batchid) & Download text or log.
@%
@%  \end{tabular}
@%  \caption{Methods in Client class to process a batch of documents.}
@%  \label{tab:Client-process-methods}
@%\end{table}


Furthermore, the Client class supports convenience methods to issue a
request to the server:

\begin{description}
\item[getrequest:] Perform a ``get'' request.
\item[postrequest] Perform a ``post'' request.
\end{description}


The general way to process a bunch of text-documents is as follows:
\begin{enumerate}
\item Set up a new batch (initbatch method) and provide a \emph{recipy} (description what
  the server must do with each document.
\item Upload the documents and receive an ID (\emph{handle}) for each
  document (upload method).
\item Start the batch (start\_batch method). The supercomputer can be
  used more efficiently when all documents are available for it when
  processing starts.
\item Check on a regular bases whether documents have been processed
  and retrieve processed documents and logfiles.
\end{enumerate}


\subsection{Inplementation of the methods of the Client class}
\label{sec:methodimplementation}

\subsubsection{Set up a batch}
\label{sec:batchsetup}

To identify a bunch of files that have to be processed in the same way
and to avoid confusion with the documents of other users, The files
and operations will be labelled with an ID, the \emph{batchid}. When
the batch is set-up the \emph{recipy}, i.e. the parsing operation that
has to be performed on the documents, is attached to the batchid.

So the first thing we have to do, is to request a batchid and specify
the recipy:

@d methods of class Client @{@%
def initbatch(self, recipe):
  """
  Initialize a new batch and provide the recipe.
  Initializes variable _id

  @@param recipe: the parse-command to apply to the uploaded texts 
  @@return: the handle to connect to the batch.
  """
  payload = []
  payload = vunlp.pack_recipe(recipe)
  mess = self.postrequest(vunlp.REQUEST_ID.format(url=self.url), payload)
  self._id = vunlp.unpack_batchid(mess)
  return  self._id

@| @}






@d methods of class Client @{@%

#
# Convenience functions
#

    def _path2id(self, path):
        """ convert a path in an id that can be included in an url for a http request.
        @@param path: 
        @@return: string with id
        """
        return path.replace('/', 'X')
   
#
# Functions to perform requests
#

    def getrequest(self, request):
        """Perform a GET request

        @@return: The un-jsonned response or None.
        """
        headers = vunlp.JSONHEADER
        r = requests.get(request, headers = headers)
        r.raise_for_status()
        if r.text.__len__() > 0:
            return r.json()
        else:
            return None

    def postrequest(self, request, payload):
        """Perform a POST request
        @@param payload: The body to be uploaded
        @@return: The un-jsonned response or None.
        """
        headers = vunlp.JSONHEADER
        r = requests.post(request, headers = headers, data=json.dumps(payload))
        r.raise_for_status()
        if r.text.__len__() > 0:
            return r.json()
        else:
            return None

    def putrequest(self, request, payload):
        """Perform a POST request
        @@param payload: The body to be jsonned and uploaded or None
        @@return: The un-jsonned response or None.
        """
        headers = vunlp.JSONHEADER
        if payload == None:
            r = requests.put(request, headers = headers)
        else:
            r = requests.put(request, headers = headers,  data=json.dumps(payload))
        r.raise_for_status()
        if r.text.__len__() > 0:
            return r.json()
        else:
            return None

    def _set_check_batchid(self, batchid):
      """Internal function to adopt a given batch-id in stand-alone mode and check existence of the batch-id"""
      if batchid != None:
        self._id = batchid
      if self._id == None:
        raise Exception('No batch-id known.')

#  def _get_filename(self):
#    """Temporary method to create unique file name until the ws can do it for us"""
#    if self._id is None:
#      log.debug("Requesting unique ID from server (recipe: " + self.recipe + ").")
#      r = requests.get(vunlp.REQUEST_ID.format(url=self.url, recipe=self.recipe))
#      r.raise_for_status()
#      self._id = r.text.strip()
#      self._filename_sequence = 0
#      log.debug("Initialized parser with id: {self._id}".format(**locals()))
#    else:
#      self._filename_sequence += 1
#    return "{self._id}_{self._filename_sequence}".format(**locals())

    def batchstatus(self, batchid = None):
      self._set_check_batchid(batchid)
      """ Retrieve status of a batch or raise exception"""      
      mess = self.getrequest(vunlp.REQUEST_BATCHITEM.format(url = self.url, batchid = self._id, item = 'status'))
      return vunlp.unpack_status(mess)



    def existing_batchid(self, batchid = None):
      """ Check whether a batch with the given id is in use

      @@param test_id: Possible batch-id
      @@return: Boolean
      """
      self._set_check_batchid(batchid)
      try:
        batchstat = batchstatus(self._id)
        return True
      except Exception as e:
        return False




#    self.recipe = recipe
#    log.debug("Requesting unique ID (recipe: " + self.recipe + ").")
##    r = requests.get(vunlp.REQUEST_ID.format(url=self.url, recipe=urllib.quote(self.recipe)))
#    payload = {'recipe': self.recipe}
#    r = requests.post(vunlp.REQUEST_ID.format(url=self.url), data=payload)
#    r.raise_for_status()
#    self._id = r.text.strip()
#    log.debug("Batch " + str(self._id) + " initiated.")
#    return str(self._id)

    def upload(self, text, textid, batchid = None):
      """
      Upload the given text into the batch.
      Use the batch-ID in stand-alone application.

      @@param text: The text to parse (as string or file object)
      @@param textid: (handle).
      @@param batchid: the handle to connect to the batch
      """
      self._set_check_batchid(batchid)
      payload = vunlp.pack_content_single(textid, text)
      mess = self.postrequest(vunlp.REQUEST_BATCHITEM.format(url=self.url, batchid=self._id, item = 'text'), payload)

#    log.debug("Uploading file {filename}".format(**locals()))
#    self._set_check_batchid(batchid)
#    r = requests.post(vunlp.REQUEST_UPLOAD.format(url=self.url, batchid=self._id), files=dict(upload = (filename, text)))
##    r = XXrequests.post(vunlp.REQUEST_UPLOAD.format(url=self.url), files=((filename, text), batchid=str(self._id)))
#    r.raise_for_status()

    def start_batch(self, batchid = None):
      """
      Start processing of the batch

      @@param batchid: the handle to connect to the batch
      """
      self._set_check_batchid(batchid)
      mess = self.putrequest(vunlp.REQUEST_BATCHITEM.format(url = self.url, batchid = self._id, item = 'start'), None)


#    self._set_check_batchid(batchid)
#    r = requests.put(vunlp.REQUEST_STARTBATCH.format(url=self.url, batchid=self._id))
#    r.raise_for_status()


    def check(self, textid, batchid = None):
        """
        Check and return the parse status of the given file
        @@param filename: a handle from a succesful upload_file call
        @@param batchid: Batch handle for stand-alone usage
        @@returns: a string indicating the status of the file
        """
        self._set_check_batchid(batchid)
        mess = self.getrequest(vunlp.REQUEST_TEXTITEM.format(url=self.url, batchid = self._id, textid = textid, item = 'status'))
        return vunlp.unpack_status(mess)

#    r = requests.get(vunlp.REQUEST_TEXTITEM.format(url=self.url, batchid=self._id, textid=filename, item='status'))
#    r.raise_for_status()
#    log.debug("Checked status for {filename}: status={r.text!r}".format(**locals()))
#    return r.text.strip()

    def logfile_available(self, textid, batchid = None):
        """
        Check whether a logfile is available and not empty.

        @@param textid: a handle from a succesful upload_file call
        @@param batchid: Batch handle for stand-alone usage
        @@return: a string containing the parse results
        """
        self._set_check_batchid(batchid)
        try:
          mess = self.getrequest(vunlp.REQUEST_TEXTITEM.format(url=self.url, batchid=self._id, textid = textid, item = 'log'))
          return True
        except Exception as e:
          return False
    


    def download(self, textid, tray, batchid = None):
        """
        Retrieve the parse results for this file. Will throw an Exception if the file is not yet parsed.
        @@param filename: a handle from a succesful upload_file call
        @@param tray: 'in', 'parse' or 'log'
        @@param batchid: Batch handle for stand-alone usage
        @@return: a string containing the parse results
        """
        self._set_check_batchid(batchid)
        if not tray in [ 'text', 'parse', 'log' ]:
          raise Exception('tray ' + tray + ' does not exist') 
        mess = self.getrequest(vunlp.REQUEST_TEXTITEM.format(url=self.url, batchid=self._id, textid = textid, item = tray))
        if mess == None:
          raise 
        name, f = vunlp.unpack_single_content(mess)
        return f.read()

#  def download_log(self, filename, batchid = None):
#    """
#    Retrieve the parse logfile for this fileif it is available. 
#    
#    @@param filename: a handle from a succesful upload_file call
#    @@param batchid: Batch handle for stand-alone usage
#    @@return: a string containing the logfile
#    """
#    self._set_check_batchid(batchid)
#    r = requests.get(vunlp.REQUEST_LOGRETRIEVE.format(url=self.url, batchid=self._id, textid=filename))
#    if r.status_code == 404:
#      return None
#    else:
#      return r.text
@| @}


\section{The module}
\label{sec:program}

@o m4_projroot/client.py @{@%
#!/usr/bin/env python
@< VU python blurb @>
""" 
@< description of the script @>
"""
from __future__ import unicode_literals, print_function, absolute_import

@< program parameters @>
@< imports @>

@< class Client @>

if __name__ == '__main__':
  @< script code @>


    
@| @}

@d program parameters @{@%
# The following parameters are modifiable by a user to create a real
# stand-alone application.
@< user-controllable settings @>

#
# Users do probably not need to meddle with the following settings
@< default settings @>
@| @}



@d script code @{@%
logging.basicConfig(level=logging.DEBUG, format='[%(asctime)-15s %(name)s:%(lineno)d %(levelname)s] %(message)s')
ok = True
import sys
if len(sys.argv) == 3:
  command, arg1 = sys.argv[1:]
  if command == "init":
    batchid = Client().initbatch(arg1)
    print(batchid)
  elif command == "start":
    Client().start_batch(arg1)
    print("batch " + str(arg1) + " started")
  else:
    ok = False
elif len(sys.argv) == 4:
  command, thisbatchid, filename = sys.argv[1:]
  if command == "upload":
    text = sys.stdin.read()
    Client().upload(text, filename, batchid = thisbatchid)
  elif command == "check":
    print(Client().check(filename, batchid = thisbatchid))
  elif command == "download":
    print(Client().download(filename, batchid = thisbatchid)) 
  else:
   ok = False
else:
   ok = False
if not ok:
  print(__doc__, file=sys.stderr)
  sys.exit(64)
@| @}



\subsection{Logging}
\label{sec:logging}

Set up logging:

@d set up logging @{@%
log = logging.getLogger(__name__)
@| @}

@d imports @{@%
import requests, logging
import urllib
#import vunlp
import json
#import clientinterface
@| @}



\subsection{Ramaining things}
\label{sec:remaining}

@d  VU python blurb @{@%
###########################################################################
#          (C) Vrije Universiteit, Amsterdam (the Netherlands)            #
#                                                                         #
# This file is part of vunlp, the VU University NLP e-lab                 #
#                                                                         #
# vunlp is free software: you can redistribute it and/or modify it under  #
# the terms of the GNU Affero General Public License as published by the  #
# Free Software Foundation, either version 3 of the License, or (at your  #
# option) any later version.                                              #
#                                                                         #
# vunlp is distributed in the hope that it will be useful, but WITHOUT    #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or   #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public     #
# License for more details.                                               #
#                                                                         #
# You should have received a copy of the GNU Affero General Public        #
# License along with vunlp.  If not, see <http://www.gnu.org/licenses/>.  #
###########################################################################
@| @}





\appendix

\section{How to read and translate this document}
\label{sec:translatedoc}

This document is an example of \emph{literate
  programming}~\cite{Knuth:1983:LP}. It contains the code of all sorts
of scripts and programs, combined with explaining texts. In this
document the literate programming tool \texttt{nuweb} is used, that is
currently available from Sourceforge
(URL:\url{m4_nuwebURL}). The advantages of Nuweb are, that
it can be used for every programming language and scripting language, that
it can contain multiple program sources and that it is very simple.


\subsection{Read this document}
\label{sec:read}

The document contains \emph{code scraps} that are collected into
output files. An output file (e.g. \texttt{output.fil}) shows up in the text as follows:

\begin{alltt}
"output.fil" \textrm{4a \(\equiv\)}
      # output.fil
      \textrm{\(<\) a macro 4b \(>\)}
      \textrm{\(<\) another macro 4c \(>\)}
      \(\diamond\)

\end{alltt}

The above construction contains text for the file. It is labelled with
a code (in this case 4a)  The constructions between the \(<\) and
\(>\) brackets are macro's, placeholders for texts that can be found
in other places of the document. The test for a macro is found in
constructions that look like:

\begin{alltt}
\textrm{\(<\) a macro 4b \(>\) \(\equiv\)}
     This is a scrap of code inside the macro.
     It is concatenated with other scraps inside the
     macro. The concatenated scraps replace
     the invocation of the macro.

{\footnotesize\textrm Macro defined by 4b, 87e}
{\footnotesize\textrm Macro referenced in 4a}
\end{alltt}

Macro's can be defined on different places. They can contain other macro´s.

\begin{alltt}
\textrm{\(<\) a scrap 87e \(>\) \(\equiv\)}
     This is another scrap in the macro. It is
     concatenated to the text of scrap 4b.
     This scrap contains another macro:
     \textrm{\(<\) another macro 45b \(>\)}

{\footnotesize\textrm Macro defined by 4b, 87e}
{\footnotesize\textrm Macro referenced in 4a}
\end{alltt}


\subsection{Process the document}
\label{sec:processing}

The raw document is named
\verb|a_<!!>m4_progname<!!>.w|. Figure~\ref{fig:fileschema}
\begin{figure}[hbtp]
  \centering
  \includegraphics{fileschema.fig}
  \caption{Translation of the raw code of this document into
    printable/viewable documents and into program sources. The figure
    shows the pathways and the main files involved.}
  \label{fig:fileschema}
\end{figure}
 shows pathways to
translate it into printable/viewable documents and to extract the
program sources. Table~\ref{tab:transtools}
\begin{table}[hbtp]
  \centering
  \begin{tabular}{lll}
    \textbf{Tool} & \textbf{Source} & \textbf{Description} \\
    gawk  & \url{www.gnu.org/software/gawk/}& text-processing scripting language \\
    M4    & \url{www.gnu.org/software/m4/}& Gnu macro processor \\
    nuweb & \url{nuweb.sourceforge.net} & Literate programming tool \\
    tex   & \url{www.ctan.org} & Typesetting system \\
    tex4ht & \url{www.ctan.org} & Convert \TeX{} documents into \texttt{xml}/\texttt{html}
  \end{tabular}
  \caption{Tools to translate this document into readable code and to
    extract the program sources}
  \label{tab:transtools}
\end{table}
lists the tools that are
needed for a translation. Most of the tools (except Nuweb) are available on a
well-equipped Linux system.

@%\textbf{NOTE:} Currently, not the most recent version  of Nuweb is used, but an older version that has been modified by me, Paul Huygen.

@d parameters in Makefile @{@%
NUWEB=m4_nuwebbinary
@| @}


\subsection{Translate and run}
\label{sec:transrun}

This chapter assembles the Makefile for this project.

@o Makefile -t @{@%
@< default target @>

@< parameters in Makefile @> 

@< impliciete make regels @>
@< expliciete make regels @>
@< make targets @>
@| @}

The default target of make is \verb|all|.

@d  default target @{@%
all : @< all targets @>
.PHONY : all

@|PHONY all @}


One of the targets is certainly the \textsc{pdf} version of this
document.

@d all targets @{m4_progname.pdf@}

We use many suffixes that were not known by the C-programmers who
constructed the \texttt{make} utility. Add these suffixes to the list.

@d parameters in Makefile @{@%
.SUFFIXES: .pdf .w .tex .html .aux .log .php

@| SUFFIXES @}



\subsection{Pre-processing}
\label{sec:pre-processing}

To make usable things from the raw input \verb|a_<!!>m4_progname<!!>.w|, do the following:

\begin{enumerate}
\item Process \verb|\$| characters.
\item Run the m4 pre-processor.
\item Run nuweb.
\end{enumerate}

This results in a \LaTeX{} file, that can be converted into a \pdf{}
or a \HTML{} document, and in the program sources and scripts.

\subsubsection{Process `dollar' characters }
\label{sec:procdollars}

Many ``intelligent'' \TeX{} editors (e.g.\ the auctex utility of
Emacs) handle \verb|\$| characters as special, to switch into
mathematics mode. This is irritating in program texts, that often
contain \verb|\$| characters as well. Therefore, we make a stub, that
translates the two-character sequence \verb|\\$| into the single
\verb|\$| character.


@d expliciete make regels @{@%
m4_<!!>m4_progname<!!>.w : a_<!!>m4_progname<!!>.w
@%	gawk '/^@@%/ {next}; {gsub(/[\\][\\$\$]/, "$$");print}' a_<!!>m4_progname<!!>.w > m4_<!!>m4_progname<!!>.w
	gawk '{if(match($$0, "@@<!!>%")) {printf("%s", substr($$0,1,RSTART-1))} else print}' a_<!!>m4_progname.w \
          | gawk '{gsub(/[\\][\\$\$]/, "$$");print}'  > m4_<!!>m4_progname<!!>.w
@% $

@| @}

@%@d expliciete make regels @{@%
@%m4_<!!>m4_progname<!!>.w : a_<!!>m4_progname<!!>.w
@%	gawk '/^@@%/ {next}; {gsub(/[\\][\\$\$]/, "$$");print}' a_<!!>m4_progname<!!>.w > m4_<!!>m4_progname<!!>.w
@%
@%@% $
@%@| @}

\subsubsection{Run the M4 pre-processor}
\label{sec:run_M4}

@d  expliciete make regels @{@%
m4_progname<!!>.w : m4_<!!>m4_progname<!!>.w
	m4 -P m4_<!!>m4_progname<!!>.w > m4_progname<!!>.w

@| @}


\subsection{Typeset this document}
\label{sec:typeset}

Enable the following:
\begin{enumerate}
\item Create a \pdf{} document.
\item Print the typeset document.
\item View the typeset document with a viewer.
\item Create a \HTML document.
\end{enumerate}

In the three items, a typeset \pdf{} document is required or it is the
requirement itself.




\subsubsection{Figures}
\label{sec:figures}

This document contains figures that have been made by
\texttt{xfig}. Post-process the figures to enable inclusion in this
document.

The list of figures to be included:

@d parameters in Makefile @{@%
FIGFILES=fileschema

@| FIGFILES @}

We use the package \texttt{figlatex} to include the pictures. This
package expects two files with extensions \verb|.pdftex| and
\verb|.pdftex_t| for \texttt{pdflatex} and two files with extensions \verb|.pstex| and
\verb|.pstex_t| for the \texttt{latex}/\texttt{dvips}
combination. Probably tex4ht uses the latter two formats too.

Make lists of the graphical files that have to be present for
latex/pdflatex:

@d parameters in Makefile @{@%
FIGFILENAMES=\$(foreach fil,\$(FIGFILES), \$(fil).fig)
PDFT_NAMES=\$(foreach fil,\$(FIGFILES), \$(fil).pdftex_t)
PDF_FIG_NAMES=\$(foreach fil,\$(FIGFILES), \$(fil).pdftex)
PST_NAMES=\$(foreach fil,\$(FIGFILES), \$(fil).pstex_t)
PS_FIG_NAMES=\$(foreach fil,\$(FIGFILES), \$(fil).pstex)

@|FIGFILENAMES PDFT_NAMES PDF_FIG_NAMES PST_NAMES PS_FIG_NAMES@}


Create
the graph files with program \verb|fig2dev|:

@d impliciete make regels @{@%
%.eps: %.fig
	fig2dev -L eps \$< > \$@@

%.pstex: %.fig
	fig2dev -L pstex \$< > \$@@

.PRECIOUS : %.pstex
%.pstex_t: %.fig %.pstex
	fig2dev -L pstex_t -p \$*.pstex \$< > \$@@

%.pdftex: %.fig
	fig2dev -L pdftex \$< > \$@@

.PRECIOUS : %.pdftex
%.pdftex_t: %.fig %.pstex
	fig2dev -L pdftex_t -p \$*.pdftex \$< > \$@@

@| fig2dev @}


\subsubsection{Bibliography}
\label{sec:bbliography}

To keep this document portable, create a portable bibliography
file. It works as follows: This document refers in the
\texttt|bibliography| statement to the local \verb|bib|-file
\verb|m4_progname.bib|. To create this file, copy the auxiliary file
to another file \verb|auxfil.aux|, but replace the argument of the
command \verb|\bibdata{m4_progname}| to the names of the bibliography
files that contain the actual references (they should exist on the
computer on which you try this). This procedure should only be
performed on the computer of the author. Therefore, it is dependent of
a binary file on his computer.


@d expliciete make regels @{@%
bibfile : m4_progname.aux m4_mkportbib
	m4_mkportbib m4_progname m4_bibliographies

.PHONY : bibfile
@| @}

\subsubsection{Create a printable/viewable document}
\label{sec:createpdf}

Make a \pdf{} document for printing and viewing.

@d make targets @{@%
pdf : m4_progname.pdf

print : m4_progname.pdf
	m4_printpdf(m4_progname)

view : m4_progname.pdf
	m4_viewpdf(m4_progname)

@| pdf view print @}

Create the \pdf{} document. This may involve multiple runs of nuweb,
the \LaTeX{} processor and the bib\TeX{} processor, and depends on the
state of the \verb|aux| file that the \LaTeX{} processor creates as a
by-product. Therefore, this is performed in a separate script,
\verb|w2pdf|.

\paragraph{The w2pdf script}
\label{sec:w2pdf}

The three processors nuweb, \LaTeX{} and bib\TeX{} are
intertwined. \LaTeX{} and bib\TeX{} create parameters or change the
value of parameters, and write them in an auxiliary file. The other
processors may need those values to produce the correct output. The
\LaTeX{} processor may even need the parameters in a second
run. Therefore, consider the creation of the (\pdf) document finished
when none of the processors causes the auxiliary file to change. This
is performed by a shell script \verb|w2pdf|.

@%@d make targets @{@%
@%m4_progname.pdf : m4_progname.w \$(FIGFILES)
@%	chmod 775 bin/w2pdf
@%	bin/w2pdf m4_progname
@%
@%@| @}



Note, that in the following \texttt{make} construct, the implicit rule
\verb|.w.pdf| is not used. It turned out, that make did not calculate
the dependencies correctly when I did use this rule.

@d  impliciete make regels@{@%
@%.w.pdf :
%.pdf : %.w \$(W2PDF)  \$(PDF_FIG_NAMES) \$(PDFT_NAMES)
	chmod 775 \$(W2PDF)
	\$(W2PDF) \$*

@| @}

The following is an ugly fix of an unsolved problem. Currently I
develop this thing, while it resides on a remote computer that is
connected via the \verb|sshfs| filesystem. On my home computer I
cannot run executables on this system, but on my work-computer I
can. Therefore, place the following script on a local directory.

@d parameters in Makefile @{@%
W2PDF=m4_nuwebbindir/w2pdf
@| @}

@d expliciete make regels  @{@%
\$(W2PDF) : m4_progname.w
	\$(NUWEB) m4_progname.w
@| @}

m4_dnl
m4_dnl Open compile file.
m4_dnl args: 1) directory; 2) file; 3) Latex compiler
m4_dnl
m4_define(m4_opencompilfil,
<!@o !>\$1<!!>\$2<! @{@%
#!/bin/bash
# !>\$2<! -- compile a nuweb file
# usage: !>\$2<! [filename]
# !>m4_header<!
NUWEB=m4_nuwebbinary
LATEXCOMPILER=!>\$3<!
@< filenames in nuweb compile script @>
@< compile nuweb @>

@| @}
!>)m4_dnl

m4_opencompilfil(<!m4_nuwebbindir/!>,<!w2pdf!>,<!pdflatex!>)m4_dnl

@%@o w2pdf @{@%
@%#!/bin/bash
@%# w2pdf -- make a pdf file from a nuweb file
@%# usage: w2pdf [filename]
@%#  [filename]: Name of the nuweb source file.
@%`#' m4_header
@%echo "translate " \$1 >w2pdf.log
@%@< filenames in w2pdf @>
@%
@%@< perform the task of w2pdf @>
@%
@%@| @}

The script retains a copy of the latest version of the auxiliary file.
Then it runs the four processors nuweb, \LaTeX{}, MakeIndex and bib\TeX{}, until
they do not change the auxiliary file or the index. 

@d compile nuweb @{@%
NUWEB=m4_nuweb
@< run the processors until the aux file remains unchanged @>
@< remove the copy of the aux file @>
@| @}

The user provides the name of the nuweb file as argument. Strip the
extension (e.g.\ \verb|.w|) from the filename and create the names of
the \LaTeX{} file (ends with \verb|.tex|), the auxiliary file (ends
with \verb|.aux|) and the copy of the auxiliary file (add \verb|old.|
as a prefix to the auxiliary filename).

@d filenames in nuweb compile script @{@%
nufil=\$1
trunk=\${1%%.*}
texfil=\${trunk}.tex
auxfil=\${trunk}.aux
oldaux=old.\${trunk}.aux
indexfil=\${trunk}.idx
oldindexfil=old.\${trunk}.idx
@| nufil trunk texfil auxfil oldaux indexfil oldindexfil @}

Remove the old copy if it is no longer needed.
@d remove the copy of the aux file @{@%
rm \$oldaux
@| @}

Run the three processors. Do not use the option \verb|-o| (to suppres
generation of program sources) for nuweb,  because \verb|w2pdf| must
be kept up to date as well.

@d run the three processors @{@%
\$NUWEB \$nufil
\$LATEXCOMPILER \$texfil
makeindex \$trunk
bibtex \$trunk
@| nuweb makeindex bibtex @}


Repeat to copy the auxiliary file and the index file  and run the processors until the
auxiliary file and the index file are equal to their copies.
 However, since I have not yet been able to test the \verb|aux|
file and the \verb|idx| in the same test statement, currently only the
\verb|aux| file is tested.

It turns out, that sometimes a strange loop occurs in which the
\verb|aux| file will keep to change. Therefore, with a counter we
prevent the loop to occur more than m4_maxtexloops times.

@d run the processors until the aux file remains unchanged @{@%
LOOPCOUNTER=0
while
  ! cmp -s \$auxfil \$oldaux 
do
  if [ -e \$auxfil ]
  then
   cp \$auxfil \$oldaux
  fi
  if [ -e \$indexfil ]
  then
   cp \$indexfil \$oldindexfil
  fi
  @< run the three processors @>
  if [ \$LOOPCOUNTER -ge 10 ]
  then
    cp \$auxfil \$oldaux
  fi;
done
@| @}


\subsubsection{Create HTML files}
\label{sec:createhtml}

\textsc{Html} is easier to read on-line than a \pdf{} document that
was made for printing. We use \verb|tex4ht| to generate \HTML{}
code. An advantage of this system is, that we can include figures
in the same way as we do for \verb|pdflatex|.

Nuweb creates a \LaTeX{} file that is suitable
for \verb|latex2html| if the source file has \verb|.hw| as suffix instead of
\verb|.w|. However, this feature is not compatible with tex4ht.

Make html file:

@d make targets @{@%
html : m4_htmltarget

@| @}

The \HTML{} file depends on its source file and the graphics files.

Make lists of the graphics files and copy them.

@d parameters in Makefile @{@%
HTML_PS_FIG_NAMES=\$(foreach fil,\$(FIGFILES), m4_htmldocdir/\$(fil).pstex)
HTML_PST_NAMES=\$(foreach fil,\$(FIGFILES), m4_htmldocdir/\$(fil).pstex_t)
@| @}


@d impliciete make regels @{@%
m4_htmldocdir/%.pstex : %.pstex
	cp  \$< \$@@

m4_htmldocdir/%.pstex_t : %.pstex_t
	cp  \$< \$@@

@| @}

Copy the nuweb file into the html directory.

@d expliciete make regels @{@%
m4_htmlsource : m4_progname.w
	cp  m4_progname.w m4_htmlsource

@| @}

We also need a file with the same name as the documentstyle and suffix
\verb|.4ht|. Just copy the file \verb|report.4ht| from the tex4ht
distribution. Currently this seems to work.

@d expliciete make regels @{@%
m4_4htfildest : m4_4htfilsource
	cp m4_4htfilsource m4_4htfildest

@| @}

Copy the bibliography.

@d expliciete make regels  @{@%
m4_htmlbibfil : m4_anuwebdir/m4_progname.bib
	cp m4_anuwebdir/m4_progname.bib m4_htmlbibfil

@| @}



Make a dvi file with \texttt{w2html} and then run
\texttt{htlatex}. 

@d expliciete make regels @{@%
m4_htmltarget : m4_htmlsource m4_4htfildest \$(HTML_PS_FIG_NAMES) \$(HTML_PST_NAMES) m4_htmlbibfil
	cp w2html m4_abindir
	cd m4_abindir && chmod 775 w2html
	cd m4_htmldocdir && m4_abindir/w2html m4_progname.w

@| @}

Create a script that performs the translation.

@%m4_<!!>opencompilfil(m4_htmldocdir/,`w2dvi',`latex')m4_dnl


@o w2html @{@%
#!/bin/bash
# w2html -- make a html file from a nuweb file
# usage: w2html [filename]
#  [filename]: Name of the nuweb source file.
`#' m4_header
echo "translate " \$1 >w2html.log
NUWEB=m4_nuwebbinary
@< filenames in w2html @>

@< perform the task of w2html @>

@| @}

The script is very much like the \verb|w2pdf| script, but at this
moment I have still difficulties to compile the source smoothly into
\textsc{html} and that is why I make a separate file and do not
recycle parts from the other file. However, the file works similar.


@d perform the task of w2html @{@%
@< run the html processors until the aux file remains unchanged @>
@< remove the copy of the aux file @>
@| @}


The user provides the name of the nuweb file as argument. Strip the
extension (e.g.\ \verb|.w|) from the filename and create the names of
the \LaTeX{} file (ends with \verb|.tex|), the auxiliary file (ends
with \verb|.aux|) and the copy of the auxiliary file (add \verb|old.|
as a prefix to the auxiliary filename).

@d filenames in w2html @{@%
nufil=\$1
trunk=\${1%%.*}
texfil=\${trunk}.tex
auxfil=\${trunk}.aux
oldaux=old.\${trunk}.aux
indexfil=\${trunk}.idx
oldindexfil=old.\${trunk}.idx
@| nufil trunk texfil auxfil oldaux @}

@d run the html processors until the aux file remains unchanged @{@%
while
  ! cmp -s \$auxfil \$oldaux 
do
  if [ -e \$auxfil ]
  then
   cp \$auxfil \$oldaux
  fi
@%  if [ -e \$indexfil ]
@%  then
@%   cp \$indexfil \$oldindexfil
@%  fi
  @< run the html processors @>
done
@< run tex4ht @>

@| @}


To work for \textsc{html}, nuweb \emph{must} be run with the \verb|-n|
option, because there are no page numbers.

@d run the html processors @{@%
\$NUWEB -o -n \$nufil
latex \$texfil
makeindex \$trunk
bibtex \$trunk
htlatex \$trunk
@| @}


When the compilation has been satisfied, run makeindex in a special
way, run bibtex again (I don't know why this is necessary) and then run htlatex another time.
@d run tex4ht @{@%
m4_index4ht
makeindex -o \$trunk.ind \$trunk.4dx
bibtex \$trunk
htlatex \$trunk
@| @}


\paragraph{create the program sources}
\label{sec:createsources}

Run nuweb, but suppress the creation of the \LaTeX{} documentation.
Nuweb creates only sources that do not yet exist or that have been
modified. Therefore make does not have to check this. However,
``make'' has to create the directories for the sources if they
do not yet exist.
@%This is especially important for the directories
@%with the \HTML{} files. It seems to be easiest to do this with a shell
@%script.
So, let's create the directories first.

@d parameters in Makefile @{@%
MKDIR = mkdir -p

@| MKDIR @}



@d make targets @{@%
DIRS = @< directories to create @>

\$(DIRS) : 
	\$(MKDIR) \$@@

@| DIRS @}


@d make targets @{@%
sources : m4_progname.w \$(DIRS)
@%	cp ./createdirs m4_bindir/createdirs
@%	cd m4_bindir && chmod 775 createdirs
@%	m4_bindir/createdirs
	\$(NUWEB) m4_progname.w

jetty : sources
	cd .. && mvn jetty:run

@| @}

@%@o createdirs @{@%
@%#/bin/bash
@%# createdirs -- create directories
@%`#' m4_header
@%@< create directories @>
@%@| @}


\section{References}
\label{sec:references}

\subsection{Literature}
\label{sec:literature}

\bibliographystyle{plain}
\bibliography{m4_progname}

\subsection{URL's}
\label{sec:urls}

\begin{description}
\item[Nuweb:] \url{m4_nuwebURL}
\item[Apache Velocity:] \url{m4_velocityURL}
\item[Velocitytools:] \url{m4_velocitytoolsURL}
\item[Parameterparser tool:] \url{m4_parameterparserdocURL}
\item[Cookietool:] \url{m4_cookietooldocURL}
\item[VelocityView:] \url{m4_velocityviewURL}
\item[VelocityLayoutServlet:] \url{m4_velocitylayoutservletURL}
\item[Jetty:] \url{m4_jettycodehausURL}
\item[UserBase javadoc:] \url{m4_userbasejavadocURL}
\item[VU corpus Management development site:] \url{http://code.google.com/p/vucom} 
\end{description}

\section{Indexes}
\label{sec:indexes}


\subsection{Filenames}
\label{sec:filenames}

@f

\subsection{Macro's}
\label{sec:macros}

@m

\subsection{Variables}
\label{sec:veriables}

@u

\end{document}

% Local IspellDict: british 

% LocalWords:  Webcom
