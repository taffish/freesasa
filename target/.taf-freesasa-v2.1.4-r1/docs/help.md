taf-freesasa 2.1.4-r1

Purpose:
  Calculate solvent-accessible surface area (SASA) from a structure.

Usage:
  taf-freesasa freesasa structure.pdb
  taf-freesasa -- --help
  taf-freesasa -- --version

Common tasks:
  taf-freesasa freesasa --format=json --depth=residue -o areas.json structure.pdb
  taf-freesasa freesasa --cif --format=xml -o areas.xml structure.cif
  taf-freesasa freesasa --shrake-rupley --resolution=960 structure.pdb
  taf-freesasa freesasa --select='"chain_A, chain A"' structure.pdb
  taf-freesasa freesasa --config-file=radii.config --format=rsa structure.pdb
  cat structure.pdb | taf-freesasa freesasa --format=seq

Inputs and outputs:
  PDB is the default; use --cif for mmCIF. Work in the input directory.
  Output goes to stdout unless you supply -o FILE. Use a new output name:
  FreeSASA can open or truncate an output before it checks the input.
  Formats: log, res, seq, rsa, pdb, cif, json, xml. JSON/XML support
  --depth=structure|chain|residue|atom. Areas are in square angstroms.
  Annotated PDB and CIF outputs require input of the same type.

Common options:
  --lee-richards (default) or --shrake-rupley    Calculation algorithm
  --radii=protor or --radii=naccess             Built-in atom radii
  --config-file=FILE                           Local classifier instead
  --probe-radius=NUMBER                        Solvent probe radius in angstroms
  --n-threads=N                                Number of calculation threads

Immediate notes:
  No database, download or GUI is needed. Keep custom classifiers with inputs.
  For spaces in names, keep quotes for the container shell, for example:
  taf-freesasa freesasa --format=json -o '"out file.json"' '"my file.pdb"'

More help:
  taf-freesasa -- --help
  https://github.com/taffish/freesasa

Wrapper options:
  taf-freesasa --help       Show this TAFFISH help.
  taf-freesasa --version    Show the wrapper version.
  taf-freesasa --compile    Print the generated shell command.
  taf-freesasa -- --help    Show FreeSASA's own options.
