%STARTUP.M Szükséges infrastruktúra felépítése a MATLAB indításakor.
%
% (C) GPLv2 Barancsuk Ádám, 2013

POSTGRESQL_JDBC_CLASSPATH = '/usr/share/java/postgresql.jar';
POSTGIS_JDBC_CLASSPATH = '/usr/share/java/postgis.jar';
POSTGRESQL_CONFIG_PATH = '../psql.conf';
DATA_PATH = '../data/';

%% Elérési utak beállítása

curPath = fileparts(mfilename('fullpath'));
cd(curPath);

addpath ([curPath '/postgis'], ...
         [curPath '/lib'] ...
);

%% JDBC adatbázismeghajtó betöltése

javaaddpath(POSTGRESQL_JDBC_CLASSPATH);
javaaddpath(POSTGIS_JDBC_CLASSPATH);


%% Adatbázishozzáférés adatainak betöltése

confHandle = fopen(POSTGRESQL_CONFIG_PATH);
conf = textscan(confHandle, '%s %s', 'delimiter', '=');
fclose(confHandle);
conf = cell2struct(conf{2}, conf{1});


%% Csatalakozás a PostGIS-hez

global conn;
conn = database(conf.PG_DB, conf.PG_USER, conf.PG_PASSWORD, 'Vendor', 'PostgreSQL');


%% Adatok betöltése

d = dir([DATA_PATH '*.mat']);

for i = 1 : numel(d)
    load([DATA_PATH d(i).name]);
end


%% A munkaterület kiürítése

clear POSTGRESQL_JDBC_CLASSPATH POSTGIS_JDBC_CLASSPATH POSTGRESQL_CONFIG_PATH DATA_PATH conf confHandle curPath ans d i

%% Misc.

global DIFF;
