# file:   ichorCNA.R
# authors: Gavin Ha, Ph.D.
#          Fred Hutch
# contact: <gha@fredhutch.org>
#
#         Justin Rhoades
#          Broad Institute
# contact: <rhoades@broadinstitute.org>

# ichorCNA: https://github.com/broadinstitute/ichorCNA
# date:   July 24, 2019
# description: Hidden Markov model (HMM) to analyze Ultra-low pass whole genome sequencing (ULP-WGS) data.
# This script is the main script to run the HMM.

library(optparse)

option_list <- list(
  # make_option(c("--id"), type = "character", default="test", help = "Patient ID. Default: [%default]"),
  make_option(c("--id"), type = "character", default="test_hmmsegment_cor", help = "Patient ID. Default: [%default]"),
  # make_option(c("--copy"), type = "character", default="NULL", help = "Path to tumor WIG file. Required."),
  # make_option(c("--copy"), type = "character", default="test_HMMSegment/do_preproc/test.correctedDepth.txt", help = "Path to tumor WIG file. Required."),
  make_option(c("--copy"), type = "character", default="examples/data/cov_5_tc_0_replicate_0.tsv.gz", help = "Path to tumor WIG file. Required."),
  make_option(c("--normal"), type="character", default="c(0.5)", help = "Initial normal contamination; can be more than one value if additional normal initializations are desired. Default: [%default]"),
  # make_option(c("--normal"), type="character", default="c(0.1, 0.2, 0.3, 0.5)", help = "Initial normal contamination; can be more than one value if additional normal initializations are desired. Default: [%default]"),
  make_option(c("--scStates"), type="character", default="NULL", help = "Subclonal states to consider. Default: [%default]"),
  make_option(c("--coverage"), type="numeric", default=NULL, help = "PICARD sequencing coverage. Default: [%default]"),
  make_option(c("--lambda"), type="character", default="NULL", help="Initial Student's t precision; must contain 4 values (e.g. c(1500,1500,1500,1500)); if not provided then will automatically use based on variance of data. Default: [%default]"),
  make_option(c("--lambdaScaleHyperParam"), type="numeric", default=3, help="Hyperparameter (scale) for Gamma prior on Student's-t precision. Default: [%default]"),
  #	make_option(c("--kappa"), type="character", default=50, help="Initial state distribution"),
  make_option(c("--ploidy"), type="character", default="2", help = "Initial tumour ploidy; can be more than one value if additional ploidy initializations are desired. Default: [%default]"),
  make_option(c("--maxCN"), type="numeric", default=7, help = "Total clonal CN states. Default: [%default]"),
  make_option(c("--estimateNormal"), type="logical", default=TRUE, help = "Estimate normal. Default: [%default]"),
  make_option(c("--estimateScPrevalence"), type="logical", default=TRUE, help = "Estimate subclonal prevalence. Default: [%default]"),
  make_option(c("--estimatePloidy"), type="logical", default=TRUE, help = "Estimate tumour ploidy. Default: [%default]"),
  make_option(c("--maxFracCNASubclone"), type="numeric", default=0.7, help="Exclude solutions with fraction of subclonal events greater than this value. Default: [%default]"),
  make_option(c("--maxFracGenomeSubclone"), type="numeric", default=0.5, help="Exclude solutions with subclonal genome fraction greater than this value. Default: [%default]"),
  make_option(c("--minSegmentBins"), type="numeric", default=50, help="Minimum number of bins for largest segment threshold required to estimate tumor fraction; if below this threshold, then will be assigned zero tumor fraction."),
  make_option(c("--altFracThreshold"), type="numeric", default=0.05, help="Minimum proportion of bins altered required to estimate tumor fraction; if below this threshold, then will be assigned zero tumor fraction. Default: [%default]"),
  make_option(c("--chrNormalize"), type="character", default="c(1:22)", help = "Specify chromosomes to normalize GC/mappability biases. Default: [%default]"),
  make_option(c("--chrTrain"), type="character", default="c(1:22)", help = "Specify chromosomes to estimate params. Default: [%default]"),
  make_option(c("--chrs"), type="character", default="c(1:22,\"X\")", help = "Specify chromosomes to analyze. Default: [%default]"),
  make_option(c("--genomeBuild"), type="character", default="hg19", help="Geome build. Default: [%default]"),
  make_option(c("--genomeStyle"), type = "character", default = "NCBI", help = "NCBI or UCSC chromosome naming convention; use UCSC if desired output is to have \"chr\" string. [Default: %default]"),
  make_option(c("--normalizeMaleX"), type="logical", default=TRUE, help = "If male, then normalize chrX by median. Default: [%default]"),
  make_option(c("--minTumFracToCorrect"), type="numeric", default=0.1, help = "Tumor-fraction correction of bin and segment-level CNA if sample has minimum estimated tumor fraction. [Default: %default]"), 
  make_option(c("--fracReadsInChrYForMale"), type="numeric", default=0.001, help = "Threshold for fraction of reads in chrY to assign as male. Default: [%default]"),
  make_option(c("--includeHOMD"), type="logical", default=FALSE, help="If FALSE, then exclude HOMD state. Useful when using large bins (e.g. 1Mb). Default: [%default]"),
  make_option(c("--txnE"), type="numeric", default=0.9999999, help = "Self-transition probability. Increase to decrease number of segments. Default: [%default]"),
  make_option(c("--txnStrength"), type="numeric", default=1e7, help = "Transition pseudo-counts. Exponent should be the same as the number of decimal places of --txnE. Default: [%default]"),
  make_option(c("--plotFileType"), type="character", default="pdf", help = "File format for output plots. Default: [%default]"),
	make_option(c("--plotYLim"), type="character", default="c(-2,2)", help = "ylim to use for chromosome plots. Default: [%default]"),
  # make_option(c("--outDir"), type="character", default="./", help = "Output Directory. Default: [%default]"),
  # make_option(c("--libdir"), type = "character", default=NULL, help = "Script library path. Usually exclude this argument unless custom modifications have been made to the ichorCNA R package code and the user would like to source those R files. Default: [%default]")
  make_option(c("--outDir"), type="character", default="outputs", help = "Output Directory. Default: [%default]"),
  make_option(c("--libdir"), type = "character", default="myichorcna/ichorCNA", help = "Script library path. Usually exclude this argument unless custom modifications have been made to the ichorCNA R package code and the user would like to source those R files. Default: [%default]")
)
parseobj <- OptionParser(option_list=option_list)
opt <- parse_args(parseobj)
print(opt)
options(scipen=0, stringsAsFactors=F)

