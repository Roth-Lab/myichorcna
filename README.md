# myichorCNA
A simple python wrapper to run [ichorCNA](https://github.com/broadinstitute/ichorCNA) with a config file. 

## Getting started
1. Clone this repo
```
git clone https://github.com/matteolepur/myichorcna.git
```
2. `cd` into this repo and install myichorcna
``` 
pip install --editable .
```
3. Run ichorCNA on example data
```
myichorcna perform-inference --output-directory 'example/results' --ctdna-data-file 'example/ctdna.wig' --ichorcna-settings 'example/settings.yaml'
```
## Quick documentation:

**Inputs**

Running ichorCNA requires two input files and an output location.
An example of all the required files is given in the `examples` directory.
A description of each required file is provided below:
1. `--output-directory 'example/results'`: where to store all outputs from ichorCNA.
2. `--ctdna-data-file 'example/ctdna.wig'`: path to .wig file containing all binned read counts outputted by readCounter.
1. `--ichorcna-settings 'settings.yaml'`: path to .yaml file containing ichorCNA settings.


**Example** 

We can run ichorCNA on the example data provided outputted to `example/results`:
```
myichorcna perform-inference --output-directory 'example/results' --ctdna-data-file 'example/ctdna.wig' --ichorcna-settings 'example/settings.yaml
```