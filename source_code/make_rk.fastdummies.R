local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  plugin_name <- "rk.fastdummies"
  plugin_ver <- "0.0.3"

  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin to create dummy variables (one-hot encoding) from survey or dataframe objects using the 'fastDummies' package. Features integrated label preservation and janitor cleaning.",
      version = plugin_ver,
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/AlfCano/rk.fastdummies",
      license = "GPL (>= 3)"
    )
  )

  # Agregamos janitor a las dependencias
  dependencies_node <- rk.XML.dependencies(
    dependencies = list(R.min = "3.5.0"),
    package = list(
      c(name = "fastDummies"),
      c(name = "janitor")
    )
  )

  # =========================================================================================
  # 2. JS Helpers (Robust Parsing)
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

  # NUEVO: Checkbox de Janitor
  chk_janitor <- rk.XML.cbox(label = "Clean all column names with janitor (snake_case)", id.name = "chk_janitor", value = "TRUE", chk = TRUE)

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
            rk.XML.frame(label = "Data Cleaning & Naming", chk_remove_selected, chk_janitor),
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
      var do_janit  = getValue("chk_janitor") == "TRUE";

      echo("require(fastDummies)\\n");
      if (do_janit) echo("require(janitor)\\n");
      echo("\\n");

      ', if(is_preview) { '
      // PREVIEW MODE
      echo("local_obj <- " + data_obj + "\\n");
      echo("is_survey <- \'variables\' %in% names(local_obj)\\n");
      echo("prev_df <- if(is_survey) head(local_obj$variables, 50) else head(local_obj, 50)\\n");
      echo("preview_data <- fastDummies::dummy_cols(.data = prev_df, select_columns = " + cols_r_code + ", remove_first_dummy = " + rem_first + ", remove_most_frequent_dummy = " + rem_freq + ", ignore_na = " + ign_na + ", remove_selected_columns = " + rem_orig + ")\\n");
      if (do_janit) echo("preview_data <- janitor::clean_names(preview_data)\\n");
      ' } else { '
      // MAIN MODE
      echo("local_obj <- " + data_obj + "\\n");
      echo("is_survey <- \'variables\' %in% names(local_obj)\\n");
      echo("working_df <- if(is_survey) local_obj$variables else local_obj\\n");
      echo("source_vars <- working_df\\n");
      echo("old_cols <- names(working_df)\\n\\n");

      echo("working_df <- fastDummies::dummy_cols(.data = working_df, select_columns = " + cols_r_code + ", remove_first_dummy = " + rem_first + ", remove_most_frequent_dummy = " + rem_freq + ", ignore_na = " + ign_na + ", remove_selected_columns = " + rem_orig + ")\\n\\n");

      echo("new_cols <- setdiff(names(working_df), old_cols)\\n\\n");

      echo("# 1. Preserve original labels and assign factor values to new dummy labels\\n");
      echo("if (exists(\'rk.set.label\')) {\\n");
      echo("  # Restore labels for original columns that might have lost metadata\\n");
      echo("  for(col_name in old_cols) {\\n");
      echo("    if(col_name %in% names(working_df)) {\\n");
      echo("      attr(working_df[[col_name]], \'.rk.meta\') <- attr(source_vars[[col_name]], \'.rk.meta\')\\n");
      echo("    }\\n");
      echo("  }\\n");
      echo("  # Set the uncleaned factor level as the label for new dummy columns\\n");
      echo("  for(nc in new_cols) {\\n");
      echo("    rk.set.label(working_df[[nc]], nc)\\n");
      echo("  }\\n");
      echo("}\\n\\n");

      if (do_janit) {
          echo("# 2. Clean column names (snake_case)\\n");
          echo("# The readable factor levels remain safely stored in the labels!\\n");
          echo("working_df <- janitor::clean_names(working_df)\\n\\n");
      }

      echo("if (is_survey) {\\n");
      echo("  dummy_results <- local_obj\\n");
      echo("  dummy_results$variables <- working_df\\n");
      echo("} else {\\n");
      echo("  dummy_results <- working_df\\n");
      echo("}\\n");
      ' }, '
    ')
  }

    js_print <- '
    if(getValue("save_dummy_obj.active")) {
      var save_name = getValue("save_dummy_obj").replace(/"/g, "\\\\\\"");

      // SOLUCIÓN: Escapamos las comillas dobles que vienen del nombre del objeto
      var inp_data_safe = getValue("inp_data").replace(/"/g, "\\\\\\"");

      echo("rk.header(\\"Dummy Variables Created: " + save_name + "\\", level=3, parameters=list(\\n");
      echo("  \\"Input Object\\" = \\"" + inp_data_safe + "\\",\\n");
      echo("  \\"Remove first dummy\\" = \\"" + getValue("remove_first_dummy") + "\\",\\n");
      echo("  \\"Clean names with janitor\\" = \\"" + getValue("chk_janitor") + "\\",\\n");
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
    dependencies = dependencies_node,
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE, overwrite = TRUE, show = FALSE
  )

  cat("\nPlugin 'rk.fastdummies' (v0.0.3) generated successfully.\n")
})
