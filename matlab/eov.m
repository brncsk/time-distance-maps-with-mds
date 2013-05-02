%EOV Egységes Országos Vetület transzformációja.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function [x, y] = eov (lat, lon)
    PHI_K = 47.1;
    RED_COEFF = 0.99993;
    EARTH_RADIUS = 6371;
    FALSE_NORTHING = 200000;
    FALSE_EASTING = 650000;
    
    x = RED_COEFF * (EARTH_RADIUS / 2) * ...
        log( ...
            (1 + cosd(PHI_K) .* sind(lat) - sind(PHI_K) .* cosd(lat) .* cosd(lon)) /    ...
            (1 - cosd(PHI_K) .* sind(lat) + sind(PHI_K) .* cosd(lat) .* cosd(lon))      ...
        ) + FALSE_NORTHING;

    y = RED_COEFF * EARTH_RADIUS * ...
        atan( ...
            sind(lon) / ...
            tand(at) * sind(PHI_K) + cosd(PHI_K) * cosd(lon) ...
        ) + FALSE_EASTING;
end

%EOV_INVTRAN Egységes Országos Vetület inverz transzformációja.
function [lat, lon] = eov_invtran (x, y)

end