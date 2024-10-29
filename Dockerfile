# Grab a python image
FROM python:3.9

# Set environment variables
ENV PYTHONUNBUFFERED 1
ENV IN_DOCKER 1

# Install necessary packages
RUN apt-get update && apt-get install -y curl nginx

# Install nvm and set it up in the environment
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    nvm install node && \
    nvm use node

# Add the Node path to the environment
ENV NVM_DIR=$HOME/.nvm
ENV PATH=$NVM_DIR/versions/node/$(ls $NVM_DIR/versions/node)/bin:$PATH

# Create and set the working directory
RUN mkdir /tcd
WORKDIR /tcd

# Copy files to the Docker image
ADD . /tcd/

# Install Python and Node dependencies
RUN pip install pipenv
RUN pipenv install --system --deploy
RUN npm ci --only=production

# Compile static files
RUN npm run build
RUN python ./tabbycat/manage.py collectstatic --noinput -v 0

