from datetime import datetime

from airflow import DAG
from airflow.operators.postgres_operator import PostgresOperator
from airflow.operators.python_operator import PythonOperator
from config import Config

#  environment variable location "/usr/local/airflow/dags/env/.env"

cfg = Config()
db_dict = dict(targetdb="targetdb", sourcedb="sourcedb")
ext_src = Config(dbname=db_dict["sourcedb"])
ext_trg = Config(dbname=db_dict["targetdb"])
conn_src = dict(conn=["source", "postgres", "sourcedb", "sourcedb", "sourcedb", "solution", "5432", "", "False", "False"])
conn_trg = dict(conn=["target", "postgres", "sourcedb", "targetdb", "sourcedb", "solution", "5432", "", "False", "False"])

dag_params = {
    'dag_id': 'Create_Target_Tables',
    'start_date': datetime(2020, 3, 27),
    'schedule_interval': None
}

with DAG(**dag_params, template_searchpath=[cfg.dir_dag_template]) as dag:
    connection_src = PythonOperator(task_id='connection_src', python_callable=cfg.db.set_airflow_connection,
                                    op_kwargs=conn_src)
    connection_trg = PythonOperator(task_id='connection_trg', python_callable=cfg.db.set_airflow_connection,
                                    op_kwargs=conn_trg)
    delete_db = PythonOperator(task_id='delete_db', python_callable=cfg.db.delete_db, op_kwargs=db_dict)
    create_db = PythonOperator(task_id='create_db', python_callable=cfg.db.create_db, op_kwargs=db_dict)
    create_ext = PythonOperator(task_id='create_ext', python_callable=ext_src.db.create_ext,
                                op_kwargs=None)
    create_trg = PythonOperator(task_id='create_trg', python_callable=ext_trg.db.create_ext,
                                op_kwargs=None)

    delete_source_table = PostgresOperator(
        task_id='delete_source_table',
        sql="delete_table.sql",
        postgres_conn_id="source"
    )

    delete_target_table = PostgresOperator(
        task_id='delete_target_table',
        sql="delete_table.sql",
        postgres_conn_id="target"
    )

    create_target_table = PostgresOperator(
        task_id='create_table',
        sql="set_up_python_target_table.sql",
        postgres_conn_id="target"
    )

    insert_source_table = PostgresOperator(
        task_id='insert_table',
        sql="set_up_python.sql",
        postgres_conn_id="source"
    )

    delete_db >> create_db >> create_ext >> create_trg >> [delete_source_table, delete_target_table] >> create_target_table >> insert_source_table  # >> insert_target_table_no_duplicate
