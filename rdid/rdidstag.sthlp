{smcl}
{it:version 1.8.5}


{title:rdidstag}

{p 4 4 2}
a program that implements the robust difference-in-differences (RDID) method in staggered adoption design developed in Ban and Kédagni (2023) in Stat


{title:Syntax}

{p 8 8 2} {bf:rdidstag} {it:depvar} [{it:indepvars}] [{it:if}] [{it:in}], {bf:gname({it:varname})} {bf:tname({it:varname})} [{it:options}]


{p 4 4 2}{bf:Options}

{col 5}{it:options}{col 36}Description
{space 4}{hline}
{col 5}Main{col 36}{break}
{col 5}	 {bf:gname({it:varname})}{col 36}specifies the variable name of the cohort index where {bf:0} is
{col 5}		{col 36}‎   assigned for the never-treated gro
{col 5}	 {bf:tname({it:varname})}{col 36}specifies the variable name of time index    {break}
{col 5}	
{col 5}Options{col 36}{break}
{col 5}	 {bf:postname({it:varname})}{col 36}specifies the variable name of the post-treatment period
{col 5}		{col 36}‎   indicator; the default is using units in periods durin
{col 5}		{col 36}‎   and after the first treatment as post-period uni
{col 5}	 {bf:infoname({it:varname})}{col 36}specifies the variable name of the information index;
{col 5}		{col 36}‎   the default is using pre-treatment perio
{col 5}	 {bf:level({it:#})}{col 36}specifies the confidence level, as a percentage,
{col 5}		{col 36}‎   for confidence intervals; the default is {bf:level(95)}
{col 5}	 {bf:figure({it:string})}{col 36}saves line plots of RDID bounds and confidence intervals
{col 5}		{col 36}‎   over the post-treatment periods for each group as
{col 5}		{col 36}‎   {bf:figure({it:string}).png}
{col 5}	 {bf:clustername({it:varname})}{col 36}specifies the variable name that identifies resampling
{col 5}		{col 36}‎   clusters in bootstrapping
{space 4}{hline}




{title:Description}

{p 4 4 2}
{bf:rdidstag} command estimates bounds on the ATT and their confidence intervals over time for different cohorts in the staggered adoption design. Please visit our  {browse "https://github.com/KyunghoonBan/rdid":GitHub repository} for more details.



{title:Example}

{p 4 4 2}
Estimate the RDID bounds on the ATT over time for different cohorts:

     . use "sim_rdidstag.dta"
     . rdidstag Y, g(G) t(year) post(posttreat) info(year) figure(sim_rdidstag)
	 
{space 1}
{space 1}
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
Ban, K. and D. Kédagni (2023). Robust Difference-in-Differences Models.  {browse "https://arxiv.org/abs/2211.06710/":https://arxiv.org/abs/2211.06710}       {break}
Ban, K. and D. Kédagni (2024). rdid and rdidstag: Stata commands for robust difference-in-differences.   {browse "https://arxiv.org/XXXX":https://arxiv.org/XXXX} 



{title:License}

{p 4 4 2}
MIT License



