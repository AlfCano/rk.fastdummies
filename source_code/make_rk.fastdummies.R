local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  plugin_name <- "rk.fastdummies"
  plugin_ver <- "0.0.1"

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
  # 2. JS Helpers
  # =========================================================================================
  js_helpers <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            var match = lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/);
            if (match) { return match[1]; }
        }
        if (fullName.indexOf("$") > -1) { return fullName.substring(fullName.lastIndexOf("$") + 1); }
        else { return fullName; }
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
  chk_remove_first <- rk.XML.cbox(
    label = "Remove first dummy variable (Avoids collinearity)",
    id.name = "remove_first_dummy",
    value = "TRUE",
    chk = FALSE
  )

  chk_remove_freq <- rk.XML.cbox(
    label = "Remove most frequent dummy variable",
    id.name = "remove_most_frequent_dummy",
    value = "TRUE",
    chk = FALSE
  )

  chk_ignore_na <- rk.XML.cbox(
    label = "Ignore NA values (Do not create dummy for NA)",
    id.name = "ignore_na",
    value = "TRUE",
    chk = FALSE
  )

  # CHANGE: Default set to FALSE (unchecked)
  chk_remove_selected <- rk.XML.cbox(
    label = "Remove original columns after creating dummies",
    id.name = "remove_selected_columns",
    value = "TRUE",
    chk = FALSE
  )

  # --- Tab 3: Output ---
  save_results <- rk.XML.saveobj(
    label = "Save Results to R Object",
    initial = "dummy_results",
    id.name = "save_dummy_obj",
    chk = TRUE
  )

  preview_btn <- rk.XML.preview(mode = "output")

  # =========================================================================================
  # 4. Main Dialog Assembly
  # =========================================================================================

  main_dialog <- rk.XML.dialog(
    label = "Create Dummy Variables (fastDummies)",
    child = rk.XML.row(
      var_selector,
      rk.XML.col(
        rk.XML.tabbook(tabs = list(
          "Variables" = rk.XML.col(
            inp_data,
            inp_cols
          ),
          "Settings" = rk.XML.col(
            rk.XML.frame(
              label = "Dummy Creation Rules",
              chk_remove_first,
              chk_remove_freq,
              chk_ignore_na
            ),
            rk.XML.frame(
              label = "Data Cleaning",
              chk_remove_selected
            )
          ),
          "Output" = rk.XML.col(
            save_results,
            preview_btn
          )
        ))
      )
    )
  )

  # =========================================================================================
  # 5. JavaScript Logic
  # =========================================================================================

  js_calc <- paste0(js_helpers, '
    // 1. Gather Inputs
    var data_obj = getValue("inp_data");

    // Process selected columns
    var raw_cols = getValue("inp_cols").split("\\n");
    var safe_cols = [];

    for (var i = 0; i < raw_cols.length; i++) {
        var clean = getColumnName(raw_cols[i]);
        if (clean !== "") {
            safe_cols.push("\\"" + clean + "\\"");
        }
    }
    var cols_r_code = (safe_cols.length > 0) ? "c(" + safe_cols.join(", ") + ")" : "NULL";

    // Options
    var rem_first = getValue("remove_first_dummy") == "TRUE" ? "TRUE" : "FALSE";
    var rem_freq  = getValue("remove_most_frequent_dummy") == "TRUE" ? "TRUE" : "FALSE";
    var ign_na    = getValue("ignore_na") == "TRUE" ? "TRUE" : "FALSE";
    var rem_orig  = getValue("remove_selected_columns") == "TRUE" ? "TRUE" : "FALSE";

    // 2. Logic Generation
    echo("local_obj <- " + data_obj + "\\n");

    // Detect Survey Objects
    echo("is_survey_obj <- inherits(local_obj, c(\\"survey.design\\", \\"svyrep.design\\", \\"tbl_svy\\"))\\n");

    echo("if (is_survey_obj) {\\n");
    echo("  working_df <- local_obj$variables\\n");
    echo("} else {\\n");
    echo("  working_df <- local_obj\\n");
    echo("}\\n");

    // Perform fastDummies operation
    echo("working_df <- fastDummies::dummy_cols(\\n");
    echo("  .data = working_df,\\n");
    echo("  select_columns = " + cols_r_code + ",\\n");
    echo("  remove_first_dummy = " + rem_first + ",\\n");
    echo("  remove_most_frequent_dummy = " + rem_freq + ",\\n");
    echo("  ignore_na = " + ign_na + ",\\n");
    echo("  remove_selected_columns = " + rem_orig + "\\n");
    echo(")\\n");

    // Reconstruct Object
    echo("if (is_survey_obj) {\\n");
    echo("  final_result <- local_obj\\n");
    echo("  final_result$variables <- working_df\\n");
    echo("} else {\\n");
    echo("  final_result <- working_df\\n");
    echo("}\\n");

    // 3. Assign to Output
    if (!is_preview) {
        echo("dummy_results <- final_result\\n");
    }
  ')

  js_print <- '
    if (is_preview) {
        echo("require(fastDummies)\\n");
        echo("require(survey)\\n");
        echo("if(inherits(final_result, \\"survey.design\\")) {\\n");
        echo("  rk.print(head(final_result$variables, 20))\\n");
        echo("} else {\\n");
        echo("  rk.print(head(final_result, 20))\\n");
        echo("}\\n");
    } else {
        echo("rk.header(\\"Dummy Variables Created\\", parameters=list(\\n");
        echo("  \\"Input Object\\" = \\"" + getValue("inp_data") + "\\",\\n");
        echo("  \\"Saved to\\" = \\"" + getValue("save_dummy_obj") + "\\",\\n");
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
        require = c("fastDummies", "survey"),
        calculate = js_calc,
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

  cat("\nPlugin 'rk.fastdummies' (v0.0.1) generated successfully.\n")
})
