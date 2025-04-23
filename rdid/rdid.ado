/***
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
|	 __treatname(_varname_)__   | specifies the treatment indicator
|	 __postname(_varname_)__    | specifies the post-treatment period indicator
|	 __infoname(_varname_)__    | specifies the information index
|	                            |
| Options                       |  
|	 __rdidtype(_#_)__          | specifies the type of RDID estimator: 
|		                        |‎   __0__ for the simple RDID (default),  
|		                        |‎   __1__ for the policy-oriented (PO) RDID,  
|		                        |‎   __2__ for the RDID with linear predictions.  
|	 __peval(_#_)__             | specifies the evaluation point for __rdidtype(2)__;
|		                        |‎   the default is the mean value of __infoname(_varname_)__ 
|		                        |‎   in the post-treatment period  
|	 __level(_#_)__             | specifies the confidence level, as a percentage,
|		                        |‎   for confidence intervals; the default is __level(95)__ 
|	 __figure(_string_)__       | saves a scatter plot of estimated selection biases
|		                        |‎   and the information index in the pre-treatment  
|		                        |‎   periods as __figure(_string_).png__ 
|	 __brep(_#_)__              | specifies the number of bootstrap replicates;
|		                        |‎   the default is __brep(500)__  
|	 __clustername(_varname_)__ | specifies the variable name that identifies resampling
|		                        |‎   clusters in bootstrapping  
|	                            |
| Options: __rdid_dy__          |  
|	 __tname(_varname_)__       | specifies the variable name for the time (required).
|	 __figure(_string_)__       | saves line plots of RDID estimates and confidence
|		                        |‎   intervals over the post-treatment periods as  
|		                        |‎   __figure(_string_).png__ 
|	 __citype(_#_)__            | specifies the type of confidence intervals to collect
|		                        |‎   for __rdidtype(0)__ (see the reference for more  
|		                        |‎   information); the default is __citype(1)__   
|	 __losstype(_#_)__          | specifies the type of loss function for __rdidtype(0)__
|		                        |‎   (see the reference for more information);  
|		                        |‎   the default is __losstype(1)__ 



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

***/



	 




