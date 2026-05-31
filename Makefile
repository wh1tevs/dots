PKGS := $(notdir $(patsubst %/,%,$(wildcard pkgs/*/)))

$(PKGS):
	@stow --no-folding --dotfiles --target=$(HOME) -d pkgs -R $@

deps:
	sudo dnf install -y $(shell cat packages)

tmux-plugins:
	mkdir -p $(HOME)/.config/tmux/plugins
	git clone https://github.com/tmux-plugins/tpm.git $(HOME)/.config/tmux/plugins/tpm

.PHONY: $(PKGS) deps tmux-plugins
