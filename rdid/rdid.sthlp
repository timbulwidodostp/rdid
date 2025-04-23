{smcl}
{it:version 1.8.5}


{title:rdid}

{p 4 4 2}
a program that implements the robust difference-in-differences (RDID) method developed in Ban and Kédagni (2023) in Stata



{title:Syntax}

{p 8 8 2} {bf:rdid} {it:depvar} [{it:indepvars}] [{it:if}] [{it:in}], {bf:treatname({it:varname})} {bf:postname({it:varname})} {bf:infoname({it:varname})} [{it:options}]

{p 8 8 2} {bf:rdid_dy} {it:depvar} [{it:indepvars}] [{it:if}] [{it:in}], {bf:treatname({it:varname})} {bf:postname({it:varname})} {bf:infoname({it:varname})} {bf:tname({it:varname})} [{it:options}]

{p 4 4 2}{bf:Options}

{col 5}{it:options}{col 36}Description
{space 4}{hline}
{col 5}Main{col 36}{break}
{col 5}	 {bf:treatname({it:varname})}{col 36}specifies the treatment indicator
{col 5}	 {bf:postname({it:varname})}{col 36}specifies the post-treatment period indicator
{col 5}	 {bf:infoname({it:varname})}{col 36}specifies the information index
{col 5}	
{col 5}Options{col 36}{break}
{col 5}	 {bf:rdidtype({it:#})}{col 36}specifies the type of RDID estimator:
{col 5}		{col 36}‎   {bf:0} for the simple RDID (default),
{col 5}		{col 36}‎   {bf:1} for the policy-oriented (PO) RDID,
{col 5}		{col 36}‎   {bf:2} for the RDID with linear predictions.
{col 5}	 {bf:peval({it:#})}{col 36}specifies the evaluation point for {bf:rdidtype(2)};
{col 5}		{col 36}‎   the default is the mean value of {bf:infoname({it:varname})}
{col 5}		{col 36}‎   in the post-treatment period
{col 5}	 {bf:level({it:#})}{col 36}specifies the confidence level, as a percentage,
{col 5}		{col 36}‎   for confidence intervals; the default is {bf:level(95)}
{col 5}	 {bf:figure({it:string})}{col 36}saves a scatter plot of estimated selection biases
{col 5}		{col 36}‎   and the information index in the pre-treatment
{col 5}		{col 36}‎   periods as {bf:figure({it:string}).png}
{col 5}	 {bf:brep({it:#})}{col 36}specifies the number of bootstrap replicates;
{col 5}		{col 36}‎   the default is {bf:brep(500)}
{col 5}	 {bf:clustername({it:varname})}{col 36}specifies the variable name that identifies resampling
{col 5}		{col 36}‎   clusters in bootstrapping
{col 5}	
{col 5}Options: {bf:rdid_dy}{col 36}{break}
{col 5}	 {bf:tname({it:varname})}{col 36}specifies the variable name for the time (required).
{col 5}	 {bf:figure({it:string})}{col 36}saves line plots of RDID estimates and confidence
{col 5}		{col 36}‎   intervals over the post-treatment periods as
{col 5}		{col 36}‎   {bf:figure({it:string}).png}
{col 5}	 {bf:citype({it:#})}{col 36}specifies the type of confidence intervals to collect
{col 5}		{col 36}‎   for {bf:rdidtype(0)} (see the reference for more
{col 5}		{col 36}‎   information); the default is {bf:citype(1)}
{col 5}	 {bf:losstype({it:#})}{col 36}specifies the type of loss function for {bf:rdidtype(0)}
{col 5}		{col 36}‎   (see the reference for more information);
{col 5}		{col 36}‎   the default is {bf:losstype(1)}
{space 4}{hline}



{title:Description}

{p 4 4 2}
{bf:rdid} is a program that estimates the RDID bounds and their confidence 
intervals for the average treatment effects (ATE). 
Please visit our  {browse "https://github.com/KyunghoonBan/rdid":GitHub repository} for more details.



{title:Example}

{p 4 4 2}
Estimate the RDID bounds:

     . use "sim_rdid.dta"
     . rdid Y, treat(D) post(pos) info(t) fig(sim_rdid)

{p 4 4 2}
Estiamate and collect the RDID bounds for each post-treatment year:
	 
     . rdid_dy Y, treat(D) post(pos) info(t) t(t) fig(sim_rdid_dy)
	 
	 
{space 1}
{space 1}



{title:Authors}

{p 4 4 2}
Kyunghoon Ban    {break}
{it:kban@saunders.rit.edu}    {break}
{browse "https://sites.google.com/view/khban/":https://sites.google.com/view/khban/}    {break}

{p 4 4 2}
Désiré Kédagni        {break}
{it:dkedagni@unc.edu}     {break}
{browse "https://sites.google.com/site/desirekedagni/":https://sites.google.com/site/desirekedagni/}



{title:References}

{p 4 4 2}
Ban, K. and D. Kédagni (2023). Robust Difference-in-Differences Models.  {browse "https://arxiv.org/abs/2211.06710/":https://arxiv.org/abs/2211.06710}.       {break}
Ban, K. and D. Kédagni (2024). rdid and rdidstag: Stata commands for robust difference-in-differences.   {browse "https://arxiv.org/XXXX":https://arxiv.org/XXXX}      {break}



{title:License}

{p 4 4 2}
MIT License



