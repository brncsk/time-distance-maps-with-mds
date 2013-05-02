#!/usr/bin/python
# coding=UTF-8

import json
import urllib2
import datetime
import pdb
import csv

INFILE = '../data/elvira.csv';
OUTFILE = '../data/elvira-dist.csv';
DESTINATIONS = [
        'Pécs', 'Szekszárd', 'Kaposvár', 'Eger', 'Debrecen', 'Szeged',
        'Kecskemét', 'Békéscsaba', 'Miskolc', 'Győr', 'Nyíregyháza',
        'Székesfehérvár', 'Szolnok', 'Budapest', 'Zalaegerszeg',
        'Esztergom', 'Salgótarján', 'Tatabánya', 'Sátoraljaújhely',
        'Veszprém', 'Szombathely' ];

mat = [[0]*len(DESTINATIONS) for _ in range(len(DESTINATIONS))];

for  l in open(INFILE, 'r').readlines():
    [a, b, t] = l.split(',');
    a = DESTINATIONS.index(a);
    b = DESTINATIONS.index(b);
    print(a, b);
    mat[min(a, b)][max(a, b)] = t.strip('\n');

csv.writer(open(OUTFILE, 'wb')).writerows(mat);
