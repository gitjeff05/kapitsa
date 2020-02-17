# KAPITSA (v0.0.1)

Tag and search your jupyter documents (.ipynb) without an extension.

## Motivation

Remembering the syntax for **complex** or **infrequent** operations in notebook environments is hard. Using Jupyter's cell metadata feature and Kapitsa, users can tag cells to make searching and aggregating examples easier.

## Solution

Kapitsa is a simple script that scans **jupyter tagged code cells** from .ipynb files for keywords and returns the source and path to the file. Users provide a configuration file to specify paths to search and begin tagging cells with their own examples. 

## Benefits 
Authors can build their own library of examples and best practices through notebooks, something they already use and share. Getting another authors code examples is as easy as pulling down their shared notebooks and adding that local path to the `.kapitsa` config file.

# Examples

## The following command finds jupyter cells tagged "*pandas*".

```bash session
> kapitsa "pandas"

Found 8 tagged cells matching pattern pandas in ~/Github/kapitsa/examples/dataframe_nih_2019.ipynb
```

```jsonc
/* Here is the first cell's output for the above query. */
/* The output is json containing source of the cell with tags */
{
  "source": [
    "# Use `copy()` when assigning a variable to a slice of a dataframe when that variable could be used for anything other than reading.\n",
    "us = df.loc[df['ORG_COUNTRY'] == 'UNITED STATES'].copy()"
  ],
  "tags": "copy loc pandas boolean"
}
...
```

## This next command matches any cell tagged "series" or "dataframe".

```bash session
> kapitsa "series|dataframe"
```

## This next command matches any cell tagged "pandas" and "regex".

```bash session
> kapitsa "(?=.*pandas)(?=.*regex)"
```

*Note: The above command does seem ridiculously complex for an `and` statement but unfortunately it is required to work.*

# Setup and install

## Dependencies

Users must have [jq >= jq-1.6](https://stedolan.github.io/jq/) installed because you need something to parse notebook documents (.ipynb) which are json.

## Clone the repo.

```bash session
> git clone https://github.com/gitjeff05/kapitsa
> cd kapitsa && chmod u+rx kapitsa # Make `kapitsa` executable by the user.
```

## Create `.kapitsa` configuration file.

```bash session
> echo '{"path":"$HOME/Github/kapitsa"}' > ~/.kapitsa
```

## Create a variable, `KAPITSA` that points to your config file.

```bash session
> export KAPITSA=$HOME/.kapitsa # add to your .bash_profile
```
## (Optional) Put `kapitsa` in your `$PATH` or make an alias.

Add this directory to your path or just make an alias in your `.bash_profile`.

```bash session
> alias kapitsa=$HOME/Github/kapitsa/kapitsa
```

# How it works

Kapitsa uses functionality built into Jupyter and JupyterLab -- saving metadata for a cell. To edit the metadata, open the "Notebook Tools" on the sidebar and look for "Cell Metadata". Users will edit this and add a key "tags" at the root level with an array of strings.

```json
{
    "tags": ["keyword1", "keyword2"]
}
```

## (Optional) Install celltags extension for JupyterLab

In the current version of JupyterLab, [the cell tagging UI](https://github.com/jupyterlab/jupyterlab/tree/master/packages/celltags) is not part of the core. You can still edit tags manually be editing the cell's json metadata. To install the cell tags UI, run the following:

```bash session
> jupyter labextension install @jupyterlab/celltags
```

# Advanced queries

Under the hood Kapitsa uses [jq regular expressions (PCRE)](https://stedolan.github.io/jq/manual/#RegularexpressionsPCRE) through the `test` method. Anything you can pass to jq's `test` method should also be valid for Kapitsa. Please open a ticket if you find any functionality missing.

# Notes on implementation

This script is meant to be minimal. Most of it is done through `find` and `jq`. I have not included comprehensive install scripts that would do a lot of the setup for you (e.g., editing `.bash_profile` or adding files to your `$HOME` directory). Users should be at least somewhat familiar with the command line (i.e., knowledge of `.bash_profile` (or similar), `alias` and `chmod`). Anyone can read the contents of `kapitsa` and know that it simply reads some files and produces an output. Please [open an issue](https://github.com/gitjeff05/kapitsa/issues) to file a bug or request a feature.

# Security 

I have done my best to ensure that this code can do no harm. The primary use of this script is to read files and output the results. It does not write to directories or publish anything it finds. It does not track your usage. It makes no network requests at all. I encourage you to check the source code and [open an issue](https://github.com/gitjeff05/kapitsa/issues) to alert the author of any security vulnerabilities. 

# Future Ideas

- A default set of examples for some languages/frameworks (e.g., python, pandas, numpy, scikit)
- Caching cell metadata to make searches faster
- Fetching metadata and source from remote locations. Users could essentially "subscribe" to other authors' preferred examples the same way bash users borrow shell configurations (.dotfiles) from authors.
- A JupyterLab extension to facilitate the search right inside of JupyterLab.

# License
MIT License. See LICENSE.md