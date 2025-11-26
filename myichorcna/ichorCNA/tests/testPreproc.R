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
  make_option(c("--WIG"), type = "character", help = "Path to tumor WIG file. Required."),
  make_option(c("--NORMWIG"), type = "character", default=NULL, help = "Path to normal WIG file. Default: [%default]"),
  make_option(c("--gcWig"), type = "character", help = "Path to GC-content WIG file; Required"),
  make_option(c("--mapWig"), type = "character", default=NULL, help = "Path to mappability score WIG file. Default: [%default]"),
  make_option(c("--normalPanel"), type="character", default=NULL, help="Median corrected depth from panel of normals. Default: [%default]"),
  make_option(c("--exons.bed"), type = "character", default=NULL, help = "Path to bed file containing exon regions. Default: [%default]"),
  make_option(c("--id"), type = "character", default="test", help = "Patient ID. Default: [%default]"),
  make_option(c("--centromere"), type="character", default=NULL, help = "File containing Centromere locations; if not provided then will use hg19 version from ichorCNA package. Default: [%default]"),
  make_option(c("--minMapScore"), type = "numeric", default=0.9, help="Include bins with a minimum mappability score of this value. Default: [%default]."),
  make_option(c("--rmCentromereFlankLength"), type="numeric", default=0, help="Length of region flanking centromere to remove. Default: [%default]"),
  make_option(c("--coverage"), type="numeric", default=NULL, help = "PICARD sequencing coverage. Default: [%default]"),
  make_option(c("--chrNormalize"), type="character", default="c(1:22)", help = "Specify chromosomes to normalize GC/mappability biases. Default: [%default]"),
  make_option(c("--chrTrain"), type="character", default="c(1:22)", help = "Specify chromosomes to estimate params. Default: [%default]"),
  make_option(c("--chrs"), type="character", default="c(1:22,\"X\")", help = "Specify chromosomes to analyze. Default: [%default]"),
  make_option(c("--genomeBuild"), type="character", default="hg19", help="Geome build. Default: [%default]"),
  make_option(c("--genomeStyle"), type = "character", default = "NCBI", help = "NCBI or UCSC chromosome naming convention; use UCSC if desired output is to have \"chr\" string. [Default: %default]"),
  make_option(c("--normalizeMaleX"), type="logical", default=TRUE, help = "If male, then normalize chrX by median. Default: [%default]"),
  make_option(c("--fracReadsInChrYForMale"), type="numeric", default=0.001, help = "Threshold for fraction of reads in chrY to assign as male. Default: [%default]"),
  # make_option(c("--libdir"), type = "character", default=NULL, help = "Script library path. Usually exclude this argument unless custom modifications have been made to the ichorCNA R package code and the user would like to source those R files. Default: [%default]")
  make_option(c("--libdir"), type = "character", default="myichorcna/ichorCNA", help = "Script library path. Usually exclude this argument unless custom modifications have been made to the ichorCNA R package code and the user would like to source those R files. Default: [%default]"),
  make_option(c("--outDir"), type = "character", default="outputs", help = "Script library path. Usually exclude this argument unless custom modifications have been made to the ichorCNA R package code and the user would like to source those R files. Default: [%default]"),
  make_option(c("--WIG"), type = "character", default="myichorcna/ichorCNA/inst/extdata/MBC_315_T2.ctDNA.reads.wig", help = "Path to tumor WIG file. Required."),
  make_option(c("--gcWig"), type = "character", default="myichorcna/ichorCNA/inst/extdata/gc_hg19_1000kb.wig", help = "Path to GC-content WIG file; Required"),
  make_option(c("--mapWig"), type = "character", default="myichorcna/ichorCNA/inst/extdata/map_hg19_1000kb.wig", help = "Path to mappability score WIG file. Default: [%default]"),
  make_option(c("--normalPanel"), type="character", default="myichorcna/ichorCNA/inst/extdata/HD_ULP_PoN_1Mb_median_normAutosome_mapScoreFiltered_median.rds", help="Median corrected depth from panel of normals. Default: [%default]"),
  make_option(c("--centromere"), type="character", default="myichorcna/ichorCNA/inst/extdata/GRCh37.p13_centromere_UCSC-gapTable.txt", help = "File containing Centromere locations; if not provided then will use hg19 version from ichorCNA package. Default: [%default]")
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
tumour_file <- opt$WIG
normal_file <- opt$NORMWIG
gcWig <- opt$gcWig
mapWig <- opt$mapWig
normal_panel <- opt$normalPanel
exons.bed <- opt$exons.bed  # "0" if none specified
centromere <- opt$centromere
minMapScore <- opt$minMapScore
flankLength <- opt$rmCentromereFlankLength
coverage <- opt$coverage
normalizeMaleX <- as.logical(opt$normalizeMaleX)
fracReadsInChrYForMale <- opt$fracReadsInChrYForMale
chrXMedianForMale <- -0.1
outDir <- opt$outDir
libdir <- opt$libdir
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


