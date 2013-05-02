function [x, g] = compute_optimal_configuration(P, D)

    global DIFF;

    format long;

    MAX_ITER = 5000;
    DECREASE_TOLERANCE = 10e-4;
    ITER_COUNT = 0;
    PREV_STRESS = 0;
    EARTH_RADIUS = 6367.5;
    WEIGHT_SCALING = -0.5;
    WEIGHT_SCALE_BY_TOP_N = 2;
    TRANSFORMED_WEIGHT_COEFF = 1e2;

    %% Preallocate stuff

    N = size(P.Lat, 1);              % Number of points
    XLat = deg2rad(P.Lat);           % Configuration for latitude values
    XLon = deg2rad(P.Lon);           %           ... for longitude values
    XLatNew = zeros(N, 1);           % Temporary storage for latitude values
    XLonNew = zeros(N, 1);           %               ... for longitude values

    % Make the dissimilarity matrix symmetric
    D = tril(D, -1);
    D = D + D';
    
    %% Precompute dissimilarity and azimuth matrices
    
    TRANSFORMED_ELEMENTS = D ~= 0;
    ORIGDIST = zeros(N);
    
    for i = 1:N
        for j = 1:N
            ORIGDIST(i, j) = real(acos(sin(XLat(i))*sin(XLat(j))+cos(XLat(i))*cos(XLat(j))*cos(XLon(j) - XLon(i)))) * EARTH_RADIUS;
        end
    end
    
    
    %% Precompute weighting (Delaunay)
    
    tri = DelaunayTri(P.Lat(:), P.Lon(:)).Triangulation;

    DNEW = zeros(N);
    W = zeros(N);    
    
    for i = 1:size(tri)
        DNEW(tri(i, 1), tri(i, 2)) = ORIGDIST(tri(i, 1), tri(i, 2));
        DNEW(tri(i, 2), tri(i, 1)) = ORIGDIST(tri(i, 1), tri(i, 2));
        
        DNEW(tri(i, 2), tri(i, 3)) = ORIGDIST(tri(i, 2), tri(i, 3));
        DNEW(tri(i, 3), tri(i, 2)) = ORIGDIST(tri(i, 2), tri(i, 3));
        
        DNEW(tri(i, 3), tri(i, 1)) = ORIGDIST(tri(i, 3), tri(i, 1));
        DNEW(tri(i, 1), tri(i, 3)) = ORIGDIST(tri(i, 3), tri(i, 1));

        W(tri(i, 1), tri(i, 2)) = ORIGDIST(tri(i, 1), tri(i, 2)) ^ WEIGHT_SCALING;
        W(tri(i, 2), tri(i, 1)) = ORIGDIST(tri(i, 1), tri(i, 2)) ^ WEIGHT_SCALING;
        
        W(tri(i, 2), tri(i, 3)) = ORIGDIST(tri(i, 2), tri(i, 3)) ^ WEIGHT_SCALING;
        W(tri(i, 3), tri(i, 2)) = ORIGDIST(tri(i, 2), tri(i, 3)) ^ WEIGHT_SCALING;
        
        W(tri(i, 3), tri(i, 1)) = ORIGDIST(tri(i, 3), tri(i, 1)) ^ WEIGHT_SCALING;
        W(tri(i, 1), tri(i, 3)) = ORIGDIST(tri(i, 3), tri(i, 1)) ^ WEIGHT_SCALING;
    end

    DNEW(TRANSFORMED_ELEMENTS) = D(TRANSFORMED_ELEMENTS);
    W(TRANSFORMED_ELEMENTS) = mean(W(:)) * TRANSFORMED_WEIGHT_COEFF;
    
    D = DNEW;

    
    %% Precompute weighting
    
