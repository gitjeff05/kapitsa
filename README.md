# KAPITSA (v0.1.1)

Search your Jupyter notebooks.

```bash session
> kapitsa help

kapitsa list [path]              List all paths containing .ipynb files.
                                 Unless given optional path, search all paths in configuration file.

kapitsa search regex [-p path]   Output all cells matching on regex.
                                 Unless given optional path, search all paths in configuration file.

kapitsa recent                   List recently modified notebooks.

---------------------------------

Examples

kapitsa list .                   Lists all paths in current directory containing .ipynb files
kapitsa search "join"            Print code cells matching "join"
kapitsa search "(join|concat)"   Print code cells matching on "join" or "concat"
```


## Motivation

As the number of your Jupyter projects grow, it becomes difficult to stay organized. Searching for code in notebooks across folders is hard. The folder structure of your ML environment is not intuitive and it is difficult to get a grasp on your local environment.

[See blog post for further explanation and the basics of these shell commands](https://www.optowealth.com/blog/better-way-to-search-your-notebooks).

## Solution

Kapitsa is a simple script that searches the **source** of Jupyter notebook cells -- in `.ipynb` files -- and returns the code and path to that file. Users just configure paths where they keep their notebooks. Kapitsa provides some convenient functions:

1. **Search** - Query your notebooks for code examples (e.g., "pd.join").
2. **Recent** - List recently modified notebooks sorted by date.
3. **List** - View all paths on your filesystem that contain notebooks.



## Benefits

Not only can you search *your* notebooks, but any notebooks on your machine. That means any notebooks you pulled from Github are now searchable. Having trouble remembering how to use `concat`? Just run `kapitsa search "concat"` to get the source of all the cells matching 'concat'. Where was that notebook you worked on 2 weeks ago? `kapitsa recent` will jog your memory.

# Examples

## Find notebook cells matching "*join*".

```bash session
> kapitsa search "join"
```

```jsonc
{
  "source": [
    "df = df.join(zip_codes.loc[:, ['Zip', 'Latitude', 'Longitude']].set_index('Zip'), on='ZIPCODE')"
  ],
  "file": "/Users/Me/Projects/NIH/train/NIH-2019-awards.ipynb"
}
{
  "source": [
    "# join two dataframes on the original dataframes' column. Index must be set appropriately on second df.\n",
    "us = us.join(zips_to_coords.loc[:, ['Zip', 'Lat', 'Long']].set_index('Zip'), on='ZIPCODE')"
  ],
  "file": "/Users/Me/Tutorials/DataframeTutorial.ipynb"
}
...
```

## Find cells matching "series" **OR** "dataframe".

```bash session
> kapitsa search "series|dataframe"
```

## Find cells matching "pandas" **AND** "numpy".

```bash session
> kapitsa "(?=.*pandas)(?=.*regex)"
```

*Note: The above command does seem ridiculously complex for an `and` statement. Perhaps there is a better way.*

## Have a quick glance to see what notebooks you have worked on recently:

```bash session
> kapitsa recent
```

```bash
Thu, 05 Mar 2020 17:05:29 -0500 /Users/Me/Github/States/train/Population.ipynb
Wed, 04 Mar 2020 11:42:24 -0500 /Users/Me/Github/Class/examples/Intro-To-Pandas.ipynb
Mon, 24 Feb 2020 22:58:51 -0500 /Users/Me/Projects/BigTime/train/Marketing-Plan.ipynb
```
## Print out a list of all paths containing notebook files:

```bash session
> kapitsa list
```

```bash
/Users/Me/Github/kapitsa/examples/
/Users/Me/Projects/Classifiers/train/awards-grants/
/Users/Me/Projects/Classifiers/train/noaa/
/Users/Me/Tutorials/DeepLearning/Fish
```


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
## Source kapitsa

```bash session
> . ./kapitsa # add to your .bash_profile
```
# Test that everything is working:

```bash session
> kapitsa list
```
If you get a list of paths then you are good to go. Add more paths (separated by ':') to the path key in `.kapitsa` config file.

# Get Help

```bash session
> kapitsa help
```


# Testing and compatability:

Kapitsa has been tested on the following platforms.

- [x] GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin19)
- [x] zsh 5.7.1 (x86_64-apple-darwin18.2.0)
- [x] GNU bash, version 4.4.20(1)-release (x86_64-pc-linux-gnu)
  - *There is a bug with `kapitsa recent` in bash 4.4 currently.*

Please open a pull request with as much information as possible so we can try to get it working.

# Advanced queries

Under the hood Kapitsa uses [jq regular expressions (PCRE)](https://stedolan.github.io/jq/manual/#RegularexpressionsPCRE) through the `test` method. Anything you can pass to jq's `test` method should also be valid for Kapitsa. Please open a ticket if you find any functionality missing.

# File Hierarchy

```bash session
> tree -L 2
.
├── LICENSE
├── README.md
├── examples
│   ├── dataframe_nih_2019.ipynb
│   ├── nih_2019.gzip
│   └── zip_geo.gzip
├── kapitsa
└── lib
    ├── find_in_notebook_source.sh
    ├── find_in_notebook_tags.sh
    ├── find_notebook_directories.sh
    └── find_recent_notebooks.sh

2 directories, 10 files
```
Note that any of the files in `lib` are meant to be run on their own or through kapitsa.

# Notes on implementation

This program is meant to be minimal. Most of it is done through `find` and `jq`. I have not included comprehensive install scripts that would do a lot of the setup for you (e.g., editing `.bash_profile` or adding files to your `$HOME` directory). Users should be at least somewhat familiar with the command line (i.e., knowledge of `.bash_profile` (or similar), `alias` and `chmod`). Anyone can read the contents of `kapitsa` and know that it simply reads some files and produces an output. Please [open an issue](https://github.com/gitjeff05/kapitsa/issues) to file a bug or request a feature.

# Security

I have done my best to ensure that this code can do no harm. The primary use of this script is to read files and output the results. It does not write to directories or publish anything it finds. It does not track your usage. It makes no network requests at all. I encourage you to check the source code and [open an issue](https://github.com/gitjeff05/kapitsa/issues) to alert the author of any security vulnerabilities.

# Future Ideas

- Search on tags. This way, users can build a more "curated" list of what they perceive as high quality examples to search. This feature is next on the list.
- A default set of examples for some languages/frameworks (e.g., python, pandas, numpy, scikit)
- Caching cell metadata to make searches faster
- Fetching metadata and source from remote locations. Users could essentially "subscribe" to other authors' preferred examples the same way bash users borrow shell configurations (.dotfiles) from authors.
- A JupyterLab extension to facilitate the search right inside of JupyterLab.

# License
MIT License. See LICENSE.md
