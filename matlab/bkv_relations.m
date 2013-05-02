function [p, d] = bkv_relations(year)

    global conn;

    try
        r = importdata(sprintf('../data/bkv/villamos-utidok-%d', year));
        travel_times = r.data;
        tt_relations = r.textdata;
    catch e
       fprintf('%s\n', e.message);
       return;
    end
    
    query = sprintf('SELECT * FROM bkv_relations(''%d-01-01'', true, 1)', year);

    cursor = exec(conn, query);
    cursor = fetch(cursor);
    data = cursor.Data;
    
    geometries = (data(:, 1));
    db_relations = (data(:, 2));
    
    nr = sum(cellfun(@(x) sum(ismember(tt_relations, x)), db_relations));
    p = struct('Lat', zeros(nr * 2, 1), 'Lon', zeros(nr * 2, 1), 'Geometry', 'MultiPoint');
    names =  cell(nr * 2, 1);
    d = zeros(nr * 2);
    
    p_i = 1;
    for i = 1:numel(geometries)
        id = find(ismember(tt_relations, db_relations{i}));
        
        if isempty(id)
            fprintf('Skipping %s\n', db_relations{i});
            continue;
        end
        
        p1 = geometries{i}.getGeometry.getFirstPoint;
        p2 = geometries{i}.getGeometry.getLastPoint;
        
        p1_id = 0;
        p2_id = 0;
        for j = 1:(nr * 2)
            if (p.Lat(j) == p1.getY) && (p.Lon(j) == p1.getX)
                p1_id = j;
            end
            if (p.Lat(j) == p2.getY) && (p.Lon(j) == p2.getX)
                p1_id = j;
            end
        end
        
        if p1_id == 0
            p.Lat(p_i) = p1.getY;
            p.Lon(p_i) = p1.getX;
            
            p1_id = p_i;
            p_i = p_i + 1;
        end
        
        if p2_id == 0
            p.Lat(p_i) = p2.getY;
            p.Lon(p_i) = p2.getX;
            
            p2_id = p_i;
            p_i = p_i + 1;
        end
        
        p.Lat(p1_id) = geometries{i}.getGeometry.getFirstPoint.getY;
        p.Lon(p1_id) = geometries{i}.getGeometry.getFirstPoint.getX;

        p.Lat(p2_id) = geometries{i}.getGeometry.getLastPoint.getY;
        p.Lon(p2_id) = geometries{i}.getGeometry.getLastPoint.getX;
        
        names{p1_id} = tt_relations{id};
        names{p2_id} = tt_relations{id};
        
        d(p1_id, p2_id) = travel_times(id);
        d(p2_id, p1_id) = travel_times(id);
    end
    
    p_i = p_i - 1;
    p.Lat = p.Lat(1:p_i);
    p.Lon = p.Lon(1:p_i);
    d = d(1:p_i,1:p_i);
    
    p.Names = names;
end