from app import app, db
from app.forms import LoginForm, RegistrationForm, ImpostazioniForm, ItemForm, ItemStatiForm, ItemRicercaForm, NegozioForm, BotForm, \
    ProxyForm, \
    StatisticheForm, ClienteForm, ClienteContattiForm, CostoForm, PagamentoForm
from app.models import User, Impostazioni, Item, Negozio, Bot, Proxy, Cliente, Cliente_Contatti, Costo, Costo_Storico_Pagamenti
from app.funzioni import insert, genera_notifiche
import os
from flask import render_template, flash, redirect, url_for, request, jsonify
from flask_login import current_user, login_user, logout_user, login_required
from werkzeug.utils import secure_filename
from werkzeug.urls import url_parse
from datetime import datetime, date, timedelta
import calendar
import sqlalchemy
from sqlalchemy import func, extract, cast

import psycopg2
from app import conn


@app.route('/')
@app.route('/homepage')
@login_required
def homepage():
    # Indicatore Acquisti mensili
    n_acquisti_mensili = current_user.own_items().filter(
        extract('month', Item.data_ordine) == extract('month', datetime.now()),
        extract('year', Item.data_ordine) == extract('year', datetime.now())
    ) \
        .count()
    n_vendite_mensili = current_user.own_items().filter(
        extract('month', Item.data_vendita) == extract('month', datetime.now()),
        Item.stato == 'Vendita'
    ) \
        .count()
    # Indicatore Stock
    n_items_stock = current_user.own_items().filter(
        Item.stato == 'Acquisto',
        Item.data_consegna.is_not(None),
    ).count()
    n_items_inconsegna = current_user.own_items().filter_by(
        stato='Acquisto',
        data_consegna=None
    ).count()
    # Indicatore Scadenze
    impostazioni = current_user.own_impostazioni().first()
    n_items_reso_in_scadenza = Item.query.join(Negozio, Negozio.descrizione == Item.negozio) \
        .filter(Item.stato == 'Acquisto',
                ((date.today()) <= Item.data_scadenza_reso),
                ((date.today()) >= Item.data_scadenza_reso - timedelta(
                    days=impostazioni.homepage_giorni_anticipo_resi)),
                Item.user_id == current_user.id
                ).count()
    n_bots_in_scadenza = Bot.query.filter(
        ((date.today()) <= Bot.data_scadenza),
        ((date.today()) >= Bot.data_scadenza - timedelta(days=impostazioni.homepage_giorni_anticipo_bot)),
        Bot.user_id == current_user.id
    ).count()
    n_proxies_in_scadenza = Proxy.query.filter(
        ((date.today()) <= Proxy.data_scadenza),
        ((date.today()) >= Proxy.data_scadenza - timedelta(days=impostazioni.homepage_giorni_anticipo_proxy)),
        Proxy.user_id == current_user.id
    ).count()
    n_pagamenti_in_scadenza = Costo.query.filter(
        ((date.today()) <= Costo.data_prox_pagamento),
        ((date.today()) >= Costo.data_prox_pagamento - timedelta(days=15)),
        Costo.user_id == current_user.id
    ).count()

    # Indicatore Statistiche mensili
    acquisti = current_user.own_items().with_entities((func.sum(Item.prezzo_totale).label('somma'))) \
                   .filter(extract('month', Item.data_ordine) == extract('month', datetime.now())) \
                   .scalar() or 0
    vendite = current_user.own_items().with_entities((func.sum(Item.incasso).label('somma'))) \
                  .filter(extract('month', Item.data_vendita) == extract('month', datetime.now())) \
                  .scalar() or 0
    ricavi_lordi = current_user.own_items().with_entities((func.sum(Item.ricavi_lordi).label('somma'))) \
                       .filter(extract('month', Item.data_vendita) == extract('month', datetime.now())) \
                       .scalar() or 0
    ricavi_netti = current_user.own_items().with_entities((func.sum(Item.ricavi_netti).label('somma'))) \
                       .filter(extract('month', Item.data_vendita) == extract('month', datetime.now())) \
                       .scalar() or 0
    val_stock = current_user.own_items().with_entities((func.sum(Item.prezzo).label('somma'))) \
                    .filter(
        Item.stato == 'Acquisto',
    ) \
                    .scalar() or 0

    return render_template('home.html', title='Homepage',
                           n_acquisti_mensili=n_acquisti_mensili, n_vendite_mensili=n_vendite_mensili,
                           n_items_stock=n_items_stock, n_items_inconsegna=n_items_inconsegna,
                           n_items_reso_in_scadenza=n_items_reso_in_scadenza, n_bots_in_scadenza=n_bots_in_scadenza, n_proxies_in_scadenza=n_proxies_in_scadenza, n_pagamenti_in_scadenza=n_pagamenti_in_scadenza,
                           acquisti=acquisti, vendite=vendite, ricavi_lordi=ricavi_lordi, ricavi_netti=ricavi_netti,
                           val_stock=val_stock)


@app.route('/lancio_notifiche')
def lancio_notifiche():
    with app.app_context():
        genera_notifiche()
    return redirect(url_for('homepage'))


@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('homepage'))
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(username=form.username.data).first()
        if user is None or not user.check_password(form.password.data):
            flash('Nome utente o password errati.', "error")
            return redirect(url_for('login'))
        login_user(user, remember=form.remember_me.data)
        next_page = request.args.get('next')
        if not next_page or url_parse(next_page).netloc != '':
            next_page = url_for('homepage')
        return redirect(next_page)
    return render_template('login.html', title='Login', form=form)


@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        user = User(username=form.username.data, email=form.email.data)
        user.set_password(form.password.data)
        db.session.add(user)
        db.session.commit()
        user_created = User.query.filter_by(username=form.username.data).first()
        impostazioni_user = Impostazioni(
            user_id=user_created.id,
            notifiche_mensili=True,
            notifiche_scadenze_resi=True, notifica_giorni_anticipo_resi=5,
            notifiche_scadenze_bot=True, notifica_giorni_anticipo_bot=5,
            notifiche_scadenze_proxy=True, notifica_giorni_anticipo_proxy=5,
            homepage_scadenze_resi=True, homepage_giorni_anticipo_resi=5,
            homepage_scadenze_bot=True, homepage_giorni_anticipo_bot=5,
            homepage_scadenze_proxy=True, homepage_giorni_anticipo_proxy=5
        )
        db.session.add(impostazioni_user)
        db.session.commit()
        flash('Utente aggiunto.')
        return redirect(url_for('login'))
    return render_template('register.html', title='Dettaglio Utente', form=form)


@app.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('homepage'))


@app.route('/user/<username>')
@login_required
def user(username):
    user = User.query.filter_by(username=username).first_or_404()
    return render_template('user.html', title='Utente', user=user)


