from myichorcna.utils import make_output_dirs, load_config_file
from myichorcna.settings import PathsManager

from pathlib import Path

import subprocess


def run_ichorCNA(
        wig_file_path: str,
        output_directory: str,
        settings_config: dict
) -> None:
    # fix sample ID not needed for my purposes
    sample_id = 'DummySampleID'

    # code and files needed for ichorCNA
    abs_path_run_script = Path(__file__).resolve().parent
    paths_manager = PathsManager(abs_path_run_script)
    repo = paths_manager.repo
    rscript = paths_manager.rscript
    gc_wig = paths_manager.gc_wig
    map_wig = paths_manager.map_wig
    centromere = paths_manager.centromere
    normal_panel = paths_manager.normal_panel

    # genome file styles
    genome_style = paths_manager.genome_style
    genome_build = paths_manager.genome_build

    # model settings needed for ichorCNA
    estimate_normal = settings_config['estimate_normal']
    estimate_ploidy = settings_config['estimate_ploidy']
    estimate_clonality = settings_config['estimate_clonality']
    normal_restarts = settings_config['normal_restarts']
    ploidy = settings_config['ploidy']
    sc_states = settings_config['subclone_states']
    max_cn = settings_config['max_cn']
    min_map_score = settings_config['min_map_score']
    max_frac_genome_subclone = settings_config['max_frac_genome_subclone']
    max_frac_cna_subclone = settings_config['max_frac_cna_subclone']
    frac_reads_chry_male = settings_config['frac_reads_chry_male']
    chrs = settings_config['chrs']
    chrs_train = settings_config['chrs_train']
    exons_bed = settings_config['exons']
    include_homd = settings_config['include_homd']
    txn_e = settings_config['txn_e']
    txn_strength = settings_config['txn_strength']
    plot_type = settings_config['plot_file_type']
    plot_ylim = settings_config['plot_ylim']

    # create command to run
    command = f"Rscript {rscript} " \
              f"--id {sample_id} " \
              f"--libdir {repo} "\
              f"--genomeStyle {genome_style} "\
              f"--genomeBuild {genome_build} "\
              f"--WIG {wig_file_path} "\
              f"--gcWig {gc_wig} "\
              f"--mapWig {map_wig} "\
              f"--centromere {centromere} "\
              f"--normalPanel {normal_panel} "\
              f"--ploidy \'{ploidy}\' "\
              f"--normal \'{normal_restarts}\' "\
              f"--maxCN {max_cn} "\
              f"--includeHOMD {include_homd} "\
              f"--chrs \'{chrs}\' "\
              f"--chrTrain \'{chrs_train}\' "\
              f"--estimateNormal {estimate_normal} "\
              f"--estimatePloidy {estimate_ploidy} "\
              f"--estimateScPrevalence {estimate_clonality} "\
              f"--scStates \'{sc_states}\' "\
              f"--exons.bed {exons_bed} "\
              f"--txnE {txn_e} "\
              f"--txnStrength {txn_strength} "\
              f"--minMapScore {min_map_score} "\
              f"--fracReadsInChrYForMale {frac_reads_chry_male} "\
              f"--maxFracGenomeSubclone {max_frac_genome_subclone} "\
              f"--maxFracCNASubclone {max_frac_cna_subclone} "\
              f"--plotFileType {plot_type} "\
              f"--plotYLim \'{plot_ylim}\' "\
              f"--outDir {output_directory}"

    # change working directory

    # run command in shell
    subprocess.run(command, shell=True, check=True)


def inference(
        output_directory: str,
        ctdna_data_file: str,
        ichorcna_settings: str,
) -> None:
    """
    Runs ichorCNA on ctDNA data file with specified settings.

    Args:
        output_directory: Path to directory to output everything from ichorCNA.
        ctdna_data_file: Path to ctDNA .wig file.
        ichorcna_settings: Path to settings .yaml file.
    """
    # create output directories
    make_output_dirs(output_directory)

    # load ichorCNA model settings
    ichorcna_settings = load_config_file(ichorcna_settings)

    # run ichorCNA
    run_ichorCNA(ctdna_data_file, output_directory, ichorcna_settings)


if __name__ == '__main__':
    wig_file = "examples/ctdna.wig"
    output_dir = "examples/example-run"
    ichor_settings = "examples/settings.yaml"
    inference(output_directory=output_dir, ctdna_data_file=wig_file, ichorcna_settings=ichor_settings)