library(HMMcopy)
library(GenomicRanges)
library(GenomeInfoDb)
options(stringsAsFactors=FALSE)
options(bitmapType='cairo')

patientID <- opt$id
copy <- opt$copy
normal <- eval(parse(text = opt$normal))
scStates <- eval(parse(text = opt$scStates))
lambda <- eval(parse(text = opt$lambda))
lambdaScaleHyperParam <- opt$lambdaScaleHyperParam
estimateNormal <- opt$estimateNormal
estimatePloidy <- opt$estimatePloidy
estimateScPrevalence <- opt$estimateScPrevalence
maxFracCNASubclone <- opt$maxFracCNASubclone
maxFracGenomeSubclone <- opt$maxFracGenomeSubclone
minSegmentBins <- opt$minSegmentBins
altFracThreshold <- opt$altFracThreshold
ploidy <- eval(parse(text = opt$ploidy))
coverage <- opt$coverage
maxCN <- opt$maxCN
txnE <- opt$txnE
txnStrength <- opt$txnStrength
normalizeMaleX <- as.logical(opt$normalizeMaleX)
includeHOMD <- as.logical(opt$includeHOMD)
minTumFracToCorrect <- opt$minTumFracToCorrect
fracReadsInChrYForMale <- opt$fracReadsInChrYForMale
chrXMedianForMale <- -0.1
outDir <- opt$outDir
libdir <- opt$libdir
plotFileType <- opt$plotFileType
plotYLim <- eval(parse(text=opt$plotYLim))
gender <- NULL
outImage <- paste0(outDir,"/", patientID,".RData")
genomeBuild <- opt$genomeBuild
genomeStyle <- opt$genomeStyle
chrs <- as.character(eval(parse(text = opt$chrs)))
chrTrain <- as.character(eval(parse(text=opt$chrTrain))); 
chrNormalize <- as.character(eval(parse(text=opt$chrNormalize))); 
seqlevelsStyle(chrs) <- genomeStyle
seqlevelsStyle(chrNormalize) <- genomeStyle
seqlevelsStyle(chrTrain) <- genomeStyle

