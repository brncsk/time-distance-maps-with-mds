boundary = struct('Lat', outStruct.TransformedFeatures.Lat(1:9181), 'Lon', outStruct.TransformedFeatures.Lon(1:9181), 'Geometry', 'Line')
roads = struct('Lat', outStruct.TransformedFeatures.Lat(9182:70723), 'Lon', outStruct.TransformedFeatures.Lon(9182:70723), 'Geometry', 'Line')
river = struct('Lat', outStruct.TransformedFeatures.Lat(70724:end), 'Lon', outStruct.TransformedFeatures.Lon(70724:end), 'Geometry', 'Line')
shapewrite(boundary, sprintf(fn, 'boundary'));
shapewrite(roads, sprintf(fn, 'roads'));
shapewrite(river, sprintf(fn, 'river'));