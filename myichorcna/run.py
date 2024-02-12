from myichorcna.utils import make_output_dirs, load_config_file
import subprocess


def inference(
        output_directory: str,
        ctdna_data_file: str,
        settings: str,
) -> None:
    """
    Runs ichorCNA on ctDNA data file with settings specified settings.

    Args:
        ctdna_data_file: Path to ctDNA .wig file.
        settings: Path to settings .yaml file.
        output_directory: Path to directory to output everything from ichorCNA.
    """
    # create output directories
    make_output_dirs(output_directory)

    # load ichorCNA settings
    config = load_config_file(settings)
    code_settings = config['settings']['code']
    files_settings = config['settings']['data_files']
    model_settings = config['settings']['model_settings']

    # run ichorCNA
    run_ichorCNA(ctdna_data_file, output_directory, code_settings, files_settings, model_settings)


def run_ichorCNA(
        wig_file_path: str,
        output_directory: str,
        code_config: dict,
        files_config: dict,
        settings_config: dict
) -> None:
    # code needed for ichorCNA
    rscript = code_config['rscript']
    repo = code_config['repo']
    sample_id = 'DummySampleID'

    # files needed for ichorCNA
    genome_style = files_config['genome_style']
    genome_build = files_config['genome_build']
    gc_wig = files_config['gc_wig']
    map_wig = files_config['map_wig']
    centromere = files_config['centromere']
    normal_panel = files_config['normal_panel']

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

    # run command in shell
    subprocess.run(command, shell=True, check=True)
