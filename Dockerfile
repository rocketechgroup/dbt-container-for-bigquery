FROM python:3.7-slim-buster AS common

ARG DBT_HOME=/home/dbtuser
ARG BUILD_DIR=/tmp/build

RUN apt-get update \
    && apt-get install -yqq curl \
    && pip install pipenv==2020.11.15

RUN groupadd -g 999 dbtuser && useradd -r -u 999 -g dbtuser dbtuser

WORKDIR ${DBT_HOME}
RUN chown -R dbtuser:dbtuser ${DBT_HOME}

USER dbtuser

RUN mkdir ${DBT_HOME}/.dbt
RUN mkdir ${BUILD_DIR}

# Update pip dependencies
COPY --chown=dbtuser:dbtuser ./infrastructure/Pipfile.lock ./
RUN pipenv sync

RUN rm -rf ${BUILD_DIR}
WORKDIR ${DBT_HOME}

# For PROD
FROM common as prod

COPY ./analysis ${DBT_HOME}/analysis
COPY ./data ${DBT_HOME}/data
COPY ./macros ${DBT_HOME}/macros
COPY ./models ${DBT_HOME}/models
COPY ./snapshots ${DBT_HOME}/snapshots
COPY ./tests ${DBT_HOME}/tests
COPY ./dbt_project.yml ${DBT_HOME}/dbt_project.yml
COPY ./infrastructure/profiles.yml ${DBT_HOME}/.dbt/profiles.yml

# For DEV development only
FROM prod as dev

ENV PATH $PATH:${DBT_HOME}/google-cloud-sdk/bin
RUN set -ex \
    && curl -sSL https://sdk.cloud.google.com | bash
