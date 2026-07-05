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

    function genLabelRestoreCode(source_obj, target_obj) {
        var code = "";
        code += "## Restore variable labels\n";
        code += "source_vars <- if('variables' %in% names(" + source_obj + ")) " + source_obj + "$variables else " + source_obj + "\n";
        code += "is_survey_tgt <- 'variables' %in% names(" + target_obj + ")\n";
        code += "target_names <- if(is_survey_tgt) names(" + target_obj + "$variables) else names(" + target_obj + ")\n";
        code += "for(col_name in target_names) {\n";
        code += "  try({\n";
        code += "    if(col_name %in% names(source_vars)) {\n";
        code += "      if(is_survey_tgt) {\n";
        code += "        attr(" + target_obj + "$variables[[col_name]], '.rk.meta') <- attr(source_vars[[col_name]], '.rk.meta')\n";
        code += "      } else {\n";
        code += "        attr(" + target_obj + "[[col_name]], '.rk.meta') <- attr(source_vars[[col_name]], '.rk.meta')\n";
        code += "      }\n";
        code += "    }\n";
        code += "  }, silent=TRUE)\n";
        code += "}\n";
        return code;
    }
  
      var data_obj = getValue("inp_data");
      if (!data_obj) return;

      var raw_cols = getCol("inp_cols");
      var safe_cols = raw_cols.map(function(c) { return "\'" + c + "\'"; });
      var cols_r_code = (safe_cols.length > 0) ? "c(" + safe_cols.join(", ") + ")" : "NULL";

      var drop_levels = getValue("drop_unused_levels") == "TRUE";
      var rem_first   = getValue("remove_first_dummy") == "TRUE" ? "TRUE" : "FALSE";
      var rem_freq    = getValue("remove_most_frequent_dummy") == "TRUE" ? "TRUE" : "FALSE";
      var ign_na      = getValue("ignore_na") == "TRUE" ? "TRUE" : "FALSE";
      var rem_orig    = getValue("remove_selected_columns") == "TRUE" ? "TRUE" : "FALSE";
      
      // Escape single quotes if user typed them in the prefix to safely insert into R single quotes
      var custom_prefix = getValue("custom_prefix");
      if (custom_prefix) {
          custom_prefix = custom_prefix.replace(/\'/g, "\\\'");
      } else {
          custom_prefix = "";
      }

      
      // PREVIEW MODE
      echo("require(fastDummies)\n");
      echo("local_obj <- " + data_obj + "\n");
      echo("is_survey <- 'variables' %in% names(local_obj)\n");
      echo("working_df <- if(is_survey) head(local_obj$variables, 50) else head(local_obj, 50)\n");
      
      if (drop_levels) {
          echo("working_df <- droplevels(working_df)\n");
      }
      
      echo("orig_cols <- names(working_df)\n");
      echo("preview_data <- fastDummies::dummy_cols(.data = working_df, select_columns = " + cols_r_code + ", remove_first_dummy = " + rem_first + ", remove_most_frequent_dummy = " + rem_freq + ", ignore_na = " + ign_na + ", remove_selected_columns = " + rem_orig + ")\n");
      
      if (custom_prefix !== "") {
          echo("new_cols <- setdiff(names(preview_data), orig_cols)\n");
          echo("names(preview_data)[names(preview_data) %in% new_cols] <- paste0('" + custom_prefix + "', new_cols)\n");
      }
      
    
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

    function genLabelRestoreCode(source_obj, target_obj) {
        var code = "";
        code += "## Restore variable labels\n";
        code += "source_vars <- if('variables' %in% names(" + source_obj + ")) " + source_obj + "$variables else " + source_obj + "\n";
        code += "is_survey_tgt <- 'variables' %in% names(" + target_obj + ")\n";
        code += "target_names <- if(is_survey_tgt) names(" + target_obj + "$variables) else names(" + target_obj + ")\n";
        code += "for(col_name in target_names) {\n";
        code += "  try({\n";
        code += "    if(col_name %in% names(source_vars)) {\n";
        code += "      if(is_survey_tgt) {\n";
        code += "        attr(" + target_obj + "$variables[[col_name]], '.rk.meta') <- attr(source_vars[[col_name]], '.rk.meta')\n";
        code += "      } else {\n";
        code += "        attr(" + target_obj + "[[col_name]], '.rk.meta') <- attr(source_vars[[col_name]], '.rk.meta')\n";
        code += "      }\n";
        code += "    }\n";
        code += "  }, silent=TRUE)\n";
        code += "}\n";
        return code;
    }
  
      var data_obj = getValue("inp_data");
      if (!data_obj) return;

      var raw_cols = getCol("inp_cols");
      var safe_cols = raw_cols.map(function(c) { return "\'" + c + "\'"; });
      var cols_r_code = (safe_cols.length > 0) ? "c(" + safe_cols.join(", ") + ")" : "NULL";

      var drop_levels = getValue("drop_unused_levels") == "TRUE";
      var rem_first   = getValue("remove_first_dummy") == "TRUE" ? "TRUE" : "FALSE";
      var rem_freq    = getValue("remove_most_frequent_dummy") == "TRUE" ? "TRUE" : "FALSE";
      var ign_na      = getValue("ignore_na") == "TRUE" ? "TRUE" : "FALSE";
      var rem_orig    = getValue("remove_selected_columns") == "TRUE" ? "TRUE" : "FALSE";
      
      // Escape single quotes if user typed them in the prefix to safely insert into R single quotes
      var custom_prefix = getValue("custom_prefix");
      if (custom_prefix) {
          custom_prefix = custom_prefix.replace(/\'/g, "\\\'");
      } else {
          custom_prefix = "";
      }

      
      // MAIN MODE
      echo("require(fastDummies)\n");
      echo("local_obj <- " + data_obj + "\n");
      echo("is_survey <- 'variables' %in% names(local_obj)\n");
      echo("working_df <- if(is_survey) local_obj$variables else local_obj\n");

      if (drop_levels) {
          echo("working_df <- droplevels(working_df)\n");
      }
      
      echo("orig_cols <- names(working_df)\n");
      echo("working_df <- fastDummies::dummy_cols(.data = working_df, select_columns = " + cols_r_code + ", remove_first_dummy = " + rem_first + ", remove_most_frequent_dummy = " + rem_freq + ", ignore_na = " + ign_na + ", remove_selected_columns = " + rem_orig + ")\n");

      if (custom_prefix !== "") {
          echo("new_cols <- setdiff(names(working_df), orig_cols)\n");
          echo("names(working_df)[names(working_df) %in% new_cols] <- paste0('" + custom_prefix + "', new_cols)\n");
      }

      echo("if (is_survey) {\n");
      echo("  dummy_results <- local_obj\n");
      echo("  dummy_results$variables <- working_df\n");
      echo("} else {\n");
      echo("  dummy_results <- working_df\n");
      echo("}\n");

      echo(genLabelRestoreCode("local_obj", "dummy_results"));
      
    
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Create Dummy Variables results")).print();	
	}
    if(getValue("save_dummy_obj.active")) {
      var save_name = getValue("save_dummy_obj").replace(/"/g, "\\\"");
      
      var custom_prefix = getValue("custom_prefix");
      if (custom_prefix) {
          custom_prefix = custom_prefix.replace(/"/g, "\\\"");
      } else {
          custom_prefix = "";
      }
      
      echo("rk.header(\"Dummy Variables Created: " + save_name + "\", level=3, parameters=list(\n");
      echo("  \"Input Object\" = \"" + getValue("inp_data") + "\",\n");
      echo("  \"Drop unused levels\" = \"" + getValue("drop_unused_levels") + "\",\n");
      echo("  \"Remove first dummy\" = \"" + getValue("remove_first_dummy") + "\",\n");
      echo("  \"Remove original columns\" = \"" + getValue("remove_selected_columns") + "\",\n");
      echo("  \"Custom Prefix\" = \"" + custom_prefix + "\"\n");
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

