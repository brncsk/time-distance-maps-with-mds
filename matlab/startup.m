
POSTGRESQL_JDBC_CLASSPATH='/usr/share/java/postgresql.jar';
POSTGRESQL_CONFIG_PATH='../psql.conf';

%% Set path

curPath = fileparts(mfilename('fullpath'));
cd(curPath);


%% Add JDBC driver path to classpath

javaaddpath(POSTGRESQL_JDBC_CLASSPATH);


%% Read database configuration

confHandle = fopen(POSTGRESQL_CONFIG_PATH);
conf = textscan(confHandle, '%s %s', 'delimiter', '=');
fclose(confHandle);
conf = cell2struct(conf{2}, conf{1});


%% Connect to PostGIS

global conn;
conn = database(conf.PG_DB, conf.PG_USER, conf.PG_PASSWORD, 'Vendor', 'PostgreSQL');
    
%% Clear workspace

clear POSTGRESQL_JDBC_CLASSPATH POSTGRESQL_CONFIG_PATH conf confHandle curPath ans
