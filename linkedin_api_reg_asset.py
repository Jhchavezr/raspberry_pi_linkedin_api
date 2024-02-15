import requests
from dotenv import load_dotenv
import os
import json

load_dotenv()

ACCESS_TOKEN=os.getenv('ACCESS_TOKEN')
URN_USER=os.getenv('URN_USER')
INEGI_TOKEN=os.getenv('INEGI_TOKEN')


url = "https://api.linkedin.com/v2/assets?action=registerUpload"

payload = json.dumps({
  "registerUploadRequest": {
    "recipes": [
      "urn:li:digitalmediaRecipe:feedshare-image"
    ],
    "owner": "urn:li:person:" + URN_USER,
    "serviceRelationships": [
      {
        "relationshipType": "OWNER",
        "identifier": "urn:li:userGeneratedContent"
      }
    ]
  }
})
headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer ' + ACCESS_TOKEN
}

response = requests.request("POST", url, headers=headers, data=payload)

if response.status_code == 200:
    print('Register successfully created! '+ response.text),
    with open('log_assets.txt', 'a') as file:
        file.write('\n' + response.text)
        file.flush()
else:
    print(f'Register failed with status code {response.status_code}: {response.text}')
