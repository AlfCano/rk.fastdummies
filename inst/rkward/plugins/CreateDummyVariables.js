// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return [];
        return raw.split("\n").filter(function(n){ return n != "" }).map(function(item) {
            if (item.indexOf("[[") > -1) {
                var parts = item.split('[["');
                var last = parts[parts.length - 1];
                return last.split('"]]')[0];
            } else if (item.indexOf("$") > -1) {
                return item.substring(item.lastIndexOf("$") + 1);
            }
            return item;
        });
    }
  
      var data_obj = getValue("inp_data");
      if (!data_obj) return;

      var raw_cols = getCol("inp_cols");
      var safe_cols = raw_cols.map(function(c) { return "\'" + c + "\'"; });
      var cols_r_code = (safe_cols.length > 0) ? "c(" + safe_cols.join(", ") + ")" : "NULL";

      var rem_first = getValue("remove_first_dummy") == "TRUE" ? "TRUE" : "FALSE";
      var rem_freq  = getValue("remove_most_frequent_dummy") == "TRUE" ? "TRUE" : "FALSE";
      var ign_na    = getValue("ignore_na") == "TRUE" ? "TRUE" : "FALSE";
      var rem_orig  = getValue("remove_selected_columns") == "TRUE" ? "TRUE" : "FALSE";
      var do_janit  = getValue("chk_janitor") == "TRUE";

      echo("require(fastDummies)\n");
      if (do_janit) echo("require(janitor)\n");
      echo("\n");

      
      // PREVIEW MODE
      echo("local_obj <- " + data_obj + "\n");
      echo("is_survey <- 'variables' %in% names(local_obj)\n");
      echo("prev_df <- if(is_survey) head(local_obj$variables, 50) else head(local_obj, 50)\n");
      echo("preview_data <- fastDummies::dummy_cols(.data = prev_df, select_columns = " + cols_r_code + ", remove_first_dummy = " + rem_first + ", remove_most_frequent_dummy = " + rem_freq + ", ignore_na = " + ign_na + ", remove_selected_columns = " + rem_orig + ")\n");
      if (do_janit) echo("preview_data <- janitor::clean_names(preview_data)\n");
      
    
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(fastDummies)){stop(" + i18n("Preview not available, because package fastDummies is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(fastDummies)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return [];
        return raw.split("\n").filter(function(n){ return n != "" }).map(function(item) {
            if (item.indexOf("[[") > -1) {
                var parts = item.split('[["');
                var last = parts[parts.length - 1];
                return last.split('"]]')[0];
            } else if (item.indexOf("$") > -1) {
                return item.substring(item.lastIndexOf("$") + 1);
            }
            return item;
        });
    }
  
      var data_obj = getValue("inp_data");
      if (!data_obj) return;

      var raw_cols = getCol("inp_cols");
      var safe_cols = raw_cols.map(function(c) { return "\'" + c + "\'"; });
      var cols_r_code = (safe_cols.length > 0) ? "c(" + safe_cols.join(", ") + ")" : "NULL";

      var rem_first = getValue("remove_first_dummy") == "TRUE" ? "TRUE" : "FALSE";
      var rem_freq  = getValue("remove_most_frequent_dummy") == "TRUE" ? "TRUE" : "FALSE";
      var ign_na    = getValue("ignore_na") == "TRUE" ? "TRUE" : "FALSE";
      var rem_orig  = getValue("remove_selected_columns") == "TRUE" ? "TRUE" : "FALSE";
      var do_janit  = getValue("chk_janitor") == "TRUE";

      echo("require(fastDummies)\n");
      if (do_janit) echo("require(janitor)\n");
      echo("\n");

      
      // MAIN MODE
      echo("local_obj <- " + data_obj + "\n");
      echo("is_survey <- 'variables' %in% names(local_obj)\n");
      echo("working_df <- if(is_survey) local_obj$variables else local_obj\n");
      echo("source_vars <- working_df\n");
      echo("old_cols <- names(working_df)\n\n");

      echo("working_df <- fastDummies::dummy_cols(.data = working_df, select_columns = " + cols_r_code + ", remove_first_dummy = " + rem_first + ", remove_most_frequent_dummy = " + rem_freq + ", ignore_na = " + ign_na + ", remove_selected_columns = " + rem_orig + ")\n\n");

      echo("new_cols <- setdiff(names(working_df), old_cols)\n\n");

      echo("# 1. Preserve original labels and assign factor values to new dummy labels\n");
      echo("if (exists('rk.set.label')) {\n");
      echo("  # Restore labels for original columns that might have lost metadata\n");
      echo("  for(col_name in old_cols) {\n");
      echo("    if(col_name %in% names(working_df)) {\n");
      echo("      attr(working_df[[col_name]], '.rk.meta') <- attr(source_vars[[col_name]], '.rk.meta')\n");
      echo("    }\n");
      echo("  }\n");
      echo("  # Set the uncleaned factor level as the label for new dummy columns\n");
      echo("  for(nc in new_cols) {\n");
      echo("    rk.set.label(working_df[[nc]], nc)\n");
      echo("  }\n");
      echo("}\n\n");

      if (do_janit) {
          echo("# 2. Clean column names (snake_case)\n");
          echo("# The readable factor levels remain safely stored in the labels!\n");
          echo("working_df <- janitor::clean_names(working_df)\n\n");
      }

      echo("if (is_survey) {\n");
      echo("  dummy_results <- local_obj\n");
      echo("  dummy_results$variables <- working_df\n");
      echo("} else {\n");
      echo("  dummy_results <- working_df\n");
      echo("}\n");
      
    
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Create Dummy Variables results")).print();	
	}
    if(getValue("save_dummy_obj.active")) {
      var save_name = getValue("save_dummy_obj").replace(/"/g, "\\\"");

      // SOLUCIÓN: Escapamos las comillas dobles que vienen del nombre del objeto
      var inp_data_safe = getValue("inp_data").replace(/"/g, "\\\"");

      echo("rk.header(\"Dummy Variables Created: " + save_name + "\", level=3, parameters=list(\n");
      echo("  \"Input Object\" = \"" + inp_data_safe + "\",\n");
      echo("  \"Remove first dummy\" = \"" + getValue("remove_first_dummy") + "\",\n");
      echo("  \"Clean names with janitor\" = \"" + getValue("chk_janitor") + "\",\n");
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

