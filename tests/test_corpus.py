# tests/test_corpus.py

import unittest
import os
import sys

# Add the project's src directory to the Python path for testing
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../src')))

from load import LoadCommand
from helpers import Helpers

class TestCorpus(unittest.TestCase):
    def test_corpus(self):
        corpus_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), 'elfs/bin/'))
        files = Helpers.scandir(corpus_dir)

        load_command_instance = LoadCommand()

        for file_name in files:
            filepath = os.path.join(corpus_dir, file_name)
            print(f"Testing: {filepath}")
            try:
                load_command_instance.run([filepath])
                self.assertTrue(True, f"Successfully attempted to load: {filepath}")
            except Exception as e:
                self.fail(f"Failed to load {filepath}: {e}")

if __name__ == '__main__':
    unittest.main()