## load ichorCNA library or source R scripts
if (!is.null(libdir) && libdir != "None"){
	source(paste0(libdir,"/R/utils.R"))
	source(paste0(libdir,"/R/segmentation.R"))
	source(paste0(libdir,"/R/EM.R"))
	source(paste0(libdir,"/R/output.R"))
	source(paste0(libdir,"/R/plotting.R"))
} else {
    library(ichorCNA)
}


dir <- paste0(outDir, "/", patientID, "/")
if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
}

outputHMM <- function(cna, segs, results, patientID = NULL, outDir = "."){
  names <- c("HOMD","HETD","NEUT","GAIN","AMP","HLAMP",paste0(rep("HLAMP", 8), 2:25))
  
  S <- results$param$numberSamples
  
  segout <- NULL
  shuffle <- NULL
  if (is.null(patientID)){
    patientID <- names(cna)[1]
  }
  ### PRINT OUT SEGMENTS FOR EACH SAMPLE TO SEPARATE FILES ###
  for (s in 1:S){
    id <- names(cna)[s]
    bin_size <- as.numeric(cna[[s]][1,"end"]) - as.numeric(cna[[s]][1,"start"]) + 1
    markers <- (segs[[s]]$end - segs[[s]]$start + 1) / bin_size  
    segTmp <- cbind(sample = as.character(id), segs[[s]][, 1:3],
                    event = names[segs[[s]]$copy.number + 1],
                    copy.number = segs[[s]]$copy.number, 
                    bins = markers,
                    median = segs[[s]]$median,
                    subclone.status=segs[[s]]$subclone.status
                    # segs[[s]][, 9:ncol(segs[[s]])]
                    )
    segout <- rbind(segout, segTmp[, 1:8])
    ### Re-ordering the columns for output ###
    shuffleTmp <- segTmp[, c(1, 2, 3, 4, 7, 8, 6, 5, 9:ncol(segTmp))]
    colnames(shuffleTmp)[1:9] <- c("ID", "chrom", "start", "end", "num.mark", "seg.median.logR", "copy.number", "call", "subclone.status")
    shuffle <- rbind(shuffle, shuffleTmp) 
  }

  segsDir <- paste0(outDir, "/", "segs")
  if (!dir.exists(segsDir)) {
      dir.create(segsDir, recursive = TRUE)
  }

  
  shu_out = paste(segsDir, "/", patientID,".seg.txt",sep="")
  seg_out = paste(segsDir, "/", patientID,".seg",sep="")
  message("Writing segments to ", seg_out)
  write.table(shuffle, file = shu_out, quote = FALSE, sep = "\t", row.names = FALSE)
  write.table(segout, file = seg_out, quote = FALSE, sep = "\t", row.names = FALSE)
  ### PRINT OUT BIN-LEVEL DATA FOR ALL SAMPLES IN SAME FILE ##
  cnaout <- cbind(cna[[1]][, -c(1)])
  # colnames(cnaout)[4:ncol(cnaout)] <- paste0(names(cna)[1], ".", colnames(cnaout)[4:ncol(cnaout)])
  colnames(cnaout)[4:ncol(cnaout)] <- paste0(colnames(cnaout)[4:ncol(cnaout)])
  if (S >= 2) {
    for (s in 2:S){
      id <- names(cna)[s]
      cnaTmp <- cna[[s]][, -c(1)]
      # colnames(cnaTmp)[4:ncol(cnaTmp)] <- paste0(id, ".", colnames(cnaTmp)[4:ncol(cnaTmp)])
      colnames(cnaTmp)[4:ncol(cnaTmp)] <- paste0(colnames(cnaTmp)[4:ncol(cnaTmp)])
      cnaout <- merge(cnaout, cnaTmp, by = c("chr", "start", "end"))
    }
  }
  cnaout$chr <- factor(cnaout$chr, levels = unique(cna[[1]]$chr))
  cnaout <- cnaout[order(cnaout[, 1], cnaout[, 2], cnaout[, 3]), ]
  cna_out = paste(outDir,"/", patientID,".cna.seg",sep="")
  message("Outputting to bin-level results to ", cna_out)
  write.table(cnaout, file = cna_out, quote = FALSE, sep = "\t", row.names = FALSE)
}


