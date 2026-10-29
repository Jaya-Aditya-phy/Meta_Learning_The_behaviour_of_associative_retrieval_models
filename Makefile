.PHONY: install test demo figures clean
install:
	pip install -e ".[dev]"
test:
	pytest
demo:
	neffretrieval demo
figures:
	neffretrieval bridge && neffretrieval nested && neffretrieval recalibrate && neffretrieval neff-policy \
	&& neffretrieval scaling --reps 2 --boot 60 && neffretrieval correction-scaling --reps 2 && neffretrieval landscape
clean:
	rm -rf outputs .pytest_cache build dist *.egg-info
