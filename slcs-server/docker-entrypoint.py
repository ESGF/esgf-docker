#!/usr/bin/python2.7
import argparse
import os
import socket
import subprocess
import time


def parse_args():
    parser = argparse.ArgumentParser(description='Start an ESGF SLCS instance.',
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('-sn', '--server-name',
                        help='The Fully Qualified Domain Name of the SLCS server.',
                        required=True,
                        metavar='my-node.esgf.org')

    parser.add_argument('-ds', '--django-superuser',
                        help='The user in UserDB that should be given django superuser permissions.',
                        required=True,
                        metavar='another')

    parser.add_argument('-su', '--static-url',
                        help='The URL used when retrieving static files.',
                        required=True,
                        metavar='http://my-cdn.esgf.org/slcs-static/')

    proxy_settings_group = parser.add_argument_group(title='Proxy Settings',
                                                     description='Settings used when SLCS is operating behind a proxy.')
    proxy_settings_group.add_argument('-up', '--url-prefix',
                                      help='Should be set when slcs is behind a proxy where all requests are being forwarded from '
                                           'the proxy to slcs. For example, if httpd is being used to proxy all requests for '
                                           'https://my-node.esgf.org/slcs-admin to the slcs application, then this option should be '
                                           'set to \'slcs-admin\'. '
                                           'See https://docs.pylonsproject.org/projects/waitress/en/latest/#using-url-prefix-to-influence-script-name-and-path-info.',
                                      required=False,
                                      metavar='slcs-admin')
    proxy_settings_group.add_argument('-xf', '--use-x-forwarded-host',
                                      help='Enables ALLOWED_HOSTS to match against the X_FORWARDED_HOST HTTP header '
                                           'instead of the HTTP HOST header. '
                                           'See https://docs.djangoproject.com/en/1.9/ref/settings/#use-x-forwarded-host',
                                      required=False,
                                      action='store_true')

    slcs_db_group = parser.add_argument_group(title='SLCS Database Settings',
                                              description='Settings used for connecting to the SLCS database.')
    slcs_db_group.add_argument('-sdn', '--slcs-database-name',
                               help='The SLCS database name.',
                               required=True,
                               metavar='esgf_slcs_server')
    slcs_db_group.add_argument('-sdu', '--slcs-database-user',
                               help='The SLCS database user.',
                               required=True,
                               metavar='db_user')
    slcs_db_group.add_argument('-sdh', '--slcs-database-host',
                               help='The SLCS database host.',
                               required=True,
                               metavar='slcsdb.esgf.org')

    slcs_db_group.add_argument('-sdp', '--slcs-database-port',
                               help='The SLCS database port.',
                               required=False,
                               default=5432,
                               metavar=5432)
    slcs_db_group.add_argument('-sde', '--slcs-database-engine',
                               help='The engine to use for the SLCS database.',
                               required=False,
                               choices=['django.db.backends.postgresql', 'django.db.backends.mysql',
                                        'django.db.backends.sqlite3', 'django.db.backends.oracle'],
                               default='django.db.backends.postgresql',
                               metavar='django.db.backends.postgresql')

    user_db_group = parser.add_argument_group(title='User Database Settings',
                                              description='Settings used for connecting to the User database.')

    user_db_group.add_argument('-udn', '--user-database-name',
                               help='The User database name.',
                               required=True,
                               metavar='esgf_slcs_server')
    user_db_group.add_argument('-udu', '--user-database-user',
                               help='The User database user.',
                               required=True,
                               metavar='db_user')
    user_db_group.add_argument('-udh', '--user-database-host',
                               help='The User database host.',
                               required=True,
                               metavar='slcsdb.esgf.org')
    user_db_group.add_argument('-udt', '--user-database-table',
                               help='The name of the User table',
                               required=False,
                               default='user',
                               metavar='user')
    user_db_group.add_argument('-uds', '--user-database-schema',
                               help='The name of the schema that contains the User table',
                               required=False,
                               default='esgf_security',
                               metavar='esgf_security')
    user_db_group.add_argument('-udp', '--user-database-port',
                               help='The User database port.',
                               required=False,
                               default=5432,
                               metavar=5432)
    user_db_group.add_argument('-ude', '--user-database-engine',
                               help='The engine to use for the User database.',
                               required=False,
                               choices=['django.db.backends.postgresql', 'django.db.backends.mysql',
                                        'django.db.backends.sqlite3', 'django.db.backends.oracle'],
                               default='django.db.backends.postgresql',
                               metavar='django.db.backends.postgresql')

    parser.add_argument('-se', '--server-email',
                        help='The email address used when sending emails. Defaults to no-reply@[--server-name].',
                        required=False,
                        metavar='no-reply@my-node.esgf.org')

    parser.add_argument('-ccf', '--cacert-chain-filepaths',
                        help='List of PEM-encoded certificate files corresponding to CA trustroot '
                             'files to be returned in the certificate issuing response. '
                             'These are concatenated with the new issued certificate. '
                             'This setting is optional and may be useful where the client''s trust roots do not '
                             'contain the complete chain of trust from the newly issued cert and a root certificate. '
                             'This option does not apply if the CA for this service is itself a root CA.',
                        required=False,
                        nargs='+',
                        metavar='/usr/local/esgf-slcs-server/conf/ca/08bd99c7.0')

    parser.add_argument('-dd', '--django-debug',
                        help='Enable Django debug mode.',
                        required=False,
                        action='store_true')

    parser.add_argument('-da', '--django-admin',
                        help='https://docs.djangoproject.com/en/1.10/ref/settings/#admins',
                        nargs='+',
                        required=False,
                        default=[],
                        metavar=('John Doe,john@example.com', 'Mary,mary@example.com'))

    args = parser.parse_args()

    if args.server_email is None:
        args.server_email = "no-reply@{0}".format(args.server_name)

    return args


def replace_in_file(file_path, replacements):
    lines = []
    with open(file_path) as infile:
        for line in infile:
            for src, target in replacements.iteritems():
                line = line.replace(src, target)
            lines.append(line)
    with open(file_path, 'w') as outfile:
        for line in lines:
            outfile.write(line)


def wait_for_db(db_host, db_port):
    attempts = 20
    sleep = 0.25
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    while True:
        try:
            if attempts >= 0:
                s.connect((db_host, db_port))
                s.close()
                break
            else:
                raise IOError(
                    "Timed out waiting to connect to {}:{}. Is the database available?".format(db_host, db_port))
        except socket.error:
            attempts -= 1
            time.sleep(sleep)


the_args = parse_args()

os.environ['SLCS_SERVER_NAME'] = the_args.server_name
os.environ['SLCS_USE_X_FORWARDED_HOST'] = str(the_args.use_x_forwarded_host)
os.environ['SLCS_STATIC_URL'] = the_args.static_url
if the_args.url_prefix:
    os.environ['SLCS_SERVER_ROOT'] = "https://{0}/{1}".format(the_args.server_name, the_args.url_prefix)
else:
    os.environ['SLCS_SERVER_ROOT'] = "https://{0}".format(the_args.server_name)

os.environ['SLCS_DB_SLCS_ENGINE'] = the_args.slcs_database_engine
os.environ['SLCS_DB_SLCS_NAME'] = the_args.slcs_database_name
os.environ['SLCS_DB_SLCS_HOST'] = the_args.slcs_database_host
os.environ['SLCS_DB_SLCS_PORT'] = str(the_args.slcs_database_port)
os.environ['SLCS_DB_SLCS_USER'] = the_args.slcs_database_user

os.environ['SLCS_DB_USER_ENGINE'] = the_args.user_database_engine
os.environ['SLCS_DB_USER_NAME'] = the_args.user_database_name
os.environ['SLCS_DB_USER_HOST'] = the_args.user_database_host
os.environ['SLCS_DB_USER_PORT'] = str(the_args.user_database_port)
os.environ['SLCS_DB_USER_USER'] = the_args.user_database_user
os.environ['SLCS_DB_USER_TABLE'] = the_args.user_database_table
os.environ['SLCS_DB_USER_SCHEMA'] = the_args.user_database_schema

os.environ['SLCS_DJANGO_DEBUG_MODE'] = str(the_args.django_debug)
os.environ['SLCS_SERVER_EMAIL'] = the_args.server_email
os.environ['SLCS_ADMINS'] = ';'.join(the_args.django_admin)

# Make sure we can reach the DBs
wait_for_db(the_args.slcs_database_host, the_args.slcs_database_port)
wait_for_db(the_args.user_database_host, the_args.user_database_port)

APPLICATION_HOME = os.environ['APPLICATION_HOME']

db_conf_dir = os.path.join(os.environ['APPLICATION_HOME'], 'conf', 'db')
assert os.path.isfile(os.path.join(db_conf_dir, 'slcsdb_passwd.txt')), \
    "{0} must be mounted as a volume and contain slcsdb_passwd.txt, userdb_passwd.txt, " \
    "and django_superuser_passwd.txt".format(db_conf_dir)
assert os.path.isfile(os.path.join(db_conf_dir, 'userdb_passwd.txt')), \
    "{0} must be mounted as a volume and contain slcsdb_passwd.txt, userdb_passwd.txt, " \
    "and django_superuser_passwd.txt".format(db_conf_dir)
assert os.path.isfile(os.path.join(db_conf_dir, 'django_superuser_passwd.txt')), \
    "{0} must be mounted as a volume and contain slcsdb_passwd.txt, userdb_passwd.txt, " \
    "and django_superuser_passwd.txt".format(db_conf_dir)

with open(os.path.join(db_conf_dir, 'django_superuser_passwd.txt')) as pass_file:
    django_su_password = pass_file.read()

ca_conf_dir = os.path.join(APPLICATION_HOME, 'conf', 'ca')
assert os.path.isfile(os.path.join(ca_conf_dir, 'onlineca.crt')), \
    "{0} must be mounted as a volume and contain onlineca.crt and onlineca.key and a directory called trustroots".format(
        ca_conf_dir)
assert os.path.isfile(os.path.join(ca_conf_dir, 'onlineca.key')), \
    "{0} must be mounted as a volume and contain onlineca.crt and onlineca.key and a directory called trustroots".format(
        ca_conf_dir)
assert os.path.isdir(os.path.join(ca_conf_dir, 'trustroots')), \
    "{0} must be mounted as a volume and contain onlineca.crt and onlineca.key and a directory called trustroots".format(
        ca_conf_dir)

app_conf_dir = os.environ['APPLICATION_CONF_DIR']
online_ca_ini = os.path.join(app_conf_dir, 'onlineca.ini')

cacert_chain_filepaths = "onlineca.server.cacert_chain_filepaths: {0}".format(
    ','.join(the_args.cacert_chain_filepaths)) if the_args.cacert_chain_filepaths else "#"
replace_in_file(online_ca_ini, {
    "{{ onlineca_cacert_chain_filepaths }}": cacert_chain_filepaths,
    "{{ application_home }}": APPLICATION_HOME})

subprocess.check_call(["/usr/bin/python2.7", "{0}/manage.py".format(os.environ['CODE_LOCATION']), "makemigrations"])
subprocess.check_call(["/usr/bin/python2.7", "{0}/manage.py".format(os.environ['CODE_LOCATION']), "migrate"])

try:
    subprocess.check_output(
        ["/usr/bin/python2.7", "{0}/manage.py".format(os.environ['CODE_LOCATION']), "createsuperuser", "--noinput",
         "--username={0}".format(the_args.django_superuser), "--email=notused@notused.com"], stderr=subprocess.STDOUT)
except subprocess.CalledProcessError as cpe:
    if "duplicate key value violates unique constraint" not in cpe.output:
        raise IOError("Error creating django superuser\n{0}".format(cpe.output))

subprocess.check_call(
    ["/usr/bin/python2.7", "{0}/manage.py".format(os.environ['CODE_LOCATION']), "collectstatic", "--noinput"])

subprocess.check_call(["waitress-serve", "--listen=*:5000", "--url-prefix={}".format(the_args.url_prefix),
                       "esgf_slcs_server.wsgi:application"])
