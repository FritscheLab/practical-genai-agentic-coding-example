.PHONY: help venv install test demo test-r demo-r check-figure check-figure-r refactor-r

help:
	@echo "Targets:"
	@echo "  venv       - create a Python environment in .venv"
	@echo "  install    - install Python plotting dependencies"
	@echo "  test       - run Python plotting behavior checks"
	@echo "  demo       - render the Python baseline PNG"
	@echo "  test-r     - run base-R plotting behavior checks"
	@echo "  demo-r     - render the R baseline PNG"
	@echo "  check-figure   - check Python journal requirements (starter should fail)"
	@echo "  check-figure-r - check R journal requirements (starter should fail)"
	@echo "  refactor-r - verify the optional R refactoring example"

venv:
	python -m venv .venv

install:
	python -m pip install -r requirements-plotting.txt

test:
	python -m unittest discover -s plotting/tests

demo:
	python plotting/plot_summary.py --output runs/baseline/summary.png

test-r:
	Rscript plotting/tests/run_tests.R

demo-r:
	Rscript plotting/plot_summary.R --output runs/baseline/summary.png

check-figure:
	python plotting/check_figure.py --output runs/with-fix/summary.png

check-figure-r:
	Rscript plotting/check_figure.R --output runs/with-fix/summary.png

refactor-r:
	Rscript examples/r_refactor/verify.R
