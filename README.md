# KAPITSA (v0.0.1)

Tag and search your jupyter documents (.ipynb) without an extension.

## Motivation

Remembering the syntax for **complex** or **infrequent** operations is hard. Also, sharing code examples and best practices with your team is difficult. Using Jupyter's cell metadata feature and Kapitsa, users can tag cells to make searching and aggregating examples easier.

## Solution

A script to query tagged code cells from .ipynb files and return the source and path to the file. Users provide a configuration file to specify paths to search and some othe optional parameters.

# Example
<!-- 
https://colorhunt.co/palette/170332
ffae8f
ff677d
cd6684
6f5a7e 
-->

<style>
    .pre-custom { background-color: #6f5a7e; }
    .host { color: #ffae8f }
    .prompt { color: #cd6684 } 
    .kapitsa { color: #ff677d }
    .search { color: #ffae8f}
</style>

<pre class="pre-custom">
<code><span class="host">foo@bar:~</span><span class="prompt">$</span> <span class="kapitsa">kapitsa</span> <span class="search">pandas loc regex</span></code>
</pre>

```bash
Found 1 match:

df.loc[df['Zips'].str.contains('\D', regex=True)]
reference: ./path/to/file.ipynb
line number: 126
```

## Installation

### Requirements

Users must have [node >= v12.15.0](https://nodejs.org/en/download/) installed. Read the Implementation section below for more information.

### Configuration File

The user defines a path to a configuration file. That configuration defines paths to search for .ipynb files and optional ignore paths and a namespace.

Export a variable, `KAPITSA` that points to your configuration file.

```bash
export KAPITSA=$HOME/.kapitsa
```

The file should be in json format:

```json
{
    "path": "$HOME/projects:$HOME/github",
    "ignore": ["**/node_modules/*"],
    "namespace": "kapitsa"
}
```

Note that `ignore` and `namespace` are optional. `namespace` can be used if users are already using metadata with keys like `pandas` or `r` or they do not want to potentially abuse the global namespace.

JupyterLab has a mechanism to save metadata for a cell. Users of Jupyter should add metadata to a cell in the format

```json
{
    "{type}": ["keyword1", "keyword2"]
}
```

where `{type}` is something like "pandas" or "numpy" -- this should be up to the user. The value supplied to `{type}` should be an array of strings representing keywords for that operation.

## Example

Suppose you are cleaning data, you notice that one of your columns, `Zip`, should only contain numbers, has some cells that contain special characters. So you assign a variable to find rows containing invalid zip codes.

```python
invalid_zips = df.loc[df['Zip'].str.contains('\D', regex=True)]
```

Now within that cells metadata, you add the following:

```json
{
    "pandas": ["loc", "str", "contains", "regex"]
}
```

# Notes on the implementation

This search script is meant to be minimal. It simply reads `code` cells from .ipynb files and filters on the `metadata` attribute and returns the contents of the `source` along with the line number and full path to the file. If seeing the source for the example is not enough, users can open the notebook and go through the example.

Note that this script must be made to be executable but its only business is to read files and output the results. It cannot write to directories or publish anything it finds. I encourage you to check the source code and open an issue to alert the author of any security vulnerabilities.

# Future Ideas

- A default set of examples for some languages/frameworks (e.g., python, pandas, numpy, scikit)
- Fetching & caching cell metadata and source from remote locations. This way users could essentially "subscribe" to another authors preferred examples the same way many bash users borrow shell configurations (.dotfiles) from prominent authors.

# Challenges

- Interoperability
- There is not a way to record the program versions that executed the cell (e.g., )

# License
MIT License. See LICENSE.md