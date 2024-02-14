FROM ubuntu:latest

#Installing R and Python
RUN apt-get update && \
    apt-get install -y r-base python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#Install dependencies
RUN Rscript -e "install.packages(c('ggplot2', 'dplyr', 'tidyr', 'siebanxicor', 'lubridate', 'httr', 'jsonlite', 'rjson', 'scales'), repos='https://cloud.r-project.org/')"

# Set working directory
WORKDIR /linkedin_api
# COPY directory
COPY . /linkedin_api

RUN chmod +x /linkedin_api/*.sh

CMD ["./linkedin_api/linkedin_inegi_shell.sh"]

