ARTIFACTS := cbfstool cbmem flashrom

$(ARTIFACTS):
	rm -f $@
	curl -fL -o $@ https://raw.githubusercontent.com/Dasharo/osfv-test-data/3b31384f0477fd08c9c884cfb642eaf4f76bb2dc/coreboot-tools/$@
	chmod +x $@
