# RUN R SCRIPT
cd ~/raspberry_pi_linkedin_api
Rscript inegi_api_exports.r
echo "R SCRIPT DONE"

#Activate virtual environment
source ~/raspberry_pi_linkedin_api/.venv/bin/activate
echo "Source activated"

#Run asset registration in Linkedin API
python3 ~/raspberry_pi_linkedin_api/linkedin_api_reg_asset.py
echo "Python asset registrated"

sleep 30
#Run Upload plot in python
python3 ~/raspberry_pi_linkedin_api/linkedin_api_upload.py
echo "Python upload done"

#Run IMAGE SHARE POST Linkedin API.
python3 ~/raspberry_pi_linkedin_api/linkedin_api_image_post.py

echo "Linkedin Share published"
# ECHO
echo "Plot created, asset registrated and uploaded, share published at : $(date)"

