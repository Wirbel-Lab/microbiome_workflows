# Metagenomics workflows

Computational workflows for metagenomics tasks, packaged with Nextflow and 
Singularity. These workflows have been developed and are maintained by the
[Bhattlab](https://www.bhattlab.com) and the 
[Wirbel-lab](https://wirbel-lab.github.io/).

This repository is modeled on the [Snakemake workflows from the 
Bhattlab](https://github.com/bhattlab/bhattlab_workflows), where you might 
find more workflows. 

![](documentation/metro_map.png)

### Table of contents

 1. [Setup](documentation/setup.md)
 2. [Running a workflow](documentation/running.md)
 3. Available workflows
    - [**Preprocessing** metagenomic data](documentation/preprocessing.md)
    - [Metagenomic **Assembly**](documentation/assembly.md)
    - [Metagenomic **Binning**](documentation/binning.md)
    - [Metagenomic **Classification**](documentation/classification.md)
    - [**Sourmash** read comparison](documentation/sourmash.md)
    - [**Viral** contig prediction](documentation/viral.md) 

### Quickstart

If you're in the Bhatt lab and working on SCG, you should clone this 
repository to your folder:
```bash
git clone git@github.com:bhattlab/bhattlab_workflows_nf.git
```
You can then run a workflow like this:

```bash
module load nextflow/24.04.4

nextflow run </path/to/this/repo>/workflows/preprocessing.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report -resume
```

Note that you might have to modify the `params.yml` 
file according to your project. There is a template in the [config 
folder](config/params.yml), as a start.  
Other users will need to change these options (see [Running a 
workflow](documentation/running.md))


**Important**  
Once everything is done and ran correctly, you should delete all the 
unnecessary temporary files and save us space on SCG! 
Just remove the `work` folder from wherever you called the nextflow command: 
```
rm -r ./work
```
You can also remove the `.nextflow` folder, which contains metadata and cache 
from the run. 
```
rm -rf .nextflow 
```

### Versions

The versions of the tools and datbases used in these workflows are 
constantly evolving, so here is a list of the current versions as a 
reference. Not all versions of tools might work with each database version
This list will be updated whenever the Dockerfiles for the processes are
updated:

| Tool | Version | Database Version |
|------|---------|------------------|
| mOTUs| v4.1.0  | v4.1.0 |
| metaphlan | v.4.2.6 | vJan26 |
| sylph | v1.0.0 | GTDB release232 |
| GTDB-tk | v2.8.0 | release232 |

## Question?

Please feel free to check out the documentation folder. Maybe your question 
has already been answered.
Otherwise, you can open an 
[issue](https://github.com/jakob-wirbel/bhattlab_workflows_nf/issues/new) 
in this repository. Please make sure to thorougly describe your problem 
and to attach any relevant output and log files.
