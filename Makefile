.PHONY: all

all: ebin ebin/sam.beam ebin/watch_load.beam

ebin:
	mkdir -p ebin

ebin/sam.beam: src/sam.erl
	erlc -I include -o ebin $<

ebin/watch_load.beam: src/watch_load.erl
	erlc -I include -o ebin $<
