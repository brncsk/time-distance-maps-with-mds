%NOOP_WEIGHTING Súlyozás csak a távolságmátrix alapján.
%
% (C) GPLv2 Barancsuk Ádám, 2013
function [W, D] = noop_weighting(X, Y, D, o)

    WEIGHT_POWER = o.WeightPower;
    SCALE_BY_DISTANCE = o.WeightScaleByDistance;

    N = size(X, 1);
%    TRANSFORMED_ELEMENTS = D ~= 0;
    ORIGDIST = squareform(pdist(horzcat(X, Y)));
%    DNEW = zeros(N);
%    W = zeros(N);

    W = ORIGDIST .^ -2;
    W(W == Inf) = 0;
    
%    W(TRANSFORMED_ELEMENTS) = mean(W(:)) * TRANSFORMED_WEIGHT_COEFF;
end