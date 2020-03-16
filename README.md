# KAPITSA (v0.1.5)

<img src="https://repository-images.githubusercontent.com/239854510/065d3b80-6323-11ea-9b2f-806dbb0c592f" alt="Kapitsa logo" style="text-align:center"/>

## Search your Jupyter notebooks.

## Motivation

As the number of projects grow, it becomes difficult to keep notebooks organized and searchable on your local machine.

[See blog post for for how this project got started and the tools behind it.](https://www.optowealth.com/blog/better-way-to-search-your-notebooks).

## Solution

Kapitsa is a simple, minimally configured command line program that provides a centralized way to search and keep track of your notebooks. Users simply configure paths where they keep their notebooks. Kapitsa provides convenience methods do do the following:

1. **Search Code** - Query your notebooks' source.
2. **Search Tags** - Query your notebooks' cell tags.
3. **List Recent** - List notebooks you have worked on recently.
4. **List Directories** - View all directories on your system that contain notebooks.

## Benefits & Use Cases

Providing the ability to search *your* notebooks and any notebooks on your machine makes finding code examples easier. Search all notebooks on your local machine -- that means notebooks you pulled from Github, too.

### Use Cases:

1. Have you ever solved some complex problem and thought bookmarking the solution for later would be beneficial? With Kapitsa, you just tag the cell with a relevant `"keyword"` and find it later with `kapitsa tags "keyword"`.

2. Having trouble remembering how to use some API in [_insert library here_]? Just run `kapitsa search "function"` to search your notebooks for all cells containing `function` in their source.

3. Where was that notebook you worked on 2 weeks ago? Running `kapitsa recent` will jog your memory.

# API

| Command                        | Description                                                              |
| ------------------------------ | -------------------------------------------------------------------------|
| kapitsa search regex [-p path] | Search notebook source.                                                  |
| kapitsa tags regex             | Search notebook cell tags.                                               |
| kapitsa list [path]            | List all paths containing .ipynb files.                                  |
| kapitsa recent                 | List recently modified notebooks.                                        |
| kapitsa clear notebook         | Remove cell outputs and execution_count from code cells in notebook      |
| kapitsa [help\|h]              | Print help info.                                                         |


# Quick Examples

| Command                                | Description                                                              |
| -------------------------------------- | -------------------------------------------------------------------------|
| kapitsa list .                         | Lists all paths in current directory containing .ipynb files             |
| kapitsa search "join"                  | Print cells matching "join"                                              |
| kapitsa search "(join\|concat)"        | Print cells matching on "join" or "concat"                               |
| kapitsa tags "(pandas\|where)"         | Print cells with tags "pandas" or "where"                                |
| kapitsa tags "(?=.*where)(?=.*loc)"    | Print cells with tags "where" and "loc"                                  |

# Verbose Examples

## Find notebook cells matching "*join*".

```bash session
> kapitsa search "join"
```

```jsonc
Found 2 matching cells in /Users/Me/File.ipynb
[
  {
    "source": [
      "df = df.join(zip_codes.loc[:, ['Zip', 'Latitude', 'Longitude']].set_index('Zip'), on='ZIPCODE')"
    ]
  },
  {
    "source": [
      "# join two dataframes on the original dataframes' column. Index must be set appropriately on second df.\n",
      "us = us.join(zips_to_coords.loc[:, ['Zip', 'Lat', 'Long']].set_index('Zip'), on='ZIPCODE')"
    ]
  }
]
...
```

## Find cells matching "series" **OR** "dataframe".

```bash session
> kapitsa search "series|dataframe"
```

## Find cells matching "pandas" **AND** "numpy".

```bash session
> kapitsa search "(?=.*pandas)(?=.*regex)"
```

*Note: The above command does seem ridiculously complex for an `and` statement. Perhaps there is a better way. For now, I wanted the users to have complete control over the argument passed to `jq` to do the search.*

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
> echo '{"path":"$HOME/Github/kapitsa"}' > ~/.kapitsa # separate paths by ":"
```

## Create an environment variable, `KAPITSA` that points to your config file.

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

Open a ticket for bug reports or feature requests.


# Testing and compatibility:

Kapitsa has been tested on the following platforms.

- [x] GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin19)
- [x] zsh 5.7.1 (x86_64-apple-darwin18.2.0)
- [x] GNU bash, version 4.4.20(1)-release (x86_64-pc-linux-gnu)

If Kapitsa is not working for you, please open a pull request with as much information as possible so we can try to get it working.

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

This program is meant to be minimal and portable. Most of the functionality is through `find` and `jq`. I have not included comprehensive install scripts that would do a lot of the setup for you (e.g., editing `.bash_profile` or adding files to your `$HOME` directory). Users should be at least somewhat familiar with the command line (i.e., knowledge of `.bash_profile` (or similar), `alias` and `chmod`). Anyone can read the contents of `kapitsa` and know that it simply reads some files and produces an output. Please [open an issue](https://github.com/gitjeff05/kapitsa/issues) to file a bug or request a feature.

# Security

I have done my best to ensure that this code can do no harm. The primary use of this script is to read files and output the results. It does not write to directories or publish anything it finds. It does not track your usage. It makes no network requests at all. I encourage you to check the source code and [open an issue](https://github.com/gitjeff05/kapitsa/issues) to alert the author of any security vulnerabilities.

# Future Ideas

- A default set of examples for some languages/frameworks (e.g., python, pandas, numpy, scikit)
- Caching cell metadata to make searches faster
- Fetching metadata and source from remote locations. Users could essentially "subscribe" to other authors' preferred examples the same way bash users borrow shell configurations (.dotfiles) from authors.
- A JupyterLab extension to facilitate the search right inside of JupyterLab.
- Ability to build cheat sheets based on tags.
- Some sort of post-save process to copy over the notebook file sans `output` and `execution_count` -- which would make `git diff` work way better.

# License

Licensed under the Apache License, Version 2.0
