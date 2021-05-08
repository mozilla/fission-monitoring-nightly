FROM continuumio/miniconda3
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
        bzr \
        gnupg2 \
        cvs \
        git \
        curl \
        mercurial \
        subversion

# install google cloud sdk
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

# Add our deps to the base conda environment
COPY environment.yml /tmp
RUN conda config --add channels conda-forge
RUN conda env update -n base -f /tmp/environment.yml

COPY . /app

CMD  /bin/bash /app/run.sh
