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
    def gc_wig(self) -> Path:
        return self.extdata.joinpath('gc_hg38_500kb.wig')

    @property
    def map_wig(self) -> Path:
        return self.extdata.joinpath('map_hg38_500kb.wig')
    
    @property
    def normal_panel(self) -> Path:
        return self.extdata.joinpath('HD_ULP_PoN_hg38_500kb_median_normAutosome_median.rds')

    @property
    def centromere(self) -> Path:
        return self.extdata.joinpath('GRCh38.GCA_000001405.2_centromere_acen.txt')

    @property
    def genome_build(self) -> str:
        return 'hg38'

    @property
    def genome_style(self) -> str:
        return "NCBI"


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
    call_ichorCNA(ichorParams=settings)


def call_ichorCNA(ichorParams: dict) -> None:
    # needed from ichorCNA
    paths_manager = PathsManager()
    ichorParams['libdir'] = paths_manager.repo
    ichorParams['RScript'] = paths_manager.ichorcna_rscript
    _run(**ichorParams)

 
def _run(
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
        

