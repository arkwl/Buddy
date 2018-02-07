#import os
#result = os.popen('curl '+ "Accept: application/json"+ " 'https://www.brainyquote.com/api/inf' -H 'origin: https://www.brainyquote.com' -H 'content-type: application/json' -H 'referer: https://www.brainyquote.com/topics/positive' --data-binary "+ '{"typ":"topic","vm":"g","langc":"en","ab":"a","pg":4,"id":"t:132668","vid":"62c44484d0b7fbdb04eed83d7ba2168c","m":0} '+ '--compressed').read()
#print (result)



import requests
import json

headers = {
    'origin': 'https://www.brainyquote.com',
    'content-type': 'application/json',
    'referer': 'https://www.brainyquote.com/topics/positive',
}

data = '{"typ":"topic","vm":"g","langc":"en","ab":"a","pg":4,"id":"t:132668","vid":"62c44484d0b7fbdb04eed83d7ba2168c","m":0}'

response = requests.post('https://www.brainyquote.com/api/inf', headers=headers, data=data)
html = json.loads(response.text)
html = html["content"]

print (html)

#curl 'https://www.brainyquote.com/api/inf' -H 'origi: https://www.brainyquote.com/topics/positive' --data-binary '{"typ":"topic","vm":"g","langc":"en","ab":"a","pg":4,"id":"t:132668","vid":"62c44484d0b7fbdb04ed83d7ba2168c","m":0}' --compressed



#curl  'https://www.brainyquote.com/api/inf' -H 'origin: https://www.brainyquote.com' -H 'content-type: application/json' -H 'referer: https://www.brainyquote.com/topics/positive' --data-binary '{"typ":"topic","vm":"g","langc":"en","ab":"a","pg":4,"id":"t:132668","vid":"62c44484d0b7fbdb04eed83d7ba2168c","m":0}' --compressed
