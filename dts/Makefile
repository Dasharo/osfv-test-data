ARTIFACTS := dts-base-image-v2.1.3.wic.gz

dts-base-image-v2.1.3.wic.gz:
	rm -f $@
	curl -fL -o $@ https://github.com/Dasharo/meta-dts/releases/download/v2.1.3/dts-base-image-v2.1.3.wic.gz

setup: $(ARTIFACTS:.gz=)

# After the fetch, or make would download the missing .gz with the rule above
$(ARTIFACTS:.gz=): %.wic: | fetch-%.wic.gz
	gzip -cdk $*.wic.gz > $@

include ../common.mk
