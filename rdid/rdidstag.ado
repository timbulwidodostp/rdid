/***
_version 1.8.5_

rdidstag
====

a program that implements the robust difference-in-differences (RDID) method in staggered adoption design developed in Ban and Kédagni (2023) in Stata

Syntax
------

> __rdidstag__ _depvar_ [_indepvars_] [_if_] [_in_], __gname(_varname_)__ __tname(_varname_)__ [_options_]


### Options

| _options_                     | Description
|:------------------------------|:-------------------------------------------------
| Main                          |   
|	 __gname(_varname_)__       | specifies the variable name of the cohort index where __0__ is 
|		                        |‎   assigned for the never-treated group
|	 __tname(_varname_)__       | specifies the variable name of time index  
|	                            |
| Options                       |  
|	 __postname(_varname_)__    | specifies the variable name of the post-treatment period 
|		                        |‎   indicator; the default is using units in periods during 
|		                        |‎   and after the first treatment as post-period units
|	 __infoname(_varname_)__    | specifies the variable name of the information index; 
|		                        |‎   the default is using pre-treatment periods
|	 __level(_#_)__             | specifies the confidence level, as a percentage, 
|		                        |‎   for confidence intervals; the default is __level(95)__ 
|	 __figure(_string_)__       | saves line plots of RDID bounds and confidence intervals 
|		                        |‎   over the post-treatment periods for each group as  
|		                        |‎   __figure(_string_).png__ 
|	 __clustername(_varname_)__ | specifies the variable name that identifies resampling 
|		                        |‎   clusters in bootstrapping  




Description
-----------

__rdidstag__ command estimates bounds on the ATT and their confidence intervals over time for different cohorts in the staggered adoption design. Please visit our [GitHub repository](https://github.com/KyunghoonBan/rdid) for more details.


Example
-------

Estimate the RDID bounds on the ATT over time for different cohorts:

     . use "sim_rdidstag.dta"
     . rdidstag Y, g(G) t(year) post(posttreat) info(year) figure(sim_rdidstag)
	 
![rdidstag Estimation Results (g=1)](sim_rdidstag_g1.png)
![rdidstag Estimation Results (g=2)](sim_rdidstag_g2.png)
![rdidstag Estimation Results (g=3)](sim_rdidstag_g3.png)
![rdidstag Estimation Results (g=4)](sim_rdidstag_g4.png)
	 
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

Ban, K. and D. Kédagni (2023). Robust Difference-in-Differences Models. [https://arxiv.org/abs/2211.06710](https://arxiv.org/abs/2211.06710/)      
Ban, K. and D. Kédagni (2024). rdid and rdidstag: Stata commands for robust difference-in-differences.  [https://arxiv.org/XXXX](https://arxiv.org/XXXX)  


License
-------

MIT License

***/









