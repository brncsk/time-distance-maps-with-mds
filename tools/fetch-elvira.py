#!/usr/bin/python
# coding=UTF-8

"""
    Magyar várospárok átlagos vasúti elérhetőségi ideje
    (az Elvira API alapján)
    (C) GPL v2 Barancsuk Ádám, 2013
"""

import json         # JSON-értelmező
import urllib2      # HTTP-kérésekhez
import datetime     # Dátum-formázáshoz
import csv          # CSV-íráshoz
import numpy        # Átlagszámításhoz
import pdb          # Hibakereséshez (nincs használatban)

# Az Elvira API végpontja
ENDPOINT_URI = 'http://apiv2.oroszi.net/elvira';

# Kimeneti fájlnevek
OUTFILE_PAIRS = '../data/elvira.csv';    # Távolságok várospáronként
OUTFILE_MAT = '../data/elvira-dist.csv'; # Teljes elérhetőségi mátrix

# Városnevek
DESTINATIONS = [
        'Pécs', 'Szekszárd', 'Kaposvár', 'Eger', 'Debrecen', 'Szeged',
        'Kecskemét', 'Békéscsaba', 'Miskolc', 'Győr', 'Nyíregyháza',
        'Székesfehérvár', 'Szolnok', 'Budapest', 'Zalaegerszeg',
        'Esztergom', 'Salgótarján', 'Tatabánya', 'Sátoraljaújhely',
        'Veszprém', 'Szombathely' ];

# Figyelembeveendő vonattípusok
# (A tapasztalatok alapján az API nagyjából ezeket szokta visszaadni, de
# egyrészt sejthető, hogy ezeknek közük sincs az angol
# szakkifejezésekhez, másrészt nehéz beazonosítani, hogy mit takarnak
# pontosan.)
TRAIN_TYPES = [
    #'passenger',    # (Személy?!)
    #'fast',         # Gyors
    #'through',      # (Sebes?!)
    'intercity'     # IC
    ];


# A lekérdezési URI-t összeállító függvény
# ("minden vonat A-ból B-be a mai napon, eredmény JSON-formátumban")
def query(s_from, s_to):
    return (ENDPOINT_URI + '?from={}&to={}&date={}&content-type=jsonp').\
        format(s_from, s_to, datetime.date.today().strftime('%Y.%m.%d.'));

# `hh:mm` alakú időbélyegből perc-érték
def time_in_minutes(s):
    t = map(int, s.split(':'));
    return t[0] * 60 + t[1];

# Kimeneti fájl megnyitása
f = open(OUTFILE_PAIRS, 'w+');

# Üres elérhetőségi mátrix létrehozása
mat = [[0] * len(DESTINATIONS) for _ in range(len(DESTINATIONS))];

# A webszolgáltatás lekérdezése várospáronként
for p in [(x, y) for x in DESTINATIONS for y in DESTINATIONS if x != y]:
    # Az API relatíve gyakran dobál HTTP 500-akat és 502-ket,
    # így addig próbálkozunk, amíg nem jutunk eredményre.
    while True:
        try:
            resp = urllib2.urlopen(query(p[0], p[1]));
            if resp.getcode() == 200:
                resp = json.load(resp);
                break;
        except:
            pass;

    # Kiszámoljuk, mennyi az átlagos vasúti elérhetőség a mai napon
    # (minden A-ból B-be közlekedő vonat útidejének átlaga)
    try:
        m = numpy.mean([time_in_minutes(x['totaltime'])
            for x in resp['timetable']
                if 'type' in x
                and x['type'] in TRAIN_TYPES]);
    except Exception as e:
        # Néhány esetben a kapott eredmény nem felel meg az általunk
        # várt formátumnak, ilyenkor jelezzük a kivételt és a hívási
        # vermet a terminálon de egyébként figyelmen kívül hagyjuk.
        print e;
        pass;

    # Kitöltjük az elérhetőségi mátrix vonatkozó elemét.
    mat[DESTINATIONS.index(p[0])][DESTINATIONS.index(p[1])] = m;

    # Kiírjuk az adatokat a párokat tartalmazó CSV-be és a terminálba.
    print "{},{},{}".format(p[0], p[1], m);
    f.write("{},{},{}\n".format(p[0], p[1], m));
    f.flush();

# Kiírjuk az elérhetőségi mátrixot CSV-be
csv.writer(open(OUTFILE_MAT, 'wb')).writerows(mat);
