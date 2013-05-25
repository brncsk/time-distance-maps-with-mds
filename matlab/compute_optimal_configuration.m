%COMPUTE_OPTIMAL_CONFIGURATION Nem-földrajzi távolságok alapján torzított
% térkép létrehozása többdimenziós skálázással.
%
% (C) GPLv2 Barancsuk Ádám, 2013

function [x, outStruct] = compute_optimal_configuration(P, D, S, o)

    % Futásiidő-mérés kezdete
    tic;

    % Számformátum beállítása hibakereséshez
    format shortg;

    % Állandók
    MAX_ITER = o.MaxIter;           % Iterációk maximális száma
    DECREASE_TOLERANCE = o.DecTol;  % A stresszfügvény minimális csökkenése két iteráció közt
    ANGLE_WEIGHT = o.AngleWeight;   % Szögeltérések súlya a stresszfüggvényben
    IDW_POWER = o.IDWPower;         % Távolságkitevő az IDW-ben

    ITER_COUNT = 0;                 % Iterációk száma
    PREV_STRESS = 0;                % A stresszfüggvény értéke az előző iterációban
    
    %% Változómemória előkészítése
    
    outStruct = struct();

    N = size(P.Lat, 1);                     % Kontrollpontok száma
    [X, Y, SF] = tmerc(P.Lat, P.Lon);       % Kontrollpontok vetületi transzformációja
    
    ORIGX = X;
    ORIGY = Y;

    % A távolságmátrix szimmetrikussá tétele
    D = tril(D, -1);
    D = D + D';

    % A kontrollpontok egymáshoz viszonyított azimutjának kiszámítása
    ORIGBEARING = zeros(N);
    
    for i = 1:N
        for j = 1:N
            ORIGBEARING(i, j) = atan2(X(j) - X(i), Y(j) - Y(i));
        end
    end
     
    
    %% Távolságmátrix és súlyozás előfeldolgozása
    
    if (strcmp(o.WeightingAlgo, 'Delaunay-háromszögelés'))
        [W, D] = delaunay_weighting(X, Y, D, o);
    elseif (strcmp(o.WeightingAlgo, 'Legközelebbi N pont alapján'))
        [W, D] = topn_weighting(X, Y, D, o);
    else
        [W, D] = noop_weighting(X, Y, D, o);
    end

    
    %% Az optimális konfiguráció számítása
    
    % Változómemória előfoglalása
    XNew = zeros(N, 1);
    YNew = zeros(N, 1);
    
    XTraces = zeros(MAX_ITER, N);
    YTraces = zeros(MAX_ITER, N);
    OLDST = zeros(MAX_ITER, 2);

    while true
        % Azimutok nullázása
        ANGLE_TERM = zeros(N, 2);
        % Távolságok frissítése az aktuális értékekre
        DIST = squareform(pdist(horzcat(X, Y)));
        
%         % Minden pontra...
%         for k = 1:N
%             % Változók frissítése
%             XSum = 0;
%             YSum = 0;
%             WSum = sum(W(k, :));
%             
%             % Minden más pontra...
%             for l = 1:N
%                 % ami nem az, amivel épp dolgozunk...
%                 if (k == l)
%                     continue;
%                 end
%                 
%                 % ...kiszámoljuk azt az "erőt", amit az `l` pont gyakorol a
%                 % `k`-ra.
%                 if (DIST(k, l) ~= 0)
%                     distinv = 1 / DIST(k, l);
%                 else
%                     distinv = 0;
%                 end
%                 
%                 XSum = XSum + W(k, l) * (X(l) + D(k, l) * distinv * (X(k) - X(l)));
%                 YSum = YSum + W(k, l) * (Y(l) + D(k, l) * distinv * (Y(k) - Y(l)));
%             end
%             
%             XNew(k) = XSum / WSum;
%             YNew(k) = YSum / WSum;
%         end
            
        % Frissítjük a pontok pozícióját.
%        X = XNew;
%        Y = YNew;
        
%        if (o.AngleStress)
            for k = 1:N

                for l = 1:N
                    if (k == l || W(k, l) == 0)
                        continue;
                    end

                    ANGLE_TERM(k,:) = ...
                        ANGLE_TERM(k,:) + (W(k, l) *  ...
                        (([X(k) Y(k)] - [X(l) Y(l)]) - (D(k, l) * [sin(ORIGBEARING(l, k)) cos(ORIGBEARING(l, k))])));
                end

                %if mod(ITER_COUNT, 100) == 0
                %end            
            end

            X(:) = X(:) - ANGLE_TERM(:, 1);
            Y(:) = Y(:) - ANGLE_TERM(:, 2);
            
            AST = 0;

            for k = 1:N
                AST = AST + sum((ANGLE_TERM(k,1) ./ ANGLE_WEIGHT).^2);
                AST = AST + sum((ANGLE_TERM(k,2) ./ ANGLE_WEIGHT).^2);
            end
