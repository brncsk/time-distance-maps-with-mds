curPath = fileparts(mfilename('fullpath'));

cd(curPath);

addpath ([curPath '/lib'], ...
        [curPath '/lib/openstreetmap'], ...
        [curPath '/lib/openstreetmap/gaimc'], ...
        [curPath '/lib/openstreetmap/hold'], ...
        [curPath '/lib/openstreetmap/lat_lon_proportions'], ...
        [curPath '/lib/openstreetmap/plotmd'], ...
        [curPath '/lib/openstreetmap/textmd'], ...
        [curPath '/lib/openstreetmap/xml2struct']);
        
clear curPath;