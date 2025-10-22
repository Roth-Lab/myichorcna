from myichorcna.utils import make_output_dirs, load_config_file
from myichorcna.call_ichorcna import call_ichorCNA

def run_ichorCNA(
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
    call_ichorCNA(
        wig_file_path=ctdna_data_file,
        output_directory=output_directory,
        settings_config=ichorcna_settings
    )

