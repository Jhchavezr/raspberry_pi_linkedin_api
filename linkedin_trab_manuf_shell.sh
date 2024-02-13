# RUN R SCRIPT
cd ~/linkedin_api
Rscript banxico_api_trab_manufactureros.r
echo "R SCRIPT DONE"

#Activate virtual environment
source ~/linkedin_api/myenv/bin/activate
echo "Source activated"
#Run asset registration in Linkedin API
#python3 ~/linkedin_api/linkedin_api_reg_asset.py
echo "Python asset registrated"

#Run Upload plot in python
python3 ~/linkedin_api/linkedin_api_upload.py
echo "Python upload done"

#Run IMAGE SHARE POST Linkedin API.
python3 ~/linkedin_api/linkedin_api_image_post.py

echo "Linkedin Share published"
# ECHO
echo "Plot created, asset registrated and uploaded, share published at Current time: $(date)"

