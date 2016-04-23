FROM alpine:3.3
MAINTAINER PentimentoLabs <contact@pentimentolabs.com>
ENV TAAL_VERSION=0.5.0-dev

# Define charset
ENV LANG=en_US.utf8

# Define timezone
ENV TIMEZONE=Europe/Paris
RUN apk add --no-cache tzdata                                                  \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime                       \
    && echo ${TIMEZONE} >  /etc/timezone                                       \
    && apk del --purge tzdata

# Install general packages
RUN apk add --no-cache bash ca-certificates curl graphviz vim

# Install Python environment
ENV PYTHON_VERSION=2.7.11-r3
RUN apk add --no-cache py-pip python=${PYTHON_VERSION}                         \
    && pip install --upgrade pip setuptools

# Install Node.js environment
ENV NODEJS_VERSION=4.3.0-r0
RUN apk add --no-cache nodejs=${NODEJS_VERSION}

# Install GDAL
ENV GDAL_VERSION=2.0.2
RUN apk add --no-cache --virtual build-dependencies g++ gcc libc-dev make                                     \
    && curl -L http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz | tar xzf - -C /tmp \
    && (cd /tmp/gdal-${GDAL_VERSION} && ./configure && make && make install)                                  \
    && rm -rf /tmp/gdal-${GDAL_VERSION}                                                                       \
    && apk del --purge build-dependencies

# Install jq
ENV JQ_VERSION=1.5-r0
RUN apk add --no-cache jq=${JQ_VERSION}

# Install CSVKit
ENV CVSKIT_VERSION=0.9.1
RUN apk add --no-cache --virtual build-dependencies gcc musl-dev postgresql-dev python-dev \
    && pip install --no-cache-dir --upgrade csvkit==${CVSKIT_VERSION} psycopg2             \
    && apk del --purge build-dependencies

# Install HTTPie
ENV HTTPIE_VERSION=0.9.3
RUN pip install --no-cache-dir --upgrade httpie==${HTTPIE_VERSION}

# Install pv
ENV PV_VERSION=1.6.0
RUN apk add --no-cache --virtual build-dependencies gcc libc-dev make                              \
    && curl -L http://www.ivarch.com/programs/sources/pv-${PV_VERSION}.tar.bz2 | tar xjf - -C /tmp \
    && (cd /tmp/pv-${PV_VERSION} && ./configure && make && make install)                           \
    && rm -rf /tmp/pv-${PV_VERSION}                                                                \
    && apk del --purge build-dependencies

# Install PostgreSQL client
RUN apk add --no-cache postgresql-client

# Install AWS CLI
ENV AWSCLI_VERSION=1.10.10
RUN pip install --no-cache-dir --upgrade awscli==${AWSCLI_VERSION}

# Configure workspace
RUN mkdir /root/workbench
COPY ./files/.bashrc /root/.bashrc

# Run Bash
WORKDIR /root/workbench
ENTRYPOINT ["bash"]