loadReadCountsFromWig <- function(counts, chrs = c(1:22, "X", "Y"), gc = NULL, map = NULL, centromere = NULL, flankLength = 100000, targetedSequences = NULL, genomeStyle = "NCBI", applyCorrection = TRUE, mapScoreThres = 0.9, chrNormalize = c(1:22, "X", "Y"), fracReadsInChrYForMale = 0.002, chrXMedianForMale = -0.5, useChrY = TRUE){
	require(HMMcopy)
	require(GenomeInfoDb)
	seqlevelsStyle(counts) <- genomeStyle
	counts.raw <- counts	
	counts <- keepChr(counts, chrs)
	
	if (!is.null(gc)){ 
		seqlevelsStyle(gc) <- genomeStyle
		counts$gc <- keepChr(gc, chrs)$value
	}
	if (!is.null(map)){ 
		seqlevelsStyle(map) <- genomeStyle
		counts$map <- keepChr(map, chrs)$value
	}
	colnames(values(counts))[1] <- c("reads")
	
	# remove centromeres
	if (!is.null(centromere)){ 
		counts <- excludeCentromere(counts, centromere, flankLength = flankLength, genomeStyle=genomeStyle)
	}
	# keep targeted sequences
	if (!is.null(targetedSequences)){
		colnames(targetedSequences)[1:3] <- c("chr", "start", "end")
		targetedSequences.GR <- as(targetedSequences, "GRanges")
		seqlevelsStyle(targetedSequences.GR) <- genomeStyle
		countsExons <- filterByTargetedSequences(counts, targetedSequences.GR)
		counts <- counts[countsExons$ix,]
	}
	gender <- NULL
	if (applyCorrection){
		## correct read counts ##
		counts <- correctReadCounts(counts, chrNormalize = chrNormalize)
		if (!is.null(map)) {
		  ## filter bins by mappability
		  counts <- filterByMappabilityScore(counts, map=map, mapScoreThres = mapScoreThres)
		}
		## get gender ##
		gender <- getGender(counts.raw, counts, gc, map, fracReadsInChrYForMale = fracReadsInChrYForMale, 
							chrXMedianForMale = chrXMedianForMale, useChrY = useChrY,
							centromere=centromere, flankLength=flankLength, targetedSequences = targetedSequences,
							genomeStyle = genomeStyle)
    }
  return(list(counts = counts, gender = gender))
}


## load seqinfo 
seqinfo <- getSeqInfo(genomeBuild, genomeStyle)

if (substr(tumour_file,nchar(tumour_file)-2,nchar(tumour_file)) == "wig") {
  wigFiles <- data.frame(cbind(patientID, tumour_file))
} else {
  wigFiles <- read.delim(tumour_file, header=F, as.is=T)
}

## FILTER BY EXONS IF PROVIDED ##
## add gc and map to GRanges object ##
if (is.null(exons.bed) || exons.bed == "None" || exons.bed == "NULL"){
  targetedSequences <- NULL
}else{
  targetedSequences <- read.delim(exons.bed, header=T, sep="\t")  
}

## load PoN
if (is.null(normal_panel) || normal_panel == "None" || normal_panel == "NULL"){
	normal_panel <- NULL
}

if (is.null(centromere) || centromere == "None" || centromere == "NULL"){ # no centromere file provided
	centromere <- system.file("extdata", "GRCh37.p13_centromere_UCSC-gapTable.txt", 
			package = "ichorCNA")
}
centromere <- read.delim(centromere,header=T,stringsAsFactors=F,sep="\t")
save.image(outImage)
## LOAD IN WIG FILES ##
numSamples <- nrow(wigFiles)