HMMsegment <- function(x, validInd = NULL, dataType = "copy", param = NULL, 
    chrTrain = c(1:22), maxiter = 50, estimateNormal = TRUE, estimatePloidy = TRUE, 
    estimatePrecision = TRUE, estimateSubclone = TRUE, estimateTransition = TRUE,
    estimateInitDist = TRUE, logTransform = FALSE, verbose = TRUE) {
  chr <- as.factor(seqnames(x[[1]]))
	# setup columns for multiple samples #
	dataMat <- as.matrix(as.data.frame(lapply(x, function(y) { mcols(x[[1]])[, dataType] })))
	
	# normalize by median and log data #
	if (logTransform){
    dataMat <- apply(dataMat, 2, function(x){ log(x / median(x, na.rm = TRUE)) })
	}else{
	  dataMat <- log(2^dataMat)
	}
	## update variable x with loge instead of log2
  for (i in 1:length(x)){
    mcols(x[[i]])[, dataType] <- dataMat[, i]
  }
  if (!is.null(chrTrain)) {
		chrInd <- chr %in% chrTrain
  }else{
  	chrInd <- !logical(length(chr))
  }
  if (!is.null(validInd)){
    chrInd <- chrInd & validInd
  }  

	if (is.null(param)){
		param <- getDefaultParameters(dataMat[chrInd])
	}
	#if (param$n_0 == 0){
	#	param$n_0 <- .Machine$double.eps
	#}
	####### RUN EM ##########
  convergedParams <- runEM(dataMat, chr, chrInd, param, maxiter, 
      verbose, estimateNormal = estimateNormal, estimatePloidy = estimatePloidy, 
      estimateSubclone = estimateSubclone, estimatePrecision = estimatePrecision, 
      estimateTransition = estimateTransition, estimateInitDist = estimateInitDist)
  # Calculate likelihood using converged params
 # S <- param$numberSamples
 # K <- length(param$ct)
 # KS <- K ^ S
 # py <- matrix(0, KS, nrow(dataMat))
 # iter <- convergedParams$iter
  # lambdasKS <- as.matrix(expand.grid(as.data.frame(convergedParams$lambda[, , iter])))
  # for (ks in 1:KS) {
  #   probs <- tdistPDF(dataMat, convergedParams$mus[ks, , iter], lambdasKS[ks, ], param$nu)
  #   py[ks, ] <- apply(probs, 1, prod) # multiply across samples for each data point to get joint likelihood.
  # }
  # 
  viterbiResults <- runViterbi(convergedParams, chr)
  
  # setup columns for multiple samples #
  segs <- segmentData(x, validInd, viterbiResults$states, convergedParams)
  #output$segs <- processSegments(output$segs, chr, start(x), end(x), x$DataToUse)
  names <- c("HOMD","HETD","NEUT","GAIN","AMP","HLAMP",paste0(rep("HLAMP", 8), 2:25))
  #if (c(0) %in% param$ct){ #if state 0 HOMD is IN params#
  	#names <- c("HOMD", names)
  	# shift states to start at 2 (HETD)
    #tmp <- lapply(segs, function(x){ x$state <- x$state + 1; x})
    #viterbiResults$states <- as.numeric(viterbiResults$states) + 1
	#}
	### PUTTING TOGETHER THE COLUMNS IN THE OUTPUT ###
  cnaList <- list()
  S <- length(x)
  for (s in 1:S){
    id <- names(x)[s]
    copyNumber <- param$jointCNstates[viterbiResults$state, s]
    subclone.status <- param$jointSCstatus[viterbiResults$state, s]
  	cnaList[[id]] <- data.frame(cbind(sample = as.character(id), 
                  chr = as.character(seqnames(x[[s]])),	
                  start = start(x[[s]]), end = end(x[[s]]), 
                  copy.number = copyNumber,
                  event = names[copyNumber + 1], 
                  logR = round(log2(exp(dataMat[,s])), digits = 4),
                  subclone.status = as.numeric(subclone.status)
  	))
  
    cnaList[[id]] <- transform(cnaList[[id]], 
                              start = as.integer(as.character(start)),
                              end = as.integer(as.character(end)), 
                              copy.number = as.numeric(copy.number),
                              logR = as.numeric(as.character(logR)),
                              subclone.status = as.numeric(subclone.status))
  
  	## order by chromosome ##
  	chrOrder <- unique(chr) #c(1:22,"X","Y")
  	cnaList[[id]] <- cnaList[[id]][order(match(cnaList[[id]][, "chr"],chrOrder)),]
  	## remove MT chr ##
    cnaList[[id]] <- cnaList[[id]][cnaList[[id]][,"chr"] %in% chrOrder, ]
    
    ## segment mean loge -> log2
    #segs[[s]]$median.logR <- log2(exp(segs[[s]]$median.logR))
    segs[[s]]$median <- log2(exp(segs[[s]]$median))
    ## add subclone status
    segs[[s]]$subclone.status <-  param$jointSCstatus[segs[[s]]$state, s]
  }	
  convergedParams$segs <- segs
  return(list(cna = cnaList, results = convergedParams, viterbiResults = viterbiResults))
}

