# simple-asm

A pipeline to assemble, filter, and scaffold genomes with HiFi + Hi-C reads. 

## Usage
Hardcoded paths are in a custom config file. The template for the config file is `config_temple`. Here's the easiest way to assemble a genome with `simple-asm`.  

1. Copy, fill and modify `config_temple`. Fill in the paths and id with single quotes. Get the taxid from ncbi (https://www.ncbi.nlm.nih.gov/datasets/taxonomy/tree/). Integers need not be filled in with quotes. 
2. run with Nextflow, passing your config file with `-c config_template`.  

`nextflow run artorias111/simple-asm -c config_template`


#### Results
Results are in the `work` directory, but you also have access to the symlinks of the actual files organized in the `results` directory, so you're not lost in the sea of hex-coded directories in `work`. 
