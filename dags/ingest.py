from datetime import datetime

from airflow import DAG
from airflow.operators.postgres_operator import PostgresOperator
from config import Config

cfg = Config()

dag_params = {
    'dag_id': 'Ingest',
    'start_date': datetime(2020, 3, 27),
    'schedule_interval': None
}

with DAG(**dag_params, template_searchpath=[cfg.dir_dag_template]) as dag:

    insert_target_table_no_duplicate = PostgresOperator(
          task_id='insert_target_table_no_duplicate',
          sql="insert_target_table_no_duplicate.sql",
          postgres_conn_id="target"
    )

    insert_target_table_no_duplicate