# Load in data 
loaded_copy <- read.csv(copy, sep='\t')
loaded_copy <- loaded_copy[, c('chrom', 'start', 'end', 'rdr')]
names(loaded_copy)[names(loaded_copy) == 'rdr'] <- 'copy'
names(loaded_copy)[names(loaded_copy) == 'chrom'] <- 'chr'
loaded_copy$chr <- gsub("chr", "", loaded_copy$chr)
loaded_copy$copy <- log(loaded_copy$copy, base=2)

# names(loaded_copy)[names(loaded_copy) == 'log2_TNratio_corrected'] <- 'copy'
span <- loaded_copy$end[1] - loaded_copy$start[1] + 1
gr_loaded_copy <- GenomicRanges::GRanges(
  ranges = IRanges(start = loaded_copy$start, width = span),
  seqnames = loaded_copy$chr, 
  copy = loaded_copy$copy
)

tumour_copy <- list()
tumour_copy[[patientID]] <- gr_loaded_copy
chrInd <- as.character(seqnames(tumour_copy[[1]])) %in% chrTrain
valid <- rep(TRUE, length(tumour_copy[[1]]$copy))
numSamples <- 1
gender <- list()
gender$gender <- "female"

# create Genomic Ranges object 

### RUN HMM ###
## store the results for different normal and ploidy solutions ##
ptmTotalSolutions <- proc.time() # start total timer
results <- list()
loglik <- as.data.frame(
  matrix(NA, nrow = length(normal) * length(ploidy), ncol = 7, 
  dimnames = list(c(), c("init", "n_est", "phi_est", "BIC", "Frac_genome_subclonal", "Frac_CNA_subclonal", "loglik")
  )))
