ARTIFACTS := sb_test_data.img
INPUTS := create_img.sh ../hello-dasharo

# Phony, the annexed image always exists and would never be rebuilt
.PHONY: sb_test_data.img
sb_test_data.img:
	$(MAKE) -C ../hello-dasharo clean
	$(MAKE) -C ../hello-dasharo dist
	./create_img.sh

include ../common.mk
