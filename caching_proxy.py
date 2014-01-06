#!/usr/bin/env python2
import BaseHTTPServer
import hashlib
import os
import os.path
import urllib2
import re

CACHE_DIR = 'cache'

if not os.path.exists(CACHE_DIR):
    os.mkdir(CACHE_DIR)

alphabets = set('qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM12345678990') # just a joke...
def cache_name(filename):
    alpha_only = ''.join([c if c in alphabets else '_' for c in filename])
    m = hashlib.md5()
    m.update(filename)
    return alpha_only + '___' + m.hexdigest()

class CacheHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_GET(self):
      cache_filename = os.path.join(CACHE_DIR, cache_name(self.path))
      if os.path.exists(cache_filename):
          print "Cache hit"
          data = open(cache_filename).readlines()
      else:
          print "Cache miss"
          data = urllib2.urlopen("http://localhost:8088" + self.path).readlines()
          open(cache_filename, 'wb').writelines(data)
      self.send_response(200)
      self.end_headers()
      self.wfile.writelines(data)

def run():
    server_address = ('', 8000)
    httpd = BaseHTTPServer.HTTPServer(server_address, CacheHandler)
    httpd.serve_forever()

if __name__ == '__main__':
    run()

