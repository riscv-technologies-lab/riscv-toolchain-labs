OUT_DIR := build
SRC_DIR := $(shell pwd)


$(OUT_DIR)/%.tex: $(SRC_DIR)/%.md
	mkdir $(OUT_DIR) || true
	pandoc -t beamer -s $^ -o $@ --standalone

$(OUT_DIR)/%.pdf: $(OUT_DIR)/%.tex
	xelatex --output-directory $(OUT_DIR) $^

all: $(OUT_DIR)/$(addsuffix .pdf, $(basename $(wildcard *.md)))