%     DNEW = zeros(N);
%     W = zeros(N);
%     
%     for i = 1:N
%         W(i,:) = 0;
%         
%         [~, idx] = sort(ORIGDIST(i,:));
%         top = idx(2:1+WEIGHT_SCALE_BY_TOP_N);
%         
%         disp([i top]);
%         
%         DNEW(i, top) = ORIGDIST(i, top);
%         DNEW(top, i) = ORIGDIST(top, i);
%         
%         W(i, top) = ORIGDIST(i, top) .^ WEIGHT_SCALING;
%         W(top, i) = ORIGDIST(top, i) .^ WEIGHT_SCALING;
%     end
%     
%     DNEW(TRANSFORMED_ELEMENTS) = D(TRANSFORMED_ELEMENTS);
%     W(TRANSFORMED_ELEMENTS) = mean(W(:)) * TRANSFORMED_WEIGHT_COEFF;
%     
%     D = DNEW;
%     
%     W = W + ORIGDIST.^-2;
%     %W(eye(size(W)) ~= 0) = 0;
%     MEAN_W = mean(W(:));
%     %W(TRANSFORMED_ELEMENTS) = mean(W(:)) * TRANSFORMED_WEIGHT_COEFF;
%     
%     fprintf('Mean weight: %f\n', MEAN_W);
%     fprintf('Weight of transformed elements: %f\n', MEAN_W * TRANSFORMED_WEIGHT_COEFF);
    
    %% Compute the optimal configuration iteratively
    
    DIST = zeros(N, N);
    
    while true
        for k = 1:N
            XLatSum = 0;
            XLonSum = 0;
            
            for l = 1:N
                if (k == l)
                    continue;
                end
                
                DIST(k, l) = real(acos(sin(XLat(k))*sin(XLat(l))+cos(XLat(k))*cos(XLat(l))*cos(XLon(l) - XLon(k)))) * EARTH_RADIUS;
                
                if (DIST(k, l) ~= 0)
                    distinv = 1 / DIST(k, l);
                else
                    distinv = 0;
                end
                
                XLatSum = XLatSum + W(k, l) * (XLat(l) + D(k, l) * distinv * (XLat(k) - XLat(l)));
                XLonSum = XLonSum + W(k, l) * (XLon(l) + D(k, l) * distinv * (XLon(k) - XLon(l)));
            end
            
            WSum = sum(W(k,:));
            XLatNew(k) = XLatSum / WSum;
            XLonNew(k) = XLonSum / WSum;
        end
        
        XLat = XLatNew;
        XLon = XLonNew;
        
        ST = 0;
        
        for k = 1:N
            ST = ST + sum(W(k,1:k-1) .* ((DIST(k,1:k-1) - D(k,1:k-1)).^2));
        end
        
        ITER_COUNT = ITER_COUNT + 1;
        
        if (ITER_COUNT > 1 && (((PREV_STRESS - ST) / PREV_STRESS) < DECREASE_TOLERANCE))
            fprintf('\nOptimization terminated after %d iterations because the\n', ITER_COUNT);
            fprintf('relative stress decrease was less than DECREASE_TOLERANCE.\n');
            fprintf('(DECREASE_TOLERANCE = %g; D_STRESS = %f; STRESS = %f)\n\n', DECREASE_TOLERANCE, PREV_STRESS - ST, ST);
            break;
        end
        
        PREV_STRESS = ST;
           
        if (ITER_COUNT > MAX_ITER)
            fprintf('Optimization terminated because the maximum number of iterations (%d) is reached.\n', MAX_ITER);
            fprintf('(STRESS = %f, Stress decrease = %f)\n', ST, ((PREV_STRESS - ST) / PREV_STRESS));
            break;
        end
    end
    
    x = geostruct_from_latlon(rad2deg(XLat), rad2deg(XLon), 'MultiPoint');
    
    DIFF = zeros(N);
    
    DLat = deg2rad(P.Lat);
    DLon = deg2rad(P.Lon);
    
    for i = 1 : N
        for j = 1 : N
            if (W(i, j) == 0)
                DIFF(i, j) = -Inf;
                continue;
            end
            
            DIFF(i, j) = abs(D(i, j) ...
                -        (real(acos(sin(XLat(i))*sin(XLat(j))+cos(XLat(i))*cos(XLat(j))*cos(XLon(j) - XLon(i)))) * EARTH_RADIUS));
        end
    end
    
    openvar('DIFF');
    image(DIFF);
    
%    colordata = colormap;
%    colordata(end+1,:) = [0 0 0];
%    colormap(colordata);
    
    g = (W ~= 0);

end  