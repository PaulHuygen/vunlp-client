vunlp-client
============

Python utility to parse documents using the VU-university facility.
Process a large quantity of texts in a simple way on lisa.surfsara

# How to use it

## Pre-supposes

1. You have a bunch of documents that has to be parsed.
2. You have a recipy (a valid prescription what Lisa has to do with each document)
3. You have access to the VU-NLP facility
4. You have a decent computer that supports Python

## Do the following

1. Clone this repository.
2. Put the documents to be processed in the "intray" subdirectory.
3. Run client.py.
4. At best, keep it running until all documents have been processed.
5. Find 
    * The processed documents in the "outtray" subdirectory
    * The unprocessable documents in the "errtray" subdirectory
    * The logfiles in the "logtray" subdirectory.

# Structure of the repository

* home directory: contains Python scripts and Github stuff
* intray, outtray, logtray: To contain the documents and logfiles
* nuweb: The "Literate Programming" sourcecode, documented in vunlpclient.pdf


