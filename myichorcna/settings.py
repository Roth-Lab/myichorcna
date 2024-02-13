from dataclasses import dataclass

@dataclass
class Settings:
    repo: str = "../ichorCNA"
    rscript: str = "../ichorCNA/scripts/runIchorCNA.R"

    gc_wig: str = "../ichorCNA/inst/extdata/gc_hg19_500kb.wig"
    map_wig: str = "../ichorCNA/inst/extdata/map_hg19_500kb.wig"
    normal_panel: str = "../ichorCNA/inst/extdata/HD_ULP_PoN_500kb_median_normAutosome_mapScoreFiltered_median.rds"
    centromere: str = "../ichorCNA/inst/extdata/GRCh37.p13_centromere_UCSC-gapTable.txt"
    genome_build: str = "hg19"  # not included in hg38
    genome_style: str = "NCBI"