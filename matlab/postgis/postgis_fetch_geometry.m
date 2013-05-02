%POSTGIS_FETCH_GEOMETRY Bármilyen geometria lekérdezése PostGIS-ből a
% Mapping Toolboxban való használathoz megfelelő formátumba.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function [g] = postgis_fetch_geometry(conn, query, varargin)
    if (~isempty(varargin))
        type = varargin{1};
    else
        type = 'Line';
    end
    g = postgis_parse_to_mapping_toolbox(conn, query, type);
end