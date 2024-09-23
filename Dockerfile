FROM rocker/r-ver:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget \
    libssl-dev \
    libxml2 \
    openssl \
    curl \
    xml2 \
    libssh2-1-dev

# Install packages
RUN R -e "install.packages('learnr')"
RUN R -e "install.packages('shiny')"
RUN R -e "install.packages('rmarkdown')"
RUN R -e "install.packages('formatR')"
RUN R -e "install.packages('ggplot2')"
RUN R -e "install.packages('remotes')"

# Copy the Shiny app into the image
COPY . /HDS_SettingUpR

WORKDIR /HDS_SettingUpR

# Make the Shiny app available at port 3838
EXPOSE 4848

# Run Shiny Server
CMD ["R", "-e", "rmarkdown::run('./HDS_SettingUpR.Rmd', shiny_args = list(host = '0.0.0.0', port=4848))"]
