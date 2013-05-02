%POSTGIS_FETCH_NODES_BY_TAG Pontok kiválasztása PostGIS-ből
% OpenStreetMap címkék alapján.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function [nodes] = postgis_fetch_nodes_by_tag(conn, tags, varargin)
    query = ['SELECT * FROM mt_nodes_by_tag(''' tags ''')'];
    
    if (~isempty(varargin))
        nodes = postgis_fetch_geometry(conn, query, 'MultiPoint', varargin{1});
    else
        nodes = postgis_fetch_geometry(conn, query, 'MultiPoint');
    end
end