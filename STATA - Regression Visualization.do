clear all
use "/Users/lukastaylor/Dropbox/ECON 5783/PS3/schools_es.dta", clear
sort cds
save stat.dta, replace

merge m:1 cds using "/Users/lukastaylor/Dropbox/ECON 5783/PS3/full_apportionment_schedule.dta"

gen runvar= ( api_rank - 643) if stype == "E"
replace runvar= ( api_rank - 600) if stype == "M"
replace runvar= ( api_rank - 584) if stype == "H"

gen treated = 0
replace treated = 1 if runvar > 0

drop percentfrl
gen percentfrl = (frl/total*100) 

summarize pct_wh pct_aa pct_hi pct_fi pct_pi pct_as pct_ai readingscore mathscore if stype == "E"  & api_rank == 643
summarize pct_wh pct_aa pct_hi pct_fi pct_pi pct_as pct_ai readingscore mathscore if stype == "E"  & api_rank == 644

summarize pct_wh pct_aa pct_hi pct_fi pct_pi pct_as pct_ai readingscore mathscore if stype == "M"  & api_rank == 600
summarize pct_wh pct_aa pct_hi pct_fi pct_pi pct_as pct_ai readingscore mathscore if stype == "M"  & api_rank == 601

summarize pct_wh pct_aa pct_hi pct_fi pct_pi pct_as pct_ai readingscore mathscore if stype == "H"  & api_rank < 584 & api_rank > 580
summarize pct_wh pct_aa pct_hi pct_fi pct_pi pct_as pct_ai readingscore mathscore if stype == "H"  & api_rank > 584 & api_rank < 575

summarize api_rank if stype == "E"
summarize api_rank if stype == "M"
summarize api_rank if stype == "H"

gen frl_pct = 0
replace frl_pct = frl/classsize
summarize mathscore readingscore api_rank classsize pct_wh pct_hi frl_pct fte_t fte_a fte_p if stype == "E"  & api_rank > 580.901 & api_rank < 619.099 & year == 2003
summarize mathscore readingscore api_rank classsize pct_wh pct_hi frl_pct fte_t fte_a fte_p if stype == "E" & year == 2003
summarize mathscore readingscore api_rank classsize pct_wh pct_hi frl_pct fte_t fte_a fte_p if stype == "M"  & api_rank > 623.901 & api_rank < 662.099 & year == 2003
summarize mathscore readingscore api_rank classsize pct_wh pct_hi frl_pct fte_t fte_a fte_p if stype == "M" & year == 2003
summarize mathscore readingscore api_rank classsize pct_wh pct_hi frl_pct fte_t fte_a fte_p if stype == "H"  & api_rank > 564.901 & api_rank < 603.099 & year == 2003
summarize mathscore readingscore api_rank classsize pct_wh pct_hi frl_pct fte_t fte_a fte_p if stype == "H"  & year == 2003

