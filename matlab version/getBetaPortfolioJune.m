%This function is called by mainToRunFamaMacBeth
%%This code is based on annual compustat, need to readjust with quarter data
function [d,allPtf] = getBetaPortfoliosJune(d,Mkt)

%% this function computes the decile portfolios for betas using the NYSE cut-offs
%%
[d,Dates] = assignBetaDecilePortfolios(d);

%to double check
% [d,Dates] = assignBetaDecilePortfoliosMonthToMonth(d);

allPtf = [];
%%compute portfolio excess returns for each of the 100 portfolios' 
parfor j = 1:length(Dates)
    loc = d.yyyymm == Dates(j);
    temp = d(loc,:);
    for k = 1:10
        for m = 1:10
            loc = find(temp.DECILE == k & temp.BetaPortfolio == m);
            y = [temp.NameExcess(loc),temp.meLag(loc)];  %meLag not used
            [ir,~] = find(isnan(y) == 1);
            y(ir,:) = [];
            tres = [Dates(j),k,m,mean(y(:,1),1)];
            allPtf = [allPtf; tres];
        end
    end
end

%%
%%compute and assign portfolio betas, use data after 1970 as in the paper
loc = allPtf(:,1) > 197012;
allPtf = allPtf(loc,:);
d.PostBeta = d.yyyymm*NaN;
allPtf(:,end+1) = NaN;

Mkt = sortrows(Mkt,1); % Mkt(:,1): date
Mkt(:,3) = [NaN;Mkt(1:end-1,2)];

for k = 1:10
    for m = 1:10
        loc = allPtf(:,2) == k & allPtf(:,3) == m;
        y = allPtf(loc,[1 4]);
        y = sortrows(y,1);
        [~,ia,ib] = intersect(y(:,1),Mkt(:,1));
        y = [y(ia,2),Mkt(ib,2:3)];
        tBetas = regress(y(:,1),[ones(size(y(:,1))), y(:,2:3)]);
        tBetas = tBetas(2) + tBetas(3);
        allPtf(loc,end) = tBetas;
        loc = d.DECILE == k & d.BetaPortfolio == m;
        d.PostBeta(loc) = tBetas;
    end
end

function [d,Dates] = assignBetaDecilePortfolios(d)
d.BetaPortfolio = d.yyyymm*NaN;
d1 = [];
Dates = unique(d.yyyymm);

for m = 1:10 
    % for each monthly size decile, take July betas out, calculate the deciles

    disp(m)
    parfor j = 1:length(Dates)
        %     for j = 1:length(Dates)
        Year = floor(Dates(j)/1e2);
        Month = Dates(j) - Year*1e2;
        %         disp(j)
        %remember the previous function (see ComputePreBetas) assigns the june Firm Betas for the next one
        %year, i.e., for example the firm beta in 199807 contains the beta
        %computed using data upto 199806 and put in from 199807 to 199906,
        %that is why the lines below are computing the portfolio assignment
        %based on july since it is the first date where the june beta is
        %appearing
        if Month > 6
            loc = d.yyyymm == Year*1e2+07 & d.DECILE == m; %size decile from Kenneth French's website
        else
            loc = d.yyyymm == (Year-1)*1e2+07 & d.DECILE == m;
        end
        
        temp = d(loc,:);
        
        y = [temp.FirmBetas, temp.EXCHCD];
        loc = y(:,2) == 1;
        
        %getting prc based on NYSE
        prc = prctile(y(loc,1),10:10:100); % decile of betas
        
        loc = d.yyyymm == Dates(j) & d.DECILE == m;
        temp1 = d(loc,:);
        
        %assigning the portfolio number to each firm
        for k = 1:length(prc)
            
            if k == 1
                loc = find(temp.FirmBetas < prc(k));
            else
                if k == 10
                    loc = find(temp.FirmBetas > prc(k-1));
                else
                    loc = find(temp.FirmBetas >= prc(k-1) & temp.FirmBetas < prc(k));
                end
            end
            
            Perms = temp.PERMNO(loc);
            
            [~,ia,~] = intersect(temp1.PERMNO, Perms);
            temp1.BetaPortfolio(ia) = k;
            
        end
        
        d1 = [d1;temp1]; % append temp1 to d1
        
    end

    disp(size(d1))
end

d = d1; clear d1;

%------
function [d,Dates] = assignBetaDecilePortfoliosMonthToMonth(d)
d.BetaPortfolio = d.yyyymm*NaN;
d1 = [];
Dates = unique(d.yyyymm);
for m = 1:10
    parfor j = 1:length(Dates)
        %     for j = 1:length(Dates)
        disp(j)
        loc = d.yyyymm == Dates(j) & d.DECILE == m;
        temp = d(loc,:);
        
        y = [temp.FirmBetas, temp.EXCHCD];
        loc = y(:,2) == 1;
        
        %getting prc based on NYSE
        prc = prctile(y(loc,1),10:10:100);
        
        for k = 1:length(prc)
            
            if k == 1
                loc = find(temp.FirmBetas < prc(k));
            else
                if k == 10
                    loc = find(temp.FirmBetas > prc(k-1));
                else
                    loc = find(temp.FirmBetas >= prc(k-1) & temp.FirmBetas < prc(k));
                end
            end
            
            temp.BetaPortfolio(loc) = k;
            
        end
        
        d1 = [d1;temp];
    end
end
d = d1; clear d1;
    