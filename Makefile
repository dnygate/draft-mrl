# Build the Internet-Draft from kramdown-rfc source.
#
# Toolchain lives outside this repository so that the harness venv keeps to the
# dependency rule in CLAUDE.md (numpy at runtime, scipy optional, pytest for tests):
#
#   python3 -m venv ~/.venvs/ietf-tools && ~/.venvs/ietf-tools/bin/pip install xml2rfc
#   gem install kramdown-rfc
#
# The gem executable directory is not on PATH under Homebrew Ruby, hence the
# absolute path below. Adjust if the Ruby version changes.

DRAFT   := draft-nygate-ippm-mrl-00
KRAMDOWN := /opt/homebrew/lib/ruby/gems/4.0.0/bin/kramdown-rfc
XML2RFC  := $(HOME)/.venvs/ietf-tools/bin/xml2rfc

.PHONY: all txt html clean check lint

all: txt

txt: $(DRAFT).txt

html: $(DRAFT).html

$(DRAFT).xml: $(DRAFT).md
	$(KRAMDOWN) $< > $@

$(DRAFT).txt: $(DRAFT).xml
	$(XML2RFC) --text $< -o $@

$(DRAFT).html: $(DRAFT).xml
	$(XML2RFC) --html $< -o $@

# House style: em dashes are banned, and no tooling should be named anywhere.
check: $(DRAFT).md
	@echo "checking for em and en dashes"
	@! grep -n "—\|–" $< || (echo "FAIL: dash found" && false)
	@echo "checking for tooling references"
	@! grep -ni "claude\|copilot\|chatgpt\|anthropic\|ai assistant" $< \
		|| (echo "FAIL: tooling reference found" && false)
	@echo "checking for non-ASCII"
	@# Internet-Draft text is conventionally ASCII and idnits reports anything else. A
	@# typographically correct minus sign is exactly the kind of thing that arrives with
	@# prose written elsewhere, so it is caught here rather than at submission. The wider
	@# project deliberately uses U+2212 in its own documents, which is why this check
	@# belongs to the draft alone.
	@# Deleting every ASCII byte and counting the remainder is the portable test. BSD grep
	@# expands no \x escapes and treats high bytes as printable even under LC_ALL=C, so
	@# both of the obvious grep formulations silently pass everything.
	@n=$$(tr -d '\000-\177' < $< | wc -c | tr -d ' '); \
		if [ "$$n" != "0" ]; then echo "FAIL: $$n non-ASCII bytes in $<"; false; fi
	@echo "ok"

# Internet-Draft text is limited to 72 columns. xml2rfc wraps prose but leaves
# sourcecode blocks alone, so an over-wide JSON example only surfaces here.
lint: $(DRAFT).txt
	@echo "checking rendered line length"
	@if awk 'length > 72 {print NR": "length" chars: "$$0}' $< | grep .; then \
		echo "FAIL: over-length lines above"; false; else echo "ok"; fi

clean:
	rm -f $(DRAFT).xml $(DRAFT).txt $(DRAFT).html kramdown.err
	rm -rf .refcache