local enr = "runvar"
local bin = 3
gen bin = round(`enr'+`bin'/2, `bin')
replace bin= bin-`bin'/2

replace bin = . if runvar == 0 & bin == 1.5


sum mathscore readingscore api_rank
gen mathnorm = (mathscore-359.8894)/38.27272
gen readnorm = (readingscore-344.3928)/27.58625
gen apinorm = (api_rank-727.6805)/97.92814
sum mathnorm readnorm apinorm

gen avgnormscore = (mathnorm + readnorm)/2
gen apinorm2003 = apinorm if year == 2003
gen avgnormscore2002 = avgnormscore if year == 2002
gen avgnormscore2003 = avgnormscore if year == 2003
gen avgnormscore2004 = avgnormscore if year == 2004

egen average_score_bin = mean(avgnormscore) , by(bin year)

twoway lfit avgnormscore avgnormscore2002
twoway (scatter average_score_bin bin) (lfit average_score_bin bin), by(year) 

egen pct_hi_bin = mean(pct_hi), by(bin year)
egen pct_wh_bin = mean(pct_wh), by(bin year)
egen percentfrl_bin = mean(percentfrl), by(bin year)

twoway (scatter apinorm2003 pct_hi_bin) (lfit apinorm2003 pct_hi_bin)
twoway (scatter apinorm2003 pct_wh_bin) (lfit apinorm2003 pct_wh_bin)
twoway (scatter apinorm2003 percentfrl_bin) (lfit apinorm2003 percentfrl_bin)

sort cds

gen list = 0
replace list = 1 if _merge==3
replace list = . if year != 2005
egen list_bin = mean(list), by(bin)
scatter list_bin bin if year == 2005, xline(0) xti("API in 2003") yti(Dollars Per Students)

gen treat = 1 if _merge==3 
replace treat = 0 if _merge==1

//Elementary School
eststo A1: qui reg mathscore runvar treat c.runvar#treat if 19.099>= runvar & runvar > -19.099 & stype =="E" & year >=2005
eststo A2: qui reg readingscore runvar treat c.runvar#treat if 19.099>= runvar & runvar > -19.099 & stype =="E" & year >=2005
eststo A3: qui reg average_score runvar treat c.runvar#treat if 19.099>= runvar & runvar > -19.099 & stype =="E" & year >=2005

esttab A*

eststo A1: qui reg mathscore runvar treat c.runvar#treat if abs(runvar)<=19.099 & stype =="E" & year <2005
eststo A2: qui reg readingscore runvar treat c.runvar#treat if abs(runvar)<=19.099 & stype =="E" & year <2005
eststo A3: qui reg average_score runvar treat c.runvar#treat if abs(runvar)<=19.099 & stype =="E" & year <2005

esttab A*

eststo A1: qui reg mathscore runvar treat c.runvar#treat if 19.099>= runvar & runvar > -19.099 & stype =="M" & year >=2005
eststo A2: qui reg readingscore runvar treat c.runvar#treat if 19.099>= runvar & runvar > -19.099 & stype =="M" & year >=2005
eststo A3: qui reg average_score runvar treat c.runvar#treat if 19.099>= runvar & runvar > -19.099 & stype =="M" & year >=2005

esttab A*

eststo A1: qui reg mathscore runvar treat c.runvar#treat if abs(runvar)<=19.099 & stype =="H" & year <2005
eststo A2: qui reg readingscore runvar treat c.runvar#treat if abs(runvar)<=19.099 & stype =="H" & year <2005
eststo A3: qui reg average_score runvar treat c.runvar#treat if abs(runvar)<=19.099 & stype =="H" & year <2005

esttab A*

eststo A1: qui reg mathscore runvar treat c.runvar#treat if 19.099>= runvar & runvar > -19.099 & stype =="H" & year >=2005
eststo A2: qui reg readingscore runvar treat c.runvar#treat if 19.099>= runvar & runvar > -19.099 & stype =="H" & year >=2005
eststo A3: qui reg average_score runvar treat c.runvar#treat if 19.099>= runvar & runvar > -19.099 & stype =="H" & year >=2005

esttab A*

gen PT = 1 if year == 2002
replace PT = 0 if year == 2003


gen PTT = PT*treat
eststo T1: qui reg readingscore treat PT PTT if stype =="E"
eststo T2: qui reg mathscore treat PT PTT if stype == "E"
esttab T*

eststo T1: qui reg readingscore treat PT PTT if stype =="M"
eststo T2: qui reg mathscore treat PT PTT if stype == "M"
esttab T*S


eststo T1: qui reg readingscore treat PT PTT if stype =="H"
eststo T2: qui reg mathscore treat PT PTT if stype == "H"
esttab T*

gen post = 1 if year >=2005
replace post = 0 if year<=2004


gen posttreat = post*treat

** ELEMENTARY 
eststo D1: reg  mathscore treat post posttreat if stype == "E"
eststo D2:reg  readingscore treat post posttreat if stype == "E"
eststo D3:reg  average_score treat post posttreat if stype == "E"
esttab D*

** Middle School 
eststo E1:reg  mathscore treat post posttreat if stype == "M"
eststo E2:reg  readingscore treat post posttreat if stype == "M"
eststo E3:reg  average_score treat post posttreat if stype == "M"
esttab E*

** Hig School
eststo F1:reg  mathscore treat post posttreat if stype == "H"
eststo F2:reg  readingscore treat post posttreat if stype == "H"
eststo F3:reg  average_score treat post posttreat if stype == "H"
esttab F*
