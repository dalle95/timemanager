from app import db, login
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import UserMixin
from hashlib import md5
from datetime import datetime

@login.user_loader
def load_user(id):
    return User.query.get(int(id))

class User(UserMixin, db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), index=True, unique=True)
    email = db.Column(db.String(120), index=True, unique=True)
    password_hash = db.Column(db.String(128))
    last_seen = db.Column(db.DateTime, default=datetime.utcnow)
    impostazioni = db.relationship('Impostazioni', backref='owner', lazy='dynamic')
    items = db.relationship('Item', backref='owner', lazy='dynamic')
    negozi = db.relationship('Negozio', backref='owner', lazy='dynamic')
    bots = db.relationship('Bot', backref='owner', lazy='dynamic')
    proxies = db.relationship('Proxy', backref='owner', lazy='dynamic')
    clienti = db.relationship('Cliente', backref='owner', lazy='dynamic')
    costi = db.relationship('Costo', backref='owner', lazy='dynamic')
    def __repr__(self):
        return '<User {}>'.format(self.username)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def avatar(self, size):
        digest = md5(self.email.lower().encode('utf-8')).hexdigest()
        return 'https://www.gravatar.com/avatar/{}?d=identicon&s={}'.format(
            digest, size)

    def own_impostazioni(self):
        return Impostazioni.query.filter(Impostazioni.user_id == self.id)

    def own_items(self):
        return Item.query.filter(Item.user_id == self.id)

    def own_negozi(self):
        return Negozio.query.filter(Negozio.user_id == self.id)

    def own_bots(self):
        return Bot.query.filter(Bot.user_id == self.id)

    def own_proxies(self):
        return Proxy.query.filter(Proxy.user_id == self.id)

    def own_clienti(self):
        return Cliente.query.filter(Cliente.user_id == self.id)

    def own_costi(self):
        return Costo.query.filter(Costo.user_id == self.id)


class Impostazioni(db.Model):
    __tablename__ = 'impostazioni'
    id = db.Column(db.Integer, primary_key=True)
    #Sezione notifiche mail
    #Sezione notifiche scadenze mensile
    notifiche_mensili = db.Column(db.Boolean)

    #Sezione notifiche per resi degli Items
    notifiche_scadenze_resi = db.Column(db.Boolean)
    notifica_giorni_anticipo_resi = db.Column(db.Integer)
    #Sezione notifiche per la scadenza bot
    notifiche_scadenze_bot = db.Column(db.Boolean)
    notifica_giorni_anticipo_bot = db.Column(db.Integer)
    # Sezione notifiche per la scadenza proxy
    notifiche_scadenze_proxy = db.Column(db.Boolean)
    notifica_giorni_anticipo_proxy = db.Column(db.Integer)

    #Sezione Homepage
    #Sezione visualizzazione per resi degli Items
    homepage_scadenze_resi = db.Column(db.Boolean)
    homepage_giorni_anticipo_resi = db.Column(db.Integer)
    #Sezione visualizzazione per la scadenza bot
    homepage_scadenze_bot = db.Column(db.Boolean)
    homepage_giorni_anticipo_bot = db.Column(db.Integer)
    # Sezione visualizzazione per la scadenza proxy
    homepage_scadenze_proxy = db.Column(db.Boolean)
    homepage_giorni_anticipo_proxy = db.Column(db.Integer)

    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

    def __repr__(self):
        return '<Profilo {}>'.format(self.id)


class Item(db.Model):
    __tablename__ = 'item'
    # Acquisito
    id = db.Column(db.Integer, primary_key=True)
    codice = db.Column(db.String(50), index=True)
    descrizione = db.Column(db.String(100), index=True)
    stato = db.Column(db.String(100), index=True)
    sku = db.Column(db.String(100), index=True)
    region = db.Column(db.String(100), index=True)
    prezzo = db.Column(db.Numeric, index=True)
    spedizione_acquisto = db.Column(db.Numeric, index=True)
    reship = db.Column(db.Numeric, index=True)
    slot = db.Column(db.Numeric(100), index=True)
    data_ordine = db.Column(db.DateTime, index=True)
    consegna_stesso_giorno = db.Column(db.Boolean, index=True)
    data_consegna = db.Column(db.DateTime, index=True)
    data_scadenza_reso = db.Column(db.DateTime, index=True)
    proxy = db.Column(db.String(100), index=True)
    bot = db.Column(db.String(100), index=True)
    negozio = db.Column(db.String(100), index=True)
    taglia = db.Column(db.String(100), index=True)
    strategia = db.Column(db.String(100), index=True)
    # Vendita
    incasso = db.Column(db.Numeric, index=True)
    spedizione_vendita = db.Column(db.Numeric, index=True)
    fee_reship = db.Column(db.Numeric, index=True)
    data_vendita = db.Column(db.DateTime, index=True)
    incasso_stesso_giorno = db.Column(db.Boolean, index=True)
    data_incasso = db.Column(db.DateTime, index=True)
    canale = db.Column(db.String(100), index=True)
    contatto = db.Column(db.String(100), index=True)
    tipologia = db.Column(db.String(100), index=True)
    # Sezione Economica
    prezzo_totale = db.Column(db.Numeric, index=True)
    ricavi_lordi = db.Column(db.Numeric, index=True)
    ricavi_netti =  db.Column(db.Numeric, index=True)
    # Organizzazione
    data_creazione = db.Column(db.DateTime, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))


    def __repr__(self):
        return '<Item {}>'.format(self.codice)

    def to_dict(self):
        return {
            'codice': self.codice,
            'descrizione': self.descrizione,
            'negozio': self.negozio,
            #'region': self.region,
            'prezzo': self.prezzo,
            'data_ordine': self.data_ordine,
            'incasso': self.incasso,
            'data_vendita': self.data_vendita
        }