counter <- 1
compNames <- rep(NA, nrow(loglik))
mainName <- rep(NA, length(normal) * length(ploidy))
#### restart for purity and ploidy values ####
for (n in normal){
  for (p in ploidy){
    if (n == 0.95 & p != 2) {
        next
    }
    logR <- as.data.frame(lapply(tumour_copy, function(x) { x$copy })) # NEED TO EXCLUDE CHR X #
    param <- getDefaultParameters(logR[valid & chrInd, , drop=F], maxCN = maxCN, includeHOMD = includeHOMD, 
                ct.sc=scStates, ploidy = floor(p), e=txnE, e.same = 50, strength=txnStrength)
    param$phi_0 <- rep(p, numSamples)
    param$n_0 <- rep(n, numSamples)
    
    ############################################
    ######## CUSTOM PARAMETER SETTINGS #########
    ############################################
    # 0.1x cfDNA #
    if (is.null(lambda)){
			logR.var <- 1 / ((apply(logR, 2, sd, na.rm = TRUE) / sqrt(length(param$ct))) ^ 2)
			param$lambda <- rep(logR.var, length(param$ct))
			param$lambda[param$ct %in% c(2)] <- logR.var 
			param$lambda[param$ct %in% c(1,3)] <- logR.var 
			param$lambda[param$ct >= 4] <- logR.var / 5
			param$lambda[param$ct == max(param$ct)] <- logR.var / 15
			param$lambda[param$ct.sc.status] <- logR.var / 10
    }else{
			param$lambda[param$ct %in% c(2)] <- lambda[2]
			param$lambda[param$ct %in% c(1)] <- lambda[1]
			param$lambda[param$ct %in% c(3)] <- lambda[3]
			param$lambda[param$ct >= 4] <- lambda[4]
			param$lambda[param$ct == max(param$ct)] <- lambda[2] / 15
			param$lambda[param$ct.sc.status] <- lambda[2] / 10
		}
		param$alphaLambda <- rep(lambdaScaleHyperParam, length(param$ct))  
				
		#############################################
		################ RUN HMM ####################
		#############################################
    hmmResults.cor <- HMMsegment(tumour_copy, valid, dataType = "copy", 
                                 param = param, chrTrain = chrTrain, maxiter = 50,
                                 estimateNormal = estimateNormal, estimatePloidy = estimatePloidy,
                                 estimateSubclone = estimateScPrevalence, verbose = TRUE)

    for (s in 1:numSamples){
  		iter <- hmmResults.cor$results$iter
  		id <- names(hmmResults.cor$cna)[s]

  		## convert full diploid solution (of chrs to train) to have 1.0 normal or 0.0 purity
  		## check if there is an altered segment that has at least a minimum # of bins
  		segsS <- hmmResults.cor$results$segs[[s]]
  		segsS <- segsS[segsS$chr %in% chrTrain, ]
  		segAltInd <- which(segsS$event != "NEUT")
  		maxBinLength = -Inf
  		if (sum(segAltInd) > 0){
  			maxInd <- which.max(segsS$end[segAltInd] - segsS$start[segAltInd] + 1)
  			maxSegRD <- GRanges(seqnames=segsS$chr[segAltInd[maxInd]], 
  								ranges=IRanges(start=segsS$start[segAltInd[maxInd]], end=segsS$end[segAltInd[maxInd]]))
  			hits <- findOverlaps(query=maxSegRD, subject=tumour_copy[[s]][valid, ])
  			maxBinLength <- length(subjectHits(hits))
  		}
  		## check if there are proportion of total bins altered 
  		# if segment size smaller than minSegmentBins, but altFrac > altFracThreshold, then still estimate TF
  		cnaS <- hmmResults.cor$cna[[s]]
  		altInd <- cnaS[cnaS$chr %in% chrTrain, "event"] == "NEUT"
  		altFrac <- sum(!altInd, na.rm=TRUE) / length(altInd)
  		if ((maxBinLength <= minSegmentBins) & (altFrac <= altFracThreshold)){
  			hmmResults.cor$results$n[s, iter] <- 1.0
  		}

      # correct integer copy number based on estimated purity and ploidy
      correctedResults <- correctIntegerCN(cn = hmmResults.cor$cna[[s]],
            segs = hmmResults.cor$results$segs[[s]], 
            purity = 1 - hmmResults.cor$results$n[s, iter], ploidy = hmmResults.cor$results$phi[s, iter],
            cellPrev = 1 - hmmResults.cor$results$sp[s, iter], 
            maxCNtoCorrect.autosomes = maxCN, maxCNtoCorrect.X = maxCN, minPurityToCorrect = minTumFracToCorrect, 
            gender = gender$gender, chrs = chrs, correctHOMD = includeHOMD)
      hmmResults.cor$results$segs[[s]] <- correctedResults$segs
      hmmResults.cor$cna[[s]] <- correctedResults$cn
    }

    iter <- hmmResults.cor$results$iter
    results[[counter]] <- hmmResults.cor
    loglik[counter, "loglik"] <- signif(hmmResults.cor$results$loglik[iter], digits = 4)
    subClonalBinCount <- unlist(lapply(hmmResults.cor$cna, function(x){ sum(x$subclone.status) }))
    fracGenomeSub <- subClonalBinCount / unlist(lapply(hmmResults.cor$cna, function(x){ nrow(x) }))
    fracAltSub <- subClonalBinCount / unlist(lapply(hmmResults.cor$cna, function(x){ sum(x$copy.number != 2) }))
    fracAltSub <- lapply(fracAltSub, function(x){if (is.na(x)){0}else{x}})
    loglik[counter, "Frac_genome_subclonal"] <- paste0(signif(fracGenomeSub, digits=2), collapse=",")
    loglik[counter, "Frac_CNA_subclonal"] <- paste0(signif(as.numeric(fracAltSub), digits=2), collapse=",")
    loglik[counter, "init"] <- paste0("n", n, "-p", p)
    loglik[counter, "n_est"] <- paste(signif(hmmResults.cor$results$n[, iter], digits = 2), collapse = ",")
    loglik[counter, "phi_est"] <- paste(signif(hmmResults.cor$results$phi[, iter], digits = 4), collapse = ",")
    counter <- counter + 1
  }
}
## get total time for all solutions ##
elapsedTimeSolutions <- proc.time() - ptmTotalSolutions
message("Total ULP-WGS HMM Runtime: ", format(elapsedTimeSolutions[3] / 60, digits = 2), " min.")

