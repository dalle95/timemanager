from app import app, db
from app.models import User, Item, Negozio, Bot, Proxy, Cliente
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, TextAreaField, DecimalField, DateField, SelectField, IntegerField, ValidationError
from wtforms.validators import DataRequired, Length, Optional, Email, EqualTo
from flask_login import current_user
from sqlalchemy import func, extract, cast
from datetime import datetime, date, timedelta


class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Sign In')


class RegistrationForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    password2 = PasswordField(
        'Repeat Password', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Register')

    def validate_username(self, username):
        user = User.query.filter_by(username=username.data).first()
        if user is not None:
            raise ValidationError('Please use a different username.')

    def validate_email(self, email):
        user = User.query.filter_by(email=email.data).first()
        if user is not None:
            raise ValidationError('Please use a different email address.')


class ProfileForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    password2 = PasswordField(
        'Repeat Password', validators=[DataRequired(), EqualTo('password')])
    #submit = SubmitField('Salva')


class ItemForm(FlaskForm):
    # Acquisto
    codice = StringField('Codice')
    descrizione = StringField('Descrizione', validators=[Length(min=0, max=100)])
    stato = StringField('Stato')
    sku = StringField('SKU')
    region = SelectField('Region',
                         choices=[('', ''), ('AT', 'AT'), ('AU', 'AU'), ('BE', 'BE'), ('CZ', 'CZ'), ('DE', 'DE'), ('DK', 'DK'), ('ES', 'ES'), ('FR', 'FR'), ('GR', 'GR'), ('HK', 'HK'), ('HU', 'HU'), ('IE', 'IE'), ('IT', 'IT'), ('LU', 'LU'), ('MY', 'MY'), ('NL', 'NL'), ('NO', 'NO'), ('PL', 'PL'), ('PT', 'PT'), ('SE', 'SE'), ('SG', 'SG'), ('UK', 'UK'), ('US', 'US')]
                         )
    prezzo = DecimalField('Prezzo', validators=[DataRequired()])
    spedizione_acquisto = DecimalField('Spedizione - Aquisto', validators=[Optional()])
    reship = DecimalField('Reship', validators=[Optional()])
    slot = DecimalField('Slot', validators=[Optional()])
    data_ordine = DateField('Data Ordine', format='%Y-%m-%d')
    consegna_stesso_giorno = BooleanField('Consegna stesso giorno', validators=[Optional()])
    data_consegna = DateField('Data Consegna', format='%Y-%m-%d', validators=[Optional()])
    data_scadenza_reso = DateField('Data Scadenza Reso', format='%Y-%m-%d', validators=[Optional()])
    proxy = SelectField('Proxy')
    bot = SelectField('Bot')
    negozio = SelectField('Shop', validators=[DataRequired()])
    taglia = StringField('Taglia')
    tipologia = SelectField('Tipologia', choices=[('',''),('Sneaker','Sneaker'), ('Abbigliamento','Abbigliamento'), ('Altro','Altro')])
    strategia = SelectField('Strategia', choices=[('-', '-'), ('Preorder', 'Preorder'), ('Flip', 'Flip'), ('Hold', 'Hold')])

    # Vendita
    incasso = DecimalField('Incasso', validators=[Optional()])
    spedizione_vendita = DecimalField('Spedizione - Vendita', validators=[Optional()])
    fee_reship = DecimalField('Fee Reship', validators=[Optional()])
    data_vendita = DateField('Data Vendita', format='%Y-%m-%d', validators=[Optional()])
    incasso_stesso_giorno = BooleanField('Incasso stesso giorno', validators=[Optional()])
    data_incasso = DateField('Data Incasso', format='%Y-%m-%d', validators=[Optional()])
    canale = StringField('Canale')
    cliente = StringField('Cliente')

    submit_salva = SubmitField('Salva')
    submit_elimina = SubmitField('Elimina')

    def __init__(self):
        super(ItemForm, self).__init__()
        self.negozio.choices = [("", "")]+[(negozio.descrizione, negozio.descrizione) for negozio in current_user.own_negozi().order_by(Negozio.descrizione.asc())]
        self.bot.choices = [("", "")]+[(bot.descrizione, bot.descrizione) for bot in current_user.own_bots().order_by(Bot.descrizione.asc())]
        self.proxy.choices = [("", "")]+[(proxy.descrizione, proxy.descrizione) for proxy in current_user.own_proxies().order_by(Proxy.descrizione.asc())]
        #self.cliente.choices = [("", "")] + [(cliente.nome, cliente.nome) for cliente in current_user.own_clienti().order_by(Cliente.nome.asc())]


class ItemStatiForm(FlaskForm):
    acquisto = SubmitField('Acquisto')
    venduto = SubmitField('Venduto')
    attesa_vendita = SubmitField('Attesa Vendita')
    reso = SubmitField('Reso')


class ItemRicercaForm(FlaskForm):
    stato = SelectField('Stato', choices=[(' ', ' '), ('Acquisto', 'Acquisto'), ('Vendita', 'Vendita'), ('Attesa Vendita', 'Attesa Vendita'), ('Reso','Reso')])
    descrizione = StringField('Descrizione')
    tipologia = SelectField('Tipologia', choices=[('', ''), ('Sneaker', 'Sneaker'), ('Abbigliamento', 'Abbigliamento'),
                                                  ('Altro', 'Altro')])
    strategia = SelectField('Strategia',
                            choices=[('', ''), ('-', '-'), ('Preorder', 'Preorder'), ('Flip', 'Flip'), ('Hold', 'Hold')])
    submit_cerca = SubmitField('Cerca')


class BulkItemsForm(FlaskForm):
    descrizione = StringField('Descrizione', validators=[Length(min=0, max=100)])
    sku = StringField('SKU')
    region = SelectField('Region',
                         choices=[('', ''), ('AT', 'AT'), ('AU', 'AU'), ('BE', 'BE'), ('CZ', 'CZ'), ('DE', 'DE'),
                                  ('DK', 'DK'), ('ES', 'ES'), ('FR', 'FR'), ('GR', 'GR'), ('HK', 'HK'), ('HU', 'HU'),
                                  ('IE', 'IE'), ('IT', 'IT'), ('LU', 'LU'), ('MY', 'MY'), ('NL', 'NL'), ('NO', 'NO'),
                                  ('PL', 'PL'), ('PT', 'PT'), ('SE', 'SE'), ('SG', 'SG'), ('UK', 'UK'), ('US', 'US')]
                         )
    prezzo = DecimalField('Prezzo', validators=[DataRequired()])
    spedizione_acquisto = DecimalField('Spedizione - Aquisto', validators=[Optional()])
    reship = DecimalField('Reship', validators=[Optional()])
    slot = DecimalField('Slot', validators=[Optional()])
    data_ordine = DateField('Data Ordine', format='%Y-%m-%d')
    consegna_stesso_giorno = BooleanField('Consegna stesso giorno', validators=[Optional()])
    data_consegna = DateField('Data Consegna', format='%Y-%m-%d', validators=[Optional()])
    data_scadenza_reso = DateField('Data Scadenza Reso', format='%Y-%m-%d', validators=[Optional()])
    proxy = SelectField('Proxy')
    bot = SelectField('Bot')
    negozio = SelectField('Shop')
    tipologia = SelectField('Tipologia', choices=[('',''),('Sneaker','Sneaker'), ('Abbigliamento','Abbigliamento'), ('Altro','Altro')])
    strategia = SelectField('Strategia', choices=[('-', '-'), ('Preorder', 'Preorder'), ('Flip', 'Flip'), ('Hold', 'Hold')])


class ImpostazioniForm(FlaskForm):
    notifiche_mensili = BooleanField('Notifiche mensili', validators=[Optional()])

    notifiche_scadenze_resi = BooleanField('Notifiche Resi', validators=[Optional()])
    notifica_giorni_anticipo_resi = IntegerField('Giorni di anticipo per la notifica', validators=[Optional()])

    notifiche_scadenze_bot = BooleanField('Notifiche Scadenza Bot', validators=[Optional()])
    notifica_giorni_anticipo_bot = IntegerField('Giorni di anticipo per la notifica', validators=[Optional()])

    notifiche_scadenze_proxy = BooleanField('Notifiche Scadenza Proxy', validators=[Optional()])
    notifica_giorni_anticipo_proxy = IntegerField('Giorni di anticipo per la notifica', validators=[Optional()])

    homepage_scadenze_resi = BooleanField('Visualizzazione Resi', validators=[Optional()])
    homepage_giorni_anticipo_resi = IntegerField('Giorni di anticipo per la visualizzazione', validators=[Optional()])

    homepage_scadenze_bot = BooleanField('Visualizzazione Scadenza Bot', validators=[Optional()])
    homepage_giorni_anticipo_bot = IntegerField('Giorni di anticipo per la visualizzazione', validators=[Optional()])

    homepage_scadenze_proxy = BooleanField('Visualizzazione Scadenza Proxy', validators=[Optional()])
    homepage_giorni_anticipo_proxy = IntegerField('Giorni di anticipo per la visualizzazione', validators=[Optional()])
    submit_salva = SubmitField('Salva')


class NegozioForm(FlaskForm):
    descrizione = StringField('Descrizione', validators=[DataRequired(), Length(min=0, max=100)])
    giorni_reso = IntegerField('Giorni per reso', validators=[DataRequired()])
    submit_salva = SubmitField('Salva')
    submit_elimina = SubmitField('Elimina')


class BotForm(FlaskForm):
    codice = StringField('Codice')
    descrizione = StringField('Descrizione', validators=[Length(min=0, max=100)])
    costo = DecimalField('Prezzo', validators=[DataRequired()])
    data_attivazione = DateField('Data Attivazione', format='%Y-%m-%d', validators=[DataRequired()])
    scadenza_giorni = IntegerField('Scadenza in giorni', validators=[DataRequired()])
    data_scadenza = DateField('Data Scadenza', format='%Y-%m-%d', validators=[Optional()])
    salva_rinnovo = BooleanField('Salva rinnovo', validators=[Optional()])
    submit_salva = SubmitField('Salva')


class ProxyForm(FlaskForm):
    codice = StringField('Codice')
    descrizione = StringField('Descrizione', validators=[Length(min=0, max=100)])
    costo = DecimalField('Prezzo', validators=[DataRequired()])
    data_attivazione = DateField('Data Attivazione', format='%Y-%m-%d', validators=[DataRequired()])
    scadenza_giorni = IntegerField('Scadenza in giorni', validators=[DataRequired()])
    data_scadenza = DateField('Data Scadenza', format='%Y-%m-%d', validators=[Optional()])
    salva_rinnovo = BooleanField('Salva rinnovo', validators=[Optional()])
    submit_salva = SubmitField('Salva')


class StatisticheForm(FlaskForm):
    filtro_mese_anno = SelectField('Filtro')
    submit = SubmitField('Vedi statistiche')

    def __init__(self):
        super(StatisticheForm, self).__init__()
        sub_query_estrazione_mese_anno_a = current_user.own_items()\
                                                     .with_entities(
                                                                    func.concat(extract('year', Item.data_ordine),' - ',extract('month', Item.data_ordine)).label('mese_anno'),
                                                                    Item.data_ordine
                                                                    )\
                                                    .order_by(Item.data_ordine.asc())\
                                                    .subquery()

        query_mese_anno_a = db.session.query(sub_query_estrazione_mese_anno_a.c.mese_anno.label('mese_anno'))\
                                                        .group_by('mese_anno')\


        sub_query_estrazione_mese_anno_v = current_user.own_items()\
                                                     .with_entities(
                                                                    func.concat(extract('year', Item.data_vendita),' - ',extract('month', Item.data_vendita)).label('mese_anno'),
                                                                    Item.data_ordine
                                                                    ) \
                                                    .filter(Item.data_vendita != None)\
                                                    .order_by(Item.data_vendita.asc())\
                                                    .subquery()

        query_mese_anno_v = db.session.query(sub_query_estrazione_mese_anno_v.c.mese_anno.label('mese_anno'))\
                                                        .group_by('mese_anno')\

        sub_query_mese_anno = query_mese_anno_a.union(query_mese_anno_v)\
                                            .subquery()

        query_mese_anno = db.session.query(sub_query_mese_anno.c.mese_anno.label("mese_anno"))\
                                            .order_by("mese_anno")\
                                            .all()

        lista_mese_anno = []
        for anno_mese in query_mese_anno:
            num_anno = str(anno_mese.mese_anno).split(' - ')[0]
            num_mese = str(anno_mese.mese_anno).split(' - ')[1]
            if num_mese == '1':
                mese = 'Gennaio'
            elif num_mese == '2':
                mese = 'Febbraio'
            elif num_mese == '3':
                mese = 'Marzo'
            elif num_mese == '4':
                mese = 'Aprile'
            elif num_mese == '5':
                mese = 'Maggio'
            elif num_mese == '6':
                mese = 'Giugno'
            elif num_mese == '7':
                mese = 'Luglio'
            elif num_mese == '8':
                mese = 'Agosto'
            elif num_mese == '9':
                mese = 'Settembre'
            elif num_mese == '10':
                mese = 'Ottobre'
            elif num_mese == '11':
                mese = 'Novembre'
            elif num_mese == '12':
                mese = 'Dicembre'
            else:
                mese = 'Errore'
            lista_mese_anno.append(((mese+' '+num_anno),(num_mese+' - '+num_anno)))
        self.filtro_mese_anno.choices = [(0, "")]+[(mese_anno[1], mese_anno[0]) for mese_anno in lista_mese_anno]


class ClienteForm(FlaskForm):
    nome = StringField('Nome', validators=[Length(min=0, max=100)])
    numero_telefono = StringField('Numero di telefono')
    taglia = StringField('Taglia')
    colore_preferito = StringField('Colore preferito')
    note = TextAreaField('Note')

    submit_salva = SubmitField('Salva')


class ClienteContattiForm(FlaskForm):
    social = SelectField('Social',
                         choices=[('', ''), ('Instagram', 'Instagram'), ('Depop', 'Depop'), ('Vinted', 'Vinted'),
                                   ('Discord', 'Discord')])
    nome = StringField('Nome', validators=[Length(min=0, max=100)])

    id = StringField('id')

    submit_aggiungi = SubmitField('Aggiungi')
    submit_aggiorna = SubmitField('Aggiorna')


class CostoForm(FlaskForm):
    descrizione = StringField('Nome', validators=[Length(min=0, max=100)])
    tipologia = StringField('Tipologia')
    fatturazione = SelectField('Fatturazione',
                             choices=[('', ''), ('Mensile', 'Mensile'), ('Bimestrale', 'Bimestrale'), ('Trimestrale', 'Trimestrale'),
                                      ('Semestrale', 'Semestrale'), ('Annuale', 'Annuale')], validators=[DataRequired()])
    costo = DecimalField('Costo', validators=[DataRequired()])
    costo_attivo = BooleanField('Costo attivo')
    data_inizio = DateField('Data di inizio', format='%Y-%m-%d', validators=[Optional()])
    data_fine = DateField('Data di fine', format='%Y-%m-%d', validators=[Optional()])
    data_prox_pagamento = DateField('Data del prossimo pagamento', format='%Y-%m-%d', validators=[Optional()])
    data_ultimo_pagamento = DateField('Data dell\'ultimo pagamento', format='%Y-%m-%d', validators=[Optional()])
    note = TextAreaField('Note')

    submit_salva = SubmitField('Salva')
    submit_elimina = SubmitField('Elimina')


class PagamentoForm(FlaskForm):
    descrizione = StringField('Descrizione', validators=[DataRequired()])
    costo = DecimalField('Costo', validators=[DataRequired()])
    data_pagamento = DateField('Data di pagamento', format='%Y-%m-%d', validators=[DataRequired()])

    id = StringField('id')

    submit_registra = SubmitField('Registra pagamento')
    submit_modifica = SubmitField('Modifica pagamento')


class BudgeteForm(FlaskForm):
    descrizione = StringField('Descrizione', validators=[Length(min=0, max=100)])
    note = TextAreaField('Note')
    saldo_attuale = DecimalField('Saldo Attuale')
    attivo = BooleanField('Conto attivo')

    submit_salva = SubmitField('Salva')
    submit_elimina = SubmitField('Cancella')


class BudgetCartaForm(FlaskForm):
    descrizione = StringField('Descrizione', validators=[Length(min=0, max=100)])
    note = TextAreaField('Note')
    saldo_attuale = DecimalField('Saldo Attuale')
    attivo = BooleanField('Carta attivo')

    id = StringField('id')

    submit_aggiungi = SubmitField('Aggiungi')
    submit_aggiorna = SubmitField('Aggiorna')

