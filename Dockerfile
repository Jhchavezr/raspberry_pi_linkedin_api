FROM ubuntu:latest
# Set the timezone environment variable
ENV TZ=America/New_York

# Install tzdata package to configure the timezone
RUN apt-get update && \
    apt-get install -y tzdata && \
    rm -rf /var/lib/apt/lists/*

# Configure the timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


#Installing R and Python
RUN apt-get update && \
    apt-get install -y r-base python3 python3-pip 
    #&&
    #\
    #apt-get clean && \
    #rm -rf /var/lib/apt/lists/*

RUN pip install requests && \
    pip install load_dotenv
    
RUN apt-get update && \
    apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev

#Install dependencies
RUN Rscript -e "install.packages(c('ggplot2', 'dplyr', 'tidyr', 'siebanxicor', 'lubridate', 'httr', 'jsonlite', 'rjson', 'scales', 'Cairo'), repos='https://cloud.r-project.org/')"

# Set working directory
WORKDIR /raspberry_pi_linkedin_api
# COPY directory
COPY . /raspberry_pi_linkedin_api/

RUN chmod +x /raspberry_pi_linkedin_api/*.sh

CMD ["bash", "linkedin_inegi_shell.sh"]