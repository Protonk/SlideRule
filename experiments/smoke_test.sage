"""
Project smoke test.

Run from project root:  ./sagew experiments/smoke_test.sage
"""

import os
_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
load(os.path.join(_root, 'tests', 'run_tests.sage'))
