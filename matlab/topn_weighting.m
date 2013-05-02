%TOPN_WEIGHTING Súlyozás a legközelebbi N pont alapján.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function [W, D] = topn_weighting(X, Y, D, o)

    WEIGHT_SCALE_BY_TOP_N = o.WeightByTopN;
    WEIGHT_POWER = o.WeightPower;
    TRANSFORMED_WEIGHT_COEFF = o.TransformedWCoeff;
    SCALE_BY_DISTANCE = o.WeightScaleByDistance;

    N = size(X, 1);
    TRANSFORMED_ELEMENTS = D ~= 0;
    ORIGDIST = squareform(pdist(horzcat(X, Y)));
    DNEW = zeros(N);
    W = zeros(N);
    
    for i = 1:N
        W(i,:) = 0;
        
        [~, idx] = sort(ORIGDIST(i,:));
        top = idx(2:1+WEIGHT_SCALE_BY_TOP_N);
        
        disp([i top]);
        
        DNEW(i, top) = ORIGDIST(i, top);
        DNEW(top, i) = ORIGDIST(top, i);
        
        if SCALE_BY_DISTANCE
            W(i, top) = ORIGDIST(i, top) .^ WEIGHT_POWER;
            W(top, i) = ORIGDIST(top, i) .^ WEIGHT_POWER;
        else
            W(i, top) = 1 .^ WEIGHT_POWER;
            W(top, i) = 1 .^ WEIGHT_POWER;
        end
    end
    
    DNEW(TRANSFORMED_ELEMENTS) = D(TRANSFORMED_ELEMENTS);
    W(TRANSFORMED_ELEMENTS) = mean(W(:)) * TRANSFORMED_WEIGHT_COEFF;
    
    D = DNEW;
    
    %W = W + ORIGDIST.^-2;
    %W(eye(size(W)) ~= 0) = 0;
    MEAN_W = mean(W(:));
    %W(TRANSFORMED_ELEMENTS) = mean(W(:)) * TRANSFORMED_WEIGHT_COEFF;
    
    fprintf('Mean weight: %f\n', MEAN_W);
    fprintf('Weight of transformed elements: %f\n', MEAN_W * TRANSFORMED_WEIGHT_COEFF);
end