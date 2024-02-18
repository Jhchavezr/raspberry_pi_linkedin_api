import requests
from dotenv import load_dotenv
import os
import json
from datetime import datetime

load_dotenv()

ACCESS_TOKEN=os.getenv('ACCESS_TOKEN')
URN_USER=os.getenv('URN_USER')
INEGI_TOKEN=os.getenv('INEGI_TOKEN')
current_datetime = datetime.now()
formatted_datetime = current_datetime.strftime("%Y-%m-%d %H:%M:%S")

# Read the log.txt file
with open('log_assets.txt', 'r') as file:
    last_digitalmedia_asset = None
    last_upload_url = None

    # Iterate through each line in the file
    for line in file:
      try:
        # Parse the JSON from the line
        data = json.loads(line)
        # Extract the asset and uploadUrl
        asset = data.get('value', {}).get('asset')
        upload_url = data.get('value', {}).get('uploadMechanism', {}).get('com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest', {}).get('uploadUrl')

        # If an asset is found, update the last_digitalmedia_asset and last_upload_url
        if asset:
            last_digitalmedia_asset = asset
            last_upload_url = upload_url
      except json.JSONDecodeError as e:
        print("Error decoding json, no line")

print({last_digitalmedia_asset})



url = "https://api.linkedin.com/v2/ugcPosts"

payload = json.dumps({
  "author": "urn:li:person:" + URN_USER,
  "lifecycleState": "PUBLISHED",
  "specificContent": {
    "com.linkedin.ugc.ShareContent": {
      "shareCommentary": {
        "text": "Gráfica generada en R con datos de la API del Banco de México o del INEGI y publicada por la API de Linkedin usando Python #API #R #Banxico #INEGI #Python #AWS #EC2 #Raspberry #Ubuntu #Linkedin"
      },
      "shareMediaCategory": "IMAGE",
      "media": [
        {
          "status": "READY",
          "description": {
            "text": "Fuente: Banxico "
          },
          "media": last_digitalmedia_asset,
          "title": {
            "text": "Información más reciente al día de la publicación"
          }
        }
      ]
    }
  },
  "visibility": {
    "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"
  }
})
headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer ' + ACCESS_TOKEN
}

response = requests.request("POST", url, headers=headers, data=payload)


if response.status_code == 201:
    print('Post successfully created! '+ response.text),
    with open('log_posts.txt', 'a') as file:
        file.write(f'{formatted_datetime}' + response.text + '\n')
        file.flush()
else:
    print(f'Upload failed with status code {response.status_code}: {response.text}')
