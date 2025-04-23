
prog def rdid_0, rclass
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
	
	
	
	
	
	
	if (`iscov' == 0) {
		qui reg `Y' `D' if `postname' == 1
		local OLS = _b[`D']
		
		local est1 = `OLS'
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
	}
	
	
	
	
		
		local ind = 1
		foreach elevar of local infoelements {
			
			qui reg `Y' `D' if `I' == `elevar'
			local SBtmp = _b[`D']
			local GDID_est = `est1' - `SBtmp'
			
			return scalar _b`ind' = `GDID_est'
			
			
			local ind = `ind' + 1
		}
		
		
	
	
end




