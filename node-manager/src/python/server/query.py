from sqlalchemy import create_engine
from threading import Thread
from time import sleep

import os, json

has_db = False

db_engine = None

PASS_FN = '/esg/config/.esg_pg_pass'

QUERY_INTERVAL=240

def  init_db():
    
    if not os.path.exists(PASS_FN):
        return (False, None)
    
    f = open(PASS_FN)

    passwd = f.read().strip()
    
    db_str = ( 'postgresql://dbsuper:' + passwd + '@esgf-postgres:5432/esgcet')

    engine = create_engine(db_str)

    return True, engine




def execute_count_query(qstr):


    
    if not has_db:
        return 0

    try:
        result = db_engine.execute(qstr)
    except:
        print "Query failed to execute"
        return -1
        
    val = 0

    for row in result:
        val = row[0]

    return str(val)


def get_user_count():
    return    execute_count_query('select count(*) from (select distinct firstname, middlename, lastname from esgf_security.user) as tmp')
#  TODO -1 to not count admin user?

def get_dl_bytes():

    return execute_count_query('select sum(xfer_size) from esgf_node_manager.access_logging where data_size = xfer_size and xfer_size > 0')


def get_dl_count():

#    return execute_count_query('select count(*) from esgf_node_manager.access_logging where data_size = xfer_size and xfer_size > 0')
    return execute_count_query('select count(*) from esgf_node_manager.access_logging where data_size = xfer_size')


def get_dl_users():

    return execute_count_query('select count(distinct user_id) from esgf_node_manager.access_logging')


has_db, db_engine = init_db()


class QueryRunner(Thread):

    def __init__(self, fn, c):

        super(QueryRunner, self).__init__()
        self.target_fn = fn
        self.esg_config = c
        

    def run(self):

        last_str = ""

        while True:

            out_dict= {}

            if self.esg_config.is_idp():
                out_dict["users_count"] = get_user_count()

            if self.esg_config.is_data():
                out_dict["download.users"] = get_dl_users()
                out_dict["download.count"] = get_dl_count()
                out_dict["download.bytes"] = get_dl_bytes()
            
            outstr = json.dumps(out_dict)


            if outstr != last_str:
                f = open(self.target_fn, "w")

                f.write(outstr)
                f.close()
                last_str = outstr
               
            sleep(QUERY_INTERVAL)
