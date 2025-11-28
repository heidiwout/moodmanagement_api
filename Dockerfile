FROM rocker/r-ver:4.3.1

# install plumber and needed R packages
RUN R -e "install.packages(c('plumber', 'jsonlite', 'magick', 'data.table', 'stringr'))"

# copy all API files into the container
WORKDIR /app
COPY . /app

# plumber listens on port 8080
EXPOSE 8080

# start the API
CMD ["R", "-e", "pr <- plumber::plumb('plumber.R'); pr$run(host='0.0.0.0', port=8080)"]
