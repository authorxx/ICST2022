# ICST2022

In this package, we provide necessary information for replicating the experiment in the paper. We provide:

For Black-Box experiments:

jar: runnable jar for EvoMaster.

exp.py: a python script to build tools and all the twelve case studies

results: contains compressed generated data

gqlbbAll: contains all the automatically generated files including logs, reports, scripts and tests. 

analyze.R: an R script to analyze results and generate table and figures in the paper.

Quick build and run:

Step 1. In this repo, we provide a python script.

Go to the root, run

python exp.py no 1000 bbgqlicst 1 1 1000 400 12 no

Step 2. After the execution is done, you will see a folder named bbgqlicst. Go to bbgqlicst and run:

./runall.sh

Step 3. After the execution is done, you will see repositories named:

logs: containing all the generated logs,

reports: containing all the generated statistics,

scripts: containing all the generated scripts,

tests: containing the automatically generated tests for the twelve apis presented in the paper for the black-Box mode.


For white-box experiments:

jar: runnable jar for EvoMaster.

petclinic source code is in: https://github.com/EMResearch/EMB
under the repository: jdk_8_maven

patio-api source code is in: https://github.com/EMResearch/EMB
under the repository: jdk_11_gradle