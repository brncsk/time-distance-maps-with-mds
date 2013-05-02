%MDS_WRAPPER Az MDS-algoritmus tesztelése és az eredmények megjelenítése/mentése.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function mds_wrapper(o)    
    %% Az algoritmus meghívása
    
    P = o.ControlPoints;
    D = o.DissimilarityMatrix;
    S = o.Features;
    [PN, outStruct] = compute_optimal_configuration(P, D, S, o);
    
    fprintf('*** Time spent in compute_optimal_configuration(): %fs\n', outStruct.RunTime);
    
    
    %% Adatok kirajzolása
    
    f = figure;
    ss = get(0, 'ScreenSize');
    set(f, 'OuterPosition', [0 0 ss(3) ss(4)]);

    % Stresszfüggvények kirajzolása
    if (o.AngleStress)
        subplot(3, 6, 1);
            title('Distance weights');
            plot(outStruct.StressHistory(:, 1));

        subplot(3, 6, 2);
            title('Angle weights');
            plot(outStruct.StressHistory(:, 2));
    else
        subplot(3, 6, [1 2]);
            title('Distance weights');
            plot(outStruct.StressHistory(:, 1));
    end
    
    % Távolság-hibák kirajzolása
    subplot(3, 6, [7:8 13:14]);
        image(outStruct.DistError);
    
    % Térkép kirajzolása
    subplot(3, 6, [3:6 9:12 15:18]);    
        symbolspec;
        maph = axesm('mercator');

        % Súlyozási kapcsolatok
        if (o.PlotWeightingEdges)
            for i = 1 : size(PN.Lat, 1)
                for j = 1 : size(PN.Lat, 1)
                    if (outStruct.WeightingEdges(i, j))
                        geoshow([P.Lat(i) P.Lat(j)], [P.Lon(i) P.Lon(j)], 'DisplayType', 'line', 'Color', [.95 .95 .95]);
                    end
                end
            end
        end

        % Eredeti geometriák
        if (o.PlotOrigFeatures)
            geoshow(S, 'SymbolSpec', symspec.border);
        end
        
        % Torzított geometriák
        if (o.PlotTransformedFeatures)
            geoshow(outStruct.TransformedFeatures, 'SymbolSpec', symspec.border2);
        end

        % Kontrollpontok címkéi és torzítási vektorok
        for i = 1 : size(PN.Lat, 1)
            if (o.PlotCPLabels)
                textm(PN.Lat(i), PN.Lon(i), sprintf(' %d %s', i, strsanitize(P.Names{i})), 'Color', 'r', 'BackgroundColor', [1 1 1]);
            end
            if (o.PlotTransformationVectors)
                geoshow([P.Lat(i) PN.Lat(i)], [P.Lon(i) PN.Lon(i)], 'DisplayType', 'line', 'Color', [.5 .5 .5], 'LineWidth', 2);
            end
        end

        % Kontrollpontok „nyoma”
        if (o.PlotCPTraces)
            geoshow(outStruct.CPTraces, 'SymbolSpec', symspec.traces);
        end
        
        % Eredeti kontrollpontok
        if (o.PlotOrigCPs)
            geoshow(P, 'SymbolSpec', symspec.cities_original);
        end
        
        % Torzított kontrollpontok
        if (o.PlotTransformedCPs)
            geoshow(PN, 'SymbolSpec', symspec.cities_transformed);
        end
        
        % Feliratok
        ylim = get(gca, 'YLim');
        xlim = get(gca, 'XLim');
        text(xlim(1) + 0.001, ylim(2) - 0.001, ...
            reptags(o.MapCaption, o, outStruct), ...
            'VerticalAlignment','top', ...
            'HorizontalAlignment','left');
        
        % Térkép exportálása képfájlba
        if (o.ExportMap)
            if (o.FileTimestamp)
                fn = sprintf('%s-%s', ...
                    reptags(o.FilePrefix, o, outStruct), ...
                    datestr(now, 'YYYY-mmm-dd-hh-MM'));
            else
                fn = reptags(o.FilePrefix, o, outStruct);
            end
            saveas(maph, sprintf('../data/figures/%s.png', fn));
        end
        
        if (o.ExportShapefiles)
            if (o.FileTimestamp)
                fn = sprintf('%s-%s', ...
                    reptags(o.FilePrefix, o, outStruct), ...
                    datestr(now, 'YYYY-mmm-dd-hh-MM'));
            else
                fn = reptags(o.FilePrefix, o, outStruct);
            end
            
            fn = sprintf('../data/shapefiles/%s-%%s.shp', fn);
            
            if (o.ShpOrigCPs)
                shapewrite(P, sprintf(fn, 'origcps'));
            end
            
            if (o.ShpTransformedCPs)
                shapewrite(PN, sprintf(fn, 'transcps'));
            end
            
            if (o.ShpOrigFeatures)
                shapewrite(S, sprintf(fn, 'origfeatures'));
            end
            
            if (o.ShpTransformedFeatures)
                shapewrite(outStruct.TransformedFeatures, sprintf(fn, 'transfeatures'));
            end
        end
        
end







