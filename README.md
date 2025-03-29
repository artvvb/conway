# Required VS Code Extensions:
- Python
- Jupyter
- Micromamba

# Running the scripts
- Open this repo in Visual Studio Code
- From the "View" menu, select "Command Palette" and run  "micromamba create environment"
- Open an ipynb notebook file
- Make sure the "default" kernel is selected in the top right corner
- Run each of the code blocks by clicking their play icons

# Simulation
Environment setup (git bash with make on windows):
- install vivado and get it on path
- install git bash for windows
- https://gist.github.com/evanwill/0207876c3243bbb6863e65ec5dc3f058

- `make sim` generates simulation snapshots for each testbench in the hdl folder, as noted with _tb suffix.
- `xsim --gui <module>_tb_snapshot.wdb` opens the simulator ui.
- More info: https://www.itsembedded.com/dhd/vivado_sim_1/

# Synthesis & Implementation
- `make bit` runs vivado to generate a bit file, using all files found in the hdl folder without the _tb suffix.