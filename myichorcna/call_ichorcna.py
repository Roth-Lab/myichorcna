from pathlib import Path
import subprocess
import yaml

class PathsManager:
    def __init__(self):
        self.myichorcna = Path(__file__).resolve().parent
        self.ichorCNA = self.myichorcna.joinpath('ichorCNA')

    @property
    def repo(self) -> Path:
        return self.myichorcna.joinpath('ichorCNA')
    
    @property
    def scripts(self) -> Path:
        return self.repo.joinpath('scripts')
    
    @property
    def extdata(self) -> Path:
        return self.repo.joinpath('inst','extdata')

    @property
    def ichorcna_rscript(self) -> Path:
        return self.scripts.joinpath('runIchorCNA.R')
    
    @property
    def ichorcna_hmmsegment_rscript(self) -> Path:
        return self.scripts.joinpath('runHMMsegment.R')
    
    @property
    def ichorcna_hmmsegment_cor_rscript(self) -> Path:
        return self.scripts.joinpath('runHMMsegmentCorrection.R')


def run_ichorCNA(
    output_dir: str, 
    ctdna_wig_file: str,
    ichorcna_params: str, 
    sample_id: str = 'DummySampleID'
) -> None:
    output_dir = Path(output_dir)
    output_dir.mkdir(exist_ok=True, parents=True)
    settings = yaml.safe_load(open(ichorcna_params, 'r'))
    settings['WIG'] = ctdna_wig_file
    settings['id'] = sample_id
    settings['outDir'] = output_dir
    
    # needed from ichorCNA
    paths_manager = PathsManager()
    settings['libdir'] = paths_manager.repo
    settings['RScript'] = paths_manager.ichorcna_rscript
    
    r_ichorcna(**settings)

 
def r_ichorcna(
    RScript: str,
    libdir: str,
    id: str, 
    genomeStyle: str,
    genomeBuild: str,
    WIG: str,
    NORMALWIG: str,
    gcWig: str,
    mapWig: str,
    normalPanel: str,
    centromere: str,
    normal: str,
    maxCN: str,
    ploidy: str,
    includeHOMD: str,
    chrs: str,
    chrTrain: str,
    estimateNormal: str,
    estimatePloidy: str,
    estimateScPrevalence: str,
    scStates: str,
    exons: str,
    txnE: str,
    txnStrength: str,
    minMapScore: str,
    fracReadsInChrYForMale: str,
    maxFracGenomeSubclone: str,
    maxFracCNASubclone: str,
    plotFileType: str,
    plotYlim: str,
    outDir: str,
):

    # create command to run
    command = f"Rscript {RScript} " \
              f"--id {id} " \
              f"--libdir {libdir} "\
              f"--genomeStyle {genomeStyle} "\
              f"--genomeBuild {genomeBuild} "\
              f"--WIG {WIG} "\
              f"--NORMWIG {NORMALWIG} "\
              f"--gcWig {gcWig} "\
              f"--mapWig {mapWig} "\
              f"--centromere {centromere} "\
              f"--normalPanel {normalPanel} "\
              f"--ploidy \'{ploidy}\' "\
              f"--normal \'{normal}\' "\
              f"--maxCN {maxCN} "\
              f"--includeHOMD {includeHOMD} "\
              f"--chrs \'{chrs}\' "\
              f"--chrTrain \'{chrTrain}\' "\
              f"--estimateNormal {estimateNormal} "\
              f"--estimatePloidy {estimatePloidy} "\
              f"--estimateScPrevalence {estimateScPrevalence} "\
              f"--scStates \'{scStates}\' "\
              f"--exons.bed {exons} "\
              f"--txnE {txnE} "\
              f"--txnStrength {txnStrength} "\
              f"--minMapScore {minMapScore} "\
              f"--fracReadsInChrYForMale {fracReadsInChrYForMale} "\
              f"--maxFracGenomeSubclone {maxFracGenomeSubclone} "\
              f"--maxFracCNASubclone {maxFracCNASubclone} "\
              f"--plotFileType {plotFileType} "\
              f"--plotYLim \'{plotYlim}\' "\
              f"--outDir {outDir}"
    
    try:
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print("Command failed")
        return False


def run_hmmsegment(
    output_dir: str, 
    ctdna_tsv_file: str,
    ichorcna_params: str, 
    sample_id: str = 'DummySampleID'
) -> None:
    output_dir = Path(output_dir)
    output_dir.mkdir(exist_ok=True, parents=True)
    settings = yaml.safe_load(open(ichorcna_params, 'r'))
    settings['copy'] = ctdna_tsv_file
    settings['id'] = sample_id
    settings['outDir'] = output_dir
    
    # needed from ichorCNA
    paths_manager = PathsManager()
    settings['libdir'] = paths_manager.repo
    settings['RScript'] = paths_manager.ichorcna_hmmsegment_rscript
    
    r_hmmsegment(**settings)


