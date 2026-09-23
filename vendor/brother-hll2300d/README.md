# Pinned Brother HL-L2300D driver

This directory vendors the original working `brother-hll2300d 3.2.0_1-1`
package for x86_64. It was built and installed on 2025-10-13 and recovered
from the local yay cache. All 13 installed payload files matched the archive
byte-for-byte, with matching modes, when captured. The archive is unchanged;
its checksum is also embedded in `scripts/install-brother-driver`.

```sh
./scripts/install-brother-driver          # verify and preview
./scripts/install-brother-driver --write  # restore if missing and pin; sudo if needed
```

Run from the repository root. Installation uses `pacman -U` on the local
archive, with no AUR access, download, or rebuild of the driver. A missing
package requires the repository dependencies `perl`, `bash`, and `lib32-glibc`
to be installed first (the latter comes from multilib). CUPS and the printer
queue are separate prerequisites; the installer does not configure queues,
replace printer settings, restart CUPS, or send a test page. It refuses to
replace an installed version that differs from the pin. Matching versions
are left alone, preserving any local settings.

## Upgrade protection

The installer places `system/pacman/hooks/00-pin-brother-hll2300d.hook` at
`/etc/pacman.d/hooks/00-pin-brother-hll2300d.hook`. Pacman's pre-transaction
guard aborts any transaction that would upgrade, downgrade, or reinstall an
already installed `brother-hll2300d`, including explicit `pacman -U` calls.
An initial install is allowed. Existing pin files receive numbered backups.
This complements the yay block and survives Omarchy's pacman.conf refresh.

The guard intentionally fails the whole transaction if the driver is selected;
it does not silently skip that package. It does not freeze CUPS, glibc, or
other dependencies, so it cannot guarantee compatibility with every future
system update. Removing the package is still allowed, followed by a restore
from this archive.

To deliberately change this policy, remove the hook first and review/update
the vendored package, checksum, and installer together. Neither the guard nor
the checksum protects against someone deliberately changing these files.

## Provenance and licenses

- Original AUR packaging commit: `ac61853bec24de4b72eea3c7f4c7e16bdcfb129e`
  in `https://aur.archlinux.org/brother-hll2300d.git`.
- `PKGBUILD` and `.SRCINFO` are the unmodified cached packaging files, for
  provenance only. The PKGBUILD checksum matches the archive's `.BUILDINFO`.
  The installer never executes the PKGBUILD or follows its HTTP URLs.
- `hll2300dlpr-3.2.0-1.i386.rpm` and
  `hll2300dcupswrapper-3.2.0-1.i386.rpm` are the original cached vendor inputs,
  not fresh downloads. Their original URLs are in the PKGBUILD.
- The GPL CUPSwrapper source scripts and notices are included inside the RPM
  and package, with the original license copied to `COPYING.cupswrapper`.
- `LICENSE.lpr.html` is Brother's LPR license from
  <https://support.brother.com/g/s/agreement/English_lpr/agree.html>, linked
  by its HL-L2300D LPR download page. Driver rights remain with Brother and
  the respective licensors; this repository does not relicense them.
- `SHA256SUMS` covers the package, original inputs, packaging, and licenses.
  Run `sha256sum -c SHA256SUMS` from this directory to check all files.

The original package was locally built and unsigned; these checksums pin the
known-working cached bytes, not an independently authenticated Brother build.
No debug package or printer-specific identifiers are included.

This version is intentionally frozen at the user's request. Brother's
[LPR download page](https://support.brother.com/g/b/downloadend.aspx?c=us&dlid=dlf101898_000&flang=4&lang=en&os=127&prod=hll2300d_us_eu_as&type3=558)
lists 3.2.0-2 with a security improvement. That update has not been applied;
pinning this version also prevents automatically receiving that fix.
