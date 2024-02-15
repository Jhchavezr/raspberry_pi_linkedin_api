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
current_directory = os.getcwd()
formatted_datetime = current_datetime.strftime("%Y-%m-%d %H:%M:%S")

today_date = datetime.today()
# Convert today's date to the format used in the file names
today_date_str = current_datetime.strftime("%Y-%m-%d")
plotfile = f"{current_directory}/plots/plot_{today_date_str}.png"
print(plotfile + current_directory)
image = open(plotfile,"rb").read()


# # Read the log.txt file
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

headers = {
  'Authorization': 'Bearer ' + ACCESS_TOKEN,
  'Content-Type': 'application/png'
}

response = requests.request("POST", last_upload_url, headers=headers, data=image)

if response.status_code == 201:
    print('Upload successfully created! '+ response.text),
    with open('log_uploads.txt', 'a') as file:
        file.write(f'\n {formatted_datetime} {response.text}')
        file.flush()
else:
    print(f'Upload failed with status code {response.status_code}: {response.text}')
