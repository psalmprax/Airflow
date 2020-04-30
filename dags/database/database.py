import psycopg2


class Database:
    def __init__(self, kwargs):
        self.connection = None
        self.cursor = None
        self.status = False
        try:
            self.connection = psycopg2.connect(dbname=kwargs['dbname'],
                                               user=kwargs['user'], host=kwargs['host'],
                                               password=kwargs['password'])
            self.connection.autocommit = True
            self.cursor = self.connection.cursor()
            self.status = True
        except Exception as err:
            print(err)
            self.status = False

    def create_db(self, **dbname):
        try:
            for key in dbname.keys():
                self.cursor.execute('CREATE DATABASE {};'.format(dbname[key]))
            self.status = True
        except Exception as err:
            print(err)
            self.status = False
        return self.status

    def create_ext(self):
        try:
            self.cursor.execute('CREATE EXTENSION IF NOT EXISTS dblink')
            self.status = True
        except Exception as err:
            print(err)
            self.status = False
        return self.status

    # def delete_db(self, **dbname):
    #     try:
    #         for key in dbname.keys():
    #             print(dbname[key])
    #             self.cursor.execute('DROP DATABASE IF EXISTS {};'.format(dbname[key]))
    #         self.status = True
    #     except Exception as err:
    #         print(err)
    #         self.status = False
    #
    #     return self.status

    def set_airflow_connection(self, **conn_str):
        try:
            for key in conn_str.keys():
                val = conn_str[key]
                col = ["conn_id", "conn_type", "host", "schema", "login", "password", "port", "extra", "is_encrypted",
                       "is_extra_encrypted"]
                col = ', '.join(col)
                query_placeholders = ','.join(['%s'] * len(val))
                sql = '''INSERT INTO public.connection(%s) VALUES(%s);''' % (col, query_placeholders)
                self.cursor.execute(sql, val)
            self.status = True
        except Exception as err:
            print(err)
            self.status = False

        return self.status

    def delete_db(self, **dbname):
        try:
            for key in dbname.keys():
                self.cursor.execute('DROP DATABASE IF EXISTS {};'.format(dbname[key]))
            self.status = True
        except Exception as err:
            print(err)
            self.status = False

        return self.status

    def cursor(self):
        return self.cursor

    def connection(self):
        return self.connection

    def conn_close(self):
        self.connection.close()
        self.status = True
        return self.status