patientDir <- paste0(outDir, "/", patientID)
if (!dir.exists(patientDir)) {
    dir.create(patientDir, recursive = TRUE)
}

loglik <- loglik[!is.na(loglik$init), ]
write.csv(loglik, file = paste0(patientDir, "/", patientID, "_loglikelihoods.csv"), row.names = FALSE)

ind <- order(as.numeric(loglik[, "loglik"]), decreasing=TRUE) 
hmmResults.cor <- results[[ind[1]]]
hmmResults.cor$results$loglik <- as.data.frame(loglik)
hmmResults.cor$results$gender <- gender$gender
hmmResults.cor$results$chrYCov <- gender$chrYCovRatio
hmmResults.cor$results$chrXMedian <- gender$chrXMedian
hmmResults.cor$results$coverage <- coverage

outputHMM(cna = hmmResults.cor$cna,
          segs = hmmResults.cor$results$segs, 
          results = hmmResults.cor$results, 
          patientID = patientID,
          outDir=patientDir)
outFile <- paste0(patientDir, "/", patientID, ".params.txt")
outputParametersToFile(hmmResults.cor, file = outFile)
### PLOT TPDF ##
outPlotFile <- paste0(patientDir,"/",patientID,"_tpdf.pdf")
pdf(outPlotFile)
iter <- hmmResults.cor$results$iter
plotParam(mus = unique(hmmResults.cor$results$mus[,1,iter]), 
          lambdas = hmmResults.cor$results$lambdas[,1,iter], 
          subclone = hmmResults.cor$results$param$ct.sc.status,
          nu = hmmResults.cor$results$param$nu, copy.states = 1:maxCN)
dev.off()


s <- 1 
iter <- hmmResults.cor$results$iter
id <- names(hmmResults.cor$cna)[s]
ploidyEst <- hmmResults.cor$results$phi[s, iter]
normEst <- hmmResults.cor$results$n[s, iter]
purityEst <- 1 - normEst
ploidyAll <- (1 - normEst) * ploidyEst + normEst * 2

outPlotFile <- paste0(patientDir, "/", patientID, "_genomeWide")
seqinfo <- getSeqInfo(genomeBuild, genomeStyle)
plotGWSolution(
  hmmResults.cor, 
  s, 
  outPlotFile, 
  seqinfo, 
  logR.column = 'logR', 
  call.column = 'event', 
  plotFileType='pdf', 
  plotYLim=c(-2, 2),
  plotSegs=TRUE, 
  estimateScPrevalence=estimateScPrevalence, 
  main=patientID
)

