***prep the table

**this do-file gets run after 20160803_prep_spreadsheet.do
**it takes the data comes out of the frequencies and puts them into table form, resembling the Table 2 she sent me

***add blank rows to get spacing of table correct to table layout
***1 between most rows
***2 between #5b and #6
***2 between #3 and #4
cap program drop addblankrow
program define addblankrow

local addafterrow=1

count
scalar countofobs=r(N)
local newcount=countofobs+1
di "Newcount is `newcount'"
set obs `newcount'
replace questionrow=``addafterrow'' if value==""
***the current existing max was 19
***18 detailed procedures
***1 extra row
**now this one will be 20
replace rowwithinquestion=20 if value==""
***slide into the placename column
replace colwithinquestion=1 if value==""
replace value="Intentionally Blank" if value==""
end


***this program adds specific row names so that the data listing will look more like Dr. janedoe's table
cap prog drop assignfancyrownames
prog define assignfancyrownames
local whichtype=1
local whichrow=2

while "``whichrow''"~="" {

**do not have "died before discharge" as a response
if ``whichtype''==1 {
replace fancyname="reading" if rowwithinquestion==1 & questionrow==``whichrow''
replace fancyname="Non-reading" if rowwithinquestion==2 & questionrow==``whichrow''
}

**do yes have "died before discharge" as a response
if ``whichtype''==2 {
replace fancyname="reading" if rowwithinquestion==1 & questionrow==``whichrow''
replace fancyname="Other outcome" if rowwithinquestion==2 & questionrow==``whichrow''
replace fancyname="Non-reading" if rowwithinquestion==3 & questionrow==``whichrow''
}

local whichrow=`whichrow'+1

***close loop for whichrow variables
}

end


***the program takes the variables that do not use common labels and assigns them to the rows
cap prog drop assignspecificlabels
prog define assignspecificlabels

local whichrow=1
local whichsubrow=1
local whichsublabel=2

while "``whichsublabel''"~="" {
di _newline(2) "Subrow is `whichsubrow', Sublabel is ``whichsublabel''"
replace fancyname="``whichsublabel''" if rowwithinquestion==`whichsubrow' & questionrow==``whichrow''

local whichsubrow=`whichsubrow'+1
local whichsublabel=`whichsublabel'+1

***close loop for whichrow variables
}

end


***insheet the listing of scalars
import delimited using 20160906_scalar_log.txt, delim("=") clear

rename v1 celllbl
rename v2 value

***drop the unneeded rows
***chi-square values
drop if index(celllbl, "chisq")>0
***denominators for cell counts
drop if index(celllbl, "denom")>0
***total for whole frequency
drop if index(celllbl, "totmat")>0
***numerators for cell counts
drop if index(celllbl, "cnt")>0
***percentages for cell counts
drop if index(celllbl, "pct")>0
**total records for that sheet
*drop if index(celllbl, "obstot")>0
**drop p-val for Q's other than Q2 and Q3

***computer was not able to calculate Fisher's exact, even after using 200x memory
***chi-square p-value was .000, so Fisher's exact should be below .01 (my guess)
***after revisions to table (from my error), Q7 also has enough obs to use chi-sq rather than Fisher's
drop if index(celllbl, "pval")>0 & index(celllbl, "Q2")==0  & index(celllbl, "Q3")==0 & index(celllbl, "Q7")==0 
drop if index(celllbl, "pval")>0 & index(celllbl, "Q7b")>0
**drop Fisher's exact for Q2 and Q3
**drop Fisher's exact for Q7
drop if index(celllbl, "fish")>0 & index(celllbl, "Q2")>0
drop if index(celllbl, "fish")>0 & index(celllbl, "Q3")>0
drop if index(celllbl, "fish")>0 & index(celllbl, "Q7")>0 & index(celllbl, "Q7b")==0

***get rid of the row that lists the command
drop if index(celllbl, ". scalar list _all")>0
**get rid of the header
drop if index(celllbl, ". log using")>0
drop if index(celllbl, "name: ")>0
drop if index(celllbl, "log: ")>0
drop if index(celllbl, "log type: ")>0
drop if index(celllbl, "opened on: ")>0
drop if index(celllbl, "----")>0
drop if index(celllbl, ". cap log close")>0
drop if index(celllbl, "_scalar_log.txt")>0
***get rid of blank lines
drop if length(trim(celllbl))==0
***remove two patients from the count of patients for adams
***institution #3
***two from the obstot_3 value
replace value=strofreal(real(value)-2) if trim(celllbl)=="obstot_3"

***get the row values
cap drop questionrow
gen questionrow=.

**the total for whole frequency is row 1
*replace questionrow=1 if index(celllbl, "obstot")>0

***starts from row 1 for Q1 about number of patients
local counter=1
foreach whichrow in obstot Q2 Q3 Q4 Q5 Q5b Q6a Q6b Q6bi Q6c Q6d Q6e Q6f Q6g Q6h Q6i Q7 Q7b Q8 Q8b Q9 Q9b {
replace questionrow=`counter' if index(celllbl, "`whichrow'")>0
local counter=`counter'+1
}

cap drop rowwithinquestion
gen rowwithinquestion=.
**the max number of rows is for Question 3 (detailed procedure name) which has 18 rows
forvalues whichnum=1/18 {
replace rowwithinquestion=`whichnum' if index(celllbl, "_r`whichnum'")>0
}

**the p-value variables
replace rowwithinquestion=1 if index(celllbl, "fish")>0
replace rowwithinquestion=1 if index(celllbl, "pval")>0
replace rowwithinquestion=1 if index(celllbl, "obstot_")>0