def r_hmmsegment(
    RScript: str,
    libdir: str,
    id: str,
    copy: str,
    genomeStyle: str,
    genomeBuild: str,
    normal: str,
    maxCN: str,
    ploidy: str,
    includeHOMD: str,
    chrs: str,
    chrTrain: str,
    estimateNormal: str,
    estimatePloidy: str,
    estimateScPrevalence: str,
    scStates: str,
    txnE: str,
    txnStrength: str,
    fracReadsInChrYForMale: str,
    maxFracGenomeSubclone: str,
    maxFracCNASubclone: str,
    plotFileType: str,
    plotYlim: str,
    outDir: str,
):

    # create command to run
    command = f"Rscript {RScript} " \
              f"--id {id} " \
              f"--libdir {libdir} "\
              f"--copy {copy} "\
              f"--genomeStyle {genomeStyle} "\
              f"--genomeBuild {genomeBuild} "\
              f"--ploidy \'{ploidy}\' "\
              f"--normal \'{normal}\' "\
              f"--maxCN {maxCN} "\
              f"--includeHOMD {includeHOMD} "\
              f"--chrs \'{chrs}\' "\
              f"--chrTrain \'{chrTrain}\' "\
              f"--estimateNormal {estimateNormal} "\
              f"--estimatePloidy {estimatePloidy} "\
              f"--estimateScPrevalence {estimateScPrevalence} "\
              f"--scStates \'{scStates}\' "\
              f"--txnE {txnE} "\
              f"--txnStrength {txnStrength} "\
              f"--fracReadsInChrYForMale {fracReadsInChrYForMale} "\
              f"--maxFracGenomeSubclone {maxFracGenomeSubclone} "\
              f"--maxFracCNASubclone {maxFracCNASubclone} "\
              f"--plotFileType {plotFileType} "\
              f"--plotYLim \'{plotYlim}\' "\
              f"--outDir {outDir}"
    
    try:
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print("Command failed")
        return False
        
def run_hmmsegment_cor(
    output_dir: str, 
    ctdna_tsv_file: str,
    ichorcna_params: str, 
    sample_id: str = 'DummySampleID'
) -> None:
    output_dir = Path(output_dir)
    output_dir.mkdir(exist_ok=True, parents=True)
    settings = yaml.safe_load(open(ichorcna_params, 'r'))
    settings['copy'] = ctdna_tsv_file
    settings['id'] = sample_id
    settings['outDir'] = output_dir
    
    # needed from ichorCNA
    paths_manager = PathsManager()
    settings['libdir'] = paths_manager.repo
    settings['RScript'] = paths_manager.ichorcna_hmmsegment_cor_rscript
    
    r_hmmsegment_cor(**settings)


def r_hmmsegment_cor(
    RScript: str,
    libdir: str,
    id: str,
    copy: str,
    genomeStyle: str,
    genomeBuild: str,
    normal: str,
    maxCN: str,
    ploidy: str,
    includeHOMD: str,
    chrs: str,
    chrTrain: str,
    estimateNormal: str,
    estimatePloidy: str,
    estimateScPrevalence: str,
    scStates: str,
    txnE: str,
    txnStrength: str,
    fracReadsInChrYForMale: str,
    maxFracGenomeSubclone: str,
    maxFracCNASubclone: str,
    plotFileType: str,
    plotYlim: str,
    outDir: str,
):

    # create command to run
    command = f"Rscript {RScript} " \
              f"--id {id} " \
              f"--libdir {libdir} "\
              f"--copy {copy} "\
              f"--genomeStyle {genomeStyle} "\
              f"--genomeBuild {genomeBuild} "\
              f"--ploidy \'{ploidy}\' "\
              f"--normal \'{normal}\' "\
              f"--maxCN {maxCN} "\
              f"--includeHOMD {includeHOMD} "\
              f"--chrs \'{chrs}\' "\
              f"--chrTrain \'{chrTrain}\' "\
              f"--estimateNormal {estimateNormal} "\
              f"--estimatePloidy {estimatePloidy} "\
              f"--estimateScPrevalence {estimateScPrevalence} "\
              f"--scStates \'{scStates}\' "\
              f"--txnE {txnE} "\
              f"--txnStrength {txnStrength} "\
              f"--fracReadsInChrYForMale {fracReadsInChrYForMale} "\
              f"--maxFracGenomeSubclone {maxFracGenomeSubclone} "\
              f"--maxFracCNASubclone {maxFracCNASubclone} "\
              f"--plotFileType {plotFileType} "\
              f"--plotYLim \'{plotYlim}\' "\
              f"--outDir {outDir}"
    
    try:
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print("Command failed")
        params_txt_file = outDir.joinpath(f"{id}", f"{id}.params.txt")
        params_txt_file.parent.mkdir(exist_ok=True, parents=True)
        with open(params_txt_file, 'w') as f:
            f.write("Failed running ichor!")
        print("created file")
    
    
        
