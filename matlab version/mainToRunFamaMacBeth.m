
%{
This code performs the Fama-MacBeth regression for any of the return
measures, it will compute the pre-betas, post betas, and run the
fama-macbeth regression. Fama-MacBeth regression with 5 lags for the autocorrelation adjustment. 
%}

function mainToRunFamaMacBeth(ReturnSeries,LagAssetId,d,File,Mkt)

    %{
    ReturnSeries: The return measure (variable) for which we want to perform Fama-MacBeth regression
    LagAssetId: Set this equal to 1 if want to use Lagged Asset Value to create the market portfolio instead of using Lagged market equity
    d: This is the table that contains all the required data, see pseudo data file
    File: This will specify the output file name
    Mkt: If market portfolio is already computed, use it as input. In that
    case, the code will skip the computation of the market portfolio based on
    the data. Use the market portfolio from Kenneth French's wesbite for stock
    returns. Make sure it is excess return, otherwise set Mkt = [].
    
    %The output of this code is saved in the folder output
    Final: this contains the coefficients and the corresponding t-statistics from the fama-macbeth regression
    
    allPtf: this contains the returns of the 100 beta/size portfolios, and the
    corresponding betas
    For allPtf, the first column is date, the second column indicates the size portfolio decile (1 to 10), 
    the third column indicates beta portfolio decile(1 to 10), 
    the fourth column is the portfolio return
    the fifth column is the portfolio beta
    
    Mkt: this contains the market portfolio returns
    %}
    
    Path = cd;
    
    Check = exist(strcat(Path,'\output'),'dir');
    if Check == 0
        mkdir(strcat(Path,'\output'));
    end
    clear Check;
    
    BetaSeries = 'PostBeta';
    
    %Compute the Pre-Betas
    [d,Mkt] =  ComputePreBetas(ReturnSeries,LagAssetId,d,Mkt);
    
    %compute returns of the 100 portfolios, assign the betas of these 100 portfolios to each firm
    [d,allPtf] = getBetaPortfoliosJune(d,Mkt);
    cd(strcat(Path,'\output'));
    save(strcat('June_',ReturnSeries,'_priorto',File,'.mat'),'d','ReturnSeries','BetaSeries');
    
    %perform FamaMacBeth
    cd(Path)
    Final = performFamaMacBeth(d,ReturnSeries,BetaSeries);
    cd(strcat(Path,'\output'));
    save(File,'Final','allPtf','Mkt');
    
    