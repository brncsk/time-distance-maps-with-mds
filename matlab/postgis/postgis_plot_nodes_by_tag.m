%POSTGIS_PLOT_NODES_BY_TAG Pontok plottolása PostGIS-ből OpenStreetMap
% címkék alapján.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function postgis_plot_nodes_by_tag(conn, tags, varargin)
    query = ['SELECT * FROM mt_nodes_by_tag(''' tags ''')'];
    
    if (length(varargin) > 1)
        postgis_plot_query(conn, query, 'MultiPoint', varargin{1}, varargin{2});
    elseif (~isempty(varargin))
        postgis_plot_query(conn, query, 'MultiPoint', varargin{1});
    else
        postgis_plot_query(conn, query, 'MultiPoint');
    end
end