# KAPITSA (v0.0.1)

Tag and search your jupyter documents (.ipynb) without an extension.

## Motivation

Remembering the syntax for **complex** or **infrequent** operations in notebook environments is hard. Sharing code examples and best practices with the public is difficult. Using Jupyter's cell metadata feature and Kapitsa, users can tag cells to make searching and aggregating examples easier.

## Solution

Kapitsa is a simple script that scans **jupyter tagged code cells** from .ipynb files for keywords and returns the source and path to the file. Users provide a configuration file to specify paths to search and begin tagging cells with their own examples. This way authors build their own library of examples and best practices to call up from the command line at any time.

# Example
<!-- 
https://colorhunt.co/palette/170332
ffae8f
ff677d
cd6684
6f5a7e 
-->

<!-- <style>
    .host { color: #6f5a7e }
    .prompt { color: #6f5a7e } 
    .kapitsa { color: #ff677d }
    .search { color: #ffae8f}
</style> -->

## The following command finds jupyter cells tagged "*pandas*"

```bash session
> kapitsa "pandas"

Found 8 tagged cells matching pattern pandas in ~/Github/kapitsa/examples/dataframe_nih_2019.ipynb
```

## The output is json containing the source and tags for the cell matching the query.

```jsonc
/* Here is the first cell's output for the above query. */
{
  "source": [
    "# Always use `copy()` whenever you assign a variable to a slice of your dataframe when that slice could be used for anything other than just reading.\n",
    "us = df.loc[df['ORG_COUNTRY'] == 'UNITED STATES'].copy()"
  ],
  "tags": "copy loc pandas boolean"
}
...
```

# Jupyter

```Jupyter Notebook
us = df.loc[df['ORG_COUNTRY'] == 'UNITED STATES'].copy()
```

## This next command matches any cell tagged "series" or "dataframe".

```bash session
> kapitsa "series|dataframe"
```

## This next command matches any cell tagged "pandas" and "regex".

```bash session
> kapitsa "(?=.*pandas)(?=.*regex)"
```

*Note: The above command does seem ridiculously complex for an and statement but unfortunately it is required to work.*

# Setup and install

## Dependencies

Users must have [jq >= jq-1.6](https://stedolan.github.io/jq/) installed because you need something to parse notebook documents (.ipynb) which are json.

## Clone or download the repo.

```bash session
> git clone https://github.com/gitjeff05/kapitsa
```

## Make sure `kapitsa` is executable by the user.

```bash session
> chmod u+rx kapitsa
```

## Create `.kapitsa` configuration file.

```bash session
echo '{"path":"$HOME/Github/kapitsa"}' > ~/.kapitsa
```

## Create a variable, `KAPITSA` that points to your config file.

```bash
export KAPITSA=$HOME/.kapitsa # add to your .bash_profile
```
## (Optional) Put `kapitsa` in your `$PATH` or make an alias.

Add this directory to your path or just make an alias in your `.bash_profile`.

```bash session
> alias kapitsa=$HOME/Github/kapitsa/kapitsa
```

# How it works

Kapitsa uses functionality built into Jupyter and JupyterLab -- saving metadata for a cell. To edit the metadata, open the "Notebook Tools" on the sidebar and look for "Cell Metadata". Users will edit this and add a key "kap" at the root level.

```json
{
    "tags": ["keyword1", "keyword2"]
}
```

# Notes on the implementation

This search script is meant to be minimal. As such, I have not included comprehensive install scripts that would do a lot of the setup for you (e.g., editing `.bash_profile` or installing in your `$HOME` directory). At the moment, I will assume consumers of this package are at least somewhat familiar with the command line and can do things like edit `.bash_profile` (or similar), create an `alias` and modify some permissions with `chmod`. Personally, I like the transparency of knowing what my scripts are doing. Anyone can read the contents of `kapitsa` and know that it simply parses some files and outputs. Please [open an issue](https://github.com/gitjeff05/kapitsa/issues) if you see anything in the script that might be a security vulnerability.

The main (and only) script simply reads `code` cells from .ipynb files and filters on the `metadata` attribute by the parameters passed in by the user. It outputs the contents of the `source` along with the line number and full path to the file. If seeing the source outside of the context is not enough, users can open the notebook and go through the example.

# Security 

I have done my best to ensure that this code can do no harm. The primary use of this script is to read files and output the results. It does not write to directories or publish anything it finds. It does not track your usage. It makes no network requests at all. I encourage you to check the source code and [open an issue](https://github.com/gitjeff05/kapitsa/issues) to alert the author of any security vulnerabilities. 

# Future Ideas

- A default set of examples for some languages/frameworks (e.g., python, pandas, numpy, scikit)
- Caching cell metadata to make searches faster
- Fetching metadata and source from remote locations. Users could essentially "subscribe" to other authors' preferred examples the same way bash users borrow shell configurations (.dotfiles) from authors.
- A JupyterLab extension so that users can easily tag cells without typing up json.

# License
MIT License. See LICENSE.md