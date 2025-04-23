

program define rdid_dy, eclass
    version 14
    syntax varlist(min=1) [if] [in], TREATname(string asis) POSTname(string asis) INFOname(string asis) Tname(string asis) ///
        [rdidtype(integer 0) peval(string asis) LEVel(integer 95) FIGure(string) Brep(integer 500) CLustername(string asis) CItype(integer 1) Losstype(integer 1)]
	
	
	if (`citype' != 1)&(`citype' != 2)&(`citype' != 3){
		display as error "The option 'citype' must be either 1, 2, or 3."
		exit 498
	}
	
	if (`rdidtype' != 0)&(`citype' != 1)&(`citype' != 2){
		display as error "The option 'rdidtype' must be either 0, 1, or 2."
		exit 498
	}
	
	if (`rdidtype' == 1) {
		if (`losstype' != 0)&(`losstype' != 1)&(`losstype' != 2){
			display as error "The option 'losstype' must be either 0, 1, or 2."
			exit 498
		}
		if (`losstype' == 0){
			local losstype "inf"
		}
	}
	
	preserve
	
	marksample touse 
	qui keep if `touse' == 1
	
	quietly count
	local N = r(N)
	
	qui levelsof `tname' if `postname' == 1, local(levelsT)
	
	local flag = 0
	foreach tlv of local levelsT {
		qui rdid `varlist' if (`postname' == 0)|(`tname' == `tlv'), treatname(`treatname') postname(`postname') infoname(`infoname') ///
        rdidtype(`rdidtype') peval(`peval') level(`level') brep(`brep') clustername(`clustername')
		
		local indep = e(indep)
		local depvar = e(depvar)
		
		if (`rdidtype' == 0) {
			matrix define res_GDID = e(results)
			local RDID_LB_`tlv' = e(RDID_LB)
			local RDID_UB_`tlv' = e(RDID_UB)
			local CI_LB_`tlv' = res_GDID[1 + `citype', 1]
			local CI_UB_`tlv' = res_GDID[1 + `citype', 2]
			
			if `flag' == 0 {
				matrix res_all = (`RDID_LB_`tlv'', `RDID_UB_`tlv'', `CI_LB_`tlv'', `CI_UB_`tlv'')
				local flag = 1
			}
			else {
				matrix res_all = res_all \ (`RDID_LB_`tlv'', `RDID_UB_`tlv'', `CI_LB_`tlv'', `CI_UB_`tlv'')
			}
		}
		else {
			if (`rdidtype' == 1) {
				local RDID_PE_`tlv' = e(L`losstype'_PE)
				local CI_LB_`tlv' = e(L`losstype'_CI_LB)
				local CI_UB_`tlv' = e(L`losstype'_CI_UB)
			}
			else {
				local RDID_PE_`tlv' = e(proj_PE)
				local CI_LB_`tlv' = e(CI_LB)
				local CI_UB_`tlv' = e(CI_UB)
			}
			
			if `flag' == 0 {
				matrix res_all = (`RDID_PE_`tlv'', `CI_LB_`tlv'', `CI_UB_`tlv'')
				local flag = 1
			}
			else {
				matrix res_all = res_all \ (`RDID_PE_`tlv'', `CI_LB_`tlv'', `CI_UB_`tlv'')
			}
		}
		
		
	}
	
	matrix rownames res_all = `levelsT'
	
    
	
	
	if "`figure'" != "" {
		if (`rdidtype' == 0) {
			matrix colnames res_all = __RDID_LB __RDID_UB __CI_LB __CI_UB
		}
		else {
			matrix colnames res_all = __RDID_PE __CI_LB __CI_UB
		}
		qui svmat res_all, names(col)
		
		capture drop __year_dis
		qui gen __year_dis = .
		local ind = 1
		foreach tlv of local levelsT {
			qui replace __year_dis = `tlv' if _n == `ind'
			local ind = `ind' + 1
		}
		
		if (`rdidtype' == 0){
			twoway (rarea __CI_LB __CI_UB __year_dis, color(gs14%50)) (line __RDID_LB __year_dis) (line __RDID_UB __year_dis), ///
				title("RDID Bound Estimates and Confidence Intervals") ///
				legend(label(2 "RDID Lower Bound") label(3 "RDID Upper Bound") label(1 "`level'% Confidence Intervals")) ///
				xtitle("T") ytitle("Value") name(graph_all, replace)
		}
		else {
			twoway (rarea __CI_LB __CI_UB __year_dis, color(gs14%50)) (line __RDID_PE __year_dis), ///
				title("RDID Estimates and Confidence Intervals") ///
				legend(label(2 "RDID estimates") label(1 "`level'% Confidence Intervals")) ///
				xtitle("T") ytitle("Value") name(graph_all, replace)
		}
			
		graph export "`figure'.png", as(png) replace
	}
	
	if (`rdidtype' == 0) {
		matrix colnames res_all = RDID_LB RDID_UB CI_LB CI_UB
	}
	else {
		matrix colnames res_all = RDID_PE CI_LB CI_UB
	}
	
	matlist res_all, twidth(15) rowtitle("T: `tname'") border(rows) format(%8.4f)
	if (`rdidtype' == 0){
		if (`citype' == 1){
			di "* Confidence intervals are obtained for the bounds (Ye et al.)"
		}
		else {
			if (`citype' == 2){
				di "* Confidence intervals are obtained for the ATT (Ye et al.)"
			}
			else {
				di "* Confidence intervals are obtained for the bounds (Union Bounds)"
			}
		}
	}
	else if (`rdidtype' == 1){
		di "* RDID estimates are obtained as PO-RDID estimates (L`losstype')"
	}
	else {
		di "* RDID estimates are obtained using projected selection biases"
	}
	
	
	ereturn scalar N = `N'
	foreach tlv of local levelsT {
		if (`rdidtype' == 0){
			ereturn scalar RDID_LB_`tlv' = `RDID_LB_`tlv''
			ereturn scalar RDID_UB_`tlv' = `RDID_UB_`tlv''
		}
		else {
			ereturn scalar RDID_PE_`tlv' = `RDID_PE_`tlv''
		}
		ereturn scalar CI_LB_`tlv' = `CI_LB_`tlv''
		ereturn scalar CI_UB_`tlv' = `CI_UB_`tlv''
	}
	
	ereturn local cmd rdid_dy
	ereturn local indep `indep'
	ereturn local depvar `depvar'
	ereturn local clustvar `"`clustername'"'
	ereturn local level `level'
	
	ereturn matrix results = res_all
end

