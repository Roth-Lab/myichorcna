from dataclasses import dataclass

from pathlib import Path


@dataclass
class RelativePaths:
    repo: str = "ichorCNA"
    rscript: str = "ichorCNA/scripts/runIchorCNA.R"

    gc_wig: str = "ichorCNA/inst/extdata/gc_hg19_500kb.wig"
    map_wig: str = "ichorCNA/inst/extdata/map_hg19_500kb.wig"
    normal_panel: str = "ichorCNA/inst/extdata/HD_ULP_PoN_500kb_median_normAutosome_mapScoreFiltered_median.rds"
    centromere: str = "ichorCNA/inst/extdata/GRCh37.p13_centromere_UCSC-gapTable.txt"
    genome_build: str = "hg19"  # not included in hg38
    genome_style: str = "NCBI"


class PathsManager:
    def __init__(self, abs_path_run_script: Path):
        self.abs_path_cli_script = abs_path_run_script
        self.relative_paths = RelativePaths()

    @property
    def repo(self) -> Path:
        return self.abs_path_cli_script.joinpath(self.relative_paths.repo)

    @property
    def rscript(self) -> Path:
        return self.abs_path_cli_script.joinpath(self.relative_paths.rscript)

    @property
    def gc_wig(self) -> Path:
        return self.abs_path_cli_script.joinpath(self.relative_paths.gc_wig)

    @property
    def map_wig(self) -> Path:
        return self.abs_path_cli_script.joinpath(self.relative_paths.map_wig)

    @property
    def normal_panel(self) -> Path:
        return self.abs_path_cli_script.joinpath(self.relative_paths.normal_panel)

    @property
    def centromere(self) -> Path:
        return self.abs_path_cli_script.joinpath(self.relative_paths.centromere)

    @property
    def genome_build(self) -> str:
        return RelativePaths.genome_build

    @property
    def genome_style(self) -> str:
        return RelativePaths.genome_style



