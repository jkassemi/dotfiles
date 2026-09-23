import contextlib
import hashlib
import io
from pathlib import Path
import runpy
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch


REPO = Path(__file__).resolve().parents[1]
SCRIPT = REPO / 'scripts/install-brother-driver'


class BrotherDriverTests(unittest.TestCase):
    def setUp(self):
        self.main = runpy.run_path(str(SCRIPT))['main']
        self.globals = self.main.__globals__
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.target = Path(self.temp.name) / 'pin.hook'
        self.expected = 'brother-hll2300d 3.2.0_1-1\n'
        self.addCleanup(patch.stopall)
        patch.dict(self.globals, TARGET=self.target).start()
        patch('platform.machine', return_value='x86_64').start()
        patch('os.geteuid', return_value=1000).start()
        self.query = Mock()
        patch.dict(self.globals, query=self.query).start()
        self.run = patch('subprocess.run').start()

    def response(self, code=0, stdout='', stderr=''):
        return subprocess.CompletedProcess([], code, stdout, stderr)

    def configure(self, installed=True):
        self.query.side_effect = [self.response(stdout=self.expected),
            self.response(stdout=self.expected) if installed else
            self.response(1, stderr="error: package 'brother-hll2300d' was not found\n"),
            self.response()]

    def invoke(self, *args):
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            return self.main(list(args))

    def test_preview_never_installs(self):
        self.configure(installed=False)
        self.assertEqual(self.invoke(), 0)
        self.run.assert_not_called()

    def test_existing_driver_only_installs_guard(self):
        self.configure()
        self.assertEqual(self.invoke('--write'), 0)
        self.assertEqual(self.run.call_count, 1)
        command = self.run.call_args.args[0]
        self.assertEqual(command[:2], ['sudo', '/usr/bin/install'])
        self.assertIn('--backup=numbered', command)
        self.assertEqual(command[-1], str(self.target))

    def test_missing_driver_installs_verified_local_archive_then_guard(self):
        self.configure(installed=False)
        self.assertEqual(self.invoke('--write'), 0)
        self.assertEqual(self.run.call_count, 2)
        self.assertEqual(self.run.call_args_list[0].args[0],
                         ['sudo', '/usr/bin/pacman', '-U', '--needed', str(self.globals['ARCHIVE'])])
        self.assertEqual(self.run.call_args_list[1].args[0][1], '/usr/bin/install')

    def test_different_installed_version_is_not_replaced(self):
        self.query.side_effect = [self.response(stdout=self.expected),
                                 self.response(stdout='brother-hll2300d 9.0-1\n')]
        with self.assertRaises(SystemExit):
            self.invoke('--write')
        self.run.assert_not_called()

    def test_corrupt_archive_fails_before_pacman_or_privileged_commands(self):
        damaged = Path(self.temp.name) / 'damaged.pkg.tar.zst'
        damaged.write_bytes(b'not the pinned driver')
        with patch.dict(self.globals, ARCHIVE=damaged), self.assertRaises(SystemExit):
            self.invoke('--write')
        self.query.assert_not_called()
        self.run.assert_not_called()

    def test_missing_dependency_is_not_bypassed(self):
        self.query.side_effect = [self.response(stdout=self.expected),
            self.response(1, stderr="error: package 'brother-hll2300d' was not found\n"),
            self.response(127, stdout='lib32-glibc\n')]
        with self.assertRaises(SystemExit):
            self.invoke('--write')
        self.run.assert_not_called()

    def test_matching_installation_is_noop(self):
        self.configure()
        self.target.write_bytes(self.globals['HOOK'].read_bytes())
        target = Mock(wraps=self.target)
        target.parents = self.target.parents
        target.stat.return_value = Mock(st_uid=0, st_gid=0, st_mode=0o100644)
        with patch.dict(self.globals, TARGET=target):
            self.assertEqual(self.invoke('--write'), 0)
        self.run.assert_not_called()

    def test_vendored_files_match_checksum_manifest(self):
        directory = REPO / 'vendor/brother-hll2300d'
        for line in (directory / 'SHA256SUMS').read_text().splitlines():
            digest, name = line.split('  ', 1)
            with self.subTest(name=name):
                self.assertEqual(hashlib.sha256((directory / name).read_bytes()).hexdigest(), digest)


if __name__ == '__main__':
    unittest.main()
