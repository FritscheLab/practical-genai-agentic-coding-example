.PHONY: help venv install test lint demo install-r test-r demo-r parity

help:
	@echo "Targets:"
	@echo "  venv      - create a Python environment in .venv"
	@echo "  install   - install Python exercise dependencies"
	@echo "  test      - run Python tests with pytest"
	@echo "  lint      - check Python with Ruff"
	@echo "  demo      - run the Python six-row example"
	@echo "  install-r - install R exercise dependencies"
	@echo "  test-r    - run native R tests"
	@echo "  demo-r    - run the R six-row example"
	@echo "  parity    - compare Python and R outputs (requires both)"

venv:
	python -m venv .venv

install:
	python -m pip install -r requirements-dev.txt

test:
	python -m pytest

lint:
	python -m ruff check .

demo:
	python -m pgacg demo --ehr data/example/exclusion_report/ehr.tsv --demo data/example/exclusion_report/demographics.tsv

install-r:
	Rscript scripts/r/install_dependencies.R

test-r:
	Rscript tests/r/run_tests.R

demo-r:
	Rscript scripts/r/demo.R --ehr data/example/exclusion_report/ehr.tsv --demo data/example/exclusion_report/demographics.tsv

parity:
	python scripts/py/check_language_parity.py
