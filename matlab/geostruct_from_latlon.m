%GEOSTRUCT_FROM_LATLON MATLAB geostruct típus készítése földrajzi
%pozíciókból.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function [s] = geostruct_from_latlon(lat, lon, type, varargin)
    s = struct( ...
        'Geometry',  type, ...
        'Lat',       lat, ...
        'Lon',       lon ...
    );

    if (~isempty(varargin))
        fn = fieldnames(varargin{1});
        for i = 1:numel(fn)
            s.(fn{i}) = ...
                {varargin{1}.(fn{i})};
        end    
    end
end