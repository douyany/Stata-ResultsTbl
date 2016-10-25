
***May 26, 2016
**this do-file put together counts and chi-square analyses for Dr. janedoe's project about [redacted]

**the raw file's name is 
**[redacted]
**in xlsx format

***I changed the first column's name from the institution name to ptid
***read in the file's spreadsheets
***variable names are in the first row
***one each for placename, wash, adams, and jeff
***as of May 26, the placename data had not arrived yet


***for the order of the columns,
***placename =1, wash =2, adams =3, jeff = 4


***remove one of two observations for two patients
***so that they do not get double-counted
***set one: 1234 and 5678
***set two: 2345 and 6789

cap prog drop discsummdropone
prog define discsummdropone

***raw variable name
local whichraw=1

***my question numbering system
local whichmyq=2

cap drop revampQ``whichmyq''
gen revampQ``whichmyq''=``whichraw''
***drop out of set one
replace revampQ``whichmyq''="" if trim(ptid)==5678
***drop out of set two
replace revampQ``whichmyq''="" if trim(ptid)==6789

end


***start the log
cap log close
log using 20160906_log.log, replace

cap scalar drop _all
cap matrix drop _all

***run the do-file for the placename data
do "20160803_read_in_placename.do"


local counter=2
foreach whichsheet in wash adams jeff {
import excel using 20160524_janedoe_orig_file.xls, ///
 sheet("`whichsheet' for analysis") firstrow clear
gen whichloc=`counter'


**save the file
save 20160524_janedoe_pg`counter'.dta, replace

***up the counter
local counter=`counter'+1
} 

**append spreadsheets to each other

**(column Y)
**doesn't currently have any entries
**Stata sees it as numeric var rather than string var
**will convert from num var to string var
use 20160524_janedoe_pg2.dta, clear
capture tostring Y, replace
***replace the dot of missing values into a blank quote (from . to "")
replace Y="" if Y=="."

forvalues whichpg=3/4 {
append using 20160524_janedoe_pg`whichpg'.dta, force
}

***capture rename the columns
***before adding the placename columns that will use those names
capture rename F rQ5bother
capture rename U sQ8bstring
capture rename V rQ8bother
capture rename X sQ9bstring
capture rename Y rQ9bother

***create the revamped variables to incorporate the responses from the "other" questions
**#Q5b
cap drop revampQ5b
gen revampQ5b=.
***from varnamewillbe 601
***one response with baseball
replace revampQ5b=1 if question5btext=="baseball"
***the Not Documented responses (category 2)
***[redacted code]


***create the revamped variables to incorporate the responses from the "other" questions
**#Q7b
cap drop revampQ7b
gen revampQ7b=.
***the two existing non-other reasons
***[redacted code]
***the other responses (starts from category 3)
***[redacted code]
                       
***create the revamped variables to incorporate the responses from the "other" questions
**#Q8b
cap drop revampQ8b
gen revampQ8b=.
***the two existing non-other reasons
***[redacted code]
***the other responses (starts from category 3)
***[redacted code]

***create the revamped variables to incorporate the responses from the "other" questions
**#Q9b
cap drop revampQ9b
gen revampQ9b=.
***the two existing non-other reasons
***[redacted code]
***the other responses (starts from category 3)
***[redacted code]


***append the placename file
append using 20160803_janedoe_placenameprepped.dta


***count the number of total records for that inst
forvalues whichplace=1/4 {
count if whichloc==`whichplace'
scalar obstot_`whichplace'=r(N)
}

cap label drop whichloclbl
label define whichloclbl 1 "placename" 2 "wash" 3 "adams" 4 "jeff"
label values whichloc whichloclbl



***program to
***convert string var into number var

cap prog drop turnintonumvar
prog define turnintonumvar
local whichvar=1
local numvarname=2

cap drop ``numvarname''
encode ``whichvar'', gen(``numvarname'')
***[redacted code]
***new line from June 06:
***[redacted code]

end


***program to
***run the tabulation

