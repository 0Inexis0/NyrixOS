import importlib.machinery
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

path = Path(__file__).resolve().parents[1] / 'desktop/bin/nyrix-shortcuts'
loader = importlib.machinery.SourceFileLoader('shortcuts', str(path))
spec = importlib.util.spec_from_loader(loader.name, loader)
m = importlib.util.module_from_spec(spec)
loader.exec_module(m)

class Shortcuts(unittest.TestCase):
    def test_conflict_after_normalization(self):
        with self.assertRaises(m.Invalid):
            m.bindings({'terminal': 'win + q'})
    def test_input_cannot_be_lua(self):
        with self.assertRaises(m.Invalid):
            m.bindings({'terminal': 'SUPER + ");os.execute("bad")'})
    def test_reload_error_restores_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            original = '{}\n'
            (root/'shortcuts.json').write_text(original)
            with patch.object(m, 'ROOT', root), patch.object(m.sys, 'argv', ['tool', 'set', 'terminal', 'SUPER + T']), patch.object(m, 'resolve_instance'), patch.object(m, 'run', side_effect=['', 'ok', 'simulated compositor error']), patch.object(m.subprocess, 'run'):
                with self.assertRaises(m.Invalid): m.main()
            self.assertEqual((root/'shortcuts.json').read_text(), original)
            self.assertFalse((root/'shortcuts.lua').exists())

if __name__ == '__main__': unittest.main()
