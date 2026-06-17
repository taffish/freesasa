# freesasa

`freesasa` packages FreeSASA for TAFFISH.

Package identity:

- name: `freesasa`
- command: `taf-freesasa`
- kind: `tool`
- version: `2.1.3-r1`
- license: Apache-2.0
- upstream: <https://github.com/mittinatten/freesasa>

## What This App Packages

FreeSASA is a command-line tool and C/C++ library for calculating solvent
accessible surface area (SASA) from biomolecular structures. It supports the
Lee and Richards algorithm by default, the Shrake and Rupley algorithm on
request, PDB and mmCIF input, configurable atom radii/classes, selection
queries, and multiple output formats.

This app builds FreeSASA 2.1.3 from the upstream GitHub tag and installs the
CLI, C header, static library, man page, sample classifier configuration files,
and a small upstream test fixture set for smoke testing.

## Scope

This app supports:

- `freesasa` CLI calculation from PDB input.
- mmCIF input through `--cif`.
- Lee and Richards and Shrake and Rupley algorithms.
- ProtOr and NACCESS radii, plus custom classifier config files.
- JSON, XML, RSA, residue, sequence, PDB, CIF, and log-style outputs.
- Selection expressions through `--select`.
- Multithreaded calculation support.
- The installed C API header and static library for users compiling against the
  runtime inside the container.

This app does not include the Python bindings. Upstream publishes Python
bindings separately from the CLI/C library; use the Python package or a
dedicated Python environment when that API is needed.

## Container Contents

- `freesasa`: FreeSASA 2.1.3 CLI.
- `/opt/freesasa/include/freesasa.h`: installed C API header.
- `/opt/freesasa/lib/libfreesasa.a`: installed static library.
- `/opt/freesasa/share/freesasa/*.config`: bundled classifier configurations,
  including ProtOr, NACCESS, OONS, and DSSP examples.
- `/opt/freesasa/share/testdata`: small upstream fixtures used by smoke tests.

The image is built with JSON, XML, mmCIF, and thread support enabled. Gemmi
headers bundled by upstream are used for mmCIF parsing.

## Usage

Show wrapper and upstream help:

```sh
taf-freesasa --help
taf-freesasa -- --help
taf-freesasa -- --version
```

Calculate SASA from a PDB file with defaults:

```sh
taf-freesasa protein.pdb
```

Write JSON output:

```sh
taf-freesasa --format=json --depth=residue -o protein.sasa.json protein.pdb
```

Read mmCIF input and write XML:

```sh
taf-freesasa --cif --format=xml -o protein.sasa.xml protein.cif
```

Use Shrake and Rupley with more test points:

```sh
taf-freesasa --shrake-rupley --resolution=960 protein.pdb
```

Use NACCESS radii and write RSA-style output:

```sh
taf-freesasa --radii=naccess --format=rsa -o protein.rsa protein.pdb
```

Run a selection query:

```sh
taf-freesasa --select="chain_A, chain A" protein.pdb
```

## Command Mode

`taf-freesasa` defaults to the upstream `freesasa` command, so normal option
arguments can be passed directly. Use `taf-freesasa -- --help` and
`taf-freesasa -- --version` when the first upstream argument starts with `-`.

Automatic command mode is enabled for the container runtime. For example,
`taf-freesasa freesasa --version` runs the packaged upstream command explicitly.

## Inputs

| Input | Meaning | Notes |
| --- | --- | --- |
| PDB file | Default structure input | Supports stdin as upstream supports it. |
| mmCIF file | Structure input with `--cif` | Added in FreeSASA 2.x through Gemmi. |
| classifier config | Custom radii/classes | Use `--config-file FILE`; sample configs are under `/opt/freesasa/share/freesasa`. |

## Outputs

FreeSASA can write several output formats through `--format`, including:

- `log`: default human-readable summary.
- `res` / `seq`: residue or sequence-oriented summaries.
- `rsa`: NACCESS-like RSA output.
- `pdb` / `cif`: structure-like output with SASA values.
- `json` / `xml`: structured output for downstream parsing.

Use `--output FILE` or `-o FILE` to write to a file. Without `--output`,
FreeSASA writes to stdout.

## Resources and Platform

No external database is required. The default classifiers are compiled into the
library and sample classifier configuration files are installed in
`/opt/freesasa/share/freesasa`.

This app is declared for native `linux/amd64` and `linux/arm64` builds. The
upstream project is source-built from C/C++ code and the package-manager notes
list Linux arm64 builds as supported by conda-forge.

## Boundaries

The Python bindings are not included. Upstream documents them as a separate
package/repository beginning with the 2.x series.

Full Doxygen HTML documentation and upstream developer test suites are not
generated in the runtime image. The installed CLI help, man page source,
README, sample configs, C header, static library, and smoke fixtures are kept.

## Testing

The smoke test covers:

- upstream version and source checksum markers
- CLI help
- installed header, static library, classifier configs, and fixture presence
- dynamic-library completeness for `freesasa`
- PDB JSON output with atom-depth traversal
- selection expression output
- mmCIF XML output

It does not replace full scientific validation on production structures,
large benchmark sets, or custom classifier parameter sets.

## License and Citation

TAFFISH app packaging: Apache-2.0.

FreeSASA is distributed under the MIT License. Upstream bundles Gemmi headers
under the Mozilla Public License 2.0; both notices are retained under
`/opt/freesasa/share/licenses/freesasa`.

Primary citation:

Mitternacht S. FreeSASA: An open source C library for solvent accessible surface
area calculations. F1000Research. 2016;5:189.
<https://doi.org/10.12688/f1000research.7931.1>
