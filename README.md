# ICST2022: White-Box and Black-Box Automated Testing for GraphQL APIs

In this package, we provide necessary information for replicating the experiment in the paper. We provide:

## Black-Box experiments

- jar: runnable jar for EvoMaster.

- exp.py: a python script to build tools and all the twelve case studies

- results: contains compressed generated data

- gqlbbAll: contains all the automatically generated files including logs, reports, scripts and tests. 

- analyze.R: an R script to analyze results and generate table and figures in the paper.

- EvoMaster: the tool used in the paper.

- EMB: contains the APIs used for white-box experiments in the paper

###Quick build and run:

Step 1. In this repo, we provide a python script.

Go to the root, run

`python exp.py no 1000 bbgqlicst 1 1 1000 400 12 no`

Step 2. After the execution is done, you will see a folder named bbgqlicst. Go to bbgqlicst and run:

`./runall.sh`

Step 3. After the execution is done, you will see repositories named:

- logs: containing all the generated logs,

- reports: containing all the generated statistics,

- scripts: containing all the generated scripts,

- tests: containing the automatically generated tests for the twelve apis presented in the paper for the black-Box mode.


## white-box experiments

### run 
jar: runnable jar for EvoMaster.

petclinic 
- source code: `EMB/jdk_8_maven/cs/graphql/spring-petclinic-graphql`
- Embedded EM driver: `EMB/jdk_8_maven/em/embedded/graphql/spring-petclinic-graphql/src/main/java/em/embedded/org/springframework/samples/petclinic/EmbeddedEvoMasterController.java`
- External EM driver:`EMB/jdk_8_maven/em/external/graphql/spring-petclinic-graphql/src/main/java/em/external/org/springframework/samples/petclinic/ExternalEvoMasterController.java`

patio-api
- source code: `EMB/jdk_11_gradle/cs/graphql/patio-api`
- Embedded EM driver:`EMB/jdk_11_gradle/em/embedded/graphql/patio-api/src/main/java/em/embedded/patio/EmbeddedEvoMasterController.java`
- External EM driver:`EMB/jdk_11_gradle/em/external/graphql/patio-api/src/main/java/em/external/patio/ExternalEvoMasterController.java`

Step 1: run Embedded/External EM Driver

Step 2: run `evomaster.jar` with following configurations
- `--problemType=GRAPHQL`
- `--algorithm=` MIO or RANDOM
- `--maxActionEvaluations=100` we use 100000 in the paper 
- `--testSuiteFileName=EMTest` 
- `--testSuiteSplitType=NONE`
- `--writeStatistics=true --snapshotInterval=5`

in the root, you will get 
- `EMTest.java` is a generated test
- `statistics.csv` contains statistics info (like coverage targets, covered lines) for the generation
- `snapshot.csv` contains snapshot of statistics info

### results
In wb-results, we provide compressed all statistics and snapshot files, i.e., 30 runs with MIO and Random using 100000 HTTP calls as search budget.