cap prog drop runthetab
prog define runthetab
local numvarname=1
local matname=2

tab ``numvarname'' whichloc , matcell(``matname'') chi2 col
scalar tot``matname''=r(N)
scalar chisq``matname''=r(chi2)
scalar pval``matname''=strofreal(r(p), "%3.2g")
if r(p)>0 & r(p)<float(.1) {
scalar pval``matname''=strofreal(r(p), "%3.2f")
**close the "<.1" condition
}
if r(p)>0 & r(p)<float(.01) {
scalar pval``matname''="<.01"
**close the "<.01" condition
}


***for the questions other than Q2 and Q3, will need Fisher's exact test
***they have cells with values under 5 obs.
***add the parentheses for float, so that the computer can run the comparison
***without the float, Stata (works in binary) may not get me the comparison I need
***from http://blog.stata.com/2011/06/17/precision-yet-again-part-i/
***the detailed tabulation of procedures is too large to run, even with 200x memory
***the p-value with chi-square is .000
***have taken it off this list for now
if "``numvarname''"~="Q2" &  "``numvarname''"~="Q3" {
tab ``numvarname'' whichloc, matcell(``matname'') exact(2)
scalar fish``matname''=strofreal(r(p_exact), "%3.2f")
if r(p_exact)>0 & r(p_exact)<float(.1) {
scalar fish``matname''=strofreal(r(p_exact), "%3.2f")
**close the "<.1" condition
}

if r(p_exact)>0 & r(p_exact)<float(.01) {
scalar fish``matname''="<.01"
**close the "<.001" condition
}
**close the not Q2 and not Q3 condition
}

***get the numbers for the denominators of the categories
forvalues whichinst=1/4 {
**non-missing values specific to that institution
count if ``numvarname''<. & whichloc==`whichinst'
scalar denom``numvarname''_`whichinst'=r(N)
}

end



***program to
***put numbers from matrix and count scalars
***into cell-specific scalars

cap prog drop putmatrixinscalar
prog define putmatrixinscalar

local matname=1
local numvarname=2
local maxinst=3
local maxrow=4

**for the tabs that don't have any placename data,
**will start the number for inst of interest at 2 rather than 1

**row of interest loop
forvalues whichrow=1/``maxrow'' {

**inst of interest loop
**will adjust for those tabs that don't have all four inst included
forvalues whichinst=1/4 {

***create a var for the info of which inst it is
local instforcol=`whichinst'


***need to re-calibrate the numbering, when placename does not have any observations for a column
***like in question #6bi
***the numbering will not be 1=placename, 2=wash, 3=adams, 4=jeff
***it will be 1=wash, 2=adams, 3=jeff
***will change the value for the institution from that number to (that number plus one)
if ``maxinst''==3 {
di "Max Inst is 3, Institution of Interest Number is `whichinst' (Pre-Move)"
local instforcol=`whichinst'+1
di "Max Inst is 3, Institution of Interest Number is `whichinst' (Post-Move)"
}

di "Displaying the vars: "
di _newline(2) "Which row: `whichrow', which inst: `whichinst', which column in table: `instforcol'"

***a break for when the three-instutition cross-tab has reached "fifth" loop
if `instforcol'==5 {
di "Break, having reached instforcol equal to 5"
continue, break
}

**get the value for the cell
cap scalar drop cnt``numvarname''_`whichrow'_`instforcol'
scalar define cnt``numvarname''_`whichrow'_`instforcol'=el(``matname'', `whichrow', `whichinst')


**get the numerator and denominator for the cell
**get the percent for the cell
cap scalar drop pct``numvarname''_`whichrow'_`instforcol'

***the numbering of the denominators matches to
***2 being wash (no placename present) and moving higher from there

***denom will run 2 to 4 when placename inst is not present
scalar define pct``numvarname''_`whichrow'_`instforcol'=(cnt``numvarname''_`whichrow'_`instforcol'/denom``numvarname''_`instforcol')

cap scalar drop cell``numvarname''_r`whichrow'_c`instforcol'

***one style of cell entry
**includes count and percentage
if "``numvarname''"=="Q2" | "``numvarname''"=="Q3" {
**count then pct
scalar define cell``numvarname''_r`whichrow'_c`instforcol'=strofreal(cnt``numvarname''_`whichrow'_`instforcol', "%9.0g")+" ("+strofreal(round(pct``numvarname''_`whichrow'_`instforcol'*100), "%9.0g")+"%)"
}

