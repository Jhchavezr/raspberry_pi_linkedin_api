# raspberry_pi_linkedin_api
Post linkedin profiles
This repository will help you make post image shares in your linkedin profile.
Everything is done via the shell scripts (you should add them to your crontab and schedule each one at one day of the week or as preferred)

## Requirements
- A Linkedin API Access Token and URN (you can get them [here]{https://learn.microsoft.com/en-us/linkedin/consumer/})..
- An INEGI token, you can get it [here]{https://www.inegi.org.mx/app/desarrolladores/generatoken/Usuarios/token_Verify}.
- A Banxico token, you can get it [overhere]{https://www.banxico.org.mx/SieAPIRest/service/v1/token}.

Here's an explanation of the shell scripts workflow
## Step 1
The R scripts do the API requests and process the information from public sources like the INEGI and Banxico (Mexican public statistics APIs).
Runs R scripts and generates a plot that is saved as an image.
## Step 2
Runs a Python script that registers an image asset to get the asset number and upload url.
## Step 3
Runs a Python script that uploads the image at the supplied url.
## Step 4
Runs a Python script that posts a share in your linkedin profile.


