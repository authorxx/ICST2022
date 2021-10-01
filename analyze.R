source("../../../utils/util.R")
source("formatutil.R")

GENERATED_FILES = paste("../generated_files", sep = "")
DATA_DIR = paste("../scripts/gqlbbAll", sep = "")
SAVE_DIR = paste("../results", sep = "")
ZIP_FILE = paste(SAVE_DIR, "/", "compressedData.zip", sep = "")
SNAP_ZIP_FILE = paste(SAVE_DIR, "/", "snapshotCompressedData.zip", sep = "")

ignoreColumns <- c()

init <- function(){
    k = gatherAndSaveData(DATA_DIR, ZIP_FILE, ignoreColumns)
    z = gatherAndSaveData(DATA_DIR, SNAP_ZIP_FILE, ignoreColumns, "^snapshot(\\w|-|_)*\\.csv$")
}

all <- function(){
    coverageGraph(budget = 100000)
    coverageGraph(budget = 1000000, prefix = "1m_coverage", sprojects = "petclinic")
    
    tableAll(budget = 100000, prefix = "table")
    tableAll(budget = 1000000, prefix = "1m_table", sprojects = "petclinic")
}


blackbox <- function(budget = 120){
    dt <- read.table(gzfile(ZIP_FILE), header = T)
    
    
    TABLE = paste(GENERATED_FILES, "/blackbox_gql",".tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    
    
    cat("\\begin{tabular}{ l r r r}\\\\ \n")
    cat("\\toprule \n")
    
    cat("SUT & \\#Endpoints & \\#NoErrors & \\#gqlErrors \\\\ \n", sep = "")
    cat("\\midrule \n")
    
    projects = sort(unique(dt$id))
    
    dactions <- dt$distinctActions
    gnoerrors <- dt$gqlNoErrors
    gerrors <- dt$gqlErrors
    
    for (project in projects) {
        
        cat("\\emph{", project, "}", sep = "")
        
        mask = dt$id == project & dt$maxActionEvaluations == budget
        
        cat("& ",dactions[mask], "& ", gnoerrors[mask], "& ", gerrors[mask] , "\\\\ \n", sep = "")
    }
    
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    
    sink()
}

coverageGraph <- function(budget = NULL, prefix = "coverage", sprojects = NULL){
    dt <- read.table(gzfile(SNAP_ZIP_FILE), header = T)

    projects = sort(unique(dt$id))
    if(!is.null(sprojects))
        projects <- projects[projects %in% sprojects]
    
    budgets <- sort(unique(dt$maxActionEvaluations))
    if(!is.null(budget))
        budgets <- c(budget)

    for(budget in budgets){
        for (proj in projects) {
            
            baseMask = dt$id == proj & dt$maxActionEvaluations == budget
            mioMask = baseMask & dt$blackBox == "false" &dt$algorithm == "MIO"
            rsMask = baseMask & dt$blackBox == "false" & dt$algorithm == "RANDOM"
            
            
            targets = sort(unique(dt$interval))
            z = length(targets)
            
            BB = rep(0, times = z)
            MIO = rep(0, times = z)
            RAND = rep(0, times = z)
            
            for (i in 1 : z) {
                targetMask = dt$interval == targets[[i]]
                MIO[[i]] = mean(dt$coveredTargets[targetMask & mioMask])
                RAND[[i]] = mean(dt$coveredTargets[targetMask & rsMask])
            }
            
            plot_colors = c("blue", "red")
            line_width = 2
            
            pdf(paste(GENERATED_FILES, "/", prefix,"_",proj,".pdf", sep = ""))
            
            yMin = min(MIO,RAND)
            yMax = max(MIO,RAND)
            
            plot(MIO, ylim = c(yMin, yMax), type = "o", col = plot_colors[[1]], pch = 21, lty = 1, lwd = line_width, ylab = "Covered Targets", xlab = "Budget Percentage", xaxt = "n")
            axis(side = 1, labels = targets, at = 1 : z)
            
            lines(RAND, type = "o", col = plot_colors[[2]], pch = 22, lty = 2, lwd = line_width)
            
            lx = 15
            ly = yMin + 0.5 * (yMax - yMin)
            
            legend(lx, ly, c("MIO", "RAND")
                   , cex = 1.2, col = plot_colors
                   , pch = 21 : 22
                   , lty = 1 : 2)
            
            dev.off()
        }
    }
}

tableAll <- function(usedMetrics = NULL, budget = NULL, prefix = "table", sprojects = NULL){
    
    dt <- read.table(gzfile(ZIP_FILE), header = T)
    
    
    TABLE = paste(GENERATED_FILES, "/", prefix, "_","all",".tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    
    cat("\\begin{tabular}{ l l r r r r r }\\\\ \n")
    cat("\\toprule \n")
    
    ## TODO if the budgets > 2
    cat("SUT & Metrics & MIO & Random & $\\hat{A}_{12}$ & \\emph{p}-value  & Relative \\\\ \n", sep = "")
    cat("\\midrule \n")
    
    projects = sort(unique(dt$id))
    
    if(!is.null(sprojects))
        projects <- projects[projects %in% sprojects]
    
    budgets <- budget
    if(is.null(budgets))
        budgets <- sort(unique(dt$maxActionEvaluations))
    
    metrics <- usedMetrics
    if(is.null(metrics))
        metrics <- c("coveredTargets", "coveredLines", "faults")
        
    
    for (proj in projects) {
        
        cat("\\emph{", proj, "}", sep = "")
        
        for (budget in budgets) {
            
            for (metric in metrics) {
                cat("&", formatValue(metric) , sep = "")
                avgAndCompare(dt, metric, budget, proj, TRUE)
            }
            
        }
        
    }
    
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    
    sink()
}

avgAndCompare <- function(dt, metric, budget, project, lastColumn = TRUE){
    
    projectMask = dt$id == project
    budgetMask =  projectMask & dt$maxActionEvaluations == budget
    
    data <- NULL
    tot <- NULL
    if (identical(metric, "coveredTargets"))
        data <- dt$coveredTargets
    else if(identical(metric, "coveredLines")){
        data <- dt$coveredLines
        tot <- max(dt$numberOfLines[projectMask])
    }else if(identical(metric, "faults"))
        data <- dt$potentialFaults
    else
        stop(metric)
    
    
    rs = data[budgetMask  & dt$algorithm=="RANDOM"]
    mio = data[budgetMask & dt$algorithm=="MIO"]
    
    all <- c(mean(rs), mean(mio))
    
    cat(" & ")
    #mv<-paste(formatC(mean(mio), digits = 1, format = "f"), sep = "")
    cat(highlighBest(value=NULL, c=mean(mio), vs=all,total= tot, includeRank= FALSE))
    
    cat(" & ")
    #rv<-paste(formatC(mean(rs), digits = 1, format = "f"), sep = "")
    cat(highlighBest(value=NULL, c= mean(rs), vs= all,total= tot, includeRank =  FALSE))
    
    a12 = measureA(mio, rs)
    
    a12v=paste(formatC(a12, digits = 2, format = "f"), sep = "")
    
    w = wilcox.test(mio, rs)
    p = w$p.value
    
    
    # format p
    pv=""
    if(is.nan(p)){
        pv="NaN"
    }else{
        pv = paste(formatC(p, digits = 3, format = "f"), sep = "")
        
        if (p < 0.001) {
            pv = "$\\le $0.001"
        } 
    }
    
    cat(" & ")
    cat(formatedValue(a12v, a12, p))
    
    cat(" & ")
    cat(formatedValue(pv, a12, p))
    
    cat(" & ")
    cat(formatedValue(relative(mean(mio), mean(rs)), a12, p))
    if(lastColumn)
        cat(lastColumnAppend())
}


selectBestAndWorstLines <- function(budget = NULL){
    
    dt <- read.table(gzfile(ZIP_FILE), header = T)
    name = "lines"
    
    SELECT = paste(GENERATED_FILES, "/select_best_and_worst.txt", sep = "")
    unlink(SELECT)
    sink(SELECT, append = TRUE, split = TRUE)
    
    
    projects = sort(unique(dt$id))
    
    for (proj in projects) {
        cat("\n\n-------------------------------------\n")
        cat(proj, "\n")
        projectMask = dt$id == proj
        if(!is.null(budget))
            projectMask = dt$id == proj & dt$maxActionEvaluations == budget
        
        sdt <- subset(dt, projectMask & dt$algorithm=="MIO")
        best <- sdt[which.max(sdt$coveredLines),]
        worst <- sdt[which.min(sdt$coveredLines),]
        
        bestTargets <- sdt[which.max(sdt$coveredTargets),]
        worstTargets <- sdt[which.min(sdt$coveredTargets),]
        
        cat("best is a seed at ", best$seed, " which achives ",best$coveredLines, " lines / total(",max(dt$numberOfLines[projectMask]), ")\n", sep = "")
        cat("best is a seed at ", bestTargets$seed, " which achives ",bestTargets$coveredTargets, " targets \n", sep = "")
        
        
        cat("worst is a seed at ", worst$seed, " which achives ",worst$coveredLines, " lines / total(",max(dt$numberOfLines[projectMask]), ")\n", sep = "")
        cat("worst is a seed at ", worstTargets$seed, " which achives ",worstTargets$coveredTargets, " targets \n", sep = "")
        
        
    }
    
    sink()
}

#selectBestAndWorstLines(100000)
#all()
