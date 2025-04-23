_version 1.8.5_

rdid
====

a program that implements the robust difference-in-differences (RDID) method developed in Ban and Kédagni (2023) in Stata 


Syntax
------

> __rdid__ _depvar_ [_indepvars_] [_if_] [_in_], __treatname(_varname_)__ __postname(_varname_)__ __infoname(_varname_)__ [_options_]

> __rdid_dy__ _depvar_ [_indepvars_] [_if_] [_in_], __treatname(_varname_)__ __postname(_varname_)__ __infoname(_varname_)__ __tname(_varname_)__ [_options_]

### Options

| _options_                     | Description
|:------------------------------|:-------------------------------------------------
| Main                          |   
|        __treatname(_varname_)__   | specifies the treatment indicator
|        __postname(_varname_)__    | specifies the post-treatment period indicator
|        __infoname(_varname_)__    | specifies the information index
|                                   |
| Options                       |  
|        __rdidtype(_#_)__          | specifies the type of RDID estimator: 
|                                       |‎   __0__ for the simple RDID (default),  
|                                       |‎   __1__ for the policy-oriented (PO) RDID,  
|                                       |‎   __2__ for the RDID with linear predictions.  
|        __peval(_#_)__             | specifies the evaluation point for __rdidtype(2)__;
|                                       |‎   the default is the mean value of __infoname(_varname_)__ 
|                                       |‎   in the post-treatment period  
|        __level(_#_)__             | specifies the confidence level, as a percentage,
|                                       |‎   for confidence intervals; the default is __level(95)__ 
|        __figure(_string_)__       | saves a scatter plot of estimated selection biases
|                                       |‎   and the information index in the pre-treatment  
|                                       |‎   periods as __figure(_string_).png__ 
|        __brep(_#_)__              | specifies the number of bootstrap replicates;
|                                       |‎   the default is __brep(500)__  
|        __clustername(_varname_)__ | specifies the variable name that identifies resampling
|                                       |‎   clusters in bootstrapping  
|                                   |
| Options: __rdid_dy__          |  
|        __tname(_varname_)__       | specifies the variable name for the time (required).
|        __figure(_string_)__       | saves line plots of RDID estimates and confidence
|                                       |‎   intervals over the post-treatment periods as  
|                                       |‎   __figure(_string_).png__ 
|        __citype(_#_)__            | specifies the type of confidence intervals to collect
|                                       |‎   for __rdidtype(0)__ (see the reference for more  
|                                       |‎   information); the default is __citype(1)__   
|        __losstype(_#_)__          | specifies the type of loss function for __rdidtype(0)__
|                                       |‎   (see the reference for more information);  
|                                       |‎   the default is __losstype(1)__ 



Description
-----------

__rdid__ is a program that estimates the RDID bounds and their confidence 
intervals for the average treatment effects (ATE). 
Please visit our [GitHub repository](https://github.com/KyunghoonBan/rdid) for more details.


Example
-------

Estimate the RDID bounds:

         . use "sim_rdid.dta"
         . rdid Y, treat(D) post(pos) info(t) fig(sim_rdid)

Estiamate and collect the RDID bounds for each post-treatment year:
             
         . rdid_dy Y, treat(D) post(pos) info(t) t(t) fig(sim_rdid_dy)
             
             
![Selection Biases](sim_rdid.png)
![rdid_dy Estimation Results](sim_rdid_dy.png)


Authors
-------

Kyunghoon Ban  
_kban@saunders.rit.edu_  
[https://sites.google.com/view/khban/](https://sites.google.com/view/khban/)  

Désiré Kédagni         
_dkedagni@unc.edu_   
[https://sites.google.com/site/desirekedagni/](https://sites.google.com/site/desirekedagni/)


References
----------

Ban, K. and D. Kédagni (2023). Robust Difference-in-Differences Models. [https://arxiv.org/abs/2211.06710](https://arxiv.org/abs/2211.06710/).      
Ban, K. and D. Kédagni (2024). rdid and rdidstag: Stata commands for robust difference-in-differences.  [https://arxiv.org/XXXX](https://arxiv.org/XXXX)     


License
-------

MIT License

