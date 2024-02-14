import requests
from dotenv import load_dotenv
import os

load_dotenv()

ACCESS_TOKEN=os.getenv('ACCESS_TOKEN')
URN_USER=os.getenv('URN_USER')
INEGI_TOKEN=os.getenv('INEGI_TOKEN')

api_url = 'https://api.linkedin.com/v2/ugcPosts'

headers = {
    'Authorization': f'Bearer ' + ACCESS_TOKEN,
    'Connection': 'Keep-Alive',
    'Content-Type': 'application/json',
}

post_body = {
    'author': 'urn:li:person:' + URN_USER,
    'lifecycleState': 'PUBLISHED',
    'specificContent': {
        'com.linkedin.ugc.ShareContent': {
            'shareCommentary': {
                'text': 'This post was created using Python in VSC.',
            },
            'shareMediaCategory': 'ARTICLE',
            'media': [
                {
                    'status': 'READY',
                    'description': {
                        'text': 'The graph was made in R with a GET request to the INEGI API!',
                    },
                    'originalUrl': 'https://jorgechavez.ameyalimexico.com/plots/plot_2024-02-06.png',
                    'title': {
                        'text': 'Indicador de remuneraciones y ocupación base 2018',
                    },
                },
            ],
        },
    },
    'visibility': {
        'com.linkedin.ugc.MemberNetworkVisibility': 'PUBLIC',
    },
}

response = requests.post(api_url, headers=headers, json=post_body)
if response.status_code == 201:
    print('Post successfully created!')
else:
    print(f'Post creation failed with status code {response.status_code}: {response.text}')