prog def rdidstag, eclass
    version 14
	
	syntax varlist(min=1) [if] [in], Gname(string asis) Tname(string asis) [POSTname(string asis) INFOname(string asis) LEVel(integer 95) FIGure(string) CLustername(string asis)]
	
	if (`level' <= 50){
		display as error "The option 'level' must be greater than 50."
		exit 498 
	}
	
	preserve
	
	marksample touse 
	qui keep if `touse' == 1
	
	quietly count
	local N = r(N)
	
	tokenize "`varlist'" 
	local Y "`1'" 
	mac shift 
	local X "`*'" 
	
	local G "`gname'"
	local T "`tname'"
	
	local p = (100 - (100 - `level')/2)/100

	
	
	

	di " **** RDID Estimation version 1.8 **** "
	di "Y name: `Y'"
	di "G name: `G'"
	if "`X'" == ""{
		di "no covariates"
	}
	else {
		di "X name(s): `X'"
		
	}
	
	
	qui levelsof `G', local(levelsG)
	local flag = 0
	foreach glv of local levelsG {
		if `glv' == 0 {
			local flag = 1
		}
	}
	
	qui sum `G' if `G' != 0
	local maxG = r(max)
	local minG = r(min)
	
	if `flag' != 1 {
		display as error "There is no never-treated group with G = 0"
		exit 498 
	
		
	}
	
	
	
	if "`postname'" == ""{
		di "postname is not specified: using units with T >= min(G) as post-period units."
		qui gen postvar = (`T' >= `minG')
		local postname "postvar"
	}
	
	if "`infoname'" == ""{
		di "infoname is not specified: using pre-period T < min(G) as the information set."
		local infoname "`tname'"
	}
	
	qui levelsof `infoname' if `postname' == 0, local(infoelements)
	
	
	capture drop __I_internal
	qui gen __I_internal = .
	foreach var of local infoelements {
		qui replace __I_internal = `var' if (`infoname' == `var')&(`postname' == 0)
	}
	local I "__I_internal"
	
	
	
	qui levelsof `T' if `postname' == 1, local(Telements)
	qui tabulate `T' if `postname' == 1, generate(__T_dummy)
	local max_T = r(r)
	
	qui levelsof `G' if `G' != 0, local(Gelements)
	qui tabulate `G' if `G' != 0, generate(__G_dummy)
	local max_G = r(r)
	
	
	forvalues i = 1/`max_G' {
		forvalues j = 1/`max_T' {
			qui replace __G_dummy`i' = 0 if __G_dummy`i' == .
			qui replace __T_dummy`j' = 0 if __T_dummy`j' == .
			qui gen __interact_`i'_`j' = __G_dummy`i' * __T_dummy`j'
		}
	}
	
	
	local dummies
	forvalues i = 1/`max_G' {
		local dummies `dummies' __G_dummy`i'
	}
	forvalues i = 1/`max_T' {
		local dummies `dummies' __T_dummy`i'
	}
	forvalues i = 1/`max_G' {
		forvalues j = 1/`max_T' {
			local dummies `dummies' __interact_`i'_`j'
		}
	}

	
	
	
	local ind = 1
	foreach elevar of local infoelements {
		
		if "`clustername'" == "" {
			qui regress `Y' `dummies' if (`postname' == 1)|(`I' == `elevar'), vce(robust)
		}
		else {
			qui regress `Y' `dummies' if (`postname' == 1)|(`I' == `elevar'), vce(cluster `clustername')
		}
		
		matrix b = e(b)
		matrix V = e(V)
		
		
		matrix variances = vecdiag(V)
		
		local n_coef = colsof(variances)
		
		matrix se = J(1, `n_coef', .)
		
		forval i = 1 / `n_coef' {
			matrix se[1, `i'] = sqrt(variances[1, `i'])
		}
		
		matrix ci_lb = b - invnormal(`p') * se
		matrix ci_ub = b + invnormal(`p') * se
		
		
		
		if `ind' == 1 {
			matrix b_union_lb = b
			matrix b_union_ub = b
			matrix ci_union_lb = ci_lb
			matrix ci_union_ub = ci_ub
		}
		else {
			forval i = 1 / `n_coef' {
				matrix b_union_lb[1, `i'] = min(b_union_lb[1, `i'], b[1, `i'])
				matrix b_union_ub[1, `i'] = max(b_union_ub[1, `i'], b[1, `i'])
				matrix ci_union_lb[1, `i'] = min(ci_union_lb[1, `i'], ci_lb[1, `i'])
				matrix ci_union_ub[1, `i'] = max(ci_union_ub[1, `i'], ci_ub[1, `i'])
			}
		}
		local ind = `ind' + 1
	}
	
	
	local indtmp = `max_G' + `max_T' + 1
	matrix results_all = (b_union_lb', b_union_ub', ci_union_lb', ci_union_ub')
	matrix results_all = results_all[`indtmp'..., 1..4]
	
	local indtmp = `max_G' * `max_T'
	matrix results_all = results_all[1..`indtmp', 1..4]
	
	local rownames_ATT
	forval i = 1 / `max_G' {
		forval j = 1 / `max_T' {
			local gi: word `i' of `Gelements'
			local tj: word `j' of `Telements'
			local rownames_ATT `rownames_ATT' "ATT(`gi'/`tj')"
		}
	}
	matrix rownames results_all = `rownames_ATT'
	matrix colnames results_all = "RDID_LB" "RDID_UB" "`level'CI_LB" "`level'CI_UB"
	
	matlist results_all, twidth(15) rowtitle("ATT(G/T)") border(rows) format(%8.4f)
	
	di "- Information elements: `infoelements'"
	di "- Post-periods: `Telements'"
	di "- Groups: `Gelements'"
	
	
	if "`figure'" != "" {
		capture drop __dis_year
		qui gen __dis_year = .
		local ind = 1
		foreach tlv of local Telements {
			qui replace __dis_year = `tlv' if _n == `ind'
			local ind = `ind' + 1
		}
		
		local indtmp = 1
		foreach glv of local Gelements {
			qui gen __dis_RDID_LB_`glv' = .
			qui gen __dis_RDID_UB_`glv' = .
			qui gen __dis_CI_LB_`glv' = .
			qui gen __dis_CI_UB_`glv' = .
			
			local ind = 1
			foreach tlv of local Telements {
				local tmp1 = results_all[`indtmp', 1]
				local tmp2 = results_all[`indtmp', 2]
				local tmp3 = results_all[`indtmp', 3]
				local tmp4 = results_all[`indtmp', 4]
		
				qui replace __dis_RDID_LB_`glv' = `tmp1' if _n == `ind'
				qui replace __dis_RDID_UB_`glv' = `tmp2' if _n == `ind'
				qui replace __dis_CI_LB_`glv' = `tmp3' if _n == `ind'
				qui replace __dis_CI_UB_`glv' = `tmp4' if _n == `ind'
				
				local ind = `ind' + 1
				local indtmp = `indtmp' + 1
			}
			
			
			twoway (rarea __dis_CI_LB_`glv' __dis_CI_UB_`glv' __dis_year, color(gs14%50)) (line __dis_RDID_LB_`glv' __dis_year) (line __dis_RDID_UB_`glv' __dis_year), ///
				title("RDID Estimates and Confidence Intervals (g=`glv')") ///
				legend(label(2 "RDID Lower Bound") label(3 "RDID Upper Bound") label(1 "`level'% Confidence Intervals")) ///
				xtitle("T") ytitle("Value") name(graph_`glv', replace) ///
				xline(`glv', lcol(red))
				
			graph export "`figure'_g`glv'.png", as(png) replace
		}
		
	}
	
	ereturn scalar N = `N'
	local ind = 1
	forval i = 1 / `max_G' {
		forval j = 1 / `max_T' {
			local gi: word `i' of `Gelements'
			local tj: word `j' of `Telements'
			ereturn scalar RDID_LB_`gi'_`tj' = results_all[`ind', 1]
			ereturn scalar RDID_UB_`gi'_`tj' = results_all[`ind', 2]
			ereturn scalar CI_LB_`gi'_`tj' = results_all[`ind', 3]
			ereturn scalar CI_UB_`gi'_`tj' = results_all[`ind', 4]
			local ind = `ind' + 1
		}
	}
	
	
	ereturn local cmd rdidstag
	ereturn local indep `"`Y'"'
	ereturn local depvar `"`X'"'
	ereturn local clustvar `"`clustername'"'
	ereturn local level `level'
	
	ereturn matrix results = results_all
	
end



