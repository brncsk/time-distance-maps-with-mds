%TMERC Mercator vetületi és inverz vetületi transzformációk.
%
% (C) GPLv2 Barancsuk Ádám, 2013

function [x2, y2, sf] = tmerc(y1, x1, varargin)
    EARTH_RADIUS = 6371;
    
    if isempty(varargin) % Project
        x2 = deg2rad(x1);
        y2 = log(abs(tand(y1) + secd(y1)));
        sf = secd(y1);
        sfm = nanmean(sf);
        x2 = x2 * EARTH_RADIUS ./ sfm;
        y2 = y2 * EARTH_RADIUS ./ sfm;
    else % Invert
        x1 = x1 .* varargin{1} / EARTH_RADIUS;
        y1 = y1 .* varargin{1} / EARTH_RADIUS;
        x2 = rad2deg(x1);
        y2 = rad2deg(atan(sinh(y1)));
        sf = sec(y1);
    end
end