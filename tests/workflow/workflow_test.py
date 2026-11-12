import subprocess


def test_workflow(module_path):
    """Run a light-weight test simulating someone using this module."""
    assert subprocess.run(
        "snakemake --use-conda --cores 1",
        shell=True,
        check=True,
        cwd=module_path,
    )
