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

[for digital plotting in pyplot](https://stackoverflow.com/questions/20036161/can-we-draw-digital-waveform-graph-with-pyplot-in-python-or-matlab)

# Simulation
Environment setup (git bash with make on windows):
- install vivado and get it on path
- install git bash for windows
- https://gist.github.com/evanwill/0207876c3243bbb6863e65ec5dc3f058

- `make sim` generates simulation snapshots for each testbench in the hdl folder, as noted with _tb suffix.
- `make gui` opens the simulator ui and loads the sim snapshot.
- More info: https://www.itsembedded.com/dhd/vivado_sim_1/

# Synthesis & Implementation
- `make bit` runs vivado to generate a bit file, using all files found in the hdl folder without the _tb suffix.