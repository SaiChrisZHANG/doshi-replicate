# doshi-replicate

This repo replicates Doshi et al (2019) and extends the analysis with Stata and Python. The project is prepared for Prof.Stephen Schaefer's project (London Business School, Finance Faculty).

## Description

First part of this project is to replicate the research of [Doshi et al (2019)](https://onlinelibrary.wiley.com/doi/full/10.1111/jofi.12758). Building on theoretical asset pricing literature, this paper examine the role of market risk and the size (equity and asset size), book‐to‐market (BTM), and volatility anomalies in the cross‐section of unlevered equity returns. They've found that unlevered market beta plays a more important role than levered beta in explaining the cross‐section of unlevered equity returns. The size effect is weakened, while the value premium and the volatility puzzle virtually disappear for unlevered returns.

This project was originally done in matlab, I revise the [matlab codes](https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fjofi.12758&file=jofi12758-sup-0002-SuppMat.zip) published by the authors and compose a python version. I plan to do a Julia version as well.

## Data used

This project uses data of CRSP and Compustat, retrieved from [WRDS](https://wrds-www.wharton.upenn.edu/).
