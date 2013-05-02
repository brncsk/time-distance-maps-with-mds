%POSTGIS_PLOT_QUERY PostGIS-lekérdezés eredményének plottolása.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function postgis_plot_query(conn, query, varargin)
    if (~isempty(varargin))
        type = varargin{1};
    else
        type = 'Line';
    end
    [s] = postgis_parse_to_mapping_toolbox(conn, query, type);

    disp(['postgis_plot_query: ' num2str(sum(~isnan(s.Lat))) ' points']);
    
    if (length(varargin) > 1)
        geoshow(s, 'SymbolSpec', varargin{2});
        
        if ((length(varargin) > 2) && strcmp(type, 'MultiPoint'))
            for i = 1 : size(s.Lat, 1)
                textm(s.Lat(i), s.Lon(i), s.Names(i));
            end
        end
    else
        geoshow(s);
    end
end