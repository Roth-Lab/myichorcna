

def run_ichorCNA(
        ctdna_data_file: str,
        ichorcna_settings: str,
        output_directory: str
) -> None:
    """
    Runs ichorCNA on ctDNA data file with settings specified settings.

    Args:
        ctdna_data_file: Path to ctDNA .wig file.
        ichorcna_settings: Path to settings .yaml file.
        output_directory: Path to directory to output everything from ichorCNA.
    """
    print("ctDNA data path {} \n".format(ctdna_data_file))
    print("ichorCNA path {} \n".format(ichorcna_settings))
    print("output directory path {}".format(output_directory))