%        end
        %%
        % 
        %   for x = 1:10
        %       disp(x)
        %   end
        % 
        
        if o.PlotCPTraces
            XTraces(ITER_COUNT + 1, :) = X(:);
            YTraces(ITER_COUNT + 1, :) = Y(:);
        end
        
        %if mod(ITER_COUNT, 100) == 0
        %    disp('---');
        %end
        
        DST = 0;
        
        for k = 1:N
            DST = DST + sum(W(k, 1:k - 1) .* ((DIST(k, 1:k - 1) - D(k, 1:k - 1)) .^ 2));
        end        
        
        if (o.AngleStress)
            ST = DST + AST;
        else
            ST = DST;
        end
        
        ITER_COUNT = ITER_COUNT + 1;
        
        if (o.AngleStress)
            OLDST(ITER_COUNT, :) = [DST AST];
        else
            OLDST(ITER_COUNT, :) = DST;
        end
        
        if (ITER_COUNT > 1 && (((PREV_STRESS - ST) / PREV_STRESS) < DECREASE_TOLERANCE))
            fprintf('\nOptimization terminated after %d iterations because the\n', ITER_COUNT);
            fprintf('relative stress decrease was less than DECREASE_TOLERANCE.\n');
            fprintf('(DECREASE_TOLERANCE = %g; D_STRESS = %f; STRESS = %f)\n\n', ...
                DECREASE_TOLERANCE, PREV_STRESS - ST, ST);
            break;
        end
        
        PREV_STRESS = ST;
           
        if (ITER_COUNT > MAX_ITER)
            fprintf(['Optimization terminated because the ' ...
                'maximum number of iterations (%d) is reached.\n'], MAX_ITER);
            fprintf('(STRESS = %f, Stress decrease = %f)\n', ST, ((PREV_STRESS - ST) /PREV_STRESS));
            break;
        end
    end

    outStruct.WeightingEdges = (W ~= 0);
    outStruct.Stress = ST;
    
    if (o.AngleStress)
        outStruct.AngleStress = AST;
    end
    
    outStruct.DistanceStress = DST;
    outStruct.StressHistory = OLDST(1:ITER_COUNT,:);
    
    outStruct.IterCount = ITER_COUNT;
    
    CPTLon = zeros(ITER_COUNT, size(XTraces, 2));
    CPTLat = zeros(ITER_COUNT, size(XTraces, 2));
    
    if o.PlotCPTraces
        for i = 1:ITER_COUNT
            [CPTLon(i,:), CPTLat(i, :)] = tmerc(YTraces(i, :)', XTraces(i, :)', SF);
        end
        outStruct.CPTraces = geostruct_from_latlon(CPTLat(:), CPTLon(:), 'MultiPoint');
    end
    
    toc
    
    %% „Out-of-sample” geometriák torzulásának számítása IDW-vel
    
    tic;
    [SX, SY, SSF] = tmerc(S.Lat, S.Lon);
    
    SNX = zeros(size(SX));
    SNY = zeros(size(SX));
    
    size(SX)
    
%     for i = 1 : size(SX)
%         IW = zeros(N, 1);
%         IDX = zeros(N, 1);
%         IDY = zeros(N, 1);
%         for j = 1 : N
%             IW(j) = 1 / (sqrt(((SX(i) - ORIGX(j)) ^ 2) + ((SY(i) - ORIGY(j)) ^ 2)) ^ IDW_POWER);
%             IDX(j) = X(j) - ORIGX(j);
%             IDY(j) = Y(j) - ORIGY(j);
%         end
% 
%         SNX(i) = SX(i) + (sum(IW .* IDX) ./ sum(IW));
%         SNY(i) = SY(i) + (sum(IW .* IDY) ./ sum(IW));
%     end
    
    TOPN = 5;
    
    for i = 1 : size(SX)
        PD = zeros(N, 1);
        IDX = zeros(TOPN, 1);
        IDY = zeros(TOPN, 1);
        IW = zeros(TOPN, 1);
        
        for j = 1 : N
            PD(j) = sqrt((SX(i) - ORIGX(j))^2 + (SY(i) - ORIGY(j))^2);
        end
        
        [~, idx] = sort(PD);
        top = idx(1:TOPN);
        
        for j = 1 : TOPN
            IW(j) = 1 / (sqrt(((SX(i) - ORIGX(top(j))) ^ 2) + ((SY(i) - ORIGY(top(j))) ^ 2)) ^ IDW_POWER);
            IDX(j) = X(top(j)) - ORIGX(top(j));
            IDY(j) = Y(top(j)) - ORIGY(top(j));
        end
        
        IW = IW ./sum(IW);

        SNX(i) = SX(i) + (sum(IW .* IDX) );
        SNY(i) = SY(i) + (sum(IW .* IDY) );        
    end
    
    [S.Lon, S.Lat] = tmerc(SNY, SNX, SSF);
    
    outStruct.TransformedFeatures = S;
    toc
    
    %% Távolsághiba számítása
    
    DIFF = abs(D - squareform(pdist(horzcat(X, Y))));
    DIFF(W == 0) = -Inf;
    
    outStruct.DistError = DIFF;
    outStruct.Distances = squareform(pdist(horzcat(X, Y)));
    
    %% Megoldásvektor inverz vetületi transzformációja

    [XDeg, YDeg] = tmerc(Y, X, SF);    
    x = geostruct_from_latlon(YDeg, XDeg, 'MultiPoint');
    
    % Futásiidő-mérés vége

    outStruct.RunTime = 0;

end  