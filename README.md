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

The following command finds jupyter cells tagged "*pandas*"


```bash session
> kapitsa pandas

Found 2 matches for "pandas":

# file: ./path/to/file.ipynb:126
df.loc[df['Zips'].str.contains('\D', regex=True)]

# file: ./path/to/other/file.ipynb:55
df = pd.read_csv('./data.gzip', parse_dates=["START","END"], compression='gzip', dtype={ 'ZIP': 'str'})
```

This next command finds jupyter cells tagged "*pandas*" also, but only specific to keywords "loc" and "regex"

```bash session
> kapitsa pandas loc regex

Found 1 match:

# file: ./path/to/file.ipynb:126
df.loc[df['Zips'].str.contains('\D', regex=True)]
```

# Setup and install

## Dependencies

Users must have [jq >= jq-1.6](https://stedolan.github.io/jq/) installed because you need something to parse notebook documents (.ipynb) which are json.

## Clone or download the repo.

```bash session
> git clone https://github.com/gitjeff05/kapitsa
```

## Put `kapitsa` in your `$PATH` or make an alias.

Add this directory to your path or just make an alias in your `.bash_profile`.

```bash session
> alias kapitsa=$HOME/Github/kapitsa/kapitsa
```

## Make `kapitsa` file executable by the user.

```bash session
> chmod u+rx kapitsa
```

## Create `.kapitsa` configuration file.

Create a `json` file `.kapitsa` with these contents and save it anywhere (`$HOME` is a good choice)

```json
{
    "path": "$HOME/Projects"
}
```

## Create a variable, `KAPITSA` that points to your config file.

```bash
export KAPITSA=$HOME/.kapitsa # add to your .bash_profile
```

## Too many steps? Here is an all-in-one (for the brave or knowledgeable):

Warning: This *should* only append a few lines to your shell configuration file and create a couple of environment variables

```bash session
> KAPITSA_INSTALL="$HOME/Github/test" && \
mkdir -p "$KAPITSA_INSTALL" && \
cd "$KAPITSA_INSTALL" && \
git clone https://github.com/gitjeff05/kapitsa && \
cd kapitsa && chmod u+x,g-x,o-x kapitsa && \
echo "alias kapitsa=$KAPITSA_INSTALL/kapitsa/kapitsa" >> "$HOME/.zshrc" && \
echo "export KAPITSA=\$HOME/.kapitsa" >> "$HOME/.zshrc" && \
echo '{"path":"$HOME/Projects"}' | jq . > "$KAPITSA" && \
unset KAPITSA_INSTALL
```

The configuration file also accepts an optional argument, `ignore` which is passed to the command `find` to skip files in that directory.

```json
{
    "path": "$HOME/projects:$HOME/github",
    "ignore": ["*/.ipynb_checkpoints/*"]
}
```

# How it works

Kapitsa uses functionality built into JupyterLab -- saving metadata for a cell. To edit the metadata, open the "Notebook Tools" on the sidebar and look for "Cell Metadata". Users will edit this and add a key "kap" at the root level.

```json
{
    "kapitsa": [
        { "{type}": ["keyword1", "keyword2"] }
    ]
}
```

where `{type}` is something like "pandas" or "numpy" -- this should be up to the user. The value supplied to `{type}` should be an array of strings representing keywords for that operation.

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