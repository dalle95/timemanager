import app
from app import app, db
from app.models import User, Impostazioni, Item, Bot, Proxy, Negozio
from app.email import send_email
from flask_login import current_user
from flask import render_template
import csv
from datetime import datetime, date, timedelta
import sqlalchemy
from sqlalchemy import extract, cast
from sqlalchemy.dialects.postgresql import INTERVAL


def convert_data_str_obj(date_str):
    date_obj = datetime.strptime(date_str, '%d/%m/%Y').date()
    return date_obj


def insert(file, user_id):
    if 'tem' in file:
        table = 'item'
    elif 'ot' in file:
        table = 'bot'
    elif 'rox' in file:
        table = 'proxy'
    elif 'egozi' in file:
        table = 'shop'
    else:
        table = None

    if table is not None:

        records = []

        with open(file, newline='') as f:
            reader = csv.reader(f)
            data = list(reader)

        for row in data[1::]:
            row_splitted = row[0].split(";")
            tupla = tuple(row_splitted)
            records.append(tupla)
            # print(tupla)

        print(records)

        fixed_data = []

        n_righe = 0
        for line in records:

            fixed_line_list = []
            for dato in line:

                if dato != "":
                    dato = str(dato)
                    fixed_line_list.append(dato)
                else:
                    fixed_line_list.append(None)

            fixed_line = tuple(fixed_line_list)

            fixed_data.append(fixed_line)
            n_righe += 1

        records = fixed_data

        if table == 'item':
            for record in records:
                # Dichiarazione valori per l'insert
                data_ordine = convert_data_str_obj(record[5])
                codice = codifica_item(data_ordine, current_user.id)
                descrizione = record[0]
                prezzo = record[1]
                spedizione_acquisto = record[2]
                reship = record[3]
                slot = record[4]
                data_consegna = convert_data_str_obj(record[6])
                proxy = Proxy.query.filter_by(codice=record[7], user_id=user_id).first()
                if proxy is not None:
                    proxy = proxy.id
                bot = Bot.query.filter_by(codice=record[8], user_id=user_id).first()
                if bot is not None:
                    bot = bot.id
                negozio = Negozio.query.filter_by(descrizione=record[9], user_id=user_id).first()
                if negozio is not None:
                    negozio = negozio.id
                taglia = record[10]
                incasso = record[11]
                spedizione_vendita = record[12]
                data_vendita = convert_data_str_obj(record[13])
                canale = record[14]
                contatto = record[15]
                stato = record[16]
                sku = record[17]
                user_id = user_id
                data_creazione = datetime.now()

                item = Item(codice=codice,
                            descrizione=descrizione,
                            prezzo=prezzo,
                            spedizione_acquisto=spedizione_acquisto,
                            reship=reship,
                            slot=slot,
                            data_ordine=data_ordine,
                            data_consegna=data_consegna,
                            proxy=proxy,
                            bot=bot,
                            negozio=negozio,
                            taglia=taglia,
                            incasso=incasso,
                            spedizione_vendita=spedizione_vendita,
                            data_vendita=data_vendita,
                            canale=canale,
                            contatto=contatto,
                            stato=stato,
                            sku=sku,
                            user_id=user_id,
                            data_creazione=data_creazione)
                db.session.add(item)
            db.session.commit()

        if table == 'bot':
            for record in records:
                # Dichiarazione valori per l'insert
                data_attivazione = convert_data_str_obj(record[2])
                codice = codifica_boteproxy(Bot, data_attivazione, current_user.id)
                descrizione = record[0]
                costo = record[1]
                data_scadenza = convert_data_str_obj(record[3])
                user_id = user_id
                data_creazione = datetime.now()

                bot = Bot(codice=codice,
                          descrizione=descrizione,
                          costo=costo,
                          data_attivazione=data_attivazione,
                          data_scadenza=data_scadenza,
                          user_id=user_id,
                          data_creazione=data_creazione)

                db.session.add(bot)
            db.session.commit()

        if table == 'proxy':
            for record in records:
                # Dichiarazione valori per l'insert
                data_attivazione = convert_data_str_obj(record[2])
                codice = codifica_boteproxy(Proxy, data_attivazione, current_user.id)
                descrizione = record[0]
                costo = record[1]
                data_scadenza = record[3]
                user_id = user_id
                data_creazione = datetime.now()

                proxy = Proxy(codice=codice,
                              descrizione=descrizione,
                              costo=costo,
                              data_attivazione=data_attivazione,
                              data_scadenza=data_scadenza,
                              user_id=user_id,
                              data_creazione=data_creazione)

                db.session.add(proxy)
            db.session.commit()

        if table == 'shop':
            for record in records:
                # Dichiarazione valori per l'insert
                descrizione = record[0]
                giorni_reso = record[1]
                user_id = user_id

                shop = Negozio(descrizione=descrizione,
                               giorni_reso=giorni_reso,
                               user_id=user_id)

                db.session.add(shop)
            db.session.commit()

        if n_righe > 1:
            table = table + 's'
            risultato = 'Il file è stato caricato. Sono stati aggiunti {} {}.'.format(n_righe, table)
        else:
            risultato = 'Il file è stato caricato. È stato aggiunto {} {}.'.format(n_righe, table)
    else:
        risultato = 'Il file non è stato caricato. Modifica il nome del file.'

    return risultato


