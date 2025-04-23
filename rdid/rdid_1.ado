
prog def rdid_1, rclass
    version 14
	
	local Y "`1'" 
	mac shift 
	
	local Xtmp "`1'"
	local X ""
	while ("`Xtmp'" != "0") {
		local X "`X' `Xtmp'"
		mac shift 
		local Xtmp "`1'"
	}
	mac shift 
	local D "`1'"  
	mac shift 
	local I "`1'"  
	mac shift 
	local postname "`1'"  
	mac shift 
	local elevar "`1'"  
	mac shift 
	local iscov "`1'"  
	mac shift 
	local rdidtype "`1'"  
	mac shift 
	local peval "`1'"  
	mac shift 
	local infoelements "`*'" 
	
	
	
	preserve
	
	
	
	
	if (`iscov' == 0) {
		qui reg `Y' `D' if `postname' == 1
		local OLS = _b[`D']
		
		local est1 = `OLS'
		return scalar OLS_ret = `OLS'
	}
	else {
		
		
	
		qui logit `D' `X' if (`postname'==1)
		capture drop PX_internal
		qui predict PX_internal
		qui replace PX_internal = . if `postname' == 0
	
		
	
		qui reg `Y' `X' if (`postname'==1)&(`D'==0)
		capture drop mu0X_internal
		qui predict mu0X_internal
		qui replace mu0X_internal = . if `postname' == 0
		
		
	
		capture drop __DRtmp
		qui gen __DRtmp = ((`D'-PX_internal)/(1-PX_internal))*(`Y'-mu0X_internal)
		
		
		
		
		qui summarize __DRtmp if `postname' == 1
		local DRa = r(mean)
		qui summarize `D' if `postname' == 1
		local DRb = r(mean)
		local DR = `DRa' / `DRb'
		
		local est1 = `DR'
		return scalar DR_ret = `DR'
	}
	
	
	
	if (`rdidtype' == 0) {
		
		qui reg `Y' `D' if `I' == `elevar'
		local SBtmp = _b[`D']
		
		return scalar SB = `SBtmp'
		return scalar GDID_est = `est1' - `SBtmp'
	}
	else {
		
		quietly {
		capture drop __SB_internal
		gen __SB_internal = .
		capture drop __SB_N
		gen __SB_N = .
		}
		
		local ind = 1
		foreach elevar of local infoelements {
			
			qui reg `Y' `D' if `I' == `elevar'
			qui replace __SB_internal = _b[`D'] in `ind'
			local tmp = e(N)
			qui replace __SB_N = `tmp' in `ind'
			local ind = `ind' + 1
			
		}
		

		if (`rdidtype' == 2) {
			
			quietly {
			capture drop __I_ind
			gen __I_ind = .
			}
			
			local ind = 1
			foreach elevar of local infoelements {
				qui replace __I_ind = `elevar' in `ind'
			local ind = `ind' + 1
			}
			qui reg __SB_internal __I_ind
			local SBproj = (`peval'*_b[__I_ind]) + _b[_cons]
			return scalar SB_proj = `SBproj'
			return scalar GDIDproj = `est1' - `SBproj'
		}
		else {
			qui sum __SB_internal [w=__SB_N], detail
			local SBlb = r(min)
			local SBub = r(max)
			local SBmed = r(p50)
			local SBmean = r(mean)
			local SBmid = 0.5*(`SBlb' + `SBub')
			
			return scalar SBlb = `SBlb'
			return scalar SBub = `SBub'
			return scalar POGDID1 = `est1' - `SBmed'
			return scalar POGDID2 = `est1' - `SBmean'
			return scalar POGDIDinf = `est1' - `SBmid'

		}
	}
	
		
end