prog def rdid, eclass
    version 14
	
	syntax varlist(min=1) [if] [in], TREATname(string asis) POSTname(string asis) INFOname(string asis) [rdidtype(integer 0) peval(string asis) LEVel(integer 95) FIGure(string) Brep(integer 500) CLustername(string asis)]
	
	if (`level' <= 50){
		display as error "The option 'level' must be greater than 50."
		exit 498 
	}
	
	preserve
	
	marksample touse 
	qui keep if `touse' == 1
	
	
	tokenize "`varlist'" 
	local Y "`1'" 
	mac shift 
	local X0 "`*'" 
	local X "`*'" 
	
	local D "`treatname'"
	
	
	
	qui sum `Y' if `D' == 0
	local nobs_0 = r(N)
	qui sum `Y' if `D' == 1
	local nobs_1 = r(N)
	if ((`nobs_0' == 0)|(`nobs_1' == 0)){
		display as error "The number of observations in treatment or control group is 0"
		exit 498 
	}
	
	di " **** RDID Estimation version 1.8 **** "
	di "Y name: `Y'"
	di "D name: `D'"
	if "`X'" == ""{
		di "no covariates"
		local iscov 0
		local X "0"
	}
	else {
		di "X name(s): `X'"
		local X "`X' 0"
		local iscov 1
	
		
		
		
	}
	
	
	
	qui levelsof `infoname' if `postname' == 0, local(infoelements)
	
	capture drop __I_internal
	qui gen __I_internal = .
	foreach var of local infoelements {
		qui replace __I_internal = `var' if (`infoname' == `var')&(`postname' == 0)
	}
	local I "__I_internal"
	
	
	
	
	if "`figure'" != "" {
		
		quietly {
			capture drop __SB
			gen __SB = .
			capture drop __I_ind
			gen __I_ind = .
		}
		
		local ind = 1
		foreach elevar of local infoelements {
			qui reg `Y' `D' if `I' == `elevar'
			qui replace __SB = _b[`D'] in `ind'
			qui replace __I_ind = `elevar' in `ind'
			local ind = `ind' + 1
		}
		
		if (`rdidtype' == 2){
			
			graph twoway (lfit __SB __I_ind) (scatter __SB __I_ind, xtitle("I (ordered)") ytitle("SB") legend(off))
			
		}
		else {
			if "`: var label `Y''" == "" {
				local Ylab "Y"
			}
			else {
				local Ylab "`: var label `Y''"
			}
			scatter __SB __I_ind, color(black) ////
			title("Selection Biases (`Ylab')", size(medium)) ////
			xtitle("I") ytitle("SB") 
			graph export "`figure'.png", as(png) replace
			
		}
	
	}
	
	
	
	
	if (`rdidtype' == 0){
		
		
		local N_val = _N
		local m_val = `N_val'
		
		

		
		local bootlist ""
		local ind = 1
		foreach elevar of local infoelements {
			rdid_1 `Y' `X' `D' `I' `postname' `elevar' `iscov' `rdidtype'
			
			local theta_N_`ind' = r(GDID_est)
			local SB_N_`ind' = r(SB)
			
			if (`ind' == 1) {
				local theta_N_min = r(GDID_est)
				local theta_N_max = r(GDID_est)
				local SB_N_min = r(SB)
				local SB_N_max = r(SB)
			}
			else {
				local theta_N_min = min(`theta_N_min', r(GDID_est))
				local theta_N_max = max(`theta_N_max', r(GDID_est))
				local SB_N_min = min(`SB_N_min', r(SB))
				local SB_N_max = max(`SB_N_max', r(SB))
			}
			local bootlist "`bootlist' r(_b`ind')"
			local ind = `ind' + 1 
		}
		local DR = r(DR_ret)
		local OLS = r(OLS_ret)
		
		if (`m_val' == `N_val'){
			
			local ind = 1
			foreach elevar of local infoelements {
				local d_`ind'_min = 0
				local d_`ind'_max = 0
				local ind = `ind' + 1 
			}
			local theta_m_min = `theta_N_min'
			local theta_m_max = `theta_N_max'
			
		}
		else {
		
			local ind = 1
			foreach elevar of local infoelements {
				local d_`ind'_min = (1 - sqrt(`m_val' / `N_val')) * (`theta_N_min' - `theta_N_`ind'')
				local d_`ind'_max = (1 - sqrt(`m_val' / `N_val')) * (`theta_N_max' - `theta_N_`ind'')
				local ind = `ind' + 1 
			}
			
			
			capture drop runif_tmp
			generate runif_tmp = runiform()
			sort runif_tmp
			replace runif_tmp = (_n <= `m_val')
			
			tempfile fullset
			save "`fullset'", replace
			keep if runif_tmp == 1
			tempfile subset
			save "`subset'", replace
			use "`subset'", clear
			
			local ind = 1
			foreach elevar of local infoelements {
				rdid_1 `Y' `X' `D' `I' `postname' `elevar' `iscov' `rdidtype'
				
				if (`ind' == 1) {
					local theta_m_min = r(GDID_est)
					local theta_m_max = r(GDID_est)
				}
				else {
					local theta_m_min = min(`theta_m_min', r(GDID_est))
					local theta_m_max = max(`theta_m_max', r(GDID_est))
				}
				local ind = `ind' + 1 
			}
			
			use "`fullset'", clear
			
		}
		
		
		
		
		
		quietly {
			
			if "`clustername'" == ""{
				bootstrap `bootlist', reps(`brep') nodrop saving(__rdid_tmp, replace): rdid_0 `Y' `X' `D' `I' `postname' 0 `iscov' `rdidtype' 0 `infoelements'
			}
			else {
				bootstrap `bootlist', reps(`brep') cluster(`clustername') nodrop saving(__rdid_tmp, replace): rdid_0 `Y' `X' `D' `I' `postname' 0 `iscov' `rdidtype' 0 `infoelements'
			}
			
			append using __rdid_tmp.dta
			erase __rdid_tmp.dta
			
			local ind = 1
			foreach elevar of local infoelements {
				gen _b_b`ind' = _bs_`ind'
				gen _b_d`ind' = _bs_`ind' + `d_`ind'_max'
				replace _bs_`ind' = _bs_`ind' + `d_`ind'_min'
				local ind = `ind' + 1
			}
			local n_info = `ind' - 1
			
			egen __minValues = rowmin(_bs_1-_bs_`n_info')
			egen __maxValues = rowmax(_b_d1-_b_d`n_info')
			
			
		}
		
		
		
		
		
		qui gen __minValue_diff = __minValues - `theta_N_min'
		qui gen __maxValue_diff = __maxValues - `theta_N_max'
		
		
		
		
		
		
		local upper = 100 - (100 - `level')/2
		_pctile __minValue_diff, p(50, `upper')
		local q_min_diff_50 = r(r1)
		local q_min_diff_upper = r(r2)
		
		local lower = (100 - `level')/2
		_pctile __maxValue_diff, p(`lower', 50)
		local q_max_diff_lower = r(r1)
		local q_max_diff_50 = r(r2)
		
		
		
		local GDID_cilbm = `theta_m_min' - sqrt(`N_val'/`m_val') * `q_min_diff_upper'
		local GDID_ciubm = `theta_m_max' - sqrt(`N_val'/`m_val') * `q_max_diff_lower'
		
		
		
		local omega = `theta_m_max' - sqrt(`N_val'/`m_val') * `q_max_diff_50' - `theta_m_min' + sqrt(`N_val'/`m_val') * `q_min_diff_50'
		local omega_pos = max(0, `omega')
		_pctile __minValues, p(25, 75)
		local q_min_25 = r(r1)
		local q_min_75 = r(r2)
		_pctile __maxValues, p(25, 75)
		local q_max_25 = r(r1)
		local q_max_75 = r(r2)
		
		
		local rho = sqrt(`N_val'/`m_val') / (log(`m_val') * max(`q_max_75' - `q_max_25', `q_min_75' - `q_min_25'))
		local p = 100 - normal(`rho' * `omega_pos')*(100 - `level')
		
		_pctile __minValue_diff, p(`p')
		local q_min_diff_p = r(r1)
		local cp = 100 - `p'
		_pctile __maxValue_diff, p(`cp')
		local q_max_diff_cp = r(r1)
		
		local GDID_cilbe = `theta_m_min' - sqrt(`N_val'/`m_val') * `q_min_diff_p'
		local GDID_ciube = `theta_m_max' - sqrt(`N_val'/`m_val') * `q_max_diff_cp'
		
		
		
		
		
		
		
		
		local ind = 1
		foreach elevar of local infoelements {
			_pctile _b_b`ind', p(`lower', `upper')
			local tmp_lower = r(r1)
			local tmp_upper = r(r2)
			
			local CI_LB_`ind' = 2*`theta_N_`ind'' - `tmp_upper'
			local CI_UB_`ind' = 2*`theta_N_`ind'' - `tmp_lower'
			
			if (`ind' == 1){
				local GDID_cilbu = `CI_LB_`ind''
				local GDID_ciubu = `CI_UB_`ind''
			}
			else {
				local GDID_cilbu = min(`GDID_cilbu', `CI_LB_`ind'')
				local GDID_ciubu = max(`GDID_ciubu', `CI_UB_`ind'')
			}
			local ind = `ind' + 1
		}
		
		
		
		
		
		
		matrix res_GDID = (`theta_N_min', `theta_N_max') \ (`GDID_cilbm', `GDID_ciubm') \ (`GDID_cilbe', `GDID_ciube') \ (`GDID_cilbu', `GDID_ciubu')
		matrix colnames res_GDID = LB UB
		matrix rownames res_GDID = RDID CI_1 CI_2 CI_3
		
		matlist res_GDID, twidth(15) rowtitle("Y: `Y'") border(rows) format(%8.4f)
		di "* RDID: Point estimates for RDID bounds"
		di "* CI_1: Confidence interval for the bounds (Ye et al.)"
		di "* CI_2: Confidence interval for the ATT (Ye et al.)"
		di "* CI_3: Confidence interval for the bounds (Union Bounds)"
		
		ereturn scalar N = `nobs_0' + `nobs_1'
		ereturn scalar SB_LB = `SB_N_min'
		ereturn scalar SB_UB = `SB_N_max'
		ereturn scalar RDID_LB = `theta_N_min'
		ereturn scalar RDID_UB = `theta_N_max'
		ereturn scalar DR = `DR'
		ereturn scalar OLS = `OLS'
		ereturn scalar CI1_LB = `GDID_cilbm'
		ereturn scalar CI1_UB = `GDID_ciubm'
		ereturn scalar CI2_LB = `GDID_cilbe'
		ereturn scalar CI2_UB = `GDID_ciube'
		ereturn scalar CI3_LB = `GDID_cilbu'
		ereturn scalar CI3_UB = `GDID_ciubu'
		
		ereturn local cmd rdid
		ereturn local indep `"`Y'"'
		ereturn local depvar `"`X0'"'
		ereturn local level `level'
		
		ereturn matrix results = res_GDID
		
	}
	else if (`rdidtype' == 1) {
		
		
		local elevar "dummy"
		local peval "dummy"
		
		if "`clustername'" == ""{
			qui bootstrap POGDID1 = r(POGDID1) POGDID2 = r(POGDID2) POGDIDinf = r(POGDIDinf), reps(`brep') nodrop level(`level'): rdid_1 `Y' `X' `D' `I' `postname' `elevar' `iscov' `rdidtype' "dummy" `infoelements'
		}
		else {
			qui bootstrap POGDID1 = r(POGDID1) POGDID2 = r(POGDID2) POGDIDinf = r(POGDIDinf), reps(`brep') cluster(`clustername') nodrop level(`level'): rdid_1 `Y' `X' `D' `I' `postname' `elevar' `iscov' `rdidtype' `peval' `infoelements'
		}
		matrix define tmp1 = e(b)
		matrix define tmp2 = e(ci_percentile)
		
		
		matrix BCI1 = ((2*tmp1[1, 1]) - tmp2[2, 1], (2*tmp1[1, 1]) - tmp2[1, 1])
		matrix BCI2 = ((2*tmp1[1, 2]) - tmp2[2, 2], (2*tmp1[1, 2]) - tmp2[1, 2])
		matrix BCIinf = ((2*tmp1[1, 3]) - tmp2[2, 3], (2*tmp1[1, 3]) - tmp2[1, 3])
		
		
		rdid_1 `Y' `X' `D' `I' `postname' `elevar' `iscov' `rdidtype' `peval' `infoelements'
		
		local DR = r(DR_ret)
		local OLS = r(OLS_ret)
		
		
		local L1_PE = r(POGDID1)
		local L2_PE = r(POGDID2)
		local Linf_PE = r(POGDIDinf)
		
		matrix res_POGDID = (r(POGDID1), BCI1) \ (r(POGDID2), BCI2) \ (r(POGDIDinf), BCIinf)
		matrix colnames res_POGDID = PE CI_LB CI_UB
		matrix rownames res_POGDID = L1 L2 Linf
		
		
		
		
		matlist res_POGDID, twidth(15) rowtitle("Y: `Y'") border(rows) format(%6.4fc)
		
		
		ereturn scalar N = `nobs_0' + `nobs_1'
		ereturn scalar DR = `DR'
		ereturn scalar OLS = `OLS'
		ereturn scalar L1_PE = `L1_PE'
		ereturn scalar L1_CI_LB = BCI1[1, 1]
		ereturn scalar L1_CI_UB = BCI1[1, 2]
		ereturn scalar L2_PE = `L1_PE'
		ereturn scalar L2_CI_LB = BCI2[1, 1]
		ereturn scalar L2_CI_UB = BCI2[1, 2]
		ereturn scalar Linf_PE = `Linf_PE'
		ereturn scalar Linf_CI_LB = BCIinf[1, 1]
		ereturn scalar Linf_CI_UB = BCIinf[1, 2]
		
		ereturn local cmd rdid
		ereturn local indep `"`Y'"'
		ereturn local depvar `"`X0'"'
		ereturn local clustvar `"`clustername'"'
		ereturn local level `level'
		
		
		ereturn matrix results = res_POGDID
		
		
	}
	else if (`rdidtype' == 2) {
		
		
		local elevar "dummy"
		if ("`peval'" == ""){
			qui sum `infoname' if `postname' == 1
			local peval = r(mean)
			di "Projection evaluation point 'peval' is not specified: mean of 'infoname' for post-period (`peval') is used."
		}
		
		
		if "`clustername'" == ""{
			qui bootstrap GDID = r(GDIDproj), reps(`brep') nodrop level(`level'): rdid_1 `Y' `X' `D' `I' `postname' `elevar' `iscov' `rdidtype' `peval' `infoelements'
		}
		else {
			qui bootstrap GDID = r(GDIDproj), reps(`brep') cluster(`clustername') nodrop level(`level'): rdid_1 `Y' `X' `D' `I' `postname' `elevar' `iscov' `rdidtype' `peval' `infoelements'
		}
		
		matrix define tmp1 = e(b)
		matrix define tmp2 = e(ci_percentile)
		
		matrix BCI = ((2*tmp1[1, 1]) - tmp2[2, 1], (2*tmp1[1, 1]) - tmp2[1, 1])
		
		
		rdid_1 `Y' `X' `D' `I' `postname' `elevar' `iscov' `rdidtype' `peval' `infoelements'
		
		
		local DR = r(DR_ret)
		local OLS = r(OLS_ret)
		local SB_hat = r(SB_proj)
		local proj_PE = r(GDIDproj)
		
		if `iscov' == 0 {
			matrix res_GDID_Proj = (r(GDIDproj), BCI, r(OLS_ret), r(SB_proj))
			matrix colnames res_GDID_Proj = PE CI_LB CI_UB OLS SB_hat
		}
		else{
			matrix res_GDID_Proj = (r(GDIDproj), BCI, r(DR_ret), r(SB_proj))
			matrix colnames res_GDID_Proj = PE CI_LB CI_UB TAU_DR SB_hat
		}
		matrix rownames res_GDID_Proj = "Y: `Y'"
		
		
		matlist res_GDID_Proj, twidth(15) border(rows) format(%6.4fc)
		
		
		ereturn scalar N = `nobs_0' + `nobs_1'
		ereturn scalar DR = `DR'
		ereturn scalar OLS = `OLS'
		ereturn scalar proj_PE = `proj_PE'
		ereturn scalar CI_LB = BCI[1, 1]
		ereturn scalar CI_UB = BCI[1, 2]
		ereturn scalar SB_hat = `SB_hat'
		
		ereturn local cmd rdid
		ereturn local indep `"`Y'"'
		ereturn local depvar `"`X0'"'
		ereturn local clustvar `"`clustername'"'
		ereturn local level `level'
		
		ereturn matrix results = res_GDID_Proj
		
	}
	else {
		
		display as error "The option 'rdidtype' must be either 0, 1, or 2."
		exit 498 
		
	}
	
end


