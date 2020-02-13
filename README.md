# KAPITSA (v0.0.1)

Tag and search your jupyter documents (.ipynb) without an extension.

## Motivation

Remembering the syntax for **complex** or **infrequent** operations is hard. Also, sharing code examples and best practices with your team is difficult. Using Jupyter's cell metadata feature and Kapitsa, users can tag cells to make searching and aggregating examples easier.

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

The following command finds jupyter cells tagged "pandas"


```bash session
> kapitsa pandas

Found 2 matches for "pandas":

# file: ./path/to/file.ipynb:126
df.loc[df['Zips'].str.contains('\D', regex=True)]

# file: ./path/to/other/file.ipynb:55
df = pd.read_csv('./data.gzip', parse_dates=["START","END"], compression='gzip', dtype={ 'ZIP': 'str'})
```

The following command finds jupyter cells tagged pandas also, but only specific to keywords "loc" and "regex"

```bash session
$ kapitsa pandas loc regex

Found 1 match:

# file: ./path/to/file.ipynb:126
df.loc[df['Zips'].str.contains('\D', regex=True)]
```

# Setup and install

## Requirements

Users must have [jq >= jq-1.6](https://stedolan.github.io/jq/) installed. Read the Implementation section below for more information.

## Download

```bash
$ git clone https://github.com/gitjeff05/kapitsa
```

## Alias or put in $PATH

Make sure that this directory is in your path or just make an alias to it in your `.bash_profile`.

```bash
alias kapitsa=$HOME/Github/kapitsa/kapitsa
```
If you go the alias route you will also have to make it executable by the owner:

```bash
$ chmod u+rx kapitsa
```

Note: Many installers do this setup for you. I decided (for now) not to. Read below for reasons why.

## Create configuration file and environment variable

Create a `json` file `.kapista` with these contents and save it anywhere (`$HOME` is a good choice)

```json
{
    "path": "$HOME/Projects"
}
```

Export a variable, `KAPITSA` that points to your configuration file. Add this to your `.bash_profile`.

```bash
export KAPITSA=$HOME/.kapitsa
```

The configuration file also accepts an optional argument, `ignore` which is passed to the command `find` to skip files in that directory.

```json
{
    "path": "$HOME/projects:$HOME/github",
    "ignore": ["*/.ipynb_checkpoints/*"]
}
```

# How it works

Kapitsa uses functionality built into JupyterLab -- saveing metadata for a cell. To edit the metadata, open the "Notebook Tools" on the sidebar and look for "Cell Metadata". Users will edit this and add a key "kap" at the root level.

```json
{
    "kap": [
        { "{type}": ["keyword1", "keyword2"] }
    ]
}
```

where `{type}` is something like "pandas" or "numpy" -- this should be up to the user. The value supplied to `{type}` should be an array of strings representing keywords for that operation.

# Notes on the implementation

This search script is meant to be minimal. It simply reads `code` cells from .ipynb files and filters on the `metadata` attribute and returns the contents of the `source` along with the line number and full path to the file. If seeing the source for the example is not enough, users can open the notebook and go through the example.

Note that this script must be made to be executable but its only business is to read files and output the results. It cannot write to directories or publish anything it finds. I encourage you to check the source code and open an issue to alert the author of any security vulnerabilities.

# Future Ideas

- A default set of examples for some languages/frameworks (e.g., python, pandas, numpy, scikit)
- Caching cell metadata to make searches faster
- Fetching metadata and source from remote locations. Users could essentially "subscribe" to other authors' preferred examples the same way bash users borrow shell configurations (.dotfiles) from authors.
- A JupyterLab extension so that users can easily tag cells without typing up json.

# License
MIT License. See LICENSE.md