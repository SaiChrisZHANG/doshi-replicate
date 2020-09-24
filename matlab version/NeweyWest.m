function nwse = NeweyWest(e,X,L,constant)
    % This file is downloaded from the mathworks file exchange
    % PURPOSE: computes Newey-West adjusted heteroscedastic-serial
    %          consistent standard errors
    %
    %        Adapted by Guillaume Nolin from the original code by Ian Gow
    %---------------------------------------------------
    % where: e = T x 1 vector of model residuals
    %        X = T x k matrix of independant variables
    %        L = lag length to use (Default: Newey-West(1994) plug-in
    %        procedure)
    
    %        constant = 0: no constant to be added;
    %                 = 1: constant term to be added (Default = 1)
    %
    %        nwse = Newey-West standard errors
    %---------------------------------------------------
    
    %% Variables
    
    if nargin < 4 || constant ~= 0
        constant = 1;
    end
    
    if constant ~= 0
        X=[ones(size(e,1),1) X];
    end
    
    indexxx = sum(isnan(X),2)==0; % drop nan
    X = X(indexxx,:);
    e = e(indexxx,:);
    
    [N,k] = size(X);
    
    if nargin < 3 || L < 0
        % Newey-West (1994) plug-in procedure
        L = floor(4*((N/100)^(2/9)));
    end
        
    if any(all(X==1,1),2)
        constant=0;
    end
    
    if constant == 1
        k = k+1;
        X = [ones(N,1),X];
    end
    
    %% Computation
    
    Q = 0;
    for l = 0:L
        w_l = 1-l/(L+1);
        for t = l+1:N
            if (l==0)   % This calculates the S_0 portion
                Q = Q  + e(t) ^2 * X(t, :)' * X(t,:);
            else        % This calculates the off-diagonal terms
                Q = Q + w_l * e(t) * e(t-l)* ...
                    (X(t, :)' * X(t-l,:) + X(t-l, :)' * X(t,:));
            end
        end
    end
    Q = (1/(N-k)) .*Q;
    
    nwse = sqrt(diag(N.*((X'*X)\Q/(X'*X))));
    
    end
    