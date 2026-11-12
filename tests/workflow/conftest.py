import pytest
import shutil
from pathlib import Path


@pytest.fixture(scope="module")
def integration_path(user_path: Path, module_path: Path):
    """Ensures the minimal integration test is ready."""
    integration_dir = Path(module_path / "tests/integration")
    if integration_dir.exists():
        # clean everything
        shutil.rmtree(integration_dir / "resources", ignore_errors=True)
        shutil.rmtree(integration_dir / "results/", ignore_errors=True)
    user_integ_dir = integration_dir / "resources/user"
    files_to_copy = [
        "module_area_potentials/WDPA/wdpa.gdb",
        "module_demand_electricity/token_entsoe.txt",
        "module_euro_building_heat/edh_api_key.txt",
    ]
    for file in files_to_copy:
        destination_file = Path(user_integ_dir / file)
        destination_file.parent.mkdir(parents=True, exist_ok=True)
        # if it is a file, copy it
        if (user_path / file).is_file():
            shutil.copy(user_path / file, destination_file)
        elif (user_path / file).is_dir():
            shutil.copytree(user_path / file, destination_file)

    return integration_dir