***other style of cell entry
**includes count, denominator, and percentage
if "``numvarname''"~="Q2" & "``numvarname''"~="Q3" {
**count over denominator then pct

scalar define cell``numvarname''_r`whichrow'_c`instforcol'=strofreal(cnt``numvarname''_`whichrow'_`instforcol', "%9.0g")+"/"+strofreal(denom``numvarname''_`instforcol', "%9.0g")+" ("+strofreal(round(pct``numvarname''_`whichrow'_`instforcol'*100), "%9.0g")+"%)"

***close the it is not Q2 or Q3 condition
}

***close the whichinst loop
}

***close the row of interest loop
}


end

***program to
***put numbers from matrix and count scalars
***into cell-specific scalars






cap drop Q2
gen Q2=.
replace Q2=1 if index(PrimaryProcedurePerformed, "brownblack")>0 
replace Q2=2 if index(PrimaryProcedurePerformed, "bluepurple")>0 
replace Q2=3 if index(PrimaryProcedurePerformed, "yellowgreen")>0 
replace Q2=4 if index(PrimaryProcedurePerformed, "redorange")>0 
tab Q2, m

cap label drop Q2lbl
label define Q2lbl 1 "yellowgreen" 2 "bluepurple" 3 "brownblack" 4 "redorange"
label values Q2 Q2lbl

***will call this one factor 2

runthetab Q2 matQ2

**matrixname: matQ2
**numvarname: Q2
**min inst: 1
**max inst: 3 (until placename arrives), 4 (now that placename is here
**max row: 4 (4 types of procedures)
putmatrixinscalar matQ2 Q2 4 4

***factor 3: the non-aggregated version of the procedure names
cap drop Q3
gen Q3=.
***[redacted code]
**this procedure #13 does not have any obs in the data 
***[redacted code]
tab Q3, m
***do not want any obs that do not have a Q3 value

cap label drop Q3lbl
***no abbreviations
***[redacted code]

***with abbreviations 
***[redacted code]
 
label values Q3 Q3lbl


runthetab Q3 matQ3

**matrixname: matQ2
**numvarname: Q2
**min inst: 1
**max inst: 3 (until placename arrives)
**max row: 17 (17 types of procedures out of 18 listed options)
putmatrixinscalar matQ3 Q3 4 17


**factor 4: 



turnintonumvar question4text Q4
runthetab Q4 matQ4
putmatrixinscalar matQ4 Q4 4 2

**factor 5: 

turnintonumvar question5text Q5
runthetab Q5 matQ5
putmatrixinscalar matQ5 Q5 4 2


**factor 5b: 



***use the revamped version of the var instead
rename revampQ5b Q5b
runthetab Q5b matQ5b
**max row: 5 (1 pre-existing answer and 4 new other reasons)
putmatrixinscalar matQ5b Q5b 4 5

*tab rQ5bother

**factor 6a:
discsummdropone question6atext 6a
turnintonumvar revampQ6a Q6a
runthetab Q6a matQ6a

putmatrixinscalar matQ6a Q6a 4 2

**factor 6b:
discsummdropone question6btext 6b
turnintonumvar revampQ6b Q6b
runthetab Q6b matQ6b

putmatrixinscalar matQ6b Q6b 4 2

**factor 6bi: 

discsummdropone question6bitext 6bi
turnintonumvar revampQ6bi Q6bi

cap drop Q6biv2
gen Q6biv2=Q6bi
***re-arrange order
replace Q6biv2=10 if Q6bi==3
replace Q6biv2=20 if Q6bi==4
replace Q6biv2=30 if Q6bi==2
*replace Q6biv2=40 if Q6bi==1
cap label drop Q6biv2lbl
***[redacted text]
label values Q6biv2 Q6biv2lbl
runthetab Q6biv2 matQ6bi

**four options for 
***[redacted text]
putmatrixinscalar matQ6bi Q6biv2 3 3


**factor 6c: 

discsummdropone question6ctext 6c
turnintonumvar revampQ6c Q6c
runthetab Q6c matQ6c

putmatrixinscalar matQ6c Q6c 4 2

**factor 6d: 

discsummdropone question6dtext 6d
turnintonumvar revampQ6d Q6d
runthetab Q6d matQ6d

putmatrixinscalar matQ6d Q6d 4 2

**factor 6e: 

discsummdropone question6etext 6e
turnintonumvar revampQ6e Q6e
runthetab Q6e matQ6e

putmatrixinscalar matQ6e Q6e 4 2


**factor 6f: 

discsummdropone question6ftext 6f
turnintonumvar revampQ6f Q6f
runthetab Q6f matQ6f

putmatrixinscalar matQ6f Q6f 4 2


**factor 6g: 
discsummdropone question6gtext 6g
turnintonumvar revampQ6g Q6g
runthetab Q6g matQ6g

putmatrixinscalar matQ6g Q6g 4 2

**factor 6h: 

discsummdropone question6htext 6h
turnintonumvar revampQ6h Q6h
runthetab Q6h matQ6h

putmatrixinscalar matQ6h Q6h 4 2

**factor 6i: 

discsummdropone question6itext 6i
turnintonumvar revampQ6i Q6i
runthetab Q6i matQ6i



putmatrixinscalar matQ6i Q6i 4 2

**factor 4: 
turnintonumvar question7text Q7 
runthetab Q7 matQ7

putmatrixinscalar matQ7 Q7 4 2

**factor 4b:

***use the revamped version of the var instead
rename revampQ7b Q7b
runthetab Q7b matQ7b
**max row: 6 (2 pre-existing answer and 4 new other reasons)
putmatrixinscalar matQ7b Q7b 4 6

**factor 5: 

turnintonumvar question8text Q8 
runthetab Q8 matQ8
putmatrixinscalar matQ8 Q8 4 2

**factor 5b: 


***use the revamped version of the var instead
rename revampQ8b Q8b
runthetab Q8b matQ8b
**max row: 5 (2 pre-existing answer and 3 new other reasons)
putmatrixinscalar matQ8b Q8b 4 5

**factor 9: 

turnintonumvar question9text Q9
runthetab Q9 matQ9
putmatrixinscalar matQ9 Q9 4 2
 

**factor 9b:


***use the revamped version of the var instead
rename revampQ9b Q9b
runthetab Q9b matQ9b
**max row: 8 (2 pre-existing answer and 6 new other reasons)
putmatrixinscalar matQ9b Q9b 4 8


***plug in the empty values for Q7b where there are no placename responses
***will want placeholders for those cells
scalar define cellQ6biv2bv2_r3_c1="./0 (.%)"
scalar define pctQ6biv2bv2_3_1=         .
scalar define cntQ6biv2bv2_3_1=         .
scalar define cellQ6biv2bv2_r2_c1="./0 (.%)"
scalar define pctQ6biv2bv2_2_1=         .
scalar define cntQ6biv2bv2_2_1=         .
scalar define cellQ6biv2bv2_r1_c1="./0 (.%)"
scalar define pctQ6biv2bv2_1_1=         .
scalar define cntQ6biv2bv2_1_1=         .

scalar list _all
matrix dir

cap log close

log using 20160906_scalar_log.txt, replace text 
scalar list _all
cap log close

***create rows and columns for table

***column 1=placename
***column 2=wash
***column 3=adams
***column 4=jeff
***column 5=p-value (either for chi-sq or for Fisher's exact test)

***the frequencies

***refer to cells of tables as r,c

***the tabs for the questions with "other" responses all at once
