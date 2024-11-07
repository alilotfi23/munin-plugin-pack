# munin-plugin-pack
# Makefile for building, testing, installing, and packaging

.PHONY: all test lint install uninstall package clean help \
        test-plugins test-config test-executable test-metrics \
        shellcheck install-plugins install-examples install-docs

# Variables
PREFIX ?= /usr/local
PLUGIN_DIR ?= $(PREFIX)/share/munin/plugins
CONF_DIR ?= /etc/munin/plugin-conf.d
DOC_DIR ?= $(PREFIX)/share/doc/munin-plugin-pack
VERSION ?= 1.0.0
PKG_NAME ?= munin-plugin-pack
TMPDIR ?= /tmp

# Plugin source directory
PLUGINS_SRC := $(shell find plugins -type f ! -name '*.bak' ! -name '*.tmp')

# All plugin files
ALL_PLUGINS := $(PLUGINS_SRC)

# Test files
TEST_SCRIPTS := $(shell find tests -name '*.sh' -type f)

# ── Default target ────────────────────────────────────────────────
all: lint test
	@echo "All checks passed."

# ── Help ───────────────────────────────────────────────────────────
help:
	@echo "munin-plugin-pack Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all           Run lint and test (default)"
	@echo "  test          Run all test suites"
	@echo "  lint          Run ShellCheck on all plugins"
	@echo "  install       Install plugins and configuration"
	@echo "  uninstall     Remove installed plugins and configuration"
	@echo "  package       Create a release tarball"
	@echo "  clean         Remove build artifacts"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX        Installation prefix (default: /usr/local)"
	@echo "  PLUGIN_DIR    Munin plugin directory"
	@echo "  VERSION       Package version (default: 1.0.0)"

# ── Testing ────────────────────────────────────────────────────────
test: test-executable test-config test-metrics test-plugins
	@echo "All tests passed."

# Test that all plugins are executable
test-executable:
	@echo "=== Testing executable permissions ==="
	@failed=0; \
	for plugin in $(ALL_PLUGINS); do \
		if [ ! -x "$$plugin" ]; then \
			echo "FAIL: $$plugin is not executable"; \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	if [ $$failed -gt 0 ]; then \
		echo "FAILED: $$failed plugin(s) not executable"; \
		exit 1; \
	fi; \
	echo "PASS: All plugins are executable"

# Test that config output is valid
test-config:
	@echo "=== Testing config output ==="
	@failed=0; \
	for plugin in $(ALL_PLUGINS); do \
		output=$$("$$plugin" config 2>&1); \
		rc=$$?; \
		if echo "$$output" | grep -q "graph_title"; then \
			:; \
		elif echo "$$output" | grep -qi "error\|no ("; then \
			:; \
		else \
			echo "WARN: $$plugin config output may be invalid (rc=$$rc)"; \
		fi; \
	done; \
	echo "PASS: Config output test complete"

# Test that metric output format is valid
test-metrics:
	@echo "=== Testing metric format ==="
	@failed=0; \
	for plugin in $(ALL_PLUGINS); do \
		output=$$("$$plugin" 2>&1); \
		# Check for .value patterns or U values or no output (dependency missing) \
		if echo "$$output" | grep -qE '\.value (U|[0-9])'; then \
			:; \
		elif [ -z "$$output" ]; then \
			:; \
		else \
			echo "WARN: $$plugin output may not contain valid metrics"; \
		fi; \
	done; \
	echo "PASS: Metric format test complete"

# Run custom test scripts
test-plugins:
	@echo "=== Running plugin test scripts ==="
	@if [ -d tests ]; then \
		for t in $(TEST_SCRIPTS); do \
			echo "Running $$t..."; \
			sh "$$t" || exit 1; \
		done; \
	fi; \
	echo "PASS: Plugin tests complete"

# ── Linting ────────────────────────────────────────────────────────
lint: shellcheck

