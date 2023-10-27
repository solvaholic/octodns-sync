import requests, os, json
import logging
try:
    from http.client import HTTPConnection # py3
except ImportError:
    from httplib import HTTPConnection # py2

# enable verbose logging
HTTPConnection.debuglevel = 1
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

# make request
response = requests.post(os.environ['_url'], json={'body':os.environ['_body']}, headers={'user-agent': os.environ['_user'], 'Authorization': 'token {}'.format(os.environ['_token'])})
response.raise_for_status()
print(response)