cap drop colwithinquestion
gen colwithinquestion=.
forvalues whichnum=1/4 {
replace colwithinquestion=`whichnum' if index(celllbl, "_c`whichnum'")>0
replace colwithinquestion=`whichnum' if index(celllbl, "obstot_`whichnum'")>0
}

**the p-value variables
replace colwithinquestion=5 if index(celllbl, "fish")>0
replace colwithinquestion=5 if index(celllbl, "pval")>0

***replace the values for variables that did not have any observations 
replace value="None" if index(value, "(.%)")>0

***one of the p-values is a dot (period), since there is only one category for that variable that has values
replace value="Not applicable" if trim(value)=="." & colwithinquestion==5

***count at this step is 329

***add the extra observations for question #3
***it is 4 obs, because there are currently 4 institutions in the dataset
***count of obs will rise from 329 to 332
set obs 332
replace questionrow=3 if value==""
**slide the other observations into higher rowwithinquestion values
replace rowwithinquestion=rowwithinquestion+1 if rowwithinquestion>12 & value~="" & questionrow==3
**insert row for [redacted text] row of table (row 13)
replace rowwithinquestion=13 if value=="" & questionrow==3
**add column values
replace colwithinquestion=1 if questionrow==3 & value=="" & rowwithinquestion==13
replace colwithinquestion=colwithinquestion[_n-1]+1 if questionrow==3 & value=="" & rowwithinquestion==13 & rowwithinquestion[_n-1]==13
**add that row that will say none
replace value="None" if questionrow==3 & trim(value)=="" & rowwithinquestion==13


***add the extra observations for question #6bi
***it is 4 obs, because there are currently 3 institutions in the dataset
***count of obs will rise from 332 to 336
set obs 336
replace questionrow=9 if value==""
**slide the other observations into higher rowwithinquestion values
replace rowwithinquestion=rowwithinquestion+1 if rowwithinquestion>1 & value~="" & questionrow==9
**insert row for [redacted text]  row of table
replace rowwithinquestion=2 if value=="" & questionrow==9
**add column values
replace colwithinquestion=1 if questionrow==9 & value=="" & rowwithinquestion==2
replace colwithinquestion=colwithinquestion[_n-1]+1 if questionrow==9 & value=="" & rowwithinquestion==2 & rowwithinquestion[_n-1]==2
**add that row that will say none
replace value="None" if questionrow==9 & value=="" & rowwithinquestion==2
 
***add blank rows to get spacing of table correct to table layout
***1 between most rows

***add one row each between the existing rows
***current count is 336
***22 questions, 22 minus 1 = 21 buffers
***336+21=357
set obs 357
replace questionrow=1 if value==""
***add sequentially from the prior row that's part of the group
replace questionrow=questionrow[_n-1]+1 if value=="" & value[_n-1]==""
***make this row within question the last one of a set
**the max number of rows is currently 18 (from question 3 Q3), so will make this value 19
replace rowwithinquestion=19 if value==""
***place holder for the column
***slide into the placename column
replace colwithinquestion=1 if value==""
replace value="Intentionally Blank" if value==""


***2 between #5b and #6
***2 between #3 and #4

**between #3 and #4
addblankrow 3
**between #5b and #6
addblankrow 6



 
***sort the data by question row and then row within question
sort questionrow rowwithinquestion colwithinquestion

list if  questionrow==questionrow[_n-1] &  rowwithinquestion==rowwithinquestion[_n-1] & colwithinquestion==colwithinquestion[_n-1]

***reshape wide
drop celllbl
reshape wide value, i(questionrow rowwithinquestion) j(colwithinquestion)


***add labels for Question row**
cap label drop  questionrowlbl
***[redacted text] 
label values questionrow questionrowlbl

***create a more readable version of the row names
cap drop fancyname
decode questionrow, gen(fancyname)

**have reading and non-reading as rows
*assignfancyrownames 1 3 4 16 18 20

**have reading and non-reading as rows plus Other outcome
*assignfancyrownames 2 6 7 9 10 11 12 13 14 15

***no longer have Other outcome as a row, aggregate the two sets together
***leads off with the one, as having reading and non-reading as rows
assignfancyrownames 1 4 5 7 8 10 11 12 13 14 15 16 17 19 21

**question 2--the various procedures (4 categories)
assignspecificlabels 2 "yellowgreen" "bluepurple" "brownblack" "redorange"

**question 3--the detailed names of the various procedures (18 names)
# delimit ;
*[redacted text] ;

# delimit cr

***[redacted text] 
# delimit ;
**question 5b;
***this set revamped after adding the "other" observations;

***[redacted text] ;

**question 6bi;
***[redacted text] ;

**question 7b;
***this set revamped after adding the "other" observations;


***[redacted text] ;

**question 8b;
***this set revamped after adding the "other" observations;


***[redacted text] ;

**question 9b;
***this set revamped after adding the "other" observations;

***[redacted text] ;

# delimit cr

cap log close
log using 20160906results_log.log, replace

**don't need to show which question within row, as it doesn't have a label yet
**remove obs number to save space
**remove header, as my varnames are not really specific to the names she uses
**force table format, to squeeze vertically
**draw separator line when question number changes, to increase readability
list questionrow fancyname value*, noobs noheader compress table sepby(questionrow)

cap log close

**add variable labels
label var questionrow "Category Header"
label var fancyname "Category Details"
label var value1 "Column placename"
label var value2 "Column wash"
label var value3 "Column adams"
label var value4 "Column jeff"
label var value5 "Column p-value"

***drop the rows for the detailed procedure descriptions, as she doesn't need them for the table
***those lines plus the two blank lines at the end appear in rows 8 through 27
drop in 8/27

**export the file into Excel

export excel questionrow fancyname value* using 20160906_table2contents.xls,  firstrow(varlabels) replace
