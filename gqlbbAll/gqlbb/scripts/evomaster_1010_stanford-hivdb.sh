#!/bin/bash 


echo "Starting EvoMaster with: "C:\Program Files\AdoptOpenJDK\jdk-8.0.265.01-hotspot"/bin/java  -Xms2G -Xmx4G  -jar evomaster.jar  --problemType GRAPHQL --ratePerMinute 60 --blackBox=True --bbExperiments=False --bbTargetUrl https://hivdb.stanford.edu/graphql --testSuiteFileName=EM_bbExp_False_rate_60_1_Test --outputFormat JAVA_JUNIT_4 --testSuiteSplitType=NONE --stoppingCriterion=FITNESS_EVALUATIONS --maxActionEvaluations=1000 --statisticsColumnId=stanford-hivdb --seed=1 --sutControllerPort=1010 --outputFolder=C:/Users/asmab/codes/EAST-papers/2022/icst-graphql/scripts/gqlbb/tests/stanford-hivdb --statisticsFile=C:/Users/asmab/codes/EAST-papers/2022/icst-graphql/scripts/gqlbb/reports/statistics_stanford-hivdb_1.csv --snapshotInterval=5 --snapshotStatisticsFile=C:/Users/asmab/codes/EAST-papers/2022/icst-graphql/scripts/gqlbb/reports/snapshot_stanford-hivdb_1.csv --appendToStatisticsFile=true --writeStatistics=true --showProgress=false >> C:/Users/asmab/codes/EAST-papers/2022/icst-graphql/scripts/gqlbb/logs/evomaster-gql/log_em_stanford-hivdb_1010.txt 2>&1"
echo

"C:\Program Files\AdoptOpenJDK\jdk-8.0.265.01-hotspot"/bin/java  -Xms2G -Xmx4G  -jar evomaster.jar  --problemType GRAPHQL --ratePerMinute 60 --blackBox=True --bbExperiments=False --bbTargetUrl https://hivdb.stanford.edu/graphql --testSuiteFileName=EM_bbExp_False_rate_60_1_Test --outputFormat JAVA_JUNIT_4 --testSuiteSplitType=NONE --stoppingCriterion=FITNESS_EVALUATIONS --maxActionEvaluations=1000 --statisticsColumnId=stanford-hivdb --seed=1 --sutControllerPort=1010 --outputFolder=C:/Users/asmab/codes/EAST-papers/2022/icst-graphql/scripts/gqlbb/tests/stanford-hivdb --statisticsFile=C:/Users/asmab/codes/EAST-papers/2022/icst-graphql/scripts/gqlbb/reports/statistics_stanford-hivdb_1.csv --snapshotInterval=5 --snapshotStatisticsFile=C:/Users/asmab/codes/EAST-papers/2022/icst-graphql/scripts/gqlbb/reports/snapshot_stanford-hivdb_1.csv --appendToStatisticsFile=true --writeStatistics=true --showProgress=false >> C:/Users/asmab/codes/EAST-papers/2022/icst-graphql/scripts/gqlbb/logs/evomaster-gql/log_em_stanford-hivdb_1010.txt 2>&1 