def codifica_item(data_ordine, user_id):
    # Codifica Item
    ext_anno = str(data_ordine.year)[-2:]
    ext_mese = data_ordine.month
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
    progressivo = Item.query.filter(
        extract('month', Item.data_ordine) == extract('month', data_ordine), Item.user_id == user_id).count() + 1
    if progressivo < 10:
        progressivo_fix = str('000' + str(progressivo))
    elif progressivo < 100:
        progressivo_fix = str('00' + str(progressivo))
    else:
        progressivo_fix = str('0' + str(progressivo))

    codice = '{}_{}_{}'.format(codice_mese, ext_anno, progressivo_fix)
    return codice


def codifica_boteproxy(modello, data_attivazione, user_id):
    # Codifica Bot e Proxy
    ext_anno = str(data_attivazione.year)[-2:]
    ext_mese = data_attivazione.month
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
    progressivo = modello.query.filter(
        extract('month', modello.data_attivazione) == extract('month', data_attivazione),
        modello.user_id == user_id).count() + 1
    if progressivo < 10:
        progressivo_fix = str('000' + str(progressivo))
    elif progressivo < 100:
        progressivo_fix = str('00' + str(progressivo))
    else:
        progressivo_fix = str('0' + str(progressivo))

    codice = '{}_{}_{}'.format(codice_mese, ext_anno, progressivo_fix)
    return codice


def items_resi_in_scadenza(user_id, giorni_anticipo):
    # Controllo tutti items
    user_items = Item.query.join(Negozio, Negozio.descrizione == Item.negozio) \
                           .filter(Item.stato == 'Acquisto',
                                   ((date.today()) <= Item.data_scadenza_reso),
                                   ((date.today()) >= Item.data_scadenza_reso - timedelta(days=giorni_anticipo)),
                                   Item.user_id == user_id
                                  )
    # print(user_items.all())
    return user_items


def bots_in_scadenza(user_id, giorni_anticipo):
    # Controllo tutti i bot
    user_bots = Bot.query.filter(
                                ((date.today()) <= Bot.data_scadenza),
                                ((date.today()) >= Bot.data_scadenza - timedelta(days=giorni_anticipo)),
                                Bot.user_id == user_id
                              )
    # print(user_bots.all())
    return user_bots


def proxies_in_scadenza(user_id, giorni_anticipo):
    # Controllo tutti i bot
    user_proxies = Proxy.query.filter(
                                ((date.today()) <= Proxy.data_scadenza),
                                ((date.today()) >= Proxy.data_scadenza - timedelta(days=giorni_anticipo)),
                                Proxy.user_id == user_id
                              )
    # print(user_proxies.all())
    return user_proxies


