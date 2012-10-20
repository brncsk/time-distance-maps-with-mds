function [s] = postgis_parse_to_mapping_toolbox(conn, query, varargin)
    if (~isempty(varargin))
        type = varargin{1};
    else
        type = 'Line';
    end

    cursor = exec(conn, query);
    cursor = fetch(cursor);
    data = cursor.Data;
    lon = cell2mat(data(:,1));
    lat = cell2mat(data(:,2));
    
    s = geostruct_from_latlon(lat, lon, type);
end