%POSTGIS_FETCH_WAYS_BY_TAG Töröttvonalak kiválasztása PostGIS-ből
% OpenStreetMap címkék alapján.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function [nodes] = postgis_fetch_ways_by_tag(conn, tags, varargin)
    query = ['SELECT * FROM mt_ways_by_tag(''' tags ''')'];
    
    if (~isempty(varargin))
        nodes = postgis_fetch_geometry(conn, query, 'Line', varargin{1});
    else
        nodes = postgis_fetch_geometry(conn, query, 'Line');
    end
end