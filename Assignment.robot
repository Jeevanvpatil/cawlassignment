*** Settings ***		## SETTING UP OF REQUIRED LIBRARIES 
Library		Selenium2Library
Library		Collections
Library		ExcellentLibrary



*** Variables ***
${jsondata}		[{ "name": "Bob", "age": 20, "gender": "male" }, { "name": "George", "age": 42, "gender": "male" }, { "name": "Sandra", "age": 43, "gender": "female" }, { "name": "Barbara", "age": 21, "gender": "female" }, { "name": "Tom", "age": 45, "gender": "male" }, { "name": "Phil", "age": 49, "gender": "male" }]
@{actual_result}				## CREATING EMPTY LIST VARIABLE
${result}						## CREATING EMPTY SCALAR VARIABLE 




*** Keywords ***
Update Table Data		## OPENS BROWSER AND INPUTS THE DATA IN TEXT FIELD
	Open Browser		https://testpages.herokuapp.com/styled/tag/dynamic-table.html		chrome
	Click Element		//summary
	Input Text		jsondata		${jsondata}
	Click Element		refreshtable



Get Table Data			## GET THE TABLE DATA - HANDLED FOR N NUMBER OF ROWS
	${rowCount}		Get Element Count		//table[@id='dynamictable']//tr
	
	FOR		${i}		IN RANGE		2		${rowCount}+1
		${name}		Get text		//table[@id='dynamictable']//tr[${i}]/td[1]
		${age}		Get text		//table[@id='dynamictable']//tr[${i}]/td[2]
		${gender}		Get text		//table[@id='dynamictable']//tr[${i}]/td[3]
		${temp_result}		Create Dictionary		name=${name}		age=${age}		gender=${gender}		##CREATES A TEMP DICTIONARY
		Append to list			${actual_result}		${temp_result}
	END
	Set Global Variable		${actual_result}	## CREATING AS GLOBAL VARIABLE TO ACCESS OUTSIDE OF KEYWORD
	
	
	
	
Validate the Result			##VALIDATES THE ACTUAL RESULT WITH EXPECTED RESULT
	${Expected_Result}		Evaluate 			json.loads($jsondata)			##CONVERTS THE STRING TO JSON FORMAT
	
	Log		${Expected_Result}		WARN
	Log		${actual_result}		WARN
	
	Create workbook		${CURDIR}//result.xlsx		overwrite_if_exist=True
	
	Write to cell		A1		Name
	Write to cell		C1		Expected Age
	Write to cell		D1		Actual Age
	Write to cell		E1		Result
	
	Write to cell		G1		Expected Gender
	Write to cell		H1		Actual Gender
	Write to cell		I1		Result
	
	${row_count}		Set Variable		${2}
	FOR		${e_dict}		IN 		@{Expected_Result}
		FOR		${a_dict}		IN 		@{actual_result}
			continue for loop if 		"${e_dict['name']}"!="${a_dict['name']}"
			
			Write to cell		A${row_count}		${e_dict['name']}
			Write to cell		C${row_count}		${e_dict['age']}
			Write to cell		D${row_count}		${a_dict['age']}
			IF		"${a_dict['age']}"=="${e_dict['age']}"
				Write to cell		E${row_count}		PASS
			ELSE
				Write to cell		E${row_count}		FAIL
			END
			
			Write to cell		G${row_count}		${e_dict['gender']}
			Write to cell		H${row_count}		${a_dict['gender']}
			IF		"${a_dict['gender']}"=="${e_dict['gender']}"
				Write to cell		I${row_count}		PASS
			ELSE
				Write to cell		I${row_count}		FAIL
			END
			${row_count}		Evaluate		${row_count}+1
			Save		
		END
	END
	Log		${result}		WARN			##PRINTING RESULTS


### --EXECUTION STARTS HERE--
*** Test Cases ***
Test
	Update Table Data
	Get Table Data
	Validate the Result