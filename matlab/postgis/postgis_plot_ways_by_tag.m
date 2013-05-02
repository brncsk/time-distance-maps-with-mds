%POSTGIS_PLOT_WAYS_BY_TAG Töröttvonalak plottolása PostGIS-ből
% OpenStreetMap címkék alapján.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function postgis_plot_ways_by_tag(conn, tags, varargin)
    query = ['SELECT * FROM mt_ways_by_tag(''' tags ''')'];
    
    if (~isempty(varargin))
        postgis_plot_query(conn, query, 'Line', varargin{1});
    else
        postgis_plot_query(conn, query);
    end
end