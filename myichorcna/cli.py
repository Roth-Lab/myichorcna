import click
from myichorcna.run import run_ichorCNA


@click.command()
@click.option(
    '-c',
    '--ctdna-data-file',
    type=click.STRING,
    required=True,
    help="Path to read counts of ctDNA data outputted by readCounter (.wig)"
)
@click.option(
    '-s',
    '--settings',
    type=click.STRING,
    required=True,
    help="Path to config file for settings of ichorCNA (.yaml)."
)
@click.option(
    '-o',
    '--output-directory',
    type=click.STRING,
    required=True,
    help="Path to directory to output results from ichorCNA."
)
def perform_inference(**kwargs):
    run_ichorCNA(**kwargs)


@click.group(name='myichorcna')
def main():
    pass


main.add_command(perform_inference)


if __name__ == "__main__":
    main()
