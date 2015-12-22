# CallosalScaling - re-analysis of Rilling & Insel (1999)

This repo uses data from the [CallosalData repository](https://github.com/guruucsd/CallosalData) to re-analyze the results and conclusions of Rilling & Insel (1999).

## Installation

1. Clone this repo.
2. Run scripts from the "publications" folder.


## Code updates

This repo uses `git subtree` to access the `CallosalData` and `matlab-utils` repos.

To access `CallosalData` updates here:

1. `git remote add -f callosaldata https://github.com/guruucsd/callosaldata`
2. `git subtree pull --prefix data callosaldata master`

To push changes to `CallosalData` to that repo:

1. `git subtree pull --prefix data origin callosaldata-branch`
2. Go to your repo, and create a pull request to https://github.com/guruucsd/callosaldata

Similar commands can be used to update `matlab-utils`, using `--prefix _lib` and remote repo  https://github.com/guruucsd/matlab-utils
