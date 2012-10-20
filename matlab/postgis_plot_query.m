function postgis_plot_query(conn, query, varargin)
    if (~isempty(varargin))
        type = varargin{1};
    else
        type = 'Line';
    end
    s = postgis_parse_to_mapping_toolbox(conn, query, type);
    
    if (length(varargin) > 1)
        geoshow(s, 'SymbolSpec', varargin{2});
    else
        geoshow(s);
    end
end