@app.route('/user/<username>/impostazioni', methods=['GET', 'POST'])
@login_required
def impostazioni(username):
    form = ImpostazioniForm()
    user = User.query.filter_by(username=username).first_or_404()
    impostazioni = Impostazioni.query.filter_by(user_id=user.id).first_or_404()

    if form.validate_on_submit():
        if form.submit_salva.data:
            impostazioni.notifiche_mensili = form.notifiche_mensili.data

            impostazioni.notifiche_scadenze_resi = form.notifiche_scadenze_resi.data
            impostazioni.notifica_giorni_anticipo_resi = form.notifica_giorni_anticipo_resi.data

            impostazioni.notifiche_scadenze_bot = form.notifiche_scadenze_bot.data
            impostazioni.notifica_giorni_anticipo_bot = form.notifica_giorni_anticipo_bot.data

            impostazioni.notifiche_scadenze_proxy = form.notifiche_scadenze_proxy.data
            impostazioni.notifica_giorni_anticipo_proxy = form.notifica_giorni_anticipo_proxy.data

            impostazioni.homepage_scadenze_resi = form.homepage_scadenze_resi.data
            impostazioni.homepage_giorni_anticipo_resi = form.homepage_giorni_anticipo_resi.data

            impostazioni.homepage_scadenze_bot = form.homepage_scadenze_bot.data
            impostazioni.homepage_giorni_anticipo_bot = form.homepage_giorni_anticipo_bot.data

            impostazioni.homepage_scadenze_proxy = form.homepage_scadenze_proxy.data
            impostazioni.homepage_giorni_anticipo_proxy = form.homepage_giorni_anticipo_proxy.data

            db.session.commit()
            flash('Modifiche salvate.')
    elif request.method == 'GET':
        form.notifiche_mensili.data = impostazioni.notifiche_mensili
        form.notifiche_scadenze_resi.data = impostazioni.notifiche_scadenze_resi
        form.notifica_giorni_anticipo_resi.data = impostazioni.notifica_giorni_anticipo_resi
        form.notifiche_scadenze_bot.data = impostazioni.notifiche_scadenze_bot
        form.notifica_giorni_anticipo_bot.data = impostazioni.notifica_giorni_anticipo_bot
        form.notifiche_scadenze_proxy.data = impostazioni.notifiche_scadenze_proxy
        form.notifica_giorni_anticipo_proxy.data = impostazioni.notifica_giorni_anticipo_proxy

        form.homepage_scadenze_resi.data = impostazioni.homepage_scadenze_resi
        form.homepage_giorni_anticipo_resi.data = impostazioni.homepage_giorni_anticipo_resi
        form.homepage_scadenze_bot.data = impostazioni.homepage_scadenze_bot
        form.homepage_giorni_anticipo_bot.data = impostazioni.homepage_giorni_anticipo_bot
        form.homepage_scadenze_proxy.data = impostazioni.homepage_scadenze_proxy
        form.homepage_giorni_anticipo_proxy.data = impostazioni.homepage_giorni_anticipo_proxy
    return render_template('dettaglio_impostazioni.html', title='Impostazioni', impostazioni=impostazioni, form=form)


@app.before_request
def before_request():
    if current_user.is_authenticated:
        current_user.last_seen = datetime.utcnow()
        db.session.commit()


@app.route('/items_js')
def items_js():
    items = current_user.own_items().all()
    return render_template('items_table_js.html', title='Items', items=items)


@app.route('/api/data')
def data():
    query = Item.query

    # search filter
    search = request.args.get('search[value]')
    if search:
        query = query.filter((
            Item.descrizione.like(f'%{search}%')
        ))
    total_filtered = query.count()

    # sorting
    order = []
    i = 0
    while True:
        col_index = request.args.get(f'order[{i}][column]')
        if col_index is None:
            break
        col_name = request.args.get(f'columns[{col_index}][data]')
        if col_name not in ['codice', 'descrizione', 'prezzo', 'data_ordine', 'incasso', 'data_vendita']:
            col_name = 'codice'
        descending = request.args.get(f'order[{i}][dir]') == 'desc'
        col = getattr(Item, col_name)
        if descending:
            col = col.desc()
        order.append(col)
        i += 1
    if order:
        query = query.order_by(*order)

    # pagination
    start = request.args.get('start', type=int)
    length = request.args.get('length', type=int)
    query = query.offset(start).limit(length)

    # response
    return {
        'data': [item.to_dict() for item in query],
        'recordsFiltered': total_filtered,
        'recordsTotal': Item.query.count(),
        'draw': request.args.get('draw', type=int),
    }


@app.route('/items', methods=['GET', 'POST'])
@login_required
def items():
    form = ItemRicercaForm()

    if request.method == 'POST':
        stato = form.stato.data

        page = request.args.get('page', 1, type=int)

        items = current_user.own_items().filter_by(
            stato=stato
        ).order_by(Item.data_ordine.desc()) \
            .paginate(page, app.config['POSTS_PER_PAGE'], False)

        next_url = url_for('items', page=items.next_num) \
            if items.has_next else None
        prev_url = url_for('items', page=items.prev_num) \
            if items.has_prev else None

    elif request.method == 'GET':
        page = request.args.get('page', 1, type=int)
        items = current_user.own_items().order_by(Item.data_ordine.desc()).paginate(page, app.config['POSTS_PER_PAGE'],
                                                                                    False)
        next_url = url_for('items', page=items.next_num) \
            if items.has_next else None
        prev_url = url_for('items', page=items.prev_num) \
            if items.has_prev else None

    return render_template('items.html', title='Items', items=items.items, page=page,
                           next_url=next_url, prev_url=prev_url,
                           form=form)


@app.route('/aggiungi_item', methods=['GET', 'POST'])
@login_required
def aggiungi_item():
    form = ItemForm()

    clienti = current_user.own_clienti().order_by(
                                            Cliente.nome.asc())\
                                        .all()

    if form.validate_on_submit():
        # Codifica Item
        ext_anno = str(form.data_ordine.data.year)[-2:]
        ext_mese = form.data_ordine.data.month
        if ext_mese == 1:
            codice_mese = 'GEN'
        elif ext_mese == 2:
            codice_mese = 'FEB'
        elif ext_mese == 3:
            codice_mese = 'MAR'
        elif ext_mese == 4:
            codice_mese = 'APR'
        elif ext_mese == 5:
            codice_mese = 'MAG'
        elif ext_mese == 6:
            codice_mese = 'GIU'
        elif ext_mese == 7:
            codice_mese = 'LUG'
        elif ext_mese == 8:
            codice_mese = 'AGO'
        elif ext_mese == 9:
            codice_mese = 'SET'
        elif ext_mese == 10:
            codice_mese = 'OTT'
        elif ext_mese == 11:
            codice_mese = 'NOV'
        elif ext_mese == 12:
            codice_mese = 'DIC'
        else:
            codice_mese = '---'
        progressivo = current_user.own_items().filter(
            extract('month', Item.data_ordine) == extract('month', form.data_ordine.data)).count() + 1
        if progressivo < 10:
            progressivo_fix = str('000' + str(progressivo))
        elif progressivo < 100:
            progressivo_fix = str('00' + str(progressivo))
        elif progressivo < 1000:
            progressivo_fix = str('0' + str(progressivo))

        codice = '{}_{}_{}'.format(codice_mese, ext_anno, progressivo_fix)

        # Calcolo data di scadenza reso
        if form.negozio.data != '0':
            negozio_desc = form.negozio.data
            negozio_giorni_reso = Negozio.query.filter(Negozio.descrizione == negozio_desc).first().giorni_reso
            data_scadenza_reso = form.data_ordine.data + timedelta(negozio_giorni_reso)
        else:
            data_scadenza_reso = None

        prezzo_totale = (form.prezzo.data or 0) + (form.reship.data or 0) + (form.slot.data or 0)
        incasso = form.incasso.data or 0

        if form.stato.data == 'Vendita':
            ricavi_lordi = incasso - (prezzo_totale)
            ricavi_netti = ricavi_lordi - ((form.spedizione_vendita.data or 0) + (form.fee_reship.data or 0))
        else:
            ricavi_lordi = 0
            ricavi_netti = 0

        item = Item(codice=codice,
                    descrizione=form.descrizione.data, sku=form.sku.data, region=form.region.data,
                    prezzo=form.prezzo.data,
                    spedizione_acquisto=form.spedizione_acquisto.data, reship=form.reship.data, slot=form.slot.data,
                    data_ordine=form.data_ordine.data, consegna_stesso_giorno=form.consegna_stesso_giorno.data,
                    data_consegna=form.data_consegna.data,
                    data_scadenza_reso=data_scadenza_reso,
                    negozio=form.negozio.data, proxy=form.proxy.data, bot=form.bot.data,
                    tipologia=form.tipologia.data, taglia=form.taglia.data,
                    stato=form.stato.data,
                    incasso=form.incasso.data, spedizione_vendita=form.spedizione_vendita.data,
                    fee_reship=form.fee_reship.data,
                    data_vendita=form.data_vendita.data, incasso_stesso_giorno=form.incasso_stesso_giorno.data,
                    data_incasso=form.data_incasso.data,
                    canale=form.canale.data, contatto=form.cliente.data,
                    prezzo_totale=prezzo_totale, ricavi_lordi=ricavi_lordi, ricavi_netti=ricavi_netti,
                    user_id=current_user.id, data_creazione=datetime.now()
                    )
        db.session.add(item)
        db.session.commit()
        flash('Item aggiunto.')
        return redirect(url_for('item', codice=codice))
    elif request.method == 'GET':
        form.stato.data = 'Acquisto'
    return render_template('dettaglio_item.html', title='Aggiungi Item', form=form, clienti=clienti)


