import json
import os
from dotenv import load_dotenv
from flask import Flask, request, jsonify, send_file
import psycopg2
from psycopg2.extras import RealDictCursor
from psycopg2.sql import SQL, Literal
import logging

load_dotenv()
pg_connection_parameters = {
    'host': os.getenv('POSTGRES_HOST') or 'localhost',
    'port': os.getenv('POSTGRES_PORT'),
    'database': os.getenv('POSTGRES_DB'),
    'user': os.getenv('POSTGRES_USER'),
    'password': os.getenv('POSTGRES_PASSWORD')
}

pg_replication_parameters = {
    'host': os.getenv('POSTGRES_HOST') or 'localhost',
    'port': os.getenv('SLAVE_PORT'),
    'database': os.getenv('POSTGRES_DB'),
    'user': os.getenv('POSTGRES_USER'),
    'password': os.getenv('POSTGRES_PASSWORD')
}

for key in pg_connection_parameters:
    if pg_connection_parameters[key] is None:
        logging.error(f'{key} is None')


def create_pg_connection():
    conn = psycopg2.connect(**pg_connection_parameters, cursor_factory=RealDictCursor)

    conn.autocommit = True
    return conn


def create_replication_connection():
    conn = psycopg2.connect(**pg_replication_parameters, cursor_factory=RealDictCursor)

    conn.autocommit = True
    return conn


app = Flask(__name__)
app.config['JSon_as_asCII'] = False


# 127.0.0.1:5000/expedition/materialized
@app.route("/expedition/materialized")
def get_holders():
    try:
        query = """select * from expedition_with_explorers_and_equipment"""
        with create_pg_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            holders = cur.fetchall()

        return holders
    except Exception as ex:
        logging.error(ex, exc_info=True)
        return '', 400


@app.route("/expedition")
def get_expedition():
    try:
        query = """select * from expedition"""
        with create_replication_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            holders = cur.fetchall()

        return holders
    except Exception as ex:
        logging.error(ex, exc_info=True)
        return '', 400


"""
curl --location 'http://localhost:5000/expedition/create' \
--header 'Content-Type: application/json' \
--data '{
    "explorer_id": "1",
    "name": "name",
    "expedition_result": "expedition_result",
    "start_date": "10-01-2020",
    "end_date": "11-01-2020",
}'
"""


@app.route("/expedition/create", methods=['POST'])
def create_expedition():
    try:
        body = request.json

        query = SQL("""
        insert into expedition(name, expedition_result, start_date, end_date)
        values({name}, {expedition_result}, {start_date}, {end_date})
        returning name, expedition_result, start_date, end_date
        """).format(name=Literal(body['name']),
                    expedition_result=Literal(body['expedition_result']),
                    start_date=Literal(body['start_date']),
                    end_date=Literal(body['end_date']))

        with create_pg_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            conn.commit()
            holder = cur.fetchone()

        return holder
    except Exception as ex:
        logging.error(ex, exc_info=True)
        return '', 400


"""
curl --location 'http://localhost:5000/expedition/update' \
--header 'Content-Type: application/json' \
--data '{
    "explorer_id": "1",
    "name": "name",
    "expedition_result": "expedition_result",
    "start_date": "12-01-2020",
    "end_date": "20-01-2020"
}'
"""


@app.route("/expedition/update", methods=['POST'])
def update_expedition():
    try:
        body = request.json

        query = SQL("""
        update expedition 
        set name = {name}, expedition_result = {expedition_result}, start_date = {start_date}, end_date = {end_date}
        where name = {name}
        returning id
        """).format(name=Literal(body['name']),
                    expedition_result=Literal(body['expedition_result']),
                    start_date=Literal(body['start_date']),
                    end_date=Literal(body['end_date']), )

        with create_pg_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            updated_rows = cur.fetchall()
            print(updated_rows)

        if len(updated_rows) == 0:
            return '', 404

        return '', 204
    except Exception as ex:
        logging.error(ex, exc_info=True)
        return '', 400


"""
curl --location --request DELETE 'http://localhost:5000/expedition/delete' \
--header 'Content-Type: application/json' \
--data '{
    "id": 7
}'
"""


@app.route("/expedition/delete", methods=['DELETE'])
def delete_expedition():
    try:
        body = request.json

        query = SQL("""
        delete from expedition 
        where id = {id}
        returning id
        """).format(id=Literal(body['id']))

        with create_pg_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            deleted_rows = cur.fetchall()

        if len(deleted_rows) == 0:
            return '', 404

        return '', 204
    except Exception as ex:
        logging.error(ex, exc_info=True)
        return '', 400


