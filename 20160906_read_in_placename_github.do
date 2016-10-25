***read in the placename dataset
**ignore the first row

***program to move info from transposed file into var names matching the other file
cap prog drop filltheqs
prog define filltheqs

*local whichqinthisdataset=1
local whichothquestion=1
local whichthisrownum=2
local whichothresponse=3


cap drop ``whichothquestion''
gen str100 ``whichothquestion''=""

while "``whichothresponse''"~="" {
replace ``whichothquestion''="``whichothresponse''" if v``whichthisrownum''==1
local whichothresponse=`whichothresponse'+2
local whichthisrownum=`whichthisrownum'+2
}
end



***start the log
cap log close
log using 20160706_log.log, replace


***read in the file
foreach whichsheet in redorange greygold bluepurple yellowgreen {
import excel using 20160728_janedoe_`whichsheet'.xls, ///
 sheet("Patient level v1") clear

 
**save the file
save 20160728_janedoe_`whichsheet'.dta, replace
 
} 

***when counting the top row
*****redorange and greygold have 100 rows
*****bluepurple and yellowgreen have 93 rows

***have to add the seven rows at the end of bluepurple and yellowgreen
***these seven rows will be 50, 53, 60, 63, 72, 75, 78 (when first row is row header)


foreach whichsheet in bluepurple yellowgreen {
use 20160728_janedoe_`whichsheet'.dta, clear


cap drop local  currcount
cap drop local  wantedcount

count
local currcount=r(N)
local wantedcount=r(N)+1

***row count in Excel is:
foreach whichnewrow in 50 53 60 63 72 75 78 {

cap drop rownum
gen rownum=_n

di "Current count: `currcount'"
di "Wanted count: `wantedcount'"
set obs `wantedcount'
***put this blank row in front of the current row at that place
replace rownum=`whichnewrow'-.1 if rownum==.

***sort the data so it will have the same row-for-row information with the redorange and greygold datasets
***prepare for the next round
sort rownum

local currcount=`currcount'+1
local wantedcount=`wantedcount'+1

***close loop for which new row
} 

di "Loops are done!  The new count is:"
count


cap drop rownum
save 20160728_janedoe_`whichsheet'100.dta, replace
***close loop for which data file
}

***cannot xpose right away, as the text fields get converted to missing

***all datasets should now have same number of rows


***add the row numbers and then transpose the dataset

foreach whichsheet in redorange greygold bluepurple100 yellowgreen100 {

use 20160728_janedoe_`whichsheet'.dta, clear

cap drop varnamewillbe 
gen varnamewillbe=.

***the row that has the ID's in it
replace varnamewillbe=0 if _n==1

***the row with primary procedure
**Q2 (Procedure) in the results table at this time will not get separate varwillbe
***Q3 (Procedure Detail)
replace varnamewillbe=302 if _n==2
replace varnamewillbe=301 if _n==3
replace varnamewillbe=304 if _n==4
replace varnamewillbe=303 if _n==5
replace varnamewillbe=305 if _n==6
replace varnamewillbe=306 if _n==7
replace varnamewillbe=311 if _n==8
replace varnamewillbe=307 if _n==9
replace varnamewillbe=312 if _n==10
replace varnamewillbe=308 if _n==11
replace varnamewillbe=313 if _n==12
replace varnamewillbe=309 if _n==13
replace varnamewillbe=314 if _n==14
replace varnamewillbe=310 if _n==15
replace varnamewillbe=316 if _n==16
replace varnamewillbe=315 if _n==17
replace varnamewillbe=318 if _n==18
replace varnamewillbe=317 if _n==19

***ignore rows 20 to 37 having secondary procedure

**4  Question
replace varnamewillbe=401 if _n==38
replace varnamewillbe=402 if _n==39
replace varnamewillbe=403 if _n==40
*** 5 Question
replace varnamewillbe=501 if _n==41
replace varnamewillbe=502 if _n==42
replace varnamewillbe=503 if _n==43
***6 Question
replace varnamewillbe=601 if _n==44
replace varnamewillbe=602 if _n==45
***other listed in  Question #6
replace varnamewillbe=699 if _n==46
***line 47 is a blank line
*** 7 Question
replace varnamewillbe=701 if _n==48
replace varnamewillbe=702 if _n==49
replace varnamewillbe=703 if _n==50
*** 8th
replace varnamewillbe=801 if _n==51
replace varnamewillbe=802 if _n==52
replace varnamewillbe=803 if _n==53
*** 9th
replace varnamewillbe=901 if _n==54
replace varnamewillbe=902 if _n==55
replace varnamewillbe=903 if _n==56
replace varnamewillbe=904 if _n==57
*** 10th
replace varnamewillbe=1001 if _n==58
replace varnamewillbe=1002 if _n==59
replace varnamewillbe=1003 if _n==60
*** 11th
replace varnamewillbe=1101 if _n==61
replace varnamewillbe=1102 if _n==62
replace varnamewillbe=1103 if _n==63