tumour_copy <- list()
for (i in 1:numSamples) {
  id <- wigFiles[i,1]
  ## create output directories for each sample ##
  dir.create(paste0(outDir, "/", id, "/"), recursive = TRUE)
  ### LOAD TUMOUR AND NORMAL FILES ###
  message("Loading tumour file:", wigFiles[i,1])
  tumour_reads <- wigToGRanges(wigFiles[i,2])
  
  ## LOAD GC/MAP WIG FILES ###
  # find the bin size and load corresponding wig files #
  binSize <- as.data.frame(tumour_reads[1,])$width 
  message("Reading GC and mappability files")
  if (is.null(gcWig) || gcWig == "None" || gcWig == "NULL"){
      stop("GC wig file is required")
  }
  gc <- wigToGRanges(gcWig)
  if (is.null(mapWig) || mapWig == "None" || mapWig == "NULL"){
      message("No mappability wig file input, excluding from correction")
      map <- NULL
  } else {
      map <- wigToGRanges(mapWig)
  }
  message("Correcting Tumour")
  
  counts <- loadReadCountsFromWig(tumour_reads, chrs = chrs, gc = gc, map = map, 
                                       centromere = centromere, flankLength = flankLength, 
                                       targetedSequences = targetedSequences, chrXMedianForMale = chrXMedianForMale,
                                       genomeStyle = genomeStyle, fracReadsInChrYForMale = fracReadsInChrYForMale,
                                       chrNormalize = chrNormalize, mapScoreThres = minMapScore)
  tumour_copy[[id]] <- counts$counts #as(counts$counts, "GRanges")
  gender <- counts$gender
  ## load in normal file if provided 
  if (!is.null(normal_file) && normal_file != "None" && normal_file != "NULL"){
	message("Loading normal file:", normal_file)
	normal_reads <- wigToGRanges(normal_file)
	message("Correcting Normal")
	counts <- loadReadCountsFromWig(normal_reads, chrs=chrs, gc=gc, map=map, 
			centromere=centromere, flankLength = flankLength, targetedSequences=targetedSequences,
			genomeStyle = genomeStyle, chrNormalize = chrNormalize, mapScoreThres = minMapScore)
	normal_copy <- counts$counts #as(counts$counts, "GRanges")
	gender.normal <- counts$gender
  }else{
	normal_copy <- NULL
  }

  ### DETERMINE GENDER ###
  ## if normal file not given, use chrY, else use chrX
  message("Determining gender...", appendLF = FALSE)
  gender.mismatch <- FALSE
  if (!is.null(normal_copy)){
	if (gender$gender != gender.normal$gender){ #use tumour # use normal if given
	# check if normal is same gender as tumour
	  gender.mismatch <- TRUE
	}
  }
  message("Gender ", gender$gender)

  ## NORMALIZE GENOME-WIDE BY MATCHED NORMAL OR NORMAL PANEL (MEDIAN) ##
  tumour_copy[[id]] <- normalizeByPanelOrMatchedNormal(tumour_copy[[id]], chrs = chrs, 
      normal_panel = normal_panel, normal_copy = normal_copy, 
      gender = gender$gender, normalizeMaleX = normalizeMaleX)
	
	### OUTPUT FILE ###
	### PUTTING TOGETHER THE COLUMNS IN THE OUTPUT ###
	outMat <- as.data.frame(tumour_copy[[id]])
	#outMat <- outMat[,c(1,2,3,12)]
	outMat <- outMat[,c("seqnames","start","end","copy")]
	colnames(outMat) <- c("chr","start","end","log2_TNratio_corrected")
	outFile <- paste0(outDir,"/",id,".correctedDepth.txt")
	message(paste("Outputting to:", outFile))
	write.table(outMat, file=outFile, row.names=F, col.names=T, quote=F, sep="\t")

} ## end of for each sample

chrInd <- as.character(seqnames(tumour_copy[[1]])) %in% chrTrain
## get positions that are valid
valid <- tumour_copy[[1]]$valid
if (length(tumour_copy) >= 2) {
  for (i in 2:length(tumour_copy)){ 
    valid <- valid & tumour_copy[[i]]$valid 
  } 
}
save.image(outImage)

