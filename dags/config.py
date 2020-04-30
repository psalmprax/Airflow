import os

from database.database import Database
from env.environs import Env


class Config:
    def __init__(self, dbname=None):
        """
        :param dbname:
        """
        self.dir_env = os.getcwd() + "/dags/env/.env"
        self.dir_dag_template = os.getcwd() + "/dags/sql"
        self.params = None
        self.env = Env()
        self.env.read_env(self.dir_env)

        if dbname is None:
            self.params = dict(user=self.env("user"), password=self.env("password"), host=self.env("host"),
                               dbname=self.env("dbname"))
        else:
            self.params = dict(user=self.env("user"), password=self.env("password"), host=self.env("host"),
                               dbname=dbname)
        self.db = Database(self.params)

    def db(self):
        return self.db

    def dir_dag_template(self):
        return self.dir_dag_template
