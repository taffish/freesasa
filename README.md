# FreeSASA for TAFFISH

Calculate solvent-accessible surface area (SASA) from a PDB or mmCIF file without
downloading a reference database. This package builds the official FreeSASA **2.1.4**
CLI and the static C library for native Linux amd64 and arm64. TAFFISH package: `2.1.4-r1`.

## Install and run

Once this version appears in the TAFFISH Index, install it explicitly:

```sh
taf update
taf install freesasa 2.1.4-r1
```

From a directory containing your input, run the installed wrapper. The default is
Lee–Richards with ProtOr radii; the text summary reports areas in Å².

```sh
taf-freesasa freesasa structure.pdb
taf-freesasa freesasa --format=json --depth=residue -o areas.json structure.pdb
taf-freesasa freesasa --cif --format=xml -o areas.xml structure.cif
taf-freesasa freesasa --shrake-rupley --resolution=960 --n-threads=2 structure.pdb
taf-freesasa freesasa --radii=naccess --format=rsa -o naccess.rsa structure.pdb
taf-freesasa freesasa --select='"chain_A, chain A"' structure.pdb
cat structure.pdb | taf-freesasa freesasa --format=seq
```

Each selection is one argument. TAFFISH 0.12 command mode passes command text to a
container shell: keep an inner pair of quotes around a literal containing spaces,
as above or `taf-freesasa freesasa --format=json -o '"surface area.json"' '"my structure.pdb"'`.
These examples are for trusted literal filenames, not arbitrary shell input.
By default results go to stdout and diagnostics to stderr. Use a **new** output
filename on each attempt, especially if the input or classifier may be wrong.
Do not point `-o` at the input. A created or nonempty file is not proof of success.

Use `taf-freesasa --help` for the wrapper's task guide, `taf-freesasa -- --help`
for upstream help and `taf-freesasa -- --version` for the scientific program's
version. The explicit `freesasa` in the other examples selects the packaged executable.
From a source checkout the corresponding command is
`taf run -- freesasa --format=json structure.pdb`.

## Inputs, classifiers and outputs

- PDB is the default, including on stdin; select mmCIF with `--cif`.
- No network cache, external database or model is required. ProtOr and NACCESS
  are built in. The small, version-matched example classifiers
  (`protor.config`, `naccess.config`, `oons.config`, `dssp.config`) are under
  `/opt/freesasa/share/freesasa`. Treat a custom classifier as a read-only
  project input: place it next to your structure and pass `--config-file=radii.config`.
  There is no installation helper or project-wide automatic discovery.
- `log`, `res` and `seq` are text summaries; `rsa` is NACCESS-style output.
  `pdb` and `cif` write annotated structures. `json` and `xml` expose totals and
  selectable structure, chain, residue or atom detail. Annotated PDB requires PDB
  input; annotated CIF requires mmCIF input (this is not a format converter). `--resolution` means slices
  for Lee–Richards and sample points for Shrake–Rupley; values across algorithms
  need not be identical.

## Backends and boundaries

The same analysis command works on all three backends from the input directory:

```sh
TAFFISH_CONTAINER_BACKEND=docker    taf-freesasa freesasa structure.pdb
TAFFISH_CONTAINER_BACKEND=podman    taf-freesasa freesasa structure.pdb
TAFFISH_CONTAINER_BACKEND=apptainer taf-freesasa freesasa structure.pdb
```

For a shared structure and classifier outside the working directory, an
administrator can grant read/traverse access to their parent directory. No
resource installation is necessary. For example, with both files in
`/srv/structures` (visible to the selected engine):

```sh
TAFFISH_CONTAINER_BACKEND=docker TAFFISH_DOCKER_RUN_ARGS='-v /srv/structures:/mnt:ro' taf-freesasa freesasa --config-file=/mnt/radii.config /mnt/structure.pdb
TAFFISH_CONTAINER_BACKEND=podman TAFFISH_PODMAN_RUN_ARGS='-v /srv/structures:/mnt:ro' taf-freesasa freesasa --config-file=/mnt/radii.config /mnt/structure.pdb
TAFFISH_CONTAINER_BACKEND=apptainer TAFFISH_APPTAINER_RUN_ARGS='--bind /srv/structures:/mnt:ro' taf-freesasa freesasa --config-file=/mnt/radii.config /mnt/structure.pdb
```

The image includes the CLI, man page, `/opt/freesasa/include/freesasa.h`,
`/opt/freesasa/lib/libfreesasa.a`, and small upstream fixtures in
`/opt/freesasa/share/testdata`. The header/archive are for a compatible **external
Linux build toolchain**; a compiler and dependency development packages are not
included in the runtime. XML, JSON, threads and Gemmi mmCIF support are enabled.

The [Python bindings](https://github.com/freesasa/freesasa-python) are released
separately. The official [WebAssembly demo](https://freesasa.github.io/demo/)
runs in the user's browser; the native CLI neither starts nor depends on it.
PyMOL-style selection syntax does not require PyMOL. No GUI server, port or
HTML report is part of this package.

## Provenance, license and verification

[Upstream release](https://github.com/mittinatten/freesasa/releases/tag/2.1.4) ·
[CLI manual](https://freesasa.github.io/doxygen/CLI.html) ·
[C API](https://freesasa.github.io/doxygen/).

The native build uses the unmodified upstream commit
`f5bc39f3cc6418db35455783609058bfa702cccb` (archive SHA256
`2c670d5186235b40b421e37e4240da939a4135270a036184ad7ad06ac008923e`).
The release fixes neighbor handling for isolated atoms. The multi-platform Debian
base is digest-pinned. Debian mirrors and their security updates change; source
identity is pinned, but these builds do not promise byte-identical future images.

Packaging: Apache-2.0. FreeSASA: MIT; bundled Gemmi: MPL-2.0; bundled PEGTL:
MIT. Original notices are retained under `/opt/freesasa/share/licenses/freesasa`,
and Debian's runtime notices remain under `/usr/share/doc`. Citation:
[Mitternacht, F1000Research 5:189 (2016)](https://doi.org/10.12688/f1000research.7931.1).

Candidate verification for `2.1.4-r1`: native amd64 on Docker, Podman and Apptainer;
native arm64 on Docker and Podman. The final Docker image sizes (uncompressed,
per engine inspection) were 118.70 MiB on amd64 and 140.15 MiB on arm64; the amd64
SIF was 45.49 MiB. Most of the runtime is Debian and the XML/ICU dependency chain.
Build tools stay in the builder, CLI debug data is stripped, and the public
header and static library are retained. An external C program linked to the
same headers/archive on both architectures and agreed with CLI output.

Offline smoke covers source identity, linking, installed resources, both input
types, structured output, algorithm choice and selections. It checks packaging
and ordinary numerical invariants, not scientific accuracy on arbitrary inputs.
