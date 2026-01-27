# The Golden Rules of RKWard Plugin Development (v3.0)

*Comprehensive guidelines for `rkwarddev` (0.08+) based on real-world debugging.*

## Part I: The Core Architecture

### 1. The R Script is the Single Source of Truth
Your output is always a single R script wrapped in `local({})`.
*   **Never** manually edit the generated `.xml`, `.js`, or `.pluginmap` files.
*   If you need to change something, change the generator script and regenerate.
*   **Structure:**
    1.  `require(rkwarddev)`
    2.  Metadata definition (`rk.XML.about`).
    3.  UI Component definitions.
    4.  JavaScript Logic (`calculate`, `printout`, `preview`).
    5.  Skeleton assembly (`rk.plugin.skeleton`).

### 2. The Hierarchy Case-Sensitivity Rule
RKWard's internal menu IDs are **case-sensitive** and predefined.
*   **Standard Menus:** `"data"`, `"analysis"`, `"plots"`, `"distributions"`.
*   **The Trap:** If you use `"Data"` (capital D), RKWard treats it as a custom menu (falling back to "Test") or creates a duplicate top-level menu.
*   **Correct:** `hierarchy = list("data", "My Submenu")`.

### 3. The `calculate` / `saveobj` Contract (The "Hardcoding" Rule)
This is the most frequently broken rule. RKWard handles variable assignment internally.
*   **The Rule:** The R object name generated inside the `calculate` block **must** be the hardcoded string defined in the `initial` argument of `rk.XML.saveobj`.
*   **The Trap:** Do not read the value of the save object to name your variable in the calculation phase.
*   **Correct Pattern:**
    *   XML: `my_save <- rk.XML.saveobj(..., initial = "my_result", id.name = "save_ui")`
    *   JS (`calculate`): `echo("my_result <- some_function(...)")`
    *   JS (`printout`): `echo("rk.header('Saved to: " + getValue("save_ui") + "')")`

---

## Part II: Internationalization (i18n)

### 4. The `po_id` Generation Logic
RKWard determines the "text domain" (translation ID) based on the **Plugin Map Name**, not the package name.
*   **Logic:** It strips spaces and special characters, CamelCases the string, and appends `_rkward`.
    *   Name: `"Survey Batch Transform"` -> ID: `SurveyBatchTransform_rkward`
*   **Best Practice:** Explicitly define `po_id` in your `rk.plugin.skeleton` call to avoid ambiguity.

### 5. The Binary File Naming Convention
The compiled translation file (`.mo`) must match the `po_id` exactly.
*   **Format:** `rkward__[po_id].mo`
*   **Example:** `inst/rkward/po/es/LC_MESSAGES/rkward__SurveyBatchTransform_rkward.mo`
*   **Failure Mode:** If the filename does not match the internal ID, the translation will simply not load, with no error message.

### 6. The Manual Fallback Strategy
Automatic message extraction (`rk.updatePluginMessages`) often fails on Windows due to system dependency paths.
*   **Strategy:** Manually create the `.po` file (text), populate it with `msgid` (original) and `msgstr` (translated), compile it with **Poedit**, and place the `.mo` file in the structure manually.

---

## Part III: Robust JavaScript Generation

### 7. The Quote Escaping Strategy (Single vs. Double)
When generating R code via JavaScript, you are nesting strings three levels deep.
*   **The Problem:** `echo("data[[\"" + var + "\"]]")` requires escaping double quotes inside a string that is inside another string. It is error-prone ("Backslash Hell").
*   **The Solution:** Use **Single Quotes** for R syntax where possible.
    *   **Better:** `echo("data[['" + var + "']]")`
    *   **Best:** Use `dplyr` piping or base R extraction that doesn't require complex quoting logic if possible.

### 8. Variable Name Safety
Never assume a user's variable name is "safe" (no spaces, no special chars).
*   **The Rule:** Always quote variable names when passing them to R functions like `select`, `across`, or `subset`.
*   **JS Helper:** `var quoted_vars = vars.map(function(v) { return "\'" + v + "\'"; }).join(", ");`

### 9. The Matrix Widget Rules
The `rk.XML.matrix` widget is powerful but strict.
*   **Numeric by Default:** It defaults to validating inputs as numbers. Text inputs will turn red and **block the Submit button**.
*   **The Fix:** Always set `mode = "string"` if the matrix accepts text (like Recode rules).
*   **Empty Rows:** Set `min = 0` to ensure the plugin doesn't block execution if the user leaves the matrix empty (or is in the middle of typing).

### 10. Preview Logic Stability
Previews run in a detached, clean R environment.
*   **Requirement 1:** You must re-`require()` any packages (`dplyr`, `srvyr`) inside the preview block.
*   **Requirement 2:** Never print complex S3 objects (like `svydesign` or `srvyr` objects) directly to the preview.
    *   **Correct:** Convert to `data.frame`, `head(50)`, and `select()` relevant columns before printing.
    *   **Pattern:** `echo("preview_data <- my_complex_obj %>% as.data.frame() %>% head(50)\n")`

---

## Part IV: UI & Layout

### 11. The Tabbook Standard
For plugins with more than 3-4 input parameters:
*   **Use `rk.XML.tabbook`** to organize UI.
*   **Tab 1 (Variables):** Source selector and variable slots.
*   **Tab 2 (Settings/Rules):** Checkboxes, dropdowns, matrices.
*   **Tab 3 (Output):** Naming patterns, Save object, Preview button.

### 12. Metadata Preservation
When creating new variables (Recode/Transform), metadata (RKWard labels) is often lost.
*   **The Fix:** Explicitly loop through input variables and copy the `.rk.meta` attribute to the new output variables in the generated R code.
*   **Targeting:** Remember that `srvyr` output objects are data frames (access via `[[col]]`), while `survey` objects are lists (access via `$variables[[col]]`).