class Negozio(db.Model):
    __tablename__ = 'negozio'
    id = db.Column(db.Integer, primary_key=True)
    descrizione = db.Column(db.String(100), index=True)
    giorni_reso = db.Column(db.Integer)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

    def __repr__(self):
        return '<Negozio {}>'.format(self.descrizione)


class Bot(db.Model):
    __tablename__ = 'bot'
    id = db.Column(db.Integer, primary_key=True)
    codice = db.Column(db.String(50), index=True)
    descrizione = db.Column(db.String(100), index=True)
    costo = db.Column(db.Numeric, index=True)
    data_attivazione = db.Column(db.DateTime, index=True)
    scadenza_giorni = db.Column(db.Integer, index=True)
    data_scadenza = db.Column(db.DateTime, index=True)
    salva_rinnovo = db.Column(db.Boolean, index=True)
    data_creazione = db.Column(db.DateTime, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

    def __repr__(self):
        return '<Bot {}>'.format(self.codice)


class Proxy(db.Model):
    __tablename__ = 'proxy'
    id = db.Column(db.Integer, primary_key=True)
    codice = db.Column(db.String(50), index=True)
    descrizione = db.Column(db.String(100), index=True)
    costo = db.Column(db.Numeric, index=True)
    data_attivazione = db.Column(db.DateTime, index=True)
    scadenza_giorni = db.Column(db.Integer, index=True)
    data_scadenza = db.Column(db.DateTime, index=True)
    salva_rinnovo = db.Column(db.Boolean, index=True)
    data_creazione = db.Column(db.DateTime, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

    def __repr__(self):
        return '<Proxy {}>'.format(self.codice)


class Cliente(db.Model):
    __tablename__ = 'cliente'
    id = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(100), index=True)
    numero_telefono = db.Column(db.String(100), index=True)
    taglia = db.Column(db.String(100), index=True)
    colore_preferito = db.Column(db.String(100), index=True)
    note = db.Column(db.String(250), index=True)

    data_creazione = db.Column(db.DateTime, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

    def __repr__(self):
        return '<Cliente {}>'.format(self.nome)

    def contatti_cliente(self):
        return Cliente_Contatti.query.filter(Cliente_Contatti.cliente_id == self.id)


class Cliente_Contatti(db.Model):
    __tablename__ = 'cliente_contatti'
    id = db.Column(db.Integer, primary_key=True)
    cliente_id = db.Column(db.Integer, db.ForeignKey('cliente.id'))

    social = db.Column(db.String(100), index=True)
    nome = db.Column(db.String(100), index=True)
    note = db.Column(db.String(250), index=True)

    data_creazione = db.Column(db.DateTime, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

    def __repr__(self):
        return '<Contatti {}>'.format(self.nome)


class Costo(db.Model):
    __tablename__ = 'costo'
    id = db.Column(db.Integer, primary_key=True)
    descrizione = db.Column(db.String(150), index=True)
    tipologia = db.Column(db.String(100), index=True)
    fatturazione = db.Column(db.String(100), index=True)
    costo = db.Column(db.Numeric, index=True)
    costo_attivo = db.Column(db.Boolean, index=True)
    data_inizio = db.Column(db.DateTime, index=True)
    data_fine = db.Column(db.DateTime, index=True)

    data_prox_pagamento = db.Column(db.DateTime, index=True)
    data_ultimo_pagamento = db.Column(db.DateTime, index=True)

    note = db.Column(db.String(250), index=True)

    data_creazione = db.Column(db.DateTime, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

    def __repr__(self):
        return '<Costo {}>'.format(self.descrizione)

    #def storico_costi(self):
    #    return Cliente_Contatti.query.filter(Cliente_Contatti.cliente_id == self.id)


class Costo_Storico_Pagamenti(db.Model):
    __tablename__ = 'costo_storico_pagamenti'
    id = db.Column(db.Integer, primary_key=True)
    costo_id = db.Column(db.Integer, db.ForeignKey('costo.id'))

    descrizione = db.Column(db.String(100), index=True)
    costo = db.Column(db.Numeric, index=True)
    data_pagamento = db.Column(db.DateTime, index=True)
    note = db.Column(db.String(250), index=True)

    data_creazione = db.Column(db.DateTime, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

    def __repr__(self):
        return '<Storico Pagamento {}>'.format(self.nome)
