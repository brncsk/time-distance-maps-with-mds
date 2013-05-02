function [s] = compute_distance_cartogram(points, pi)

    msize = size(points.Lat, 1);
    proxind = spalloc(msize, msize, nnz(pi));
    proxind(1:size(pi, 1),1:size(pi, 2)) = pi;

    dlat=zeros(msize,msize);
    dlon = zeros(msize,msize);
    lat_base = zeros(msize,msize);
    lon_base = zeros(msize, msize);
    arclen=zeros(msize,msize);
    azimuth=zeros(msize,msize);
    
    for i = 1:msize 
        for j = 1:msize
            
            if i == j
                continue;
            end
            
            [arclen(i,j), azimuth(i,j)] = distance( ...
                points.Lat(i), points.Lon(i),       ...
                points.Lat(j), points.Lon(j)        ...
            );
        
            dlat(i, j) = points.Lat(j) - points.Lat(i);
            lat_base(i, j) = points.Lat(i);

            dlon(i, j) = points.Lon(j) - points.Lon(i);
            lon_base(i, j) = points.Lon(i);
        end
    end

    dist = deg2km(arclen);
%    dist(proxind ~= 0) = proxind(proxind ~= 0);
    
    p = ~logical(tril(dist));
    azimuth = azimuth(p);
    dist = dist(p);
    dlat = dlat(p);
    dlon = dlon(p);
    lat_base = lat_base(p);
    lon_base = lon_base(p);
    proxind = proxind(p);
    
    [x,~,lon_res] = lsqcurvefit(@(az, t) t.*sind(az), azimuth, proxind, dlon);
    [y,~,lat_res] = lsqcurvefit(@(az, t) t.*cosd(az), azimuth, proxind, dlat);
    
%    lon_res = -(lon_res - (dist.*cos(x))) + lon_base;
%    lat_res = -(lat_res - (dist.*sin(y))) + lat_base;

newx = sin(x) .* dist
    
    lat = zeros(msize);
    lon = zeros(msize);
    
    lat(p) = lat_res;
    lon(p) = lon_res;
    s = geostruct_from_latlon(lat, lon, 'Point');
end