@app.route('/item/<codice>', methods=['GET', 'POST'])
@login_required
def item(codice):
    item = Item.query.filter_by(codice=codice, user_id=current_user.id).first_or_404()
    clienti = current_user.own_clienti().order_by(
                                            Cliente.nome.asc()) \
                                        .all()

    form = ItemForm()
    stato = ItemStatiForm()

    if form.validate_on_submit():
        if form.submit_salva.data:
            item.descrizione = form.descrizione.data
            item.sku = form.sku.data
            item.region = form.region.data
            item.prezzo = form.prezzo.data
            item.spedizione_acquisto = form.spedizione_acquisto.data
            item.reship = form.reship.data
            item.data_ordine = form.data_ordine.data
            item.consegna_stesso_giorno = form.consegna_stesso_giorno.data
            item.data_consegna = form.data_consegna.data
            item.proxy = form.proxy.data
            item.bot = form.bot.data
            item.negozio = form.negozio.data
            item.tipologia = form.tipologia.data
            item.taglia = form.taglia.data
            item.slot = form.slot.data
            item.incasso = form.incasso.data
            item.spedizione_vendita = form.spedizione_vendita.data
            item.fee_reship = form.fee_reship.data
            item.data_vendita = form.data_vendita.data
            item.incasso_stesso_giorno = form.incasso_stesso_giorno.data
            item.data_incasso = form.data_incasso.data
            item.canale = form.canale.data
            item.contatto = form.cliente.data
            item.stato = form.stato.data
            # Calcolo data di scadenza reso
            if form.negozio.data != '0':
                negozio = Negozio.query.filter(Negozio.descrizione == form.negozio.data).first()
                item.data_scadenza_reso = form.data_ordine.data + timedelta(days=negozio.giorni_reso)
            else:
                item.data_scadenza_reso = None
            prezzo_totale = (form.prezzo.data or 0) + (form.reship.data or 0) + (form.slot.data or 0)
            item.prezzo_totale = prezzo_totale
            '''
            if form.stato.data == 'Vendita':
                if form.incasso.data is None or form.data_incasso.data is None:
                    flash('Per registrare la vendita devi compilare l\'incasso e la data di incasso.', "error")
                    return render_template('dettaglio_item.html', title='Item', form=form)
            '''
            if form.stato.data == 'Vendita':
                ricavi_lordi = (form.incasso.data or 0) - (prezzo_totale)
                item.ricavi_lordi = ricavi_lordi
                item.ricavi_netti = ricavi_lordi - (
                            (form.spedizione_vendita.data or 0) + (form.fee_reship.data or 0))

            db.session.commit()
            flash('Le modifiche sono state salvate.')
            return redirect(url_for('item', codice=codice))

        if form.submit_elimina.data:
            item = Item.query.filter_by(codice=codice, user_id=current_user.id).first_or_404()
            db.session.delete(item)
            db.session.commit()
            flash('Item cancellato.')
            return redirect(url_for('items'))

    if stato.validate_on_submit():
        if stato.acquisto.data:
            item.stato = 'Acquisto'
        if stato.attesa_vendita.data:
            item.stato = 'Attesa vendita'
        if stato.venduto.data:
            item.stato = 'Vendita'
        if stato.reso.data:
            item.stato = 'Reso'
        db.session.commit()
        flash('Stato aggiornato.', 'info')

    elif request.method == 'GET':
        form.codice.data = item.codice
        form.descrizione.data = item.descrizione
        form.sku.data = item.sku
        form.region.data = item.region
        form.prezzo.data = item.prezzo
        form.spedizione_acquisto.data = item.spedizione_acquisto
        form.reship.data = item.reship
        form.data_ordine.data = item.data_ordine
        form.consegna_stesso_giorno.data = item.consegna_stesso_giorno
        form.data_consegna.data = item.data_consegna
        form.data_scadenza_reso.data = item.data_scadenza_reso
        form.proxy.data = item.proxy
        form.bot.data = item.bot
        form.negozio.data = item.negozio
        form.tipologia.data = item.tipologia
        form.taglia.data = item.taglia
        form.slot.data = item.slot
        form.incasso.data = item.incasso
        form.spedizione_vendita.data = item.spedizione_vendita
        form.fee_reship.data = item.fee_reship
        form.data_vendita.data = item.data_vendita
        form.incasso_stesso_giorno.data = item.incasso_stesso_giorno
        form.data_incasso.data = item.data_incasso
        form.canale.data = item.canale
        form.cliente.data = item.contatto
        form.stato.data = item.stato

    form.codice.data = item.codice
    form.descrizione.data = item.descrizione
    form.sku.data = item.sku
    form.region.data = item.region
    form.prezzo.data = item.prezzo
    form.spedizione_acquisto.data = item.spedizione_acquisto
    form.reship.data = item.reship
    form.data_ordine.data = item.data_ordine
    form.consegna_stesso_giorno.data = item.consegna_stesso_giorno
    form.data_consegna.data = item.data_consegna
    form.data_scadenza_reso.data = item.data_scadenza_reso
    form.proxy.data = item.proxy
    form.bot.data = item.bot
    form.negozio.data = item.negozio
    form.tipologia.data = item.tipologia
    form.taglia.data = item.taglia
    form.slot.data = item.slot
    form.incasso.data = item.incasso
    form.spedizione_vendita.data = item.spedizione_vendita
    form.fee_reship.data = item.fee_reship
    form.data_vendita.data = item.data_vendita
    form.incasso_stesso_giorno.data = item.incasso_stesso_giorno
    form.data_incasso.data = item.data_incasso
    form.canale.data = item.canale
    form.cliente.data = item.contatto
    form.stato.data = item.stato

    return render_template('dettaglio_item.html', title='Item', form=form, stato=stato, item=item, clienti=clienti)


@app.route('/gestisci_item/<id>', methods=['GET', 'POST'])
def gestisci_item(id):
    item = Item.query.filter_by(id=id, user_id=current_user.id).first_or_404()
    if request.method == 'POST':
        if request.form['Venduto']:
            flash('Venduto')
        elif request.form['Attesa Vendita']:
            flash('Attesa Vendita')
        elif request.form['Reso']:
            flash('Reso')

        return redirect(url_for('item', codice=item.id))



def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']


