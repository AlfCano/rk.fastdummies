# rk.fastdummies: Fast One-Hot Encoding for RKWard

![Version](https://img.shields.io/badge/Version-0.0.2-blue.svg)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.fastdummies/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.fastdummies/actions/workflows/lintr.yml)

**rk.fastdummies** extends RKWard's data wrangling capabilities by providing a graphical interface for the `{fastDummies}` package. It allows users to quickly create dummy variables (one-hot encoding) from character or factor variables. Uniquely, this plugin supports both standard `data.frame` objects and complex survey designs (`svydesign`), ensuring that your weighted data structure remains intact during transformation.

### 🚀 What's New in Version 0.0.2
1.  **Added support for survey objects:** Now one plug-in supports regular data frames and survey design objects.
2.  **Unused Level Dropping:** Added an option to run `droplevels()` on your data before processing, preventing the creation of empty dummy columns for unused factor levels.
3.  **Custom Prefixing:** Added an input field to prepend a custom string to all generated dummy variable names, allowing for better organization in large datasets.

## 🚀 What's New in Version 0.0.1

This is the initial release of the plugin, focusing on robust dummy variable creation and integration with survey objects.

### Key Highlights
1.  **Survey Design Support:** The plugin automatically detects if the input is a `survey.design` object. It creates dummy variables within the design's data slot without breaking weights or stratification details.
2.  **Collinearity Control:** built-in options to remove the first dummy or the most frequent dummy to avoid the "dummy variable trap" in regression models.
3.  **Smart Column Selection:** You can select specific columns to expand, or leave the selection empty to automatically convert all factor and character columns in the dataset.

### 🌍 Internationalization
The interface is fully localized in:
*   🇺🇸 English (Default)
*   🇪🇸 Spanish (`es`)
*   🇫🇷 French (`fr`)
*   🇩🇪 German (`de`)
*   🇧🇷 Portuguese (Brazil) (`pt_BR`)

## ✨ Features

### 1. Fast One-Hot Encoding
Convert categorical variables into multiple binary (0/1) columns.
*   **Automatic Naming:** New columns are named strictly as `variable_level` (e.g., `gender_male`, `gender_female`).
*   **Safety:** Handles special characters in column names to ensure valid R variable names.

### 2. Regression Readiness
Prepare your data for statistical modeling immediately.
*   **Remove First Dummy:** Automatically drops the first level (reference category) to prevent perfect multicollinearity in linear models.
*   **Remove Most Frequent:** Optionally drops the most frequent category to use it as the reference level.

### 3. Data Cleaning
*   **Original Columns:** Option to automatically remove the original categorical columns after the dummies are created, keeping your workspace tidy.
*   **NA Handling:** Choose whether to create a separate dummy column for `NA` values or ignore them (preserving `NA` rows).

## 📦 Installation

This plugin is not yet on CRAN. To install it, use the `remotes` or `devtools` package in RKWard.

1.  **Open RKWard**.
2.  **Run the following command** in the R Console:

    ```R
    # If you don't have devtools installed:
    # install.packages("devtools")
    
    local({
      require(remotes)
      install_github("AlfCano/rk.fastdummies", force = TRUE)
    })
    ```
3.  **Restart RKWard** to load the new menu entries.

## 💻 Usage

Once installed, the tool is organized under the **Data** menu:

**`Data` -> `Data Wrangling` -> `Create Dummy Variables`**

1.  **Select Input:** Choose a Data Frame or Survey Design.
2.  **Select Columns:** Pick specific variables or leave empty for all.
3.  * **Configure:** Set rules for reference categories, choose to drop unused factor levels, and define custom name prefixes.
4.  **Save:** The result is saved to a new R object (default: `dummy_results`).

## 🛠️ Dependencies

This plugin relies on the following R packages:
*   `fastDummies` (Core algorithm)
*   `survey` (Object handling)
*   `rkwarddev` (Plugin generation)

#### Troubleshooting: Errors installing `devtools` or missing binary dependencies (Windows)

If you encounter errors mentioning "non-zero exit status", "namespace is already loaded", or requirements for compilation (compiling from source) when installing packages, it is likely because the R version bundled with RKWard is older than the current CRAN standard.

**Workaround:**
Until a new, more recent version of R (current bundled version is 4.3.3) is packaged into the RKWard executable, these issues will persist. To fix this:

1.  Download and install the latest version of R (e.g., 4.5.2 or newer) from [CRAN](https://cloud.r-project.org/).
2.  Open RKWard and go to the **Settings** (or Preferences) menu.
3.  Run the **"Installation Checker"**.
4.  Point RKWard to the newly installed R version.

This "two-step" setup (similar to how RStudio operates) ensures you have access to the latest pre-compiled binaries, avoiding the need for RTools and manual compilation.

## ✍️ Author & License

*   **Author:** Alfonso Cano (<alfonso.cano@correo.buap.mx>)
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)
