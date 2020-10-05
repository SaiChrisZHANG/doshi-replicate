clear;
clc;
close all;

%{
- this function generates the graph of beta vs the mean returns of the 100 beta/size portfolios
- note that the portfolio returns from the function are saved in terms of
the excess returns, therefore this code adds the risk-free rate and generates the graphs
%}

Path = cd;
cd(strcat(Path,'\output'));
disp('make sure to load the file here else it will generate error');
%load the output file from mainToRunFamaMacBeth, name as defined in this function

cd(strcat(Path,'\pseudodata'))
ffRf = readtable('ffRf.csv'); %allPtf is excess

Betas = unique(allPtf(:,5)); 
Dates = unique(allPtf(:,1));
Dates = Dates(Dates > 197106 & Dates <= 201206);
Ptfs = Dates;
for j = 1:length(Betas)

    Ptfs(:,j+1) = NaN;
    loc = find(allPtf(:,5) == Betas(j));
    temp = allPtf(loc,[1,4]);
    [~,ia,ib] = intersect(Ptfs(:,1),temp(:,1));
    Ptfs(ia,j+1) = temp(ib,2);

end

%portfolio returns are excess
[c,ia,ib] = intersect(Ptfs(:,1),ffRf.yyyymm);
Ptfs(ia,2:end) = Ptfs(ia,2:end) + repmat(ffRf.rfFFWebsite(ib),1,100);

Mean = nanmean(Ptfs(:,2:end));
% suggested by Matlab: replace nanmean with mean(,'omitnan')
Mean = Mean';
scatter(Betas,Mean*1e2);
xlim([0.2 2.2])
ylim([0.4 2.2]);
x = Betas;
X = [ones(size(x)),x];
y = Mean*1e2;

b = X\y;
yCalc2 = X*b;
reg = regstats(y,X(:,2),'linear');
hold on
plot(x,yCalc2,'--','LineWidth',2)
xlabel('Betas')
ylabel('Monthly Percentage Returns');
