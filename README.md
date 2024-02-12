# cfClone
A Bayesian probabilistic model that infers cancer clone prevalence using matched ctDNA and single-cell WGS.

## Installation
1. Clone this repo
```
git clone https://github.com/matteolepur/cfclone.git
```
2. `cd` into this repo and install cfClone
``` 
pip install --editable .
```
3. Run cfClone on example data
```
cfclone inference --mcmc-output-file 'lol_mcmc.tsv' --ctdna-data-fie 'lol_ctdna.tsv' --clone-cn-profiles-file 'lol_cn.bed'
```
## Quick documentation:

### Required inputs
Running cfClone requires two input files and an output location.
Other parameters can be modified.
An example of all the required files is given in the `examples` directory.
A description of each required file is provided below:
1. `--mcmc-output-file lol_mcmc.tsv`: where to store mcmc traces of all parameters will be stored.
2. `--ctdna-data-file lol_ctdna.tsv`: gc and mappability corrected binned read counts of the ctdna.
3. `--clone-cn-profiles-file lol_cn.bed`: binned copy number profiles for each cancer clone.

### Optional inputs
4. `--cfclone-data-file lol_storage.tsv`: where to store all data used to train cfclone.
5. `--num-mcmc-iters 1000`: number of mcmc iterations used to train cfclone.
6. `--num-burnin-iters 500`: number of burnin iterations used to train cfclone.

### Example Run
We can run cfClone on the example data provided outputted to `example_mcmc_output.tsv` as follows:
`cfclone inference --mcmc-output-file 'example/example_mcmc_output.tsv' --ctdna-data-file 'example/ctdna.tsv' --clone-cn-profiles-file 'example/clone_cn_prifle.bed'`

### License 
cfClone is licensed inder the MIT License.

### Contact
Author: [Matteo Lepur](matteolepur@stat.ubc.ca)