*** 12th
replace varnamewillbe=1201 if _n==64
replace varnamewillbe=1202 if _n==65
replace varnamewillbe=1203 if _n==66

*** 13th
replace varnamewillbe=1301 if _n==67
replace varnamewillbe=1302 if _n==68
replace varnamewillbe=1303 if _n==69

*** 14th
replace varnamewillbe=1401 if _n==70
replace varnamewillbe=1402 if _n==71
replace varnamewillbe=1403 if _n==72

*** 15th
replace varnamewillbe=1501 if _n==73
replace varnamewillbe=1502 if _n==74
replace varnamewillbe=1503 if _n==75

*** 16th
replace varnamewillbe=1601 if _n==76
replace varnamewillbe=1602 if _n==77
replace varnamewillbe=1603 if _n==78

*** 17th
replace varnamewillbe=1701 if _n==79
replace varnamewillbe=1702 if _n==80
replace varnamewillbe=1703 if _n==81

*** 18th
replace varnamewillbe=1801 if _n==82
replace varnamewillbe=1802 if _n==83
replace varnamewillbe=1803 if _n==84
***other listed in  Question #18
replace varnamewillbe=1899 if _n==85

*** 19th
replace varnamewillbe=1901 if _n==86
replace varnamewillbe=1902 if _n==87
replace varnamewillbe=1903 if _n==88

*** 20th
replace varnamewillbe=2001 if _n==89
replace varnamewillbe=2002 if _n==90
replace varnamewillbe=2003 if _n==91
***other listed in Question #20
replace varnamewillbe=2099 if _n==92

*** 21st
replace varnamewillbe=2101 if _n==93
replace varnamewillbe=2102 if _n==94
replace varnamewillbe=2103 if _n==95

*** 22nd
replace varnamewillbe=2201 if _n==96
replace varnamewillbe=2202 if _n==97
replace varnamewillbe=2203 if _n==98
***other listed in  22nd
replace varnamewillbe=2299 if _n==99


***convert the X's to ones, so that they will be preserved in the tranpose
foreach whichvar of varlist _all {

***rename the variable names, so they'll be ready for the merge
**leave columns A and B as is
if "`whichvar'"~="A" & "`whichvar'"~="B" & "`whichvar'"~="varnamewillbe" {
rename `whichvar' `whichsheet'`whichvar'

di "Am working on variable: `whichvar'"
***conditions needed to be met:
***there is an X in that field
***the length of the field is one (only thing there is the X)
replace `whichsheet'`whichvar'="1" if index(`whichsheet'`whichvar', "X")>0 & strlen(trim(`whichsheet'`whichvar'))==1

