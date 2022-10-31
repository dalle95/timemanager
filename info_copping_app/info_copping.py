from app import app, db
from app.models import User, Item, Negozio, Bot, Proxy

if __name__ == '__main__':
    app.run(host='0.0.0.0', port='8080', debug=False)


@app.shell_context_processor
def make_shell_context():
    return {'db': db, 'User': User, 'Item': Item, 'Negozio': Negozio, 'Bot': Bot, 'Proxy': Proxy}