def genera_notifiche():
    # Controllo tutti gli utenti e li controllo uno alla volta
    users = User.query.all()
    for user in users:
        username = user.username
        email = user.email

        # Controllo le impostazioni dell'utente
        impostazioni_user = Impostazioni.query.filter_by(user_id=user.id).first()
        # Se l'utente ha attive le notifiche per i resi chiamo la funzione che trova gli items
        if impostazioni_user.notifiche_scadenze_resi:
            items = items_resi_in_scadenza(user.id, impostazioni_user.notifica_giorni_anticipo_resi)
            print('Scadenze Items per ' + username + ': ' + str(items.all()))
            if not items.all():
                items = 0
                items_ok = 0
            else:
                items_ok = 1
        else:
            items = 0
            items_ok = 0
        # Se l'utente ha attive le notifiche per le scadenze dei bot chiamo la funzione che li trova
        if impostazioni_user.notifiche_scadenze_bot:
            bots = bots_in_scadenza(user.id, impostazioni_user.notifica_giorni_anticipo_bot)
            print('Scadenze Bots per ' + username + ': ' + str(bots.all()))
            if not bots.all():
                bots = 0
                bots_ok = 0
            else:
                bots_ok = 1
        else:
            bots = 0
            bots_ok = 0
        # Se l'utente ha attive le notifiche per le scadenze dei proxy chiamo la funzione che li trova
        if impostazioni_user.notifiche_scadenze_proxy:
            proxies = proxies_in_scadenza(user.id, impostazioni_user.notifica_giorni_anticipo_proxy)
            print('Scadenze Proxies per ' + username + ': ' + str(proxies.all()))
            if not proxies.all():
                proxies = 0
                proxies_ok = 0
            else:
                proxies_ok = 1
        else:
            proxies = 0
            proxies_ok = 0

        if (items_ok + bots_ok + proxies_ok) != 0:
            with app.app_context():
                send_email('[Info Copping] Notifica Scadenze',
                           sender=app.config['ADMINS'][0],
                           recipients=[email, app.config['ADMINS'][0]],
                           text_body=render_template('email/notifica_scadenze.txt',
                                                     items=items,
                                                     bots=bots,
                                                     proxies=proxies,
                                                     user=username),
                           html_body=render_template('email/notifica_scadenze.html',
                                                     items=items,
                                                     bots=bots,
                                                     proxies=proxies,
                                                     user=username)
                           )



'''
.join(Impostazioni, Impostazioni.user_id == User.id)\
.filter((Impostazioni.notifiche_resi == True) |
        (Impostazioni.notifiche_proxy == True) |
        (Impostazioni.notifiche_bot == True) |
        (Impostazioni.notifiche_mensili == True)
        ) \
    # Recupero gli items con il reso in scadenza
    items_query = items_resi_in_scadenza()

    items = items_query.join(User, User.id == Item.user_id)\
                       .join(Impostazioni, Impostazioni.user_id == User.id)\
                       .filter(Impostazioni.notifiche_resi == True)\
                       .all()

    users = []
    for item in items:
        if item.user_id not in users:
            users.append(item.user_id)

    # Itero per ogni user trovato per mandargli l'email con la notifica
    for user in users:
        query_user_items = items_query.with_entities(
                                                    Item.codice,
                                                    Item.descrizione,
                                                    Item.data_ordine + (func.cast('1 DAYS', INTERVAL) * Negozio.giorni_reso),
                                                    Item.user_id
                                                    )\
                                      .filter(Item.user_id == user)\
                                      .order_by(Item.data_ordine.asc())

        user_items = query_user_items.all()
        user = User.query.filter(User.id == user).first()
        username = user.username
        email = user.email
        print(username + ': ' + str(user_items))

        with app.app_context():
            send_email('Notifica Resi in Scadenza',
                       sender=app.config['ADMINS'][0],
                       recipients=[email],
                       text_body=render_template('email/notifica_reso.txt',
                                                 items=user_items, user=username),
                       html_body=render_template('email/notifica_reso.html',
                                                 items=user_items, user=username)
                       )





def schedula_notifiche():
    with app.app_context():
        scheduler = BackgroundScheduler(timezone="Europe/Rome")
        scheduler.start()

        trigger = CronTrigger(
            year="*", month="*", day="*", hour="0", minute="26", second="0", timezone="Europe/Rome"
        )
        scheduler.add_job(
            genera_notifiche,
            trigger=trigger,
            args=[app],
            name="Notifiche resi in scadenza",
        )
        while True:
            sleep(5)


'''