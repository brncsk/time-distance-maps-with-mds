function [p] = bkv_ways(year, tolr)

    global conn;

    try
        r = importdata(sprintf('../data/bkv/villamos-utidok-%d', year));
        travel_times = r.data;
        tt_relations = r.textdata;
    catch e
       fprintf('%s\n', e.message);
       return;
    end
    
    query = sprintf('SELECT * FROM bkv_relations(''%d-01-01'', true, %f)', year, tolr);

    cursor = exec(conn, query);
    cursor = fetch(cursor);
    data = cursor.Data;
    
    geometries = (data(:, 1));
    db_relations = (data(:, 2));
    
    nr = sum(cellfun(@(x) sum(ismember(tt_relations, x)), db_relations));
    p = struct('Lat', [], 'Lon', [], 'Geometry', 'Line');
    
    for i = 1:numel(geometries)
        id = find(ismember(tt_relations, db_relations{i}));
        
        if isempty(id)
            fprintf('Skipping %s\n', db_relations{i});
            continue;
        end
        
        g = geometries{i}.getGeometry;
        for j = 1 : g.numPoints - 1
            p.Lat(size(p.Lat) + 1) = g.getPoint(j).getY;
            p.Lon(size(p.Lon) + 1) = g.getPoint(j).getX;
        end
               
        p.Lat(size(p.Lat) + 1) = NaN;
        p.Lon(size(p.Lon) + 1) = NaN;
    end
    
    p.Lat = p.Lat';
    p.Lon = p.Lon';
end