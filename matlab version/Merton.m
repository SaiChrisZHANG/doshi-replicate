clear
clc
% close all

%this code runs the estimation of the Merton model, two equations - two
%unknowns to estimate the asset value and asset volatility

TFix = 3.38; %maturity of debt
cd('folder')
load data.mat; %table is named 'd'
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
