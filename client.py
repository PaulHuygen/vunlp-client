#!/usr/bin/env python
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

""" 
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

 @file:   client.py

 @author: Wouter van Atteveldt <wouter@vanatteveldt.com> and Paul Huygen <paul.huygen@huygen.nl>

 @copyright:   GNU Affero General Public License 


"""
from __future__ import unicode_literals, print_function, absolute_import

# The following parameters are modifiable by a user to create a real
# stand-alone application.
DEFAULT_URL = localhost:8090


#
# Users do probably not need to meddle with the following settings
# Templates for API calls, should be instantiated with .format(url=".."[,filename=".."])
REQUEST_ID =         "{url}/batch"
REQUEST_UPLOAD =     "{url}/batch/{batchid}/text"
REQUEST_STARTBATCH = "{url}/batch/{batchid}/start"
REQUEST_STATUS=      "{url}/batch/{batchid}/text/{textid}/status"
REQUEST_LOGCHECK=      "{url}/batch/{batchid}/text/{textid}/log"
REQUEST_RETRIEVE =   "{url}/getparse/{batchid}/{filename}"
REQUEST_LOGRETRIEVE =   "{url}/batch/{batchid}/text/{textid}/log"
#vunlp.REQUEST_IDCHECK =    "{url}/batch/{batchid}/status"


import requests, logging
import urllib
#import vunlp
import json
#import clientinterface


class Client():
    """
    Class that communicates with the vu nlp web service to upload, check,
    and retrieve parses.
    Since each Connection has a unique id, use the same connection object
    for all actions on a file.
    
    """

    def __init__(self, url=DEFAULT_URL, batchid = None, logfiles = True):
      """

      @param url: the url of the web service
      @param batchid: An existing batch id or None
      @param logfiles: If True, download logfiles as well
      """

      log.debug("Execute init method")
      self.url = url
      self._id = batchid
      self.downloadlogfiles = logfiles
    def initbatch(self, recipe):
      """
      Initialize a new batch and provide the recipe.
      Initializes variable _id

      @param recipe: the parse-command to apply to the uploaded texts 
      @return: the handle to connect to the batch.
      """
      payload = []
      payload = vunlp.pack_recipe(recipe)
      mess = self.postrequest(vunlp.REQUEST_ID.format(url=self.url), payload)
      self._id = vunlp.unpack_batchid(mess)
      return  self._id

    
    #
    # Convenience functions
    #

        def _path2id(self, path):
            """ convert a path in an id that can be included in an url for a http request.
            @param path: 
            @return: string with id
            """
            return path.replace('/', 'X')
       
    #
    # Functions to perform requests
    #

        def getrequest(self, request):
            """Perform a GET request

            @return: The un-jsonned response or None.
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
            @param payload: The body to be uploaded
            @return: The un-jsonned response or None.
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
            @param payload: The body to be jsonned and uploaded or None
            @return: The un-jsonned response or None.
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

          @param test_id: Possible batch-id
          @return: Boolean
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

          @param text: The text to parse (as string or file object)
          @param textid: (handle).
          @param batchid: the handle to connect to the batch
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

          @param batchid: the handle to connect to the batch
          """
          self._set_check_batchid(batchid)
          mess = self.putrequest(vunlp.REQUEST_BATCHITEM.format(url = self.url, batchid = self._id, item = 'start'), None)


    #    self._set_check_batchid(batchid)
    #    r = requests.put(vunlp.REQUEST_STARTBATCH.format(url=self.url, batchid=self._id))
    #    r.raise_for_status()


        def check(self, textid, batchid = None):
            """
            Check and return the parse status of the given file
            @param filename: a handle from a succesful upload_file call
            @param batchid: Batch handle for stand-alone usage
            @returns: a string indicating the status of the file
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

            @param textid: a handle from a succesful upload_file call
            @param batchid: Batch handle for stand-alone usage
            @return: a string containing the parse results
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
            @param filename: a handle from a succesful upload_file call
            @param tray: 'in', 'parse' or 'log'
            @param batchid: Batch handle for stand-alone usage
            @return: a string containing the parse results
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
    #    @param filename: a handle from a succesful upload_file call
    #    @param batchid: Batch handle for stand-alone usage
    #    @return: a string containing the logfile
    #    """
    #    self._set_check_batchid(batchid)
    #    r = requests.get(vunlp.REQUEST_LOGRETRIEVE.format(url=self.url, batchid=self._id, textid=filename))
    #    if r.status_code == 404:
    #      return None
    #    else:
    #      return r.text
    




if __name__ == '__main__':
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
  


    
