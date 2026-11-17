#!/bin/sh
# Independent offline probes. No writes outside a fresh temporary directory.
set -eu
d=$(mktemp -d)
stage=${1:-missing}; log_path=
finish() {
  rc=$?
  trap - 0 HUP INT TERM
  if [ "$rc" -ne 0 ]; then
    printf 'smoke-stage=%s exit=%s\n' "$stage" "$rc" >&2
    if [ -n "$log_path" ] && [ -f "$log_path" ]; then tail -n 30 "$log_path" >&2 || :; fi
  fi
  if ! rm -rf -- "$d"; then
    printf 'smoke-stage=cleanup scratch=%s\n' "$d" >&2
    if [ "$rc" -eq 0 ]; then rc=1; fi
  fi
  exit "$rc"
}
trap finish 0
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
share=/opt/freesasa/share
pdb=$share/testdata/1ubq.pdb
case "$stage" in
  identity)
    log_path="$d/version"
    freesasa --version > "$d/version" 2>&1
    grep -Fx 'FreeSASA 2.1.4' "$d/version"
    grep -Fx 'upstream_commit=f5bc39f3cc6418db35455783609058bfa702cccb' "$share/doc/freesasa/source.txt"
    grep -Fx 'sha256=2c670d5186235b40b421e37e4240da939a4135270a036184ad7ad06ac008923e' "$share/doc/freesasa/source.txt"
    test -s /opt/freesasa/include/freesasa.h && test -s /opt/freesasa/lib/libfreesasa.a || exit 1
    test -s "$share/man/man1/freesasa.1"
    for f in LICENSE GEMMI-MPL-2.0-LICENSE.txt PEGTL-MIT.txt; do test -s "$share/licenses/freesasa/$f"; done
    for f in protor naccess oons dssp; do test -s "$share/freesasa/$f.config"; done
    (cd "$share/freesasa" && sha256sum -c "$share/doc/freesasa/classifiers.sha256")
    log_path="$d/ldd"
    ldd "$(command -v freesasa)" > "$d/ldd" 2>&1
    if grep -F 'not found' "$d/ldd"; then exit 1; fi
    ;;
  help)
    log_path="$d/help"
    freesasa --help > "$d/help" 2>&1
    # The upstream synopsis spells the thread switch differently from the parser.
    # Check thread support by running it in the selection probe below.
    for flag in --format --config-file --select --cif; do
      grep -F -- "$flag" "$d/help" >/dev/null || { echo "missing CLI capability: $flag" >&2; exit 1; }
    done
    ;;
  pdb)
    freesasa --format=json --depth=atom -o "$d/result" "$pdb"
    grep -F '"total"' "$d/result" >/dev/null
    grep -F '"atoms"' "$d/result" >/dev/null
    ;;
  cif)
    freesasa --cif --format=xml -o "$d/result" "$share/testdata/1ubq.cif"
    grep -F 'http://freesasa.github.io/' "$d/result" >/dev/null
    grep -F '<area ' "$d/result" >/dev/null
    ;;
  selection)
    freesasa --select='ubiq, chain A' --format=seq -o "$d/result" "$pdb"
    grep -F 'SEQ A' "$d/result" >/dev/null
    freesasa --shrake-rupley --n-threads=2 --resolution=100 --radii=naccess --format=rsa -o "$d/sr" "$pdb"
    grep -q '^RES ' "$d/sr"
    ;;
  *) exit 2 ;;
esac
