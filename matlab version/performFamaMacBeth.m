%This function is called by mainToRunFamaMacBeth
function Final = performFamaMacBeth(d,ReturnSeries,BetaSeries)

Dates = unique(d.yyyymm);

%june size for fama-macbeth
d.lnme = log(d.mejun);

%compute BTM
d.BE(d.BE<=0) = NaN;
d.lnbeme=log(d.BE./d.medec);
d.lnbeme(isinf(abs(d.lnbeme)) == 1) = NaN;

d.lnbame = log(d.at./d.medec);
d.lnbame(isinf(abs(d.lnbame)) == 1) = NaN;

d.lnbabe = log(d.at./d.BE);
d.lnbabe(isinf(abs(d.lnbabe)) == 1) = NaN;

%Constant, Beta, Size, BTM, BA/E, BA/BE
% Specifications for which we want to run the Fama-MacBeth
Specs = [1,1,0,0,0 0; 1,1,1,1,0,0];
% Specs = [1,1,0,0,0 0; 1,0,1,0,0 0; 1 1 1 0 0 0; 1,0,0,1,0 0; 1,0,0,0,1,1; 1,1,1,1,0,0];

yAll = eval(strcat('d.',ReturnSeries));
xAllFact = [ones(size(yAll)), eval(strcat('d.',BetaSeries)), d.lnme, d.lnbeme, d.lnbame, d.lnbabe];
CoeffAll = ones(size(Specs))*NaN;
tStatAll = CoeffAll;
tStatAll_1 = tStatAll;

%looping over specifications
for k = 1:size(Specs,1)

    disp(k)
    clear xAll;
    locSpec = find(Specs(k,:) == 1);
    xAll = xAllFact(:,locSpec);
    
    %looping over dates to perform the cross-sectional regressions
    for j = 1:length(Dates)
        
        loc = find(d.yyyymm == Dates(j));
        y = yAll(loc)*1e2;
        x = xAll(loc,:);   
        
        [ir,~] = find(isnan(x));
        tx = x;
        tx(ir,:) = [];
        R = rank(tx);
        
        tx = [y,x];
        [ir,~] = find(isnan(tx) == 1);
        tx(ir,:) = [];
        if R == size(x,2) && size(tx,1) > 7 % check colliearity
            disp(size(y))
            disp(size(x))
            
            [b,~,~,~,tR2] = regress(y,x);
            R2(j,:) = tR2(1);            
            Coeff(j,:) = [Dates(j), b'];            
        else % set as nan
            if j == 1
                Coeff(j,:) = [Dates(j), ones(size(locSpec))*NaN];
            else
                Coeff(j,:) = Coeff(j-1,:)*NaN;
            end
        end
    end
    
    Dates = Coeff(:,1);
    Coeff = Coeff(:,2:end);
    CoeffAll(k,locSpec) = nanmean(Coeff);
    
    %t-stat without autocorrelation adjustment
    %tStatAll(k,locSpec) = (nanmean(Coeff)./nanstd(Coeff)).*sqrt(sum(isnan(Coeff)~=1));   
    
    %compute the newey west t-statistics
    for j = 1:size(Coeff,2) % loop over each coefficient
        y1 = [ones(size(Coeff(:,j))), Coeff(:,j)];     
        [ir,~] = find(isnan(y1) == 1);
        y1(ir,:) = [];
        nwse = NeweyWest(y1(:,2) - nanmean(y1(:,2)),[],5);
        temptStat(1,j) = nanmean(y1(:,2))./nwse;
    end
    
    tStatAll_1(k,locSpec) = temptStat; clear temptStat;
    R2All(k,:) = nanmean(R2(R2~=0));
    clear Coeff
end

Coeff = CoeffAll; Signif = tStatAll_1; 
% clear CoeffAll tStatAll;
Final = [];
for j = 1:size(Coeff,1)
    
    temp = [Coeff(j,:); Signif(j,:); Signif(j,:)*NaN];
    Final = [Final; temp];
    
end