@app.route('/caricamento_csv', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            flash('Nessun file caricato')
            return redirect(request.url)
        file = request.files['file']
        # If the user does not select a file, the browser submits an
        # empty file without a filename.
        if file.filename == '':
            flash('Nessun file caricato')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            info_caricamento = insert(str(os.path.join(app.config['UPLOAD_FOLDER'] + r"\\" + filename)),
                                      current_user.id)
            os.remove(str(os.path.join(app.config['UPLOAD_FOLDER'] + r"\\" + filename)))
            flash('{}'.format(info_caricamento))
            return redirect(url_for('upload_file', name=filename))
        else:
            flash('Tipo di file non consentito')
    return render_template('caricamento_massivo.html', title='Caricamento tramite CSV')


@app.route('/negozi')
@login_required
def negozi():
    page = request.args.get('page', 1, type=int)
    negozi = current_user.own_negozi().order_by(
        Negozio.descrizione.asc()).paginate(page, app.config['POSTS_PER_PAGE'], False)
    next_url = url_for('negozi', page=negozi.next_num) \
        if negozi.has_next else None
    prev_url = url_for('negozi', page=negozi.prev_num) \
        if negozi.has_prev else None
    return render_template('negozi.html', title='Shops', negozi=negozi.items, next_url=next_url, prev_url=prev_url)


@app.route('/aggiungi_negozio', methods=['GET', 'POST'])
@login_required
def aggiungi_negozio():
    form = NegozioForm()
    if form.validate_on_submit():
        negozio = Negozio(descrizione=form.descrizione.data, giorni_reso=form.giorni_reso.data, user_id=current_user.id)
        db.session.add(negozio)
        db.session.commit()
        flash('Shop aggiunto.')
        return redirect(url_for('negozi'))
    return render_template('dettaglio_negozio.html', title='Aggiungi Negozio', form=form)


@app.route('/negozio/<descrizione>', methods=['GET', 'POST'])
@login_required
def negozio(descrizione):
    negozio = Negozio.query.filter_by(descrizione=descrizione, user_id=current_user.id).first_or_404()
    items = Item.query.filter_by(negozio=descrizione, user_id=current_user.id).all()
    n_acquisti = Item.query.filter_by(negozio=descrizione,
                                      user_id=current_user.id).count()
    prezzo_acquisti = Item.query.with_entities(func.sum(Item.incasso)).filter_by(negozio=descrizione,
                                                                                 user_id=current_user.id).scalar()
    form = NegozioForm()
    if form.validate_on_submit():
        if form.submit_salva.data:
            if form.descrizione.data is None or form.giorni_reso.data is None:
                flash('Per aggiungere il negozio compilare entrambe le informazioni.', "error")
            else:
                negozio.descrizione = form.descrizione.data
                negozio.giorni_reso = form.giorni_reso.data
                db.session.commit()
                flash('Le modifiche sono state salvate.')
        if form.submit_elimina.data:
            negozio = Negozio.query.filter_by(descrizione=descrizione, user_id=current_user.id).first_or_404()
            db.session.delete(negozio)
            item_update = Item.query.filter(Item.sito == negozio.id)
            for item in item_update:
                item.sito = None
            db.session.commit()
            flash('Negozio cancellato.')
            return redirect(url_for('negozi'))
    elif request.method == 'GET':
        form.descrizione.data = negozio.descrizione
        form.giorni_reso.data = negozio.giorni_reso
    return render_template('dettaglio_negozio.html', title='Negozio', form=form, items=items, n_acquisti=n_acquisti,
                           prezzo_acquisti=prezzo_acquisti)


@app.route('/trova_negozio/<descrizione>', methods=['GET'])
@login_required
def trova_negozio(descrizione):
    return redirect(url_for('negozio', descrizione=descrizione))


@app.route('/bots')
@login_required
def bots():
    page = request.args.get('page', 1, type=int)
    bots = current_user.own_bots().order_by(Bot.data_attivazione.desc()).paginate(page, app.config['POSTS_PER_PAGE'],
                                                                                  False)
    next_url = url_for('bots', page=bots.next_num) \
        if bots.has_next else None
    prev_url = url_for('bots', page=bots.prev_num) \
        if bots.has_prev else None
    return render_template('bots.html', title='Bots', bots=bots.items, next_url=next_url, prev_url=prev_url)


@app.route('/aggiungi_bot', methods=['GET', 'POST'])
@login_required
def aggiungi_bot():
    form = BotForm()

    if form.validate_on_submit():

        # Codifica Bot
        ext_anno = str(form.data_attivazione.data.year)[-2:]
        ext_mese = form.data_attivazione.data.month
        if ext_mese == 1:
            codice_mese = 'GEN'
        elif ext_mese == 2:
            codice_mese = 'FEB'
        elif ext_mese == 3:
            codice_mese = 'MAR'
        elif ext_mese == 4:
            codice_mese = 'APR'
        elif ext_mese == 5:
            codice_mese = 'MAG'
        elif ext_mese == 6:
            codice_mese = 'GIU'
        elif ext_mese == 7:
            codice_mese = 'LUG'
        elif ext_mese == 8:
            codice_mese = 'AGO'
        elif ext_mese == 9:
            codice_mese = 'SET'
        elif ext_mese == 10:
            codice_mese = 'OTT'
        elif ext_mese == 11:
            codice_mese = 'NOV'
        elif ext_mese == 12:
            codice_mese = 'DIC'
        else:
            codice_mese = '---'
        progressivo = current_user.own_items().filter(
            extract('month', Bot.data_attivazione) == extract('month', form.data_attivazione.data)).count() + 1
        if progressivo < 10:
            progressivo_fix = str('000' + str(progressivo))
        elif progressivo < 100:
            progressivo_fix = str('00' + str(progressivo))
        elif progressivo < 1000:
            progressivo_fix = str('0' + str(progressivo))

        codice = '{}_{}_{}'.format(codice_mese, ext_anno, progressivo_fix)

        data_scadenza = form.data_attivazione.data + timedelta(days=form.scadenza_giorni.data)

        bot = Bot(codice=codice, descrizione=form.descrizione.data,
                  costo=form.costo.data,
                  data_attivazione=form.data_attivazione.data, scadenza_giorni=form.scadenza_giorni.data,
                  data_scadenza=data_scadenza,
                  salva_rinnovo=form.salva_rinnovo.data,
                  user_id=current_user.id, data_creazione=datetime.now())
        db.session.add(bot)
        db.session.commit()
        flash('Bot aggiunto.')
        return redirect(url_for('bots'))
    return render_template('dettaglio_bot.html', title='Aggiungi Bot', form=form)


@app.route('/bot/<codice>', methods=['GET', 'POST'])
@login_required
def bot(codice):
    bot = Bot.query.filter_by(codice=codice, user_id=current_user.id).first_or_404()
    items = Item.query.filter_by(bot=bot.descrizione, user_id=current_user.id).all()
    n_acquisti = Item.query.filter_by(bot=bot.descrizione,
                                      user_id=current_user.id).count()
    prezzo_acquisti = Item.query.with_entities(func.sum(Item.incasso)).filter_by(bot=bot.descrizione,
                                                                                 user_id=current_user.id).scalar()
    form = BotForm()
    if form.validate_on_submit():
        bot.descrizione = form.descrizione.data
        bot.costo = form.costo.data
        bot.data_attivazione = form.data_attivazione.data
        bot.scadenza_giorni = form.scadenza_giorni.data
        bot.data_scadenza = form.data_attivazione.data + timedelta(days=form.scadenza_giorni.data)
        bot.salva_rinnovo = form.salva_rinnovo.data
        db.session.commit()
        flash('Le modifiche sono state salvate.')
    elif request.method == 'GET':
        form.codice.data = bot.codice
        form.descrizione.data = bot.descrizione
        form.costo.data = bot.costo
        form.data_attivazione.data = bot.data_attivazione
        form.scadenza_giorni.data = bot.scadenza_giorni
        form.data_scadenza.data = bot.data_scadenza
        form.salva_rinnovo.data = bot.salva_rinnovo
    return render_template('dettaglio_bot.html', title='Bot', form=form, items=items, n_acquisti=n_acquisti,
                           prezzo_acquisti=prezzo_acquisti)


@app.route('/trova_bot/<descrizione>', methods=['GET'])
@login_required
def trova_bot(descrizione):
    bot = Bot.query.filter_by(descrizione=descrizione, user_id=current_user.id).first_or_404()
    return redirect(url_for('bot', codice=bot.codice))


@app.route('/proxies')
@login_required
def proxies():
    page = request.args.get('page', 1, type=int)
    proxies = current_user.own_proxies().order_by(Proxy.data_attivazione.desc()).paginate(page,
                                                                                          app.config['POSTS_PER_PAGE'],
                                                                                          False)
    next_url = url_for('proxies', page=proxies.next_num) \
        if proxies.has_next else None
    prev_url = url_for('proxies', page=proxies.prev_num) \
        if proxies.has_prev else None
    return render_template('proxies.html', title='Proxy', proxies=proxies.items, next_url=next_url, prev_url=prev_url)


@app.route('/aggiungi_proxy', methods=['GET', 'POST'])
@login_required
def aggiungi_proxy():
    form = ProxyForm()

    if form.validate_on_submit():

        # Codifica Proxy
        ext_anno = str(form.data_attivazione.data.year)[-2:]
        ext_mese = form.data_attivazione.data.month
        if ext_mese == 1:
            codice_mese = 'GEN'
        elif ext_mese == 2:
            codice_mese = 'FEB'
        elif ext_mese == 3:
            codice_mese = 'MAR'
        elif ext_mese == 4:
            codice_mese = 'APR'
        elif ext_mese == 5:
            codice_mese = 'MAG'
        elif ext_mese == 6:
            codice_mese = 'GIU'
        elif ext_mese == 7:
            codice_mese = 'LUG'
        elif ext_mese == 8:
            codice_mese = 'AGO'
        elif ext_mese == 9:
            codice_mese = 'SET'
        elif ext_mese == 10:
            codice_mese = 'OTT'
        elif ext_mese == 11:
            codice_mese = 'NOV'
        elif ext_mese == 12:
            codice_mese = 'DIC'
        else:
            codice_mese = '---'
        progressivo = current_user.own_items().filter(
            extract('month', Proxy.data_attivazione) == extract('month', form.data_attivazione.data)).count() + 1
        if progressivo < 10:
            progressivo_fix = str('000' + str(progressivo))
        elif progressivo < 100:
            progressivo_fix = str('00' + str(progressivo))
        elif progressivo < 1000:
            progressivo_fix = str('0' + str(progressivo))

        codice = '{}_{}_{}'.format(codice_mese, ext_anno, progressivo_fix)

        data_scadenza = form.data_attivazione.data + timedelta(days=form.scadenza_giorni.data)

        proxy = Proxy(codice=codice,
                      descrizione=form.descrizione.data, costo=form.costo.data,
                      data_attivazione=form.data_attivazione.data, scadenza_giorni=form.scadenza_giorni.data,
                      data_scadenza=data_scadenza,
                      salva_rinnovo=form.salva_rinnovo.data,
                      user_id=current_user.id, data_creazione=datetime.now())
        db.session.add(proxy)
        db.session.commit()
        flash('Proxy aggiunto.')
        return redirect(url_for('proxies'))
    return render_template('dettaglio_proxy.html', title='Aggiungi Proxy', form=form)


@app.route('/proxy/<codice>', methods=['GET', 'POST'])
@login_required
def proxy(codice):
    proxy = Proxy.query.filter_by(codice=codice, user_id=current_user.id).first_or_404()
    items = Item.query.filter_by(proxy=proxy.descrizione, user_id=current_user.id).all()
    n_acquisti = Item.query.filter_by(proxy=proxy.descrizione,
                                      user_id=current_user.id).count()
    prezzo_acquisti = Item.query.with_entities(func.sum(Item.incasso)).filter_by(proxy=proxy.descrizione,
                                                                                 user_id=current_user.id).scalar()
    form = ProxyForm()
    if form.validate_on_submit():
        proxy.descrizione = form.descrizione.data
        proxy.costo = form.costo.data
        proxy.data_attivazione = form.data_attivazione.data
        proxy.scadenza_giorni = form.scadenza_giorni.data or 0
        proxy.data_scadenza = form.data_attivazione.data + timedelta(days=form.scadenza_giorni.data)
        proxy.salva_rinnovo = form.salva_rinnovo.data
        db.session.commit()
        flash('Le modifiche sono state salvate.')
    elif request.method == 'GET':
        form.codice.data = proxy.codice
        form.descrizione.data = proxy.descrizione
        form.costo.data = proxy.costo
        form.data_attivazione.data = proxy.data_attivazione or 0
        form.scadenza_giorni.data = proxy.scadenza_giorni
        form.data_scadenza.data = proxy.data_scadenza
        form.salva_rinnovo.data = proxy.salva_rinnovo

    return render_template('dettaglio_proxy.html', title='Proxy', form=form, items=items, n_acquisti=n_acquisti,
                           prezzo_acquisti=prezzo_acquisti)


@app.route('/trova_proxy/<descrizione>', methods=['GET'])
@login_required
def trova_proxy(descrizione):
    proxy = Proxy.query.filter_by(descrizione=descrizione, user_id=current_user.id).first_or_404()
    return redirect(url_for('proxy', codice=proxy.codice))


@app.route('/statistiche', methods=['GET', 'POST'])
@login_required
def statistiche():
    form = StatisticheForm()

    if form.validate_on_submit():
        filtro = form.filtro_mese_anno.data
        print(filtro)
        if filtro:
            filtro_mese = str(filtro).split(' - ')[0]
            filtro_anno = str(filtro).split(' - ')[1]
        else:
            filtro_mese = datetime.now().month
            filtro_anno = datetime.now().year

        acquisti = current_user.own_items().with_entities((func.sum(Item.prezzo_totale).label('somma'))) \
                       .filter(
            extract('month', Item.data_ordine) == filtro_mese,
            extract('year', Item.data_ordine) == filtro_anno
        ) \
                       .scalar() or 0
        n_acquisti = current_user.own_items() \
                         .filter(
            extract('month', Item.data_ordine) == filtro_mese,
            extract('year', Item.data_ordine) == filtro_anno
        ) \
                         .count() or 0
        vendite = current_user.own_items().with_entities((func.sum(Item.incasso).label('somma'))) \
                      .filter(
            extract('month', Item.data_vendita) == filtro_mese,
            extract('year', Item.data_vendita) == filtro_anno
        ) \
                      .scalar() or 0
        n_vendite = current_user.own_items() \
                        .filter(
            extract('month', Item.data_vendita) == filtro_mese,
            extract('year', Item.data_vendita) == filtro_anno
        ) \
                        .count() or 0
        ricavi_lordi = current_user.own_items().with_entities((func.sum(Item.ricavi_lordi).label('somma'))) \
                           .filter(
            extract('month', Item.data_vendita) == filtro_mese,
            extract('year', Item.data_vendita) == filtro_anno
        ) \
                           .scalar() or 0
        ricavi_netti = current_user.own_items().with_entities((func.sum(Item.ricavi_netti).label('somma'))) \
                           .filter(
            extract('month', Item.data_vendita) == filtro_mese,
            extract('year', Item.data_vendita) == filtro_anno
        ) \
                           .scalar() or 0
        val_stock = current_user.own_items().with_entities((func.sum(Item.prezzo).label('somma'))) \
                        .filter(
            Item.stato == 'Acquisto',
        ) \
                        .scalar() or 0
        n_items_stock = current_user.own_items() \
                            .filter(
            Item.stato == 'Acquisto',
        ) \
                            .count() or 0
        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        s = "select  negozio, count(*)||'/'||(select count(*) from item where user_id = {})::numeric, round((count(*)::numeric/(select count(*) from item where user_id = {})::numeric)::numeric*100, 2) from item where user_id = {} group by negozio".format(
            current_user.id, current_user.id, current_user.id)
        cur.execute(s)  # Execute the SQL
        item_per_negozio = cur.fetchall()

        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        s = "select  bot, count(*)||'/'||(select count(*) from item where user_id = {})::numeric, round((count(*)::numeric/(select count(*) from item where user_id = {})::numeric)::numeric*100, 2) from item where user_id = {} group by bot".format(
            current_user.id, current_user.id, current_user.id)
        cur.execute(s)  # Execute the SQL
        item_per_bot = cur.fetchall()

        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        s = "select  proxy, count(*)||'/'||(select count(*) from item where user_id = {})::numeric, round((count(*)::numeric/(select count(*) from item where user_id = {})::numeric)::numeric*100, 2) from item where user_id = {} group by proxy".format(
            current_user.id, current_user.id, current_user.id)
        cur.execute(s)  # Execute the SQL
        item_per_proxy = cur.fetchall()

        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        s = "select  contatto, count(*)||'/'||(select count(*) from item where user_id = {})::numeric, round((count(*)::numeric/(select count(*) from item where user_id = {})::numeric)::numeric*100, 2) from item where user_id = {} group by contatto".format(
            current_user.id, current_user.id, current_user.id)
        cur.execute(s)  # Execute the SQL
        item_per_cliente = cur.fetchall()

    elif request.method == 'GET':
        filtro_mese = datetime.now().month
        filtro_anno = datetime.now().year
        num_mese = filtro_mese
        num_anno = filtro_anno
        form.filtro_mese_anno.data = str(num_mese) + ' - ' + str(num_anno)

        acquisti = current_user.own_items().with_entities((func.sum(Item.prezzo_totale).label('somma'))) \
                       .filter(
            extract('month', Item.data_ordine) == filtro_mese,
            extract('year', Item.data_ordine) == filtro_anno
        ) \
                       .scalar() or 0
        n_acquisti = current_user.own_items() \
                         .filter(
            extract('month', Item.data_ordine) == filtro_mese,
            extract('year', Item.data_ordine) == filtro_anno
        ) \
                         .count() or 0
        vendite = current_user.own_items().with_entities((func.sum(Item.incasso).label('somma'))) \
                      .filter(
            extract('month', Item.data_vendita) == filtro_mese,
            extract('year', Item.data_vendita) == filtro_anno
        ) \
                      .scalar() or 0
        n_vendite = current_user.own_items() \
                        .filter(
            extract('month', Item.data_vendita) == filtro_mese,
            extract('year', Item.data_vendita) == filtro_anno
        ) \
                        .count() or 0
        ricavi_lordi = current_user.own_items().with_entities((func.sum(Item.ricavi_lordi).label('somma'))) \
                           .filter(
            extract('month', Item.data_vendita) == filtro_mese,
            extract('year', Item.data_vendita) == filtro_anno
        ) \
                           .scalar() or 0
        ricavi_netti = current_user.own_items().with_entities((func.sum(Item.ricavi_netti).label('somma'))) \
                           .filter(
            extract('month', Item.data_vendita) == filtro_mese,
            extract('year', Item.data_vendita) == filtro_anno
        ) \
                           .scalar() or 0
        val_stock = current_user.own_items().with_entities((func.sum(Item.prezzo).label('somma'))) \
                        .filter(
            Item.stato == 'Acquisto',
        ) \
                        .scalar() or 0
        n_items_stock = current_user.own_items() \
                            .filter(
            Item.stato == 'Acquisto',
        ) \
                            .count() or 0

        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        s = "select  negozio, count(*)||'/'||(select count(*) from item where user_id = {})::numeric, round((count(*)::numeric/(select count(*) from item where user_id = {})::numeric)::numeric*100, 2) from item where user_id = {} group by negozio".format(
            current_user.id, current_user.id, current_user.id)
        cur.execute(s)  # Execute the SQL
        item_per_negozio = cur.fetchall()

        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        s = "select  bot, count(*)||'/'||(select count(*) from item where user_id = {})::numeric, round((count(*)::numeric/(select count(*) from item where user_id = {})::numeric)::numeric*100, 2) from item where user_id = {} group by bot".format(
            current_user.id, current_user.id, current_user.id)
        cur.execute(s)  # Execute the SQL
        item_per_bot = cur.fetchall()

        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        s = "select  proxy, count(*)||'/'||(select count(*) from item where user_id = {})::numeric, round((count(*)::numeric/(select count(*) from item where user_id = {})::numeric)::numeric*100, 2) from item where user_id = {} group by proxy".format(
            current_user.id, current_user.id, current_user.id)
        cur.execute(s)  # Execute the SQL
        item_per_proxy = cur.fetchall()

        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        s = "select  contatto, count(*)||'/'||(select count(*) from item where user_id = {})::numeric, round((count(*)::numeric/(select count(*) from item where user_id = {})::numeric)::numeric*100, 2) from item where user_id = {} group by contatto".format(
            current_user.id, current_user.id, current_user.id)
        cur.execute(s)  # Execute the SQL
        item_per_cliente = cur.fetchall()

    return render_template('statistiche.html', title='Statistiche',
                           form=form,
                           acquisti=acquisti, n_acquisti=n_acquisti,
                           vendite=vendite, n_vendite=n_vendite,
                           ricavi_lordi=ricavi_lordi, ricavi_netti=ricavi_netti,
                           val_stock=val_stock, n_items_stock=n_items_stock,
                           item_per_negozio=item_per_negozio,
                           item_per_bot=item_per_bot, item_per_proxy=item_per_proxy,
                           item_per_cliente=item_per_cliente
                           )


@app.route('/aggiungi_cliente', methods=['GET', 'POST'])
@login_required
def aggiungi_cliente():
    form = ClienteForm()
    form2 = ClienteContattiForm()

    if form.validate_on_submit():
        cliente = Cliente(nome=form.nome.data,
                          numero_telefono=form.numero_telefono.data,
                          taglia=form.taglia.data, colore_preferito=form.colore_preferito.data,
                          note=form.note.data,
                          user_id=current_user.id, data_creazione=datetime.now())
        db.session.add(cliente)
        db.session.commit()
        flash('Cliente aggiunto.')
        cliente_aggiunto = Cliente.query.filter_by(nome=form.nome.data, numero_telefono=form.numero_telefono.data,
                                                   user_id=current_user.id).first_or_404()
        return redirect(url_for('cliente', id=cliente_aggiunto.id))
    return render_template('dettaglio_cliente.html', title='Aggiungi Cliente', form=form, cliente=None, form2=form2)


@app.route('/cliente/<id>', methods=['GET', 'POST'])
@login_required
def cliente(id):
    cliente = Cliente.query.filter_by(id=id, user_id=current_user.id).first_or_404()
    cliente_contatti = Cliente_Contatti.query.filter_by(cliente_id=id).all()
    items = Item.query.filter_by(contatto=cliente.nome, user_id=current_user.id).all()
    n_acquisti = Item.query.filter_by(contatto=cliente.nome,
                                      user_id=current_user.id).count()
    prezzo_acquisti = Item.query.with_entities(func.sum(Item.incasso)).filter_by(contatto=cliente.nome,
                                                                                 user_id=current_user.id).scalar()

    form = ClienteForm()
    form2 = ClienteContattiForm()

    if form.validate_on_submit():

        cliente.nome = form.nome.data
        cliente.numero_telefono = form.numero_telefono.data
        cliente.taglia = form.taglia.data
        cliente.colore_preferito = form.colore_preferito.data
        cliente.note = form.note.data

        db.session.commit()
        flash('Le modifiche sono state salvate.')

    elif request.method == 'GET':
        form.nome.data = cliente.nome
        form.numero_telefono.data = cliente.numero_telefono
        form.taglia.data = cliente.taglia
        form.colore_preferito.data = cliente.colore_preferito
        form.note.data = cliente.note

    return render_template('dettaglio_cliente.html', title='Dettaglio Cliente', form=form, form2=form2, cliente=cliente,
                           cliente_contatti=cliente_contatti, items=items, n_acquisti=n_acquisti,
                           prezzo_acquisti=prezzo_acquisti)


@app.route('/trova_cliente/<nome>', methods=['GET'])
@login_required
def trova_cliente(nome):
    cliente = Cliente.query.filter_by(nome=nome, user_id=current_user.id).first_or_404()
    return redirect(url_for('cliente', id=cliente.id))


@app.route('/clienti')
@login_required
def clienti():
    page = request.args.get('page', 1, type=int)
    clienti = current_user.own_clienti().order_by(
        Cliente.nome.asc()).paginate(page, app.config['POSTS_PER_PAGE'], False)
    next_url = url_for('clienti', page=negozi.next_num) \
        if clienti.has_next else None
    prev_url = url_for('clienti', page=negozi.prev_num) \
        if clienti.has_prev else None
    return render_template('clienti.html', title='Clienti', clienti=clienti.items, next_url=next_url, prev_url=prev_url)


@app.route("/aggiungi_contatto/<id>", methods=["POST"])
@login_required
def aggiungi_contatto(id):
    cliente = Cliente.query.filter_by(id=id, user_id=current_user.id).first_or_404()

    form2 = ClienteContattiForm()

    if request.method == 'POST':
        if form2.submit_aggiungi.data:
            social = form2.social.data
            nome = form2.nome.data

            cliente_id = cliente.id

            contatto = Cliente_Contatti(cliente_id=cliente_id,
                                        social=social, nome=nome,
                                        user_id=current_user.id, data_creazione=datetime.now())
            db.session.add(contatto)
            db.session.commit()
            flash('Contatto aggiunto.')
        return redirect(url_for('cliente', id=cliente.id))


@app.route("/elimina_contatto/<id>", methods=['POST'])
@login_required
def elimina_contatto(id):
    if request.method == 'POST':
        contatto = Cliente_Contatti.query.filter_by(id=id, user_id=current_user.id).first_or_404()
        cliente = Cliente.query.get(int(contatto.cliente_id))

        db.session.delete(contatto)
        db.session.commit()
        flash('Contatto cancellato.')
    return redirect(url_for('cliente', id=cliente.id))


@app.route("/aggiorna_contatto", methods=["POST"])
@login_required
def aggiorna_contatto():
    form2 = ClienteContattiForm()

    if request.method == 'POST':
        id = form2.id.data
        social = form2.social.data
        nome = form2.nome.data

        contatto = Cliente_Contatti.query.get(int(id))

        contatto.social = social
        contatto.nome = nome

        db.session.commit()
        flash('Contatto aggiornato.')

        cliente = Cliente.query.filter_by(id=contatto.cliente_id, user_id=current_user.id).first_or_404()
        return redirect(url_for('cliente', id=cliente.id))


@app.route('/aggiungi_costo_singolo', methods=['GET', 'POST'])
@login_required
def aggiungi_costo_singolo():
    form = CostoForm()

    if request.method == 'POST':
        ora = datetime.now()
        costo = Costo(descrizione=form.descrizione.data,
                      tipologia='Pagamento Singolo',
                      costo=form.costo.data,
                      note=form.note.data,
                      user_id=current_user.id, data_creazione=ora)
        db.session.add(costo)
        db.session.commit()
        flash('Costo aggiunto.')
        costo_aggiunto = Costo.query.filter_by(descrizione=form.descrizione.data,
                                               data_creazione=ora,
                                               user_id=current_user.id).first_or_404()

        return redirect(url_for('costo', id=costo_aggiunto.id))

    elif request.method == 'GET':
        form.tipologia.data = 'Pagamento Singolo'

    return render_template('dettaglio_costo.html', title='Dettaglio Costo Singolo', form=form)


@app.route('/aggiungi_costo_periodico', methods=['GET', 'POST'])
@login_required
def aggiungi_costo_periodico():
    form = CostoForm()

    if form.validate_on_submit():
        ora = datetime.now()
        costo = Costo(descrizione=form.descrizione.data,
                      tipologia='Pagamento Periodico', fatturazione=form.fatturazione.data,
                      costo=form.costo.data,
                      data_inizio=form.data_inizio.data,
                      note=form.note.data,
                      user_id=current_user.id, data_creazione=ora)
        db.session.add(costo)
        db.session.commit()
        flash('Costo aggiunto.')
        costo_aggiunto = Costo.query.filter_by(descrizione=form.descrizione.data,
                                               data_creazione=ora,
                                               user_id=current_user.id).first_or_404()

        return redirect(url_for('costo', id=costo_aggiunto.id))

    elif request.method == 'GET':
        form.tipologia.data = 'Pagamento Periodico'

    return render_template('dettaglio_costo.html', title='Dettaglio Costo Periodico', form=form)


@app.route('/costo/<id>', methods=['GET', 'POST'])
@login_required
def costo(id):
    costo = Costo.query.filter_by(id=id, user_id=current_user.id).first_or_404()
    storico_pagamenti = Costo_Storico_Pagamenti.query.filter_by(costo_id=costo.id, user_id=current_user.id).all()
    n_pagamenti = Costo_Storico_Pagamenti.query.filter_by(costo_id=costo.id, user_id=current_user.id).count()
    val_pagamenti = Costo_Storico_Pagamenti.query.with_entities(func.sum(Costo_Storico_Pagamenti.costo)).filter_by(costo_id=costo.id, user_id=current_user.id).scalar()

    form = CostoForm()
    form2 = PagamentoForm()

    if request.method == 'POST':
        if form.submit_salva.data:
            costo.descrizione = form.descrizione.data
            #costo.tipologia = form.tipologia.data
            costo.fatturazione = form.fatturazione.data
            costo.costo = form.costo.data
            costo.costo_attivo = form.costo_attivo.data
            #costo.data_inizio = form.data_inizio.data
            #costo.data_fine = form.data_fine.data
            costo.note = form.note.data

            db.session.commit()
            flash('Le modifiche sono state salvate.')

            form.descrizione.data = costo.descrizione
            form.tipologia.data = costo.tipologia
            form.fatturazione.data = costo.fatturazione
            form.costo.data = costo.costo
            form.costo_attivo.data = costo.costo_attivo
            form.data_inizio.data = costo.data_inizio
            form.data_fine.data = costo.data_fine
            form.data_ultimo_pagamento.data = costo.data_ultimo_pagamento
            form.data_prox_pagamento.data = costo.data_prox_pagamento
            form.note.data = costo.note

        if form.submit_elimina.data:
            costo = Costo.query.filter_by(id=id, user_id=current_user.id).first_or_404()
            pagamenti = Costo_Storico_Pagamenti.query.filter_by(costo_id=costo.id, user_id=current_user.id).all()
            for pagamento in pagamenti:
                db.session.delete(pagamento)
            db.session.delete(costo)
            db.session.commit()
            flash('Costo cancellato.')
            return redirect(url_for('costi'))


    elif request.method == 'GET':
        form.descrizione.data = costo.descrizione
        form.tipologia.data = costo.tipologia
        form.fatturazione.data = costo.fatturazione
        form.costo.data = costo.costo
        form.costo_attivo.data = costo.costo_attivo
        form.data_inizio.data = costo.data_inizio
        form.data_fine.data = costo.data_fine
        form.data_ultimo_pagamento.data = costo.data_ultimo_pagamento
        form.data_prox_pagamento.data = costo.data_prox_pagamento
        form.note.data = costo.note

    if costo.tipologia == 'Pagamento Periodico':
        title = 'Dettaglio Costo Periodico'
    else:
        title = 'Dettaglio Costo Singolo'

    return render_template('dettaglio_costo.html', title=title, form=form, form2=form2, costo=costo,
                           storico_pagamenti=storico_pagamenti, n_pagamenti=n_pagamenti, val_pagamenti=val_pagamenti)


@app.route("/registra_pagamento/<id>", methods=["POST"])
@login_required
def registra_pagamento(id):
    costo_query = Costo.query.filter_by(id=id, user_id=current_user.id).first_or_404()

    form2 = PagamentoForm()

    if request.method == 'POST':
        if form2.submit_registra.data:
            descrizione = form2.descrizione.data
            costo = form2.costo.data
            data_pagamento = form2.data_pagamento.data

            costo_id = costo_query.id

            pagamento = Costo_Storico_Pagamenti(costo_id=costo_id,
                                                descrizione=descrizione, costo=costo, data_pagamento=data_pagamento,
                                                user_id=current_user.id, data_creazione=datetime.now())

            if costo_query.tipologia == 'Pagamento Periodico':
                giorno_pagamento = costo_query.data_inizio.day

                if costo_query.fatturazione == 'Mensile':
                    periodicita = 1
                elif costo_query.fatturazione == 'Bimestrale':
                    periodicita = 2
                elif costo_query.fatturazione == 'Trimestrale':
                    periodicita = 3
                elif costo_query.fatturazione == 'Semestrale':
                    periodicita = 6
                elif costo_query.fatturazione == 'Annuale':
                    periodicita = 12

                def add_months(sourcedate, months):
                    month = sourcedate.month - 1 + months
                    year = sourcedate.year + month // 12
                    month = month % 12 + 1
                    day = min(sourcedate.day, calendar.monthrange(year, month)[1])
                    return datetime(year, month, day, 0, 0, 0)

                costo_query.data_prox_pagamento = add_months(data_pagamento, periodicita)

            costo_query.data_ultimo_pagamento = data_pagamento

            db.session.add(pagamento)
            db.session.commit()

            flash('Pagamento aggiunto.')
        return redirect(url_for('costo', id=costo_query.id))


@app.route('/costi')
@login_required
def costi():
    page = request.args.get('page', 1, type=int)
    costi = current_user.own_costi().order_by(
        Costo.data_inizio.asc()).paginate(page, app.config['POSTS_PER_PAGE'], False)
    next_url = url_for('costi', page=negozi.next_num) \
        if costi.has_next else None
    prev_url = url_for('costi', page=negozi.prev_num) \
        if costi.has_prev else None
    return render_template('costi.html', title='Costi', costi=costi.items, next_url=next_url, prev_url=prev_url)


# Sezione homepage
@app.route('/items_acquisti_mensili')
@login_required
def items_acquisti_mensili():
    page = request.args.get('page', 1, type=int)
    items = current_user.own_items().filter(
        extract('month', Item.data_ordine) == extract('month', datetime.now())).order_by(Item.codice.asc()).paginate(
        page, app.config['POSTS_PER_PAGE'], False)
    next_url = url_for('items', page=items.next_num) \
        if items.has_next else None
    prev_url = url_for('items', page=items.prev_num) \
        if items.has_prev else None
    return render_template('items_indicatori.html', title='Acquisti Mensili', items=items.items, next_url=next_url,
                           prev_url=prev_url)


@app.route('/items_vendite_mensili')
@login_required
def items_vendite_mensili():
    page = request.args.get('page', 1, type=int)
    items = current_user.own_items().filter(extract('month', Item.data_vendita) == extract('month', datetime.now()),
                                            Item.stato == 'Vendita').order_by(Item.codice.asc()).paginate(page,
                                                                                                          app.config[
                                                                                                              'POSTS_PER_PAGE'],
                                                                                                          False)
    next_url = url_for('items', page=items.next_num) \
        if items.has_next else None
    prev_url = url_for('items', page=items.prev_num) \
        if items.has_prev else None
    return render_template('items_indicatori.html', title='Vendite Mensili', items=items.items, next_url=next_url,
                           prev_url=prev_url)


@app.route('/items_stock')
@login_required
def items_stock():
    page = request.args.get('page', 1, type=int)
    items = current_user.own_items().filter(
        Item.stato == 'Acquisto',
        Item.data_consegna.is_not(None),
    ) \
        .order_by(Item.codice.asc()) \
        .paginate(page, app.config['POSTS_PER_PAGE'], False)

    next_url = url_for('items', page=items.next_num) \
        if items.has_next else None
    prev_url = url_for('items', page=items.prev_num) \
        if items.has_prev else None
    return render_template('items_indicatori.html', title='Items in Stock', items=items.items, next_url=next_url,
                           prev_url=prev_url)


@app.route('/items_inconsegna')
@login_required
def items_inconsegna():
    page = request.args.get('page', 1, type=int)
    items = current_user.own_items().filter_by(
        stato='Acquisto',
        data_consegna=None
    ) \
        .order_by(Item.codice.asc()) \
        .paginate(page, app.config['POSTS_PER_PAGE'], False)

    next_url = url_for('items', page=items.next_num) \
        if items.has_next else None
    prev_url = url_for('items', page=items.prev_num) \
        if items.has_prev else None
    return render_template('items_indicatori.html', title='Items in consegna', items=items.items, next_url=next_url,
                           prev_url=prev_url)


@app.route('/items_reso_in_scadenza')
@login_required
def items_reso_in_scadenza():
    impostazioni = current_user.own_impostazioni().first()
    items = Item.query.join(Negozio, Negozio.descrizione == Item.negozio) \
        .filter(Item.stato == 'Acquisto',
                ((date.today()) <= Item.data_scadenza_reso),
                ((date.today()) >= Item.data_scadenza_reso - timedelta(
                    days=impostazioni.homepage_giorni_anticipo_resi)),
                Item.user_id == current_user.id
                ) \
        .order_by(Item.data_scadenza_reso.asc())

    return render_template('items_indicatori.html', title='Items reso in scadenza', items=items)


@app.route('/bots_in_scadenza')
@login_required
def bots_in_scadenza():
    impostazioni = current_user.own_impostazioni().first()
    bots = Bot.query.filter(
        ((date.today()) <= Bot.data_scadenza),
        ((date.today()) >= Bot.data_scadenza - timedelta(days=impostazioni.homepage_giorni_anticipo_bot)),
        Bot.user_id == current_user.id
    ) \
        .order_by(Bot.data_scadenza.asc())
    return render_template('bots.html', title='Bots in scadenza', bots=bots)


@app.route('/proxy_in_scadenza')
@login_required
def proxies_in_scadenza():
    impostazioni = current_user.own_impostazioni().first()
    proxies = Proxy.query.filter(
        ((date.today()) <= Proxy.data_scadenza),
        ((date.today()) >= Proxy.data_scadenza - timedelta(days=impostazioni.homepage_giorni_anticipo_proxy)),
        Proxy.user_id == current_user.id
    ) \
        .order_by(Proxy.data_scadenza.asc())
    return render_template('proxies.html', title='Proxy in scadenza', proxies=proxies)


@app.route('/pagamenti_in_scadenza')
@login_required
def pagamenti_in_scadenza():
    impostazioni = current_user.own_impostazioni().first()
    costi = Costo.query.filter(
        ((date.today()) <= Costo.data_prox_pagamento),
        ((date.today()) >= Costo.data_prox_pagamento - timedelta(days=15)),
        Costo.user_id == current_user.id
    ) \
        .order_by(Costo.data_prox_pagamento.asc())
    return render_template('costi.html', title='Pagamenti in scadenza', costi=costi)