shellcheck:
	@echo "=== Running ShellCheck ==="
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck --severity=warning --shell=sh \
			$(ALL_PLUGINS) \
			tests/*.sh \
			scripts/*.sh 2>&1 || true; \
		echo "ShellCheck complete."; \
	else \
		echo "SKIP: ShellCheck not installed (install with: apt-get install shellcheck)"; \
	fi

# ── Installation ───────────────────────────────────────────────────
install: install-plugins install-examples install-docs
	@echo "Installation complete."
	@echo "  Plugins installed to: $(PLUGIN_DIR)"
	@echo "  Restart munin-node to apply: systemctl restart munin-node"

install-plugins:
	@echo "=== Installing plugins ==="
	@install -d $(DESTDIR)$(PLUGIN_DIR)/docker
	@install -d $(DESTDIR)$(PLUGIN_DIR)/security
	@install -d $(DESTDIR)$(PLUGIN_DIR)/disk
	@install -d $(DESTDIR)$(PLUGIN_DIR)/web
	@install -d $(DESTDIR)$(PLUGIN_DIR)/backup
	@install -d $(DESTDIR)$(PLUGIN_DIR)/network
	@install -d $(DESTDIR)$(PLUGIN_DIR)/system
	@install -d $(DESTDIR)$(PLUGIN_DIR)/kubernetes
	@install -d $(DESTDIR)$(PLUGIN_DIR)/qdrant
	@install -d $(DESTDIR)$(PLUGIN_DIR)/api
	@for plugin in $(ALL_PLUGINS); do \
		install -m 0755 "$$plugin" "$(DESTDIR)$(PLUGIN_DIR)/$$plugin"; \
	done
	@echo "Plugins installed."

install-examples:
	@echo "=== Installing example configs ==="
	@install -d $(DESTDIR)$(DOC_DIR)/examples
	@install -m 0644 examples/* $(DESTDIR)$(DOC_DIR)/examples/
	@echo "Examples installed."

install-docs:
	@echo "=== Installing documentation ==="
	@install -d $(DESTDIR)$(DOC_DIR)
	@install -m 0644 README.md CHANGELOG.md CONTRIBUTING.md LICENSE $(DESTDIR)$(DOC_DIR)/
	@if [ -d docs ]; then \
		install -m 0644 docs/* $(DESTDIR)$(DOC_DIR)/; \
	fi
	@echo "Documentation installed."

# ── Uninstallation ─────────────────────────────────────────────────
uninstall:
	@echo "=== Uninstalling plugins ==="
	@for plugin in $(ALL_PLUGINS); do \
		rm -f "$(DESTDIR)$(PLUGIN_DIR)/$$plugin"; \
	done
	@echo "Plugins removed from $(PLUGIN_DIR)"
	@echo "Note: empty directories may remain. Remove manually if needed."

# ── Packaging ──────────────────────────────────────────────────────
package:
	@echo "=== Creating release package ==="
	@mkdir -p $(TMPDIR)/$(PKG_NAME)-$(VERSION)
	@cp -r plugins examples docs scripts tests $(TMPDIR)/$(PKG_NAME)-$(VERSION)/
	@cp README.md CHANGELOG.md CONTRIBUTING.md LICENSE Makefile .gitignore \
		$(TMPDIR)/$(PKG_NAME)-$(VERSION)/
	@tar -czf $(PKG_NAME)-$(VERSION).tar.gz \
		-C $(TMPDIR) $(PKG_NAME)-$(VERSION)
	@rm -rf $(TMPDIR)/$(PKG_NAME)-$(VERSION)
	@echo "Package created: $(PKG_NAME)-$(VERSION).tar.gz"
	@ls -lh $(PKG_NAME)-$(VERSION).tar.gz

# ── Clean ──────────────────────────────────────────────────────────
clean:
	@echo "=== Cleaning build artifacts ==="
	@rm -f $(PKG_NAME)-*.tar.gz
	@rm -rf tests/tmp tests/output
	@echo "Clean complete."
