freesasa 2.1.3-r1

Purpose:
  Solvent accessible surface area (SASA) calculation for biomolecular
  structures with the FreeSASA command-line tool and C library runtime.

Usage:
  taf-freesasa -- --help
  taf-freesasa -- --version
  taf-freesasa protein.pdb
  taf-freesasa --format=json --depth=residue -o protein.sasa.json protein.pdb

Common workflows:
  taf-freesasa --cif --format=xml -o protein.sasa.xml protein.cif
  taf-freesasa --shrake-rupley --resolution=960 protein.pdb
  taf-freesasa --radii=naccess --format=rsa -o protein.rsa protein.pdb
  taf-freesasa --select="chain_A, chain A" protein.pdb

Packaged command:
  freesasa   FreeSASA 2.1.3 CLI

Installed runtime files:
  /opt/freesasa/include/freesasa.h
  /opt/freesasa/lib/libfreesasa.a
  /opt/freesasa/share/freesasa/*.config

Inputs:
  protein.pdb          Default PDB input
  protein.cif          mmCIF input when --cif is set
  classifier.config    Custom radii/classes with --config-file FILE

Key output formats:
  log                  Default human-readable summary
  res, seq             Residue or sequence summaries
  rsa                  NACCESS-like RSA output
  pdb, cif             Structure-style output with SASA values
  json, xml            Structured output for downstream parsing

Notes:
  No external database is required.
  JSON, XML, mmCIF, and thread support are enabled in this image.
  Sample classifier configs are under /opt/freesasa/share/freesasa.
  Python bindings are not included; upstream publishes them separately.

Detailed documentation:
  https://freesasa.github.io/
  https://freesasa.github.io/doxygen/CLI.html
  https://github.com/mittinatten/freesasa

Wrapper options:
  taf-freesasa --help       Show this TAFFISH help.
  taf-freesasa --version    Show TAFFISH wrapper version.
  taf-freesasa --compile    Compile the TAFFISH wrapper.
  taf-freesasa -- --help    Pass option-leading arguments to freesasa.