***with all the X's replaced in the patient's column,
***should be able to destring that field
*if strlen(trim(`whichvar'))>0 in 1 & strlen(trim(`whichvar'))<9 in 1 {
*destring `whichvar', replace
*}

***close the which string var condition
}

***close the whichvar foreach
}


***drop the rows where varnamewillbe is blank
drop if varnamewillbe==.

**save the file
save 20160728_janedoe_`whichsheet'plusvar.dta, replace

} 

***
***
***
***
***
***
***time to merge redorange greygold bluepurple100 yellowgreen100
***merge the four files together

use 20160728_janedoe_redorangeplusvar.dta, clear
foreach whichsheet in greygold bluepurple100 yellowgreen100 {
merge 1:1 varnamewillbe using 20160728_janedoe_`whichsheet'plusvar.dta, gen(add`whichsheet')

**drop the newly created merge variable
drop add`whichsheet'
}


cap drop greygoldrownum
cap drop redorangerownum
save 20160728_janedoe_tog4.dta, replace

***start of changes to file from August 03 version start here
***recategorize the string responses for other reasons of non-compliance so that they will survive the transpose

***#Q5b
***varnamewillbe 699, row 28 of the dataset does not have any responses
***no obs have freehand responses for other for why non-compliance
***do not need to make adjustments at this stage for incoming revampQ5b variable

***#Q7b
***varnamewillbe 1899, row 66 of the dataset does have one response
***1 obs have freehand responses for other for why non-compliance
**one obs. has "cookies", this response will now be under category 6, cookies
replace yellowgreen100AB="6" in 66 if trim(yellowgreen100AB)=="cookies"

***#Q8b
***varnamewillbe 2099, row 73 of the dataset does have two responses
***2 obs have freehand responses for other for why non-compliance
**one obs. has "cake", this response will now be under category 3, cake
replace greygoldH="3" in 73 if trim(greygoldH)=="cake"
**one obs. has "torte", this response will now be under category 3, cake
replace greygoldQ="3" in 73 if trim(greygoldQ)=="torte"

***#Q9b
***varnamewillbe 2299, row 80 of the dataset does have two responses
***2 obs have freehand responses for other for why non-compliance
**one obs. has "pudding", this response will now be under category 3, cake
replace redorangeE="3" in 80 if trim(redorangeE)=="pudding"
**one obs. has "fruit", this response will now be under category 4, fruit
replace redorangeF="4" in 80 if trim(redorangeF)=="fruit"


***
***
***
***
***
***the tabs for the questions with "other" responses all at once
cap log close
log using 20160906placenameotherresponses_log.log, replace

**tabulate the responses for the "other categories"
***convert the X's to ones, so that they will be preserved in the tranpose
foreach whichvar of varlist _all {

foreach whichother in 699 1899 2099 2299 {

*list `whichvar' if varnamewillbe==`whichother' & "`whichvar'"=="A", notrim noheader
capture confirm string var `whichvar'

***check only for string var
if _rc==0 & "`whichvar'"~="A" & "`whichvar'"~="B" & "`whichvar'"~="varnamewillbe" {
*di `whichvar'
list A `whichvar' if varnamewillbe==`whichother' & strlen(trim(`whichvar'))>0, notrim noheader

***close the if condition
}

***close the list of x99 variables condition
}

***attempt the destring
if "`whichvar'"~="A" & "`whichvar'"~="B" & "`whichvar'"~="varnamewillbe" {
quietly destring `whichvar', replace force
}

***close the for all variables condition
}

cap log close


**having tabulated the responses for other,
**will now do transpose
**and string responses will become missing
**transpose the file

***drop the two vars that have the question descriptions
drop A B

xpose, clear promote

save 20160803_janedoe_placenamexpose.dta, replace


***take this file, where the varnamewillbe info is now on row 10 and create the variable names to match the other datasets

***filltheqs section

***this section redacted to obscure the contents of the project

***create the re-categorized non-compliance string response variables

**#Q5b
cap drop revampQ5b
gen revampQ5b=.
***from varnamewillbe 601
***one response with baseball
replace revampQ5b=1 if v26==1

**#Q7b
cap drop revampQ7b
gen revampQ7b=.
***varnamewillbe 1801
***four response with hockey
replace revampQ7b=1 if v63==1
***one response with football
replace revampQ7b=2 if v64==1
***pull over values from Other
replace revampQ7b=v66 if v66~=. & revampQ7b==.

**#Q8b
cap drop revampQ8b
gen revampQ8b=.
***varnamewillbe 2001
***no response with hockey
replace revampQ8b=1 if v70==1
***two response with basketball
replace revampQ8b=2 if v71==1
***pull over values from Other
replace revampQ8b=v73 if v73~=. & revampQ8b==.


**#Q9b
cap drop revampQ9b
gen revampQ9b=.
***varnamewillbe 2201
***no response with hockey
replace revampQ9b=1 if v77==1
***two response with basketball
replace revampQ9b=2 if v78==1
***pull over values from Other
replace revampQ9b=v80 if v80~=. & revampQ9b==.


***location code will for one for placename
gen whichloc=1

***drop the row that has the question numbers in it
drop if v1==0

***count the number of total records for that sheet
count
scalar obstot_1=r(N)

***rename id variable
***convert ptid from number var to string var
gen ptid=string(v1, "%10.0g")

***drop the other variables that aren't going to match with the variable names of the other dataset
drop v1-v80


compress

save 20160803_janedoe_placenameprepped.dta, replace
***this file now ready for merge with other institutions' file