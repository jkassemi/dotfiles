import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'scripts/dotfiles'
INSTALL = SCRIPT.parents[1] / 'install'


class RestoreTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / 'repo'
        self.home = self.root / 'user'
        (self.repo / 'scripts').mkdir(parents=True)
        (self.repo / 'config').mkdir(parents=True)
        self.home.mkdir()
        self.script = self.repo / 'scripts/dotfiles'
        self.script.write_bytes(SCRIPT.read_bytes())
        (self.repo / 'install').write_bytes(INSTALL.read_bytes())
        (self.repo / 'manifest.json').write_text(json.dumps({'config/test': '.config/test', 'config/theme': '.config/theme'}))
        (self.repo / 'config/test').write_text('saved')
        (self.repo / 'config/theme').symlink_to('../generated/theme')

    def run_command(self, *args, expected=0):
        result = subprocess.run(['python3', str(self.script), *args, '--home', str(self.home)],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return result

    def test_preview_restore_capture_backup_and_idempotence(self):
        self.run_command('apply')
        self.assertFalse((self.home / '.config').exists())
        self.run_command('apply', '--write')
        self.run_command('status')
        self.assertEqual(os.readlink(self.home / '.config/theme'), '../generated/theme')
        target = self.home / '.config/test'
        target.write_text('local edits')
        self.run_command('status', expected=1)
        self.run_command('capture')
        self.assertEqual((self.repo / 'config/test').read_text(), 'saved')
        self.run_command('capture', '--write')
        self.assertEqual((self.repo / 'config/test').read_text(), 'local edits')
        self.assertTrue(any(p.read_text() == 'saved' for p in self.home.glob('.local/state/dotfiles/backups/*/capture/.config/test')))
        target.write_text('another local edit')
        self.run_command('apply', '--write')
        self.assertTrue(any(p.read_text() == 'another local edit' for p in self.home.glob('.local/state/dotfiles/backups/*/apply/.config/test')))
        self.assertIn('Already up to date', self.run_command('apply', '--write').stdout)

    def test_missing_source_does_not_partially_apply(self):
        (self.repo / 'config/theme').unlink()
        self.run_command('apply', '--write', expected=2)
        self.assertFalse((self.home / '.config/test').exists())

    def test_symlink_parent_is_refused(self):
        (self.home / '.config').symlink_to(self.repo / 'config', target_is_directory=True)
        self.run_command('apply', '--write', expected=2)

    def test_path_traversal_is_refused(self):
        (self.repo / 'manifest.json').write_text('{"config/test": "../escape"}')
        self.run_command('apply', '--write', expected=2)

    def test_source_path_traversal_is_refused(self):
        (self.repo / 'manifest.json').write_text('{"../escape": ".config/test"}')
        self.run_command('capture', '--write', expected=2)

    def test_duplicate_destinations_are_refused(self):
        (self.repo / 'manifest.json').write_text(json.dumps({
            'config/test': '.config/test', 'config/theme': '.config/test'}))
        self.run_command('apply', '--write', expected=2)

    def test_installer_preview_and_isolated_restore(self):
        base = ['python3', str(self.repo / 'install'), '--home', str(self.home)]
        subprocess.run(base, check=True, capture_output=True)
        self.assertFalse((self.home / '.config').exists())
        subprocess.run(base + ['--write'], check=True, capture_output=True)
        self.run_command('status')
        result = subprocess.run(base + ['--write', '--activate'], capture_output=True)
        self.assertEqual(result.returncode, 2)

    def test_activation_requires_write(self):
        result = subprocess.run(['python3', str(self.repo / 'install'), '--activate'],
                                capture_output=True)
        self.assertEqual(result.returncode, 2)


if __name__ == '__main__':
    unittest.main()
