#import os
#result = os.popen('curl '+ "Accept: application/json"+ " 'https://www.brainyquote.com/api/inf' -H 'origin: https://www.brainyquote.com' -H 'content-type: application/json' -H 'referer: https://www.brainyquote.com/topics/positive' --data-binary "+ '{"typ":"topic","vm":"g","langc":"en","ab":"a","pg":4,"id":"t:132668","vid":"62c44484d0b7fbdb04eed83d7ba2168c","m":0} '+ '--compressed').read()
#print (result)



import requests
import json
import re


headers = {
    'origin': 'https://www.brainyquote.com',
    'content-type': 'application/json',
    'referer': 'https://www.brainyquote.com/topics/positive',
}

data = '{"typ":"topic","vm":"g","langc":"en","ab":"a","pg":4,"id":"t:132668","vid":"62c44484d0b7fbdb04eed83d7ba2168c","m":0}'

response = requests.post('https://www.brainyquote.com/api/inf', headers=headers, data=data)
html = json.loads(response.text)
html = html["content"]

#print (html)
text_file = open("html.txt", "w")
text_file.write(html)
text_file.close()


d = []
count = 0
source = "https://www.brainyquote.com/topics/positive"
while 1:

    quote = re.search('title="view quote">(.*)</a>', html)
    author = re.search('title="view author">(.*)</a>', html)

    if author is None or quote is None:
        break

    count += 1
    html = html.replace('title="view quote">'+str(quote.group(1))+'</a>', "")
    html = html.replace('title="view author">'+str(author.group(1))+'</a>', "")

    obj = {
        "quote"  : str(quote.group(1)),
        "author" : str(author.group(1)),
        "source" : str(source)
    }

    d.append(obj)
    #print (quote.group(1))
    #print (author.group(1))
    #print (source)

import json
with open('data.json', 'w') as outfile:
    json.dump(d, outfile)



#curl 'https://www.brainyquote.com/api/inf' -H 'origi: https://www.brainyquote.com/topics/positive' --data-binary '{"typ":"topic","vm":"g","langc":"en","ab":"a","pg":4,"id":"t:132668","vid":"62c44484d0b7fbdb04ed83d7ba2168c","m":0}' --compressed



#curl  'https://www.brainyquote.com/api/inf' -H 'origin: https://www.brainyquote.com' -H 'content-type: application/json' -H 'referer: https://www.brainyquote.com/topics/positive' --data-binary '{"typ":"topic","vm":"g","langc":"en","ab":"a","pg":4,"id":"t:132668","vid":"62c44484d0b7fbdb04eed83d7ba2168c","m":0}' --compressed
