clear all
use "/Users/lukastaylor/Dropbox/Mac/Downloads/maketable4/maketable4.dta"
sort shortnam
duplicates list shortnam
duplicates drop shortnam, force

save "/Users/lukastaylor/Dropbox/Mac/Downloads/maketable4/maketable4.dta", replace
import delimited "/Users/lukastaylor/Dropbox/ECON 5783/Project/current GDP.csv", clear 
sort shortnam
duplicates list shortnam
duplicates drop shortnam, force
save "/Users/lukastaylor/Dropbox/Mac/Downloads/maketable4/current GDP.dta", replace

import delimited "/Users/lukastaylor/Dropbox/ECON 5783/Project/contractvia2.csv", varnames(1) clear 
sort shortnam
duplicates list shortnam
duplicates drop shortnam, force
save "/Users/lukastaylor/Dropbox/ECON 5783/Project/contractvia2.dta", replace

duplicates list shortnam
duplicates drop shortnam, force
merge m:1 shortnam using "/Users/lukastaylor/Dropbox/Mac/Downloads/maketable4/maketable4.dta" , generate(_mergeAE)
merge m:1 shortnam using "/Users/lukastaylor/Dropbox/Mac/Downloads/maketable4/current GDP.dta" , generate(_mergeFZ)

duplicates list shortnam
duplicates drop shortnam, force
merge m:1 shortnam using "/Users/lukastaylor/Dropbox/ECON 5783/Project/contractvia2.dta" , generate(_mergeCV)

save "/Users/lukastaylor/Dropbox/Mac/Downloads/maketable4/merged.dta", replace

gen loggdp = log(value)
gen id = _n


eststo A1: reg loggdp avexpr, vce(cluster id)
eststo A2: reg loggdp avexpr lat_abst, vce(cluster id)
eststo A3: reg loggdp avexpr lat_abst asia, vce(cluster id)
eststo A4: reg loggdp avexpr lat_abst asia africa, vce(cluster id)

esttab A*

graph twoway (lfit avexpr logem4) (scatter avexpr logem4)
graph twoway (lfit loggdp logem4) (scatter loggdp logem4)

eststo B1: ivregress 2sls loggdp (avexpr=logem4), first vce(cluster id)
estat firststage
//weakivtest
weakiv, level(90)
eststo B2: ivregress 2sls loggdp lat_abst (avexpr=logem4),first vce(cluster id)
estat firststage
weakiv, level(90)
eststo B3: ivregress 2sls loggdp lat_abst africa (avexpr=logem4), first vce(cluster id)
estat firststage
weakiv, level(90)
eststo B4: ivregress 2sls loggdp lat_abst africa asia (avexpr=logem4), first vce(cluster id)
estat firststage
weakiv, level(90)

esttab B*

encode contractviability, generate(contractviability2)


eststo A1: reg loggdp contractviability2, vce(cluster id)
eststo A2: reg loggdp contractviability2 lat_abst, vce(cluster id)
eststo A3: reg loggdp contractviability2 lat_abst asia, vce(cluster id)
eststo A4: reg loggdp contractviability2 lat_abst asia africa, vce(cluster id)

esttab A*


graph twoway (lfit avexpr logem4) (scatter avexpr logem4)
graph twoway (lfit contractviability2 logem4) (scatter contractviability2 logem4)

eststo A1: ivregress 2sls loggdp  (contractviability2=logem4), first vce(cluster id)
estat firststage
weakiv, level(90)
eststo A2: ivregress 2sls loggdp  lat_abst (contractviability2=logem4),first vce(cluster id)
estat firststage
weakiv, level(90)
eststo A3: ivregress 2sls loggdp  lat_abst africa (contractviability2=logem4), first vce(cluster id)
estat firststage
weakiv, level(90)
eststo A4: ivregress 2sls loggdp  lat_abst africa asia (contractviability2=logem4), vce(cluster id)
estat firststage
weakiv, level(90)

esttab A*

ivregress 2sls loggdp  lat_abst africa asia (contractviability2=logem4) if shortnam != "USA" & shortnam != "CAN" & shortnam != "AUS" & shortnam != "NZL", vce(cluster id)
ivregress 2sls loggdp  lat_abst africa asia (avexpr=logem4) if shortnam != "USA" & shortnam != "CAN" & shortnam != "AUS" & shortnam != "NZL", vce(cluster id)
