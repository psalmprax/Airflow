# https://github.com/WASdev/ci.docker/issues/194
FROM puckel/docker-airflow:1.10.6
USER root
RUN pip install --upgrade pip
USER airflow
RUN python -m pip install --user psycopg2-binary
ENV AIRFLOW_HOME=/usr/local/airflow
COPY ./airflow.cfg /usr/local/airflow/airflow.cfg
