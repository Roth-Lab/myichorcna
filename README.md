# myichorCNA
My repository to run [ichorCNA](https://github.com/broadinstitute/ichorCNA) developed by Gavin Ha and co. 

## Installation
1. Clone this repo
```
git clone https://github.com/matteolepur/myichorcna.git
```
2. `cd` into this repo and install cfClone
``` 
pip install --editable .
```
3. Run ichorCNA on example data
```
myichorcna perform-inference --output-directory 'example/results' --ctdna-data-file 'example/ctdna.wig' --ichorcna-settings 'example/settings.yaml'
```
## Quick documentation:

### Required inputs
Running ichorCNA requires two input files and an output location.
An example of all the required files is given in the `examples` directory.
A description of each required file is provided below:
1. `--output-directory 'example/results': where to store all outputs from ichorCNA`.
2. `--ctdna-data-file 'example/ctdna.wig': path to .wig file containing all binned read counts outputted by readCounter.`
1. `--ichorcna-settings 'settings.yaml'`: path to 
2. `--ctdna-data-file lol_ctdna.tsv`: gc and mappability corrected binned read counts of the ctdna.
3. `--clone-cn-profiles-file lol_cn.bed`: binned copy number profiles for each cancer clone.

### Example Run
We can run ichorCNA on the example data provided outputted to `example/results`:
`myichorcna perform-inference --output-directory 'example/results' --ctdna-data-file 'example/ctdna.wig' --ichorcna-settings 'example/settings.yaml'`

### Contact
Author: [Matteo Lepur](matteolepur@stat.ubc.ca)
