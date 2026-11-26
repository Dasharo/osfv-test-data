# Included by each */Makefile with ARTIFACTS, after ARTIFACTS is set

# Fetch each artifact from the annex, build it when the annex cannot fetch it
setup: $(addprefix fetch-,$(ARTIFACTS))

fetch-%:
	git annex get $* || { echo "Fetching $* failed, building it" >&2; $(MAKE) -B $* || { git checkout -- $*; exit 1; }; }

.PHONY: setup
.DELETE_ON_ERROR:
