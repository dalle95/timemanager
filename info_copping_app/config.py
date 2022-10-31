import os
basedir = os.path.abspath(os.path.dirname(__file__))


class Config(object):
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'K-vXT9hTh.9KL6S'
    UPLOAD_FOLDER =  r"C:\Users\Administrator\Desktop\Infocopping\info_copping - official\uploads"
    ALLOWED_EXTENSIONS = {'csv'} # os.environ.get('ALLOWED_EXTENSIONS')
    #SQLALCHEMY_DATABASE_URI = 'postgresql://APP_DB:KaJUk4azBXAGjX$@192.168.1.12:8484/APP_DB_TEST' # os.environ.get('DATABASE_URL')  # 'sqlite:///' + os.path.join(basedir, 'app.db')
    SQLALCHEMY_DATABASE_URI = 'postgresql://APP_DB:KaJUk4azBXAGjX$@localhost/APP_DB'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    POSTS_PER_PAGE = 10


    # Configurazione server Mail
    MAIL_SERVER = 'smtp.googlemail.com' # os.environ.get('MAIL_SERVER')
    MAIL_PORT = 587 # int(os.environ.get('MAIL_PORT') or 587)
    MAIL_USE_TLS = 1 # os.environ.get('MAIL_USE_TLS') is not None
    MAIL_USERNAME = 'infocopping.notifier@gmail.com' # os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = 'infocopping_2022' # os.environ.get('MAIL_PASSWORD')
    ADMINS = ['infocopping.notifier@gmail.com']
