import psycopg2
from psycopg2 import Error
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import pandas as pd
import sys
import time

def upload(file):
    try:
        connection = psycopg2.connect(dbname="your-db-name",
                                      user="your-user-name",
                                      password="your-db-password",
                                      host="localhost",
                                      port="5432")
        connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = connection.cursor()
        data = pd.read_excel(file)
        cursor.execute("""SELECT endpoint_id FROM public.endpoint_names""")
        epids = cursor.fetchall()
        cursor.execute("""SELECT endpoint_id, endpoint_name FROM endpoint_names""")
        names = cursor.fetchall()
        excel = []
        base = []
        ezbase = []
        for index, row in data.iterrows():
            endid = (row['endpoint_id'],)
            if endid in epids:
                stroka = (row['endpoint_id'], row['endpoint_name'])
                ezbase.append(stroka)
            else:
                stroka = (row['endpoint_id'], row['endpoint_name'])
                excel.append(stroka)
        for i in epids:
            Exists = False
            for n in ezbase:
                if n[0] == i[0]:
                    Exists = True
            if Exists == False:
                base += i
        for i in excel:
            record = (i[0], i[1])
            upload_query = """INSERT INTO endpoint_names (endpoint_id, endpoint_name) \
                                    VALUES (%s,%s)"""
            cursor.execute(upload_query, record)
            connection.commit()
            print("Запись успешно добавлена в таблицу")
        for i in base:
            id = str(i)
            delete_query = f"""DELETE FROM endpoint_names
            WHERE endpoint_id = {id}"""
            cursor.execute(delete_query)
            connection.commit()
            print("Запись удалена")
        for i in ezbase:
            for k in names:
                if i[0] == k[0]:
                    if i[1] != k[1]:
                        record = (i[1], i[0])
                        update_query = """Update endpoint_names set endpoint_name = %s where endpoint_id = %s"""
                        cursor.execute(update_query, record)
                        connection.commit()
                        print(f"Запись успешно обновлена")
    except (Exception, Error) as error:
        print("Ошибка при работе с PostgreSQL:", error)
    finally:
        if connection:
            cursor.close()
            connection.close()
            print("Соединение с PostgreSQL закрыто")

if __name__ == '__main__':
    file = sys.argv[1]
    upload(file)
    time.sleep(5)