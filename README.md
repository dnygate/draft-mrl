# draft-nygate-ippm-mrl

Source for an IETF Internet-Draft defining **mouth-to-ear response latency (MRL)** for
conversational voice systems, together with an active method for measuring it at the RTP
egress reference point of the calling endpoint.

MRL is the interval between the transmission of the final speech sample of a caller's
utterance and the arrival of the first sample of the system's response audio. Two
variants are defined, one taken at packet arrival and one taken behind a de-jitter buffer
of stated target depth, and both are required in any report. The method is specified so
that both timestamps come from a single clock on a single host, which means the metric
needs no synchronisation between the measuring endpoint and the system under test.

## Status

Pre-submission. This draft has not been submitted to the IETF, has no working group
behind it, and carries unresolved editorial questions listed in its final appendix. The
most significant of those is what should count as response audio when a system emits a
filled pause or an earcon before its substantive reply.

The intended venue is the IPPM working group, though the charter question is open and
DISPATCH and the Independent Submission stream are both plausible alternatives.

## Building

The toolchain is deliberately kept outside any project virtual environment:

    python3 -m venv ~/.venvs/ietf-tools
    ~/.venvs/ietf-tools/bin/pip install xml2rfc
    gem install kramdown-rfc

Then:

    make        # renders draft-nygate-ippm-mrl-00.txt
    make html   # renders the HTML version
    make check  # house style checks
    make clean

The `KRAMDOWN` path at the top of the `Makefile` assumes Homebrew Ruby and will need
adjusting if the Ruby version changes.

## Reference implementation

An open instrument implementing this method is published separately at
[dnygate/voice-ai-latency-harness](https://github.com/dnygate/voice-ai-latency-harness),
archived at [10.5281/zenodo.22124823](https://doi.org/10.5281/zenodo.22124823). Where the
implementation and this specification disagree, the specification is correct and the
implementation has a bug.

## Licence

Contributions to the IETF are made under the terms of BCP 78 and BCP 79.
