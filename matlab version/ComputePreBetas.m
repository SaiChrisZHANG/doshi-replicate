%This function is called by mainToRunFamaMacBeth
function [dt,Mkt] = ComputePreBetas(RetSeries,LagAssetId,dt,Mkt)

%% read the returns data i.e., compute excess returns
dt = getFirmSpecificData(RetSeries,dt);

%compute excess market returns
if isempty(Mkt)
    Mkt = getMarketData(dt,LagAssetId);
end

Mkt(:,3) = NaN;
%create lagged excess market return
Mkt(2:end,3) = Mkt(1:end-1,2);
disp(nanmean(Mkt(:,2:3)))

%compute firm-specific betas and assign to next year
dt = getFirmBetas(dt,Mkt);

function dt = getFirmSpecificData(RetSeries,dt)
dt.Name = eval(strcat('dt.',RetSeries));
dt.NameExcess = dt.Name - dt.rfFFWebsite;

function Mkt = getMarketData(dt,LagAssetId) 
% only called when market excess returns are not available (e.g. asset-value weighted one)
% equity value weighted portfolio returns can be retrieved from Kennith French's website

Dates = unique(dt.yyyymm);
Dates(isnan(Dates))  = [];
Dates(Dates<197107) = []; % keep unique dates before 1971 Jul.

for j = 1:length(Dates)
    
    loc = find(dt.yyyymm == Dates(j));
    
    if LagAssetId == 1
        y = [dt.NameExcess(loc),dt.AssetValueLag(loc)]; %return and equity value
    else
        y = [dt.NameExcess(loc),dt.meLag(loc)]; %return and asset value
    end
    
    [ir,ic] = find(isnan(y) == 1);
    y(ir,:) = []; %drop nan

    if size(y,1) > 10
        Mkt(j,:) = [Dates(j), sum(y(:,1).*y(:,2)/sum(y(:,2)))]; %if more than 10 months, calculate weighted return
    else
        Mkt(j,:) = [Dates(j), NaN];
    end

end
    
function dt = getFirmBetas(dt,Mkt)

%%run the capm model with lagged market to eestimate the betas using past five year of data
Dates = unique(dt.yyyymm);
Dates(isnan(Dates))  = [];
Dates(Dates<197101) = [];

Perm = unique(dt.PERMNO);
Perm(isnan(Perm)) = [];
dt1 = [];
disp(size(Perm))

%running the estimation firm-by-firm
parfor k = 1:length(Perm) %loop over firms
    
    if mod(k,100) == 0
        disp(k);
    end
    loc = dt.PERMNO == Perm(k);
    temp = dt(loc,:);
    
    %for each firm compute the betas
    temp = computeFirmBetas(temp,Mkt); 
    % returns the june beta both as next year's beta and a seperate column
    dt1 = [dt1;temp];
    
end

dt = dt1; clear dt1;

function temp = computeFirmBetas(temp,Mkt)
temp.FirmBetas = NaN*temp.yyyymm;
temp.JuneFirmBetas = temp.FirmBetas;

for j = 1971:2012 %loop over years
    
    %identify June, as well as identify past five year 
    St = (j-5)*1e2 + 6; % start: 5 years before current year
    En = j*1e2 + 6; % end: current year
    loc = find(temp.yyyymm > St & temp.yyyymm <= En);
    y = [temp.yyyymm(loc), temp.NameExcess(loc)];
    [ir,~] = find(isnan(y) == 1);
    y(ir,:) = [];
    
    %perform the capm regression if at least 24 monthly data points available
    if size(y,1) >= 24
        [~,ia,ib] = intersect(y(:,1),Mkt(:,1)); % return the index
        tx = [ones(size(Mkt(ib,1))), Mkt(ib,2:3)]; %Mkt(ib, 2:3) is the market return and lag market return
        [ir,~] = find(isnan(tx) == 1); % drop nans
        tx(ir,:) = [];
        R = rank(tx);
        if R == size(tx,2) % make sure there's no colinearity
            y = [y(ia,2),Mkt(ib,2:3)]; %y(ia,2) is the excess return of the stock
            tBetas = regress(y(:,1),[ones(size(y(:,1))),y(:,2:3)]);
            tBetas = tBetas(2) + tBetas(3);
        else
            disp(R)
            disp(Mkt(ib,2:3))
            tBetas = NaN;
        end
    else        
        tBetas = NaN;
    end
    
    %identify next 1 year, assign the june beta to next one year
    Enp1 = (j+1)*1e2 + 6;
    loc = temp.yyyymm > En & temp.yyyymm <= Enp1;
    temp.FirmBetas(loc) = tBetas;
    
    %also hold june beta in a separate column
    loc = temp.yyyymm == En;
    temp.JuneFirmBetas(loc) = tBetas;
    
end