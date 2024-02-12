alias f := format
alias l := lint

default: serve

serve:
  @mdbook serve --open

run-workflows:
  @act -P ubuntu-22.04=ghcr.io/catthehacker/ubuntu:runner-22.04

check:
  @nix flake check -L
  @nix build ".#lints.all-checks" -L

check-format:
  @nix build ".#lints.all-formats" -L

format:
  @nix build ".#lints.format-all"
  @result/bin/format-all

lint: check format

build BUILD_DIR="build":
  @nix build
  @cp -Lr result/. {{BUILD_DIR}}
