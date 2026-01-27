// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	preprocess(true);
	calculate(true);
	printout(true);
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(fastDummies)){stop(" + i18n("Preview not available, because package fastDummies is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(fastDummies)\n");
	}	if(is_preview) {
		echo("if(!base::require(survey)){stop(" + i18n("Preview not available, because package survey is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(survey)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            var match = lastPart.match(/\[\[\"(.*?)\"\]\]/);
            if (match) { return match[1]; }
        }
        if (fullName.indexOf("$") > -1) { return fullName.substring(fullName.lastIndexOf("$") + 1); }
        else { return fullName; }
    }
  
    // 1. Gather Inputs
    var data_obj = getValue("inp_data");

    // Process selected columns
    var raw_cols = getValue("inp_cols").split("\n");
    var safe_cols = [];

    for (var i = 0; i < raw_cols.length; i++) {
        var clean = getColumnName(raw_cols[i]);
        if (clean !== "") {
            safe_cols.push("\"" + clean + "\"");
        }
    }
    var cols_r_code = (safe_cols.length > 0) ? "c(" + safe_cols.join(", ") + ")" : "NULL";

    // Options
    var rem_first = getValue("remove_first_dummy") == "TRUE" ? "TRUE" : "FALSE";
    var rem_freq  = getValue("remove_most_frequent_dummy") == "TRUE" ? "TRUE" : "FALSE";
    var ign_na    = getValue("ignore_na") == "TRUE" ? "TRUE" : "FALSE";
    var rem_orig  = getValue("remove_selected_columns") == "TRUE" ? "TRUE" : "FALSE";

    // 2. Logic Generation
    echo("local_obj <- " + data_obj + "\n");

    // Detect Survey Objects
    echo("is_survey_obj <- inherits(local_obj, c(\"survey.design\", \"svyrep.design\", \"tbl_svy\"))\n");

    echo("if (is_survey_obj) {\n");
    echo("  working_df <- local_obj$variables\n");
    echo("} else {\n");
    echo("  working_df <- local_obj\n");
    echo("}\n");

    // Perform fastDummies operation
    echo("working_df <- fastDummies::dummy_cols(\n");
    echo("  .data = working_df,\n");
    echo("  select_columns = " + cols_r_code + ",\n");
    echo("  remove_first_dummy = " + rem_first + ",\n");
    echo("  remove_most_frequent_dummy = " + rem_freq + ",\n");
    echo("  ignore_na = " + ign_na + ",\n");
    echo("  remove_selected_columns = " + rem_orig + "\n");
    echo(")\n");

    // Reconstruct Object
    echo("if (is_survey_obj) {\n");
    echo("  final_result <- local_obj\n");
    echo("  final_result$variables <- working_df\n");
    echo("} else {\n");
    echo("  final_result <- working_df\n");
    echo("}\n");

    // 3. Assign to Output
    if (!is_preview) {
        echo("dummy_results <- final_result\n");
    }
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Create Dummy Variables results")).print();	
	}
    if (is_preview) {
        echo("require(fastDummies)\n");
        echo("require(survey)\n");
        echo("if(inherits(final_result, \"survey.design\")) {\n");
        echo("  rk.print(head(final_result$variables, 20))\n");
        echo("} else {\n");
        echo("  rk.print(head(final_result, 20))\n");
        echo("}\n");
    } else {
        echo("rk.header(\"Dummy Variables Created\", parameters=list(\n");
        echo("  \"Input Object\" = \"" + getValue("inp_data") + "\",\n");
        echo("  \"Saved to\" = \"" + getValue("save_dummy_obj") + "\",\n");
        echo("  \"Remove first dummy\" = \"" + getValue("remove_first_dummy") + "\",\n");
        echo("  \"Remove original columns\" = \"" + getValue("remove_selected_columns") + "\"\n");
        echo("))\n");
    }
  
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var saveDummyObj = getValue("save_dummy_obj");
		var saveDummyObjActive = getValue("save_dummy_obj.active");
		var saveDummyObjParent = getValue("save_dummy_obj.parent");
		// assign object to chosen environment
		if(saveDummyObjActive) {
			echo(".GlobalEnv$" + saveDummyObj + " <- dummy_results\n");
		}	
	}

}

