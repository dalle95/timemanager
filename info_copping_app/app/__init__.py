from flask import Flask
from config import Config
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from flask_mail import Mail
import os
import logging
from logging.handlers import SMTPHandler, RotatingFileHandler
import psycopg2

app = Flask(__name__)  # Per definire l'init dell'app
app.config.from_object(Config)  # Per recuperare il file di configurazione
db = SQLAlchemy(app)  # Per utilizzare il DB
migrate = Migrate(app, db)  # Per gestire la migrazione del DB
login = LoginManager(app)  # Per gestire il login degli utenti
login.login_view = 'login'  # Per gestire il 'login_required'
mail = Mail(app)  # Per gestire l'invio email

#conn = psycopg2.connect(dbname='APP_DB_TEST', user='APP_DB', password='KaJUk4azBXAGjX$', host='192.168.1.12', port='8484')
conn = psycopg2.connect(dbname='APP_DB', user='APP_DB', password='KaJUk4azBXAGjX$', host='localhost', port='5432')


if not app.debug:
    if app.config['MAIL_SERVER']:
        auth = None
        if app.config['MAIL_USERNAME'] or app.config['MAIL_PASSWORD']:
            auth = (app.config['MAIL_USERNAME'], app.config['MAIL_PASSWORD'])
        secure = None
        if app.config['MAIL_USE_TLS']:
            secure = ()
        mail_handler = SMTPHandler(
            mailhost=(app.config['MAIL_SERVER'], app.config['MAIL_PORT']),
            fromaddr='no-reply@' + app.config['MAIL_SERVER'],
            toaddrs=app.config['ADMINS'], subject='Info Copping Failure',
            credentials=auth, secure=secure)
        mail_handler.setLevel(logging.ERROR)
        app.logger.addHandler(mail_handler)
    if not os.path.exists('logs'):
        os.mkdir('logs')
    file_handler = RotatingFileHandler('logs/info_copping.log', maxBytes=10240,
                                       backupCount=10)
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'))
    file_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)

    app.logger.setLevel(logging.INFO)
    app.logger.info('Info Copping startup')

from app import routes, forms, models, errors, email
