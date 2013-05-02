function [s] = reptags(s, inStruct, outStruct)
    if iscell(s)
        s = sprintf('%s\n' ,s{:});
    end
    s = strrep(s, '%cps', inStruct.ControlPointDescription);
    s = strrep(s, '%features', strrep(inStruct.FeaturesDescription, '_', '\_'));
    s = strrep(s, '%dm', inStruct.DissimilarityDescription);
    s = strrep(s, '%weightalgo', inStruct.WeightingAlgo);
    s = strrep(s, '%weightp', sprintf('%.1f', inStruct.WeightPower));
    s = strrep(s, '%maxiter', sprintf('%d', inStruct.MaxIter));
    s = strrep(s, '%dectol', sprintf('%e', inStruct.DecTol));
    s = strrep(s, '%idwp', sprintf('%.1d', inStruct.IDWPower));
    s = strrep(s, '%angles', sprintf('%d', inStruct.AngleStress));
    s = strrep(s, '%angleweight', sprintf('%e', inStruct.AngleWeight));
    s = strrep(s, '%iters', sprintf('%d', outStruct.IterCount));
    s = strrep(s, '%st', sprintf('%.1f', outStruct.Stress));
    s = strrep(s, '%ast', sprintf('%.1f', outStruct.AngleStress));
    s = strrep(s, '%dst', sprintf('%.1f', outStruct.DistanceStress));
end