@app.route("/expedition/search")
def expedition_search():
    try:
        date_from = request.args.get('date_from')
        date_to = request.args.get('date_to')
        expedition_result = request.args.get('expedition_result')

        if date_from is None:
            date_from_condition = "true"
        else:
            date_from_condition = "start_date >= {date_from}"

        if date_to is None:
            date_to_condition = "true"
        else:
            date_to_condition = "start_date <= {date_to}"

        if expedition_result is None:
            expedition_result_condition = "true"
        else:
            expedition_result_condition = "expedition_result = {expedition_result}"

        query = SQL(f"""
        select *
        from expedition
        where {date_from_condition} and {date_to_condition} and {expedition_result_condition}
        """).format(date_from=Literal(date_from), date_to=Literal(date_to),
                    expedition_result=Literal(expedition_result))

        with create_pg_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            rows = cur.fetchall()

        if len(rows) == 0:
            return '', 404

        return rows
    except Exception as ex:
        logging.error(ex, exc_info=True)
        return '', 400


@app.route("/expedition/find_by_result")
def storage_cells_find_by_code():
    try:
        name = request.args.get('name')
        if name is None:
            return '', 404

        query = SQL("""
        select *
        from expedition
        where name = {name}
        """).format(name=Literal(name))

        with create_pg_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            rows = cur.fetchone()

        if rows is None:
            return '', 404

        return rows
    except Exception as ex:
        logging.error(ex, exc_info=True)
        return '', 400


@app.route('/')
def autocomplete_page():
    try:
        return send_file('templates/autocomplete.html')
    except Exception as ex:
        logging.error(repr(ex), exc_info=True)
        return {'message': 'Bad Request'}, 400


@app.route('/levenshtein')
def levenshtein():
    try:
        name = request.args.get('name')
        query = SQL("select * from expedition where levenshtein(name, {name}) <= 2;").format(name=Literal(name))
        with create_pg_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            expedition = cur.fetchall()

        return expedition
    except Exception as ex:
        logging.error(ex, exc_info=True)
        return '', 400


@app.route('/autocomplete')
def autocomplete():
    try:
        name = request.args.get('name')

        query = SQL("select * from expedition where name %> {name}").format(name=Literal(name))

        with create_pg_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            equipment = cur.fetchall()

        return jsonify(list(map(lambda row: row['name'], equipment)))
    except Exception as ex:
        logging.error(repr(ex), exc_info=True)
        return {'message': 'Bad Request'}, 400


"""
curl --location 'http://localhost:5000/explorer/update' \
--header 'Content-Type: application/json' \
--data '{
    "name": "name",
    "height": 180,
    "width": 110,
    "education": [
        {
            "name": "КФУ",
            "completion_date": 2014,
            "degree": "magister"
        },
        {
            "name": "ВШЭ",
            "completion_date": 2019,
            "degree": "phd"
        }
    ]
}'
"""


@app.route("/explorer/update", methods=['POST'])
def update_explorer():
    try:
        body = request.json
        query = SQL("""
        update explorer 
        set name = {name}, height = {height}, width = {width}, education = {education}
        where name = {name}
        returning id
        """).format(name=Literal(body['name']),
                    height=Literal(body['height']),
                    width=Literal(body['width']),
                    education=Literal(json.dumps(body['education'])))

        with create_pg_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            updated_rows = cur.fetchall()
            print(updated_rows)

        if len(updated_rows) == 0:
            return '', 404

        return '', 204
    except Exception as ex:
        logging.error(ex, exc_info=True)
        return '', 400


# 127.0.0.1:5000/explorer/materialized
@app.route("/explorer/materialized_jsonb")
def get_explorer_jsonb():
    try:
        query = """select * from explorers_and_equipment where education @> '%s'""" % json.dumps([request.args])
        with create_pg_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            holders = cur.fetchall()
        return holders
    except Exception as ex:
        logging.error(ex, exc_info=True)
        return '', 400


@app.route("/explorer/materialized_array")
def get_explorer_array():
    try:
        query = """select * from explorers_and_equipment where forum && array ['%s']""" % request.args.get('forum')
        with create_pg_connection() as conn, conn.cursor() as cur:
            cur.execute(query)
            holders = cur.fetchall()

        if not holders:
            with create_pg_connection() as conn, conn.cursor() as cur:
                cur.execute("select * from explorers_and_equipment")
                holders = cur.fetchall()
        return holders
    except Exception as ex:
        logging.error(ex, exc_info=True)
        return '', 400


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=True)
