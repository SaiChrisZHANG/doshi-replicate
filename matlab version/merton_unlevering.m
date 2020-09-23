clear
clc
% close all

%this code runs the estimation of the Merton model, two equations - two
%unknowns to estimate the asset value and asset volatility

TFix = 3.38;
cd('pseudodata')
load sample.mat;
d.T = ones(size(d.PERMNO))*TFix;
cd ..;

%drop these since these would be added in the estimation for comparison
%only
% d1 = d;
d(:,{'AssetValue','AssetVolatility'}) = [];

%creating new file for now for comparison, usually overwrite d
Estimates = EstimateMerton(d,'Debt');

%in an unlikely scenario if dedv is zero
loc = Estimates.dedv == 0;
Estimates.dedv(loc) = NaN;
Estimates.RatioIto = (1./Estimates.dedv).*(Estimates.Equity./Estimates.AssetValue);
Estimates.RatioItoLag = [NaN; Estimates.RatioIto(1:end-1)]; %this is for informative purpose, 200001 is filled in actual data


%For Table 4 Panel C
Estimates.ItoUsingBaseMertonT338 = Estimates.RetExcess.*Estimates.RatioItoLag + Estimates.rfFFWebsite;

%For Table 4 Panel D
%This is 1 - L; 1 - Market Debt/(Market Debt + Market Equity)
Estimates.RatioTBm = Estimates.Equity./Estimates.AssetValue;
Estimates.RatioTBmLag = [NaN; Estimates.RatioTBm(1:end-1)]; %this is for informative purpose, 200001 is filled in actual data
Estimates.TBUsingBaseMertonT338 = Estimates.RetExcess.*Estimates.RatioTBmLag + Estimates.rfFFWebsite;

%For Table 3
Estimates.RetTimesLevLag = Estimates.RetExcess.*(1-Estimates.LevLag) + Estimates.rfFFWebsite;


function t = EstimateMerton(t,DebtCol)

    %this is the function called by mainMerton.m to estimate the parameters of the model
    % (d,'Debt')
    %definition of debt, in pseudo code it ltq, can be changed to total debt using dlcq + dlttq
    t.Debt = eval(strcat('t.',DebtCol));
    
    %initial value for asset volatility
    t.vV = t.EquityVolatility.*t.Equity./(t.Equity + t.Debt);
    
    %options for optimization
    options = optimset('LargeScale','off','MaxFunEvals',1e+03,'MaxIter',1e+03,'TolX',1e-6);
    
    %assign fields for output
    t.AssetValue = t.vV*NaN;
    t.AssetVolatility = t.AssetValue;
    t.dedv = t.AssetValue;
    
    for i=1:length(t.Debt)
        tic
        disp(i)    
        if isnan(t.Equity(i)) || isnan(t.Debt(i)) || isnan(t.rf338(i))...
                || isnan(t.EquityVolatility(i)) || isnan(t.vV(i)) || t.EquityVolatility(i)<=0 || isnan(t.T(i))
        else
            T = t.T(i);
            sigmaV=fminsearch(@(x) EquityVolatilityEq(x,t.Equity(i),t.Debt(i),t.rf338(i),t.EquityVolatility(i),T),t.vV(i),options);
            sigmaV = abs(sigmaV);        
            [~, NewAv, dedv]=EquityVolatilityEq(sigmaV,t.Equity(i),t.Debt(i),t.rf338(i),t.EquityVolatility(i),T);
            NewAv = abs(NewAv);
            t.AssetValue(i) = NewAv;
            t.AssetVolatility(i) = abs(sigmaV);
            t.dedv(i) = dedv;
        end
        toc
    end
    t.vV = [];
    
    function [Error, NewAv, d1]=EquityVolatilityEq(sigmaV,e,f,rf,vE,T)
    
    options = optimset('LargeScale','off','MaxFunEvals',1e+03,'MaxIter',1e+03,'TolX',1e-6);
    sigmaV = abs(sigmaV);
    NewAv=fminsearch(@(av) SolveOneEquation(av,e,sigmaV,f,rf,T),e+f,options);
    NewAv = abs(NewAv);
    
    %alternative to blsdelta
    % d1=(log(NewAv./f)+(rf+0.5*sigmaV.^2)*T)./(sigmaV*sqrt(T));
    % d1 = norm_cdf(d1); %faster norm_cdf
    
    if f == 0
        %blsdelta fails if f = 0;
        f = 1e-50;
    end
    
    if NewAv == 0
        %blsdelta fails if NewAv = 0; unlikely to happen
        NewAv = 1e-50;
    end
    
    d1 = blsdelta(NewAv,f,rf,T,sigmaV);
    modelSigmaE=sigmaV*d1*NewAv/e;
    Error=(vE-modelSigmaE)^2;
    
    function Error=SolveOneEquation(v,E,vV,F,rf,T)
    vV = abs(vV);
    v = abs(v);
    EModel=blsprice(v,F,rf,T,vV);
    
    % alternative to blsprice
    % EModel=BlackScholes(v,F,rf,T,vV,0,1);
    
    Error=(E-EModel)^2;