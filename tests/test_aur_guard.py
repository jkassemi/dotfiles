from pathlib import Path
import subprocess
import unittest


GUARD = Path(__file__).resolve().parents[1] / 'system/yay'


class AurGuardTests(unittest.TestCase):
    def run_guard(self, *args):
        return subprocess.run(['/bin/bash', str(GUARD), *args],
                              capture_output=True, text=True)

    def test_install_and_alternative_entry_points_are_blocked(self):
        for args in [(), ('google-chrome',),
                     ('-S', '--noconfirm', '--needed', 'google-chrome'),
                     ('-S', 'aur/google-chrome'), ('-Syu',),
                     ('--aur', '--sync', 'google-chrome'),
                     ('-Slqa',), ('-Gpa', 'google-chrome'),
                     ('-Qqe', '-S', 'google-chrome')]:
            with self.subTest(args=args):
                result = self.run_guard(*args)
                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertIn('disabled by local policy', result.stderr)

    def test_omarchy_update_step_skips_successfully(self):
        result = self.run_guard('-Sua', '--noconfirm', '--cleanafter',
                                '--ignore', 'gcc14,gcc14-libs')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('AUR updates skipped', result.stderr)

    @unittest.skipUnless(Path('/usr/bin/pacman').exists(), 'requires Arch Linux')
    def test_removal_menu_queries_match_pacman(self):
        for args in [('-Qqe',), ('-Qi', 'pacman')]:
            with self.subTest(args=args):
                expected = subprocess.run(['/usr/bin/pacman', *args],
                                          capture_output=True, text=True)
                actual = self.run_guard(*args)
                self.assertEqual(actual.returncode, expected.returncode)
                self.assertEqual(actual.stdout, expected.stdout)
                self.assertEqual(actual.stderr, expected.stderr)

    @unittest.skipUnless(Path('/usr/bin/pacman').exists(), 'requires Arch Linux')
    def test_query_arguments_cannot_switch_to_install(self):
        result = self.run_guard('-Qi', '-S', 'google-chrome')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("package '-S' was not found", result.stderr)


if __name__ == '__main__':
    unittest.main()
