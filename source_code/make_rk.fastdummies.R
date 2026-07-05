local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  plugin_name <- "rk.fastdummies"
  plugin_ver <- "0.0.2"

  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin to create dummy variables (one-hot encoding) from survey or dataframe objects using the 'fastDummies' package.",
      version = plugin_ver,
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/AlfCano/rk.fastdummies",
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # 2. JS Helpers (Robust Parsing & Metadata)
  # =========================================================================================
  js_helpers <- '
    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return [];
        return raw.split("\\n").filter(function(n){ return n != "" }).map(function(item) {
            if (item.indexOf("[[") > -1) {
                var parts = item.split(\'[[\"\');
                var last = parts[parts.length - 1];
                return last.split(\'"]]\')[0];
            } else if (item.indexOf("$") > -1) {
                return item.substring(item.lastIndexOf("$") + 1);
            }
            return item;
        });
    }

    function genLabelRestoreCode(source_obj, target_obj) {
        var code = "";
        code += "## Restore variable labels\\n";
        code += "source_vars <- if(\'variables\' %in% names(" + source_obj + ")) " + source_obj + "$variables else " + source_obj + "\\n";
        code += "is_survey_tgt <- \'variables\' %in% names(" + target_obj + ")\\n";
        code += "target_names <- if(is_survey_tgt) names(" + target_obj + "$variables) else names(" + target_obj + ")\\n";
        code += "for(col_name in target_names) {\\n";
        code += "  try({\\n";
        code += "    if(col_name %in% names(source_vars)) {\\n";
        code += "      if(is_survey_tgt) {\\n";
        code += "        attr(" + target_obj + "$variables[[col_name]], \'.rk.meta\') <- attr(source_vars[[col_name]], \'.rk.meta\')\\n";
        code += "      } else {\\n";
        code += "        attr(" + target_obj + "[[col_name]], \'.rk.meta\') <- attr(source_vars[[col_name]], \'.rk.meta\')\\n";
        code += "      }\\n";
        code += "    }\\n";
        code += "  }, silent=TRUE)\\n";
        code += "}\\n";
        return code;
    }
  '

  # =========================================================================================
  # 3. UI Resources
  # =========================================================================================

  # --- Tab 1: Variables ---
  var_selector <- rk.XML.varselector(id.name = "v_selector")

  inp_data <- rk.XML.varslot(
    label = "Input Data (Data Frame or Survey Object)",
    source = "v_selector",
    required = TRUE,
    id.name = "inp_data",
    classes = c("data.frame", "survey.design", "tbl_svy", "svyrep.design")
  )

  inp_cols <- rk.XML.varslot(
    label = "Columns to expand (Leave empty to expand all factor/char columns)",
    source = "v_selector",
    multi = TRUE,
    id.name = "inp_cols"
  )

  # --- Tab 2: Settings ---
  chk_remove_first <- rk.XML.cbox(label = "Remove first dummy variable (Avoids collinearity)", id.name = "remove_first_dummy", value = "TRUE", chk = FALSE)
  chk_remove_freq <- rk.XML.cbox(label = "Remove most frequent dummy variable", id.name = "remove_most_frequent_dummy", value = "TRUE", chk = FALSE)
  chk_ignore_na <- rk.XML.cbox(label = "Ignore NA values (Do not create dummy for NA)", id.name = "ignore_na", value = "TRUE", chk = FALSE)
  chk_remove_selected <- rk.XML.cbox(label = "Remove original columns after creating dummies", id.name = "remove_selected_columns", value = "TRUE", chk = FALSE)

  # --- Tab 3: Output ---
  save_results <- rk.XML.saveobj(label = "Save Results to R Object", initial = "dummy_results", id.name = "save_dummy_obj", chk = TRUE)
  preview_btn <- rk.XML.preview(label="Preview data", id.name="preview_btn", mode = "data")
  preview_note <- rk.XML.text("<i>Note: Preview limited to 50 rows for performance.</i>")

  # =========================================================================================
  # 4. Main Dialog Assembly
  # =========================================================================================

  main_dialog <- rk.XML.dialog(
    label = "Create Dummy Variables (fastDummies)",
    child = rk.XML.row(
      var_selector,
      rk.XML.col(
        rk.XML.tabbook(tabs = list(
          "Variables" = rk.XML.col(inp_data, inp_cols, rk.XML.stretch()),
          "Settings"  = rk.XML.col(
            rk.XML.frame(label = "Dummy Creation Rules", chk_remove_first, chk_remove_freq, chk_ignore_na),
            rk.XML.frame(label = "Data Cleaning", chk_remove_selected),
            rk.XML.stretch()
          ),
          "Output"    = rk.XML.col(rk.XML.stretch(), preview_btn, preview_note, save_results)
        ))
      )
    )
  )

  # =========================================================================================
  # 5. JavaScript Logic Generation
  # =========================================================================================

  js_gen_dummy <- function(is_preview) {
    paste0(js_helpers, '
      var data_obj = getValue("inp_data");
      if (!data_obj) return;

      var raw_cols = getCol("inp_cols");
      var safe_cols = raw_cols.map(function(c) { return "\\\'" + c + "\\\'"; });
      var cols_r_code = (safe_cols.length > 0) ? "c(" + safe_cols.join(", ") + ")" : "NULL";

      var rem_first = getValue("remove_first_dummy") == "TRUE" ? "TRUE" : "FALSE";
      var rem_freq  = getValue("remove_most_frequent_dummy") == "TRUE" ? "TRUE" : "FALSE";
      var ign_na    = getValue("ignore_na") == "TRUE" ? "TRUE" : "FALSE";
      var rem_orig  = getValue("remove_selected_columns") == "TRUE" ? "TRUE" : "FALSE";

      ', if(is_preview) { '
      // PREVIEW MODE
      echo("require(fastDummies)\\n");
      echo("local_obj <- " + data_obj + "\\n");
      echo("is_survey <- \'variables\' %in% names(local_obj)\\n");
      echo("prev_df <- if(is_survey) head(local_obj$variables, 50) else head(local_obj, 50)\\n");
      echo("preview_data <- fastDummies::dummy_cols(.data = prev_df, select_columns = " + cols_r_code + ", remove_first_dummy = " + rem_first + ", remove_most_frequent_dummy = " + rem_freq + ", ignore_na = " + ign_na + ", remove_selected_columns = " + rem_orig + ")\\n");
      ' } else { '
      // MAIN MODE
      echo("require(fastDummies)\\n");
      echo("local_obj <- " + data_obj + "\\n");
      echo("is_survey <- \'variables\' %in% names(local_obj)\\n");
      echo("working_df <- if(is_survey) local_obj$variables else local_obj\\n");

      echo("working_df <- fastDummies::dummy_cols(.data = working_df, select_columns = " + cols_r_code + ", remove_first_dummy = " + rem_first + ", remove_most_frequent_dummy = " + rem_freq + ", ignore_na = " + ign_na + ", remove_selected_columns = " + rem_orig + ")\\n");

      echo("if (is_survey) {\\n");
      echo("  dummy_results <- local_obj\\n");
      echo("  dummy_results$variables <- working_df\\n");
      echo("} else {\\n");
      echo("  dummy_results <- working_df\\n");
      echo("}\\n");

      echo(genLabelRestoreCode("local_obj", "dummy_results"));
      ' }, '
    ')
  }

  js_print <- '
    if(getValue("save_dummy_obj.active")) {
      var save_name = getValue("save_dummy_obj").replace(/"/g, "\\\\\\"");
      echo("rk.header(\\"Dummy Variables Created: " + save_name + "\\", level=3, parameters=list(\\n");
      echo("  \\"Input Object\\" = \\"" + getValue("inp_data") + "\\",\\n");
      echo("  \\"Remove first dummy\\" = \\"" + getValue("remove_first_dummy") + "\\",\\n");
      echo("  \\"Remove original columns\\" = \\"" + getValue("remove_selected_columns") + "\\"\\n");
      echo("))\\n");
    }
  '

  # =========================================================================================
  # 6. Skeleton Assembly
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = main_dialog),
    js = list(
        require = c("fastDummies"),
        calculate = js_gen_dummy(FALSE),
        preview = js_gen_dummy(TRUE),
        printout = js_print
    ),
    pluginmap = list(
        name = "Create Dummy Variables",
        hierarchy = list("data", "Data Wrangling"),
        po_id = "rk_fastdummies"
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE, overwrite = TRUE, show = FALSE
  )

  cat("\nPlugin 'rk.fastdummies' (v0.0.2) generated successfully.\n")
})
