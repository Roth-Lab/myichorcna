import click
from myichorcna.run import inference


@click.command()
@click.option(
    '-o',
    '--output-directory',
    type=click.STRING,
    required=True,
    help="Path to directory to output results from ichorCNA."
)
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
def perform_inference(**kwargs):
    inference(**kwargs)


@click.group(name='myichorcna')
def main():
    pass


main.add_command(perform_inference)


if __name__ == "__main__":
    main()
