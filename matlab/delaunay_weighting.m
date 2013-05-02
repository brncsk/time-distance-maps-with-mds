%DELAUNAY_WEIGHTING Súlyozás Delaunay-háromszögelés alapján.
%
% (C) GPLv2 Barancsuk Ádám, 2013

function [W, D] = delaunay_weighting (X, Y, D, o)

    WEIGHT_POWER = o.WeightPower;
    TRANSFORMED_WEIGHT_COEFF = o.TransformedWCoeff;

    N = size(X, 1);
    TRANSFORMED_ELEMENTS = D ~= 0;
    ORIGDIST = squareform(pdist(horzcat(X, Y)));
    DNEW = zeros(N);
    W = zeros(N);    
    
    tri = DelaunayTri(X(:), Y(:)).Triangulation;

    for i = 1:size(tri)
        DNEW(tri(i, 1), tri(i, 2)) = ORIGDIST(tri(i, 1), tri(i, 2));
        DNEW(tri(i, 2), tri(i, 1)) = ORIGDIST(tri(i, 1), tri(i, 2));
        
        DNEW(tri(i, 2), tri(i, 3)) = ORIGDIST(tri(i, 2), tri(i, 3));
        DNEW(tri(i, 3), tri(i, 2)) = ORIGDIST(tri(i, 2), tri(i, 3));
        
        DNEW(tri(i, 3), tri(i, 1)) = ORIGDIST(tri(i, 3), tri(i, 1));
        DNEW(tri(i, 1), tri(i, 3)) = ORIGDIST(tri(i, 3), tri(i, 1));

        W(tri(i, 1), tri(i, 2)) = ORIGDIST(tri(i, 1), tri(i, 2)) ^ WEIGHT_POWER;
        W(tri(i, 2), tri(i, 1)) = ORIGDIST(tri(i, 1), tri(i, 2)) ^ WEIGHT_POWER;
        
        W(tri(i, 2), tri(i, 3)) = ORIGDIST(tri(i, 2), tri(i, 3)) ^ WEIGHT_POWER;
        W(tri(i, 3), tri(i, 2)) = ORIGDIST(tri(i, 2), tri(i, 3)) ^ WEIGHT_POWER;
        
        W(tri(i, 3), tri(i, 1)) = ORIGDIST(tri(i, 3), tri(i, 1)) ^ WEIGHT_POWER;
        W(tri(i, 1), tri(i, 3)) = ORIGDIST(tri(i, 3), tri(i, 1)) ^ WEIGHT_POWER;
    end

    DNEW(TRANSFORMED_ELEMENTS) = D(TRANSFORMED_ELEMENTS);
    W(TRANSFORMED_ELEMENTS) = mean(W(:)) * TRANSFORMED_WEIGHT_COEFF;
    D = DNEW;
    
end