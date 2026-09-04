---
title: "Mouth-to-Ear Response Latency for Conversational Voice Systems: Metric Definition and Active Measurement Method"
abbrev: "Mouth-to-Ear Response Latency"
docname: draft-nygate-ippm-mrl-00
category: info
submissiontype: IETF
consensus: true
v: 3
area: "Operations and Management"
workgroup: "IP Performance Measurement"
keyword:
  - latency
  - conversational
  - RTP
  - endpointing
  - voice
venue:
  group: "IP Performance Measurement"
  type: "Working Group"
  mail: "ippm@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/ippm/"
  github: "dnygate/draft-mrl"
author:
  -
    fullname: Daniel Nygate
    email: dnygate@outlook.com
normative:
  RFC3550:
  RFC3551:
  RFC8259:
informative:
  RFC2330:
  RFC6076:
  RFC6390:
  RFC7679:
  RFC7799:
  RFC8911:
  RFC8912:
  RFC3611:
  G114:
    title: "One-way transmission time"
    author:
      - organization: ITU-T
    date: 2003
    seriesinfo:
      ITU-T: Recommendation G.114
  G711:
    title: "Pulse code modulation (PCM) of voice frequencies"
    author:
      - organization: ITU-T
    date: 1988
    seriesinfo:
      ITU-T: Recommendation G.711
  HARNESS:
    title: "voice-ai-latency-harness: an instrument for measuring mouth-to-ear response latency"
    author:
      - fullname: Daniel Nygate
    date: 2026
    seriesinfo:
      DOI: 10.5281/zenodo.22124823
  TTFAB:
    title: "Voice agent latency benchmark: time to first audio byte measured from real phone calls"
    author:
      - organization: OpenBenchmarks Labs
    date: 2026
    target: https://openbenchmarks.com/voice-agent-latency

--- abstract

This document defines mouth-to-ear response latency (MRL), a performance metric for
conversational voice systems, together with an active method for measuring it at the
RTP reference point of the calling endpoint. MRL is the interval between the
transmission of the final speech sample of a caller's utterance and the arrival of the
first sample of the system's response audio. Two variants are defined, one taken at
packet arrival and one taken behind a de-jitter buffer of stated target depth. The
method is specified so that both timestamps are drawn from a single clock on a single
host, so that the metric requires no synchronisation between the measuring endpoint and
the system under test. Requirements for stimulus material, capture content, quality
control, calibration and reporting are given.

--- middle

# Introduction

Conversational voice systems built from speech recognition, language modelling and
speech synthesis components are now widely deployed over SIP and RTP. Response latency
is a primary determinant of whether such a system is usable, and it is measured today by
several parties who do not agree on what is being measured. There is no common
definition of the quantity, no agreed reference point at which to observe it, and no
convention for reporting its uncertainty.

Figures produced under different assumptions are routinely compared as though they were
commensurable, which is the practical problem this document exists to address.
{{decomposition}} sets out the terms that separate one figure from another, and
{{existing}} describes the axes along which current measurement practice divides.

This document takes no position on the magnitude of any term, on the accuracy of any
published figure, or on the merits of any existing measurement effort. It defines a
quantity and a method of observing it, so that figures produced by different parties are
comparable.

## Motivation and decomposition {#decomposition}

For a caller connected to a conversational voice system over SIP and RTP, the interval
between the end of the caller's utterance and the arrival of response audio comprises,
in order of occurrence:

| Term |
|---|
| de-jitter buffer depth on the inbound leg |
| voice activity detection and endpointing decision |
| speech recognition finalisation after the endpoint decision |
| orchestration, retrieval and any tool invocation |
| language model time to first token |
| speech synthesis time to first audio |
| encoding, packetisation and media relay |
| de-jitter buffer depth on the outbound leg |

A figure covering one or two of these terms does not predict the interval a caller
experiences, and the terms are not separable by observation at the caller. MRL is
defined here as the aggregate, observed at a single reference point, precisely because
the aggregate is what an external observer can measure without instrumenting the system
under test.

## Existing practice {#existing}

Two kinds of figure are published today.

Component-level figures are reported by the operators of individual components, most
commonly the interval from a request reaching a speech synthesis endpoint to the first
audio byte returned, and less commonly the interval to a language model's first token.
These are observed at an API boundary internal to the system and cover a subset of the
terms above.

Caller-side figures are produced by placing a call and observing the response. At least
one such effort publishes both its results and its tooling openly {{TTFAB}}, reporting
the interval between the caller's speech end and the onset of the response as observed
in a recording of the call rather than in any timestamp reported by the system.

Caller-side efforts differ from one another along axes that render their outputs
incomparable, and those axes are the reason this document exists:

* the reference point at which the response is observed, which may be an RTP endpoint,
  a recording made by a carrier or a conferencing bridge, or an endpoint's audio device,
  each placing a different and frequently uncharacterised quantity of transport and
  buffering inside the measured interval;
* the determination of the caller's speech end, which may be derived from a voice
  activity detector applied to the transmitted audio, or from prior annotation of known
  stimulus material;
* the treatment of buffering, since an interval taken at packet arrival and an interval
  taken after a de-jitter buffer differ by the depth of that buffer;
* the definition of response onset, which for audio that ramps in gradually is a choice
  of threshold rather than an observation;
* whether the measuring instrument has itself been calibrated against a known delay, and
  therefore whether a reported figure is a point estimate or an upper bound.

An effort that states its choices along these axes produces figures a reader can
interpret, whereas two efforts that have chosen differently produce figures which cannot
be placed side by side even when each is internally correct. This document specifies one
set of choices and requires that they be reported alongside any figure derived under
them.

## Scope

This document specifies:

* the definition of the MRL metric and its two required variants;
* the method of measurement, including the reference point, the determination of the
  interval endpoints, and the required contents of a capture;
* the conditions under which a measurement MUST be treated as invalid;
* the fields that MUST accompany a reported figure.

This document does not specify endpointing strategy, barge-in handling, speech
recognition or synthesis behaviour, or any property of the system under test. It does
not specify a signalling protocol; the method assumes an established RTP session and is
independent of how that session was established.

## Relationship to existing work

The metric defined here is an application-layer performance metric in the sense of
{{RFC6390}}, and this document follows the template in Section 5.4 of that document.
{{RFC6076}} defines end-to-end performance metrics for telephony sessions at the SIP
layer and is the closest existing IETF work in subject matter; the metric defined here
concerns the media plane rather than signalling, and is complementary. No existing IETF
document defines the quantity described in {{decomposition}} or specifies a reference
point at which to observe it.

The framework of {{RFC2330}} and the delay metric of {{RFC7679}} inform the treatment of
error and uncertainty. The method described here is an active method in the taxonomy of
{{RFC7799}}, since it generates the stimulus whose response it measures.

{{RFC3611}} and its extensions define a reporting mechanism by which endpoints convey
media quality metrics in band. Conveying MRL in that manner is out of scope for this
document and is noted in {{future}} as possible follow-on work.

> \[\[EDITOR'S NOTE, on venue. The IPPM charter bounds the group's work to "metrics and
> methodologies which are applicable over transport-layer protocols over IP", while also
> covering "applications running over transport layer protocols". Whether a metric whose
> dominant terms are speech recognition, inference and synthesis falls inside that
> boundary is a fair question and should be settled before effort is spent on -01.
>
> The precedent in favour is draft-ietf-ippm-responsiveness, an adopted IPPM work item
> targeting Proposed Standard, which measures at the application layer over HTTP/2 and
> HTTP/3 and justifies itself explicitly on user experience. The argument against is that
> responsiveness remains a property of the network under load, whereas most of MRL is
> not attributable to the network at all.
>
> If IPPM declines, the alternatives are to take the question to DISPATCH, which exists
> for work with no obvious home, or to pursue publication through the Independent
> Submission stream. The document is written to stand in any of the three.
>
> Separately, decide whether to pursue registration in the Performance Metrics Registry
> ({{RFC8911}}, initially populated by {{RFC8912}}); {{registry}} holds a draft entry.
> The registry has to date been populated with IP-layer path metrics, so eligibility
> should be confirmed before the appendix is presented as a proposal.\]\]

# Conventions and Definitions

{::boilerplate bcp14-tagged}

The following terms are used throughout.

Calling endpoint:
: The endpoint that generates the stimulus utterance and observes the response. All
  measurement is performed here.

System under test (SUT):
: The conversational voice system that receives the stimulus and generates a response.
  The method treats the SUT as opaque.

Reference point:
: The point at which timestamps are taken. See {{refpoint}}.

Stimulus:
: A prerecorded utterance transmitted by the calling endpoint to elicit a response.

Speech end:
: The final sample of speech in the stimulus, determined offline. See {{t0}}.

Response onset:
: The first sample of the SUT's response audio, determined offline. See {{onset}}.

# Metric Definition

## Metric name

Mouth-to-Ear Response Latency (MRL), reported in two variants named Ingress MRL and
Playout MRL.

## Metric description

MRL is the interval between the instant at which the calling endpoint transmits the
final speech sample of a stimulus utterance and the instant at which the first sample of
the SUT's response reaches the calling endpoint.

MRL is defined as:

~~~
MRL = t1 - t0
~~~

where t0 and t1 are as defined in {{t0}} and {{t1}}.

MRL is signed. A negative value indicates that response audio reached the calling
endpoint before the stimulus had finished being transmitted, which occurs with
aggressive endpointing and with backchannel responses. Implementations MUST report
negative values as measured and MUST NOT clamp them to zero.

## Interval start: t0 {#t0}

t0 is the instant at which the final speech sample of the stimulus is transmitted by the
calling endpoint at the reference point.

t0 MUST be determined by:

1. annotating the stimulus offline to sample precision to locate the speech end;
2. mapping that sample onto the RTP packet that carried it, using RTP timestamps as
   defined in {{RFC3550}};
3. interpolating within that packet at the sample rate to obtain the sample's offset
   from the packet's transmission instant.

t0 is therefore the transmission instant of the carrying packet plus the target sample's
offset within that packet. The sign of the offset term is significant; see
{{errors}}.

t0 MUST NOT be derived from voice activity detection performed at run time. A run-time
detector has a decision lag of its own, that lag is a term within the quantity being
measured, and using it to define t0 would conceal the term.

Annotation of the stimulus MUST NOT extend the speech end by a fixed constant. A fixed
extension displaces t0 later by that constant and, since MRL is t1 minus t0, reduces
every reported figure by the same constant. See {{errors}}.

> \[\[EDITOR'S NOTE: the reference implementation uses decay-following hysteresis with a
> short sliding RMS refinement. A normative specification has to decide how much of that
> to mandate. The options are to specify the algorithm, to specify a conformance test
> that any annotator MUST pass against a published reference signal, or to require only
> that the annotation be published alongside the result so that a reviewer can
> substitute their own. The second is probably the right answer and needs the reference
> signal to be published as part of this work.\]\]

## Interval end: t1 {#t1}

t1 is the instant at which the first sample of the SUT's response reaches the calling
endpoint, taken at the reference point.

t1 MUST be determined by reassembling the received stream in RTP timestamp order,
locating the response onset as specified in {{onset}}, and mapping the onset sample back
through the packet that carried it.

Two variants of t1 are defined, and both MUST be reported.

### Ingress MRL {#ingress}

Ingress MRL takes t1 at the arrival instant of the onset sample, that is, at the
reference point with no buffering applied.

Ingress MRL isolates the contribution of the SUT and of the network path from the
buffering policy of the calling endpoint. Its variance under a jittered path tracks the
jitter of that path, because the metric reports the path as it finds it, and an
implementation showing less variance than the path exhibits is smoothing a quantity it
was asked to observe.

### Playout MRL {#playout}

Playout MRL takes t1 at the instant at which the onset sample would be released from a
de-jitter buffer of stated target depth.

The target depth MUST be reported with the figure. The de-jitter model used MUST anchor
on the minimum transit delay observed over a stated initial window, which is the
behaviour adaptive buffers converge toward, rather than on the arrival instant of the
first packet received.

Playout MRL corresponds to the interval a caller waits and is the variant to compare
against conversational turn-taking norms.

Playout MRL is distinct from the one-way transmission delay addressed by {{G114}}, and
the two are not interchangeable. One-way transmission delay concerns the time taken to
carry audio across a path and applies to a conversation between two people, whereas MRL
concerns the time a system takes to begin responding and includes transmission delay as
one term among several. A system may satisfy the transmission delay guidance in {{G114}}
on both legs and still exhibit an MRL an order of magnitude larger.

### Both variants required

An implementation MUST report both variants. Ingress MRL on its own understates the
interval a caller experiences, while a bare Playout MRL leaves the SUT confounded with
whatever buffering policy the calling endpoint happened to apply, so neither figure can
be interpreted without the other.

## Response onset {#onset}

The instant at which audio begins has no unique definition, because synthesised speech
commonly ramps in over tens of milliseconds rather than beginning at full level. Onset
is therefore computed under three named variants, and the dispersion across them is a
component of the reported uncertainty.

| Variant | Above noise floor | Absolute floor | Sustained for |
|---|---|---|---|
| sensitive | 6 dB | -55 dBov | 10 ms |
| headline | 10 dB | -50 dBov | 20 ms |
| strict | 12 dB | -45 dBov | 30 ms |

Levels are expressed in dBov, referenced to full-scale RMS.

The `headline` variant is the reported figure. The spread of MRL across all three
variants is the onset-definition uncertainty of the measurement and MUST be published
alongside any headline figure. On an abrupt onset the spread is small; on a gradual ramp
it grows with the ramp duration and becomes the dominant uncertainty term.

Sub-frame refinement of the onset instant MUST use a short sliding RMS. Instantaneous
sample magnitude crosses any fixed threshold on isolated noise peaks at a rate high
enough to displace the boundary materially; see {{errors}}.

## Unprompted audio {#greeting}

A conversational voice system commonly speaks before the caller does, opening with a
greeting that arrives within a few hundred milliseconds of the session being established.
That audio responds to nothing, because the caller has not yet spoken.

Response-onset detection MUST NOT begin before the end of any such unprompted audio. The
point at which it ended MUST be recorded in the capture, and the noise-floor estimate
required by {{onset}} MUST be taken from audio following that point.

Detection across the whole received stream locates the greeting instead of the response.
Since the greeting precedes t0, the resulting MRL is large and negative, and because this
document licenses negative values as genuine behaviour there is no bound against which such
an error announces itself. In the reference implementation, a capture carrying an 800 ms
greeting with a true MRL of 900 ms yielded -2085 ms and satisfied every condition in
{{qc}}.

A greeting falling inside the noise-floor window is speech rather than channel noise, so it
raises the estimate and displaces every onset threshold derived from it. On the same
capture the floor moved by 1.35 dB.

A calling endpoint SHOULD NOT begin transmitting its stimulus while unprompted audio is
still in progress. A system that implements barge-in detection will stop speaking when it
hears the caller, which truncates the greeting and alters the interaction under
measurement.

The interval from session establishment to the onset of unprompted audio is a distinct and
useful quantity, since a caller who hears nothing for several seconds after the line opens
is poorly served whatever the system's MRL turns out to be. It shares no terms with MRL and
is not defined here; see {{future}}.

## Filler audio and response continuity {#whatcounts}

t1 as defined in {{t1}} is the onset of the system's first response audio, whatever that
audio happens to contain. A system that emits an earcon, a breath or a filled pause while
its response is still being generated therefore records a low MRL while conveying nothing
during that interval, and would rank above a system that stayed quiet and then answered.

This document does not resolve that by identifying which audio carries meaning. A metric
incorporating a judgement about meaning cannot be re-derived from a published capture by an
independent reviewer, and that reproducibility is the property which makes the rest of this
specification worth having. The discriminator is structural instead: filler is followed by
silence before the substantive response begins, and continuous speech is not.

An implementation MUST, within a window of 2000 ms following t1, measure the longest
interval whose level lies below the onset threshold of the headline variant. Intervals
carried by no packet MUST be excluded from that measurement, because a lost or
late-discarded frame leaves a gap indistinguishable from a deliberate pause and would
otherwise allow a degraded path to manufacture filler.

Where that interval exceeds 150 ms:

* the response MUST be reported as discontiguous;
* a second onset MUST be reported, at the start of the final contiguous segment, together
  with the MRL derived from it.

MRL itself is unchanged by this section, so no figure measured under an earlier revision
becomes invalid. A reader receives both onsets and can see whether they differ and by how
much.

The 2000 ms window and the 150 ms threshold are fixed by this document rather than left to
the implementation, for the reason given in {{onset}}: figures derived under different
parameters cannot be compared even when each is internally correct. Both MUST be reported
alongside any figure derived under them.

# Method of Measurement

## Reference point {#refpoint}

All timestamps MUST be taken at the RTP egress and ingress reference point of the
calling endpoint, that is, immediately before a packet is passed to the operating system
for transmission and immediately after a packet is received from it.

The reference point is chosen so that the measurement includes every term a caller
experiences downstream of the calling endpoint's own send path, and excludes the calling
endpoint's own playout hardware, which is a property of the observer rather than of the
SUT.

## Stimulus requirements

Stimulus material MUST be prerecorded and MUST be transmitted at the nominal frame rate
of the codec in use. The stimulus MUST be hashed and the hash MUST be recorded with the
capture, so that a changed stimulus invalidates a comparison loudly rather than
silently.

The method is independent of the codec, and the codec in use MUST be reported with any
figure derived under it. Where a payload format from {{RFC3551}} is used, the sample rate
and frame period follow that profile, and the companding of {{G711}} applies to the PCMU
and PCMA formats.

## Transmission pacing

The calling endpoint MUST measure the deviation of its own transmission instants from
the nominal frame grid and MUST record the worst deviation observed during the call. An
endpoint that cannot pace its own transmission has an unreliable t0 and therefore an
unreliable MRL. See {{qc}}.

## Capture contents

A capture MUST contain raw payloads and raw timestamps only. A capture MUST NOT contain
any derived quantity, including any latency figure.

This requirement exists so that a revised onset definition, or a definition proposed by
a reviewer, can be applied to existing data without repeating a collection. The
uncertainty analysis in {{onset}} is not possible otherwise.

## Clock requirements {#clocks}

Both t0 and t1 MUST be taken from a single monotonic clock on the calling endpoint.

Because the interval is the difference of two timestamps drawn from one clock on one
host, the metric requires no synchronisation between the calling endpoint and the SUT,
and is insensitive to offset between them. This is a deliberate property of the
definition and distinguishes the method from one-way delay measurement, where clock
synchronisation between the two hosts dominates the error budget as described in
Section 3.7.1 of {{RFC7679}}.

A wall-clock timestamp MAY be recorded in parallel for the sole purpose of correlating
captures with traces obtained from the SUT. Any offset or skew in that clock affects
such correlation only and MUST NOT affect the reported MRL.

## Sources of error and calibration {#errors}

An implementation MUST state its calibrated accuracy, and MUST state the conditions
under which that calibration was obtained.

Calibration is performed by replacing the SUT with a reference responder that replies at
a programmed delay, so that ground truth is known exactly. Under each channel condition
the offset from ground truth that the physics of the channel requires is predictable in
advance: for Ingress MRL it is the base transit delay plus the mean jitter excess, and
for Playout MRL it is the base transit delay plus the buffer target depth. The
calibration criterion is therefore the residual after subtracting that predicted offset,
rather than the raw difference from ground truth.

Calibration MUST NOT be performed exclusively at programmed delays that are integer
multiples of the frame period. A responder that evaluates its emission deadline once per
received frame quantises its own output to the frame period, and that error is invisible
at frame-commensurate delays because the deadline then falls on a frame boundary.

The following error mechanisms are known to produce plausible-looking but incorrect
figures, and an implementation is advised to test for each:

Fixed annotation extension:
: Extending the stimulus speech end by a constant biases every figure low by that
  constant.

Instantaneous-magnitude thresholding, at either boundary:
: Sub-frame refinement on sample magnitude rather than a short sliding RMS lets isolated
  noise peaks cross the threshold. At the stimulus end boundary this displaces t0 late; at
  the response onset it displaces t1 early, biasing MRL low by up to one analysis window.
  The second was masked in the reference implementation for as long as its calibration
  responder placed responses on the analysis grid, and surfaced only once a media-clock
  responder placed them where they began: it accounted for the whole of a -0.40 ms
  headline bias and a 0.99 ms spread between onset variants on a hard onset. A fix applied
  at one boundary has to be checked against its mirror.

Frame-quantised reference responder:
: Adds a uniform error between zero and one frame period, invisible at frame-commensurate
  calibration delays.

Frame-offset sign error:
: Using the wrong sign for the within-frame offset term of t0 produces a residual of
  twice the offset with the opposite sign. A large bias accompanied by a tight spread is
  the signature of a definitional or arithmetic error rather than of host timing noise,
  and implementations are advised to report that discrimination automatically.

Symmetric jitter modelling:
: A simulated channel that models network jitter as zero-mean Gaussian permits a
  minimum-tracking de-jitter anchor to sit earlier than the minimum transit delay allows,
  which appears as a negative bias in Playout MRL. Network jitter is one-sided and has a
  hard floor at the minimum transit delay. Sender pacing deviation is a different
  mechanism and is symmetric, because a timer-driven sender can fire either early or
  late.

Calibration source that is not an honest RTP sender:
: A reference responder whose RTP timestamps count frames rather than follow a media
  clock, or whose idle-stream pacing depends on whether it is receiving anything,
  produces playout figures with errors that ingress cannot see, since ingress is derived
  from arrival and playout through the timestamp. Observed as a 44.7 ms transit slip
  that flagged late discard on jitter-free calls, and 9.54 ms of playout spread that no
  buffer target reduced. Both surfaced only from kept captures over a real path.

> \[\[EDITOR'S NOTE: the reference implementation's calibrated figures are published in
> {{HARNESS}} and are deliberately not reproduced here. A metric specification that
> carries one implementation's results becomes stale and invites the reader to treat
> those figures as a conformance target. Confirm this is the right call in review.\]\]

# Units of Measurement

MRL is reported in milliseconds, signed, to a resolution of not coarser than 0.1 ms.

Uncertainty terms accompanying the figure are reported in the same units.

# Measurement Points and Measurement Domain

The single measurement point is the calling endpoint's RTP reference point as defined in
{{refpoint}}. No observation of the SUT's internal state is required, and none is
assumed to be available.

The measurement domain is the path between the calling endpoint and the SUT together
with the SUT itself. The method does not separate the two, and reported figures are
therefore properties of the pairing rather than of the SUT alone. Where separation is
required, the path contribution has to be characterised independently and reported
alongside.

# Measurement Timing

Each measurement corresponds to one stimulus and one response within one session. A
reported distribution MUST state the number of measurements attempted and the number
discarded, as required by {{qc}}.

> \[\[TODO: specify whether multiple stimulus/response exchanges within a single session
> are permitted, and if so what conditioning effects have to be reported. A system whose
> nth turn is faster than its first because a model is warm is a real effect and the
> draft currently has nothing to say about it.\]\]

# Quality Control and Result Validity {#qc}

Two classes of condition are defined.

## Blocking conditions

A measurement exhibiting any of the following MUST be discarded and MUST NOT be reported
as a figure:

* no speech end could be located in the stimulus;
* no packets were received from the SUT;
* no response onset was found;
* the response onset fell within the first received frame, so that the true onset may
  precede the observation window;
* the worst transmission pacing deviation exceeded a stated threshold.

The pacing threshold in the reference implementation is 5 ms. A calling endpoint that
cannot pace its own transmission within that bound has an unreliable t0.

Discarding a measurement under these conditions is correct behaviour. An implementation
MUST NOT relax a blocking condition in order to retain a measurement.

## Advisory conditions

The following conditions do not invalidate a measurement but MUST be reported with it:

* packet loss above a stated threshold;
* late discard above a stated threshold.

A call over a lossy path remains a valid measurement of a lossy path. Where the frame
carrying the response onset is itself lost, onset detection is deferred by whole frames
and the resulting figure is an upper bound rather than a point estimate, which is why
the flag has to travel with the number.

## Reporting of discards

Every reported distribution MUST be accompanied by the count of measurements discarded.
A run that discards a large fraction of its measurements is not comparable with one that
discards none, irrespective of the percentiles of the survivors.

# Reporting {#reporting}

## Required fields

A reported MRL figure MUST be accompanied by:

* Ingress MRL and Playout MRL, both signed;
* the playout target depth;
* the onset variant used for the headline figure, and the spread across all three
  variants;
* the codec and frame period;
* the number of measurements attempted and the number discarded;
* any advisory flags raised;
* the calibrated accuracy of the measuring implementation and the conditions of that
  calibration;
* an identifier for the SUT configuration sufficient to establish that two figures refer
  to the same configuration, without necessarily disclosing that configuration.

## Reporting format {#format}

A reported result MUST be expressible as a JSON object {{RFC8259}} carrying the members
defined below. The format exists so that a reader can establish, without contacting the
party who produced a figure, whether two figures were derived under the same choices.

The `schema` member MUST be present and MUST be the string `mrl-report/1` for reports
conforming to this document.

### instrument

Describes the measuring implementation and its calibration. All members are REQUIRED.

`name`, `version`:
: Identify the implementation that produced the report.

`calibration`:
: An object recording the outcome of the procedure in {{errors}}. It MUST carry
  `conditions`, a human-readable statement of the channel and host conditions under which
  calibration was performed, and for each of `ingress` and `playout` a `bias_ms` and a
  `p95_abs_error_ms`. It SHOULD carry `reference`, a URI or DOI at which the calibration
  evidence can be inspected. An implementation that has not been calibrated MUST set
  `calibration` to `null` rather than omitting it, and every figure in such a report is
  an upper bound rather than a point estimate.

### measurement

Describes the choices along the axes in {{existing}}. All members are REQUIRED.

`reference_point`:
: Where t1 was observed. The value `rtp-endpoint` denotes the reference point defined in
  {{refpoint}}. Any other value denotes an observation point that includes additional and
  possibly uncharacterised transport, and MUST be accompanied by `reference_point_notes`
  describing what lies inside the interval.

`codec`, `frame_period_ms`, `sample_rate_hz`:
: The media parameters in force.

`playout_target_ms`:
: The de-jitter buffer target depth used to derive Playout MRL.

`onset_variants`:
: An array of objects, each carrying `name`, `margin_db`, `absolute_dbov` and
  `sustain_ms`. The parameters MUST be stated rather than referenced by name alone, so
  that a report remains interpretable if the defaults in {{onset}} are ever revised.

`headline_variant`:
: The `name` of the variant whose figures are quoted as the headline.

`continuity_window_ms`, `continuity_gap_threshold_ms`:
: The parameters of {{whatcounts}}, stated rather than assumed so that a report remains
  interpretable if the defaults are ever revised.

### subject

Identifies what was measured. `stimulus_id` and `stimulus_sha256` are REQUIRED.
`sut_identifier` is REQUIRED and `sut_config_sha256` is RECOMMENDED, the latter allowing
two reports to be shown to concern the same configuration without that configuration
being disclosed.

### results

Aggregate figures. All members are REQUIRED.

`n_attempted`, `n_reported`, `n_discarded`:
: Counts of measurements. `n_attempted` MUST equal `n_reported` plus `n_discarded`.

`discard_reasons`:
: An object mapping each blocking condition in {{qc}} to the number of measurements it
  discarded. The counts MUST sum to `n_discarded`.

`ingress`, `playout`:
: Objects carrying at least `mean_ms`, `p50_ms`, `p95_ms` and `max_ms`, computed over the
  reported measurements under the headline variant. Values are signed.

`onset_definition_uncertainty_ms`:
: The spread of MRL across all variants in `onset_variants`, carrying at least `p50` and
  `max`. This member MUST be present, since a headline figure quoted without it is
  incomplete under {{onset}}.

`continuity`:
: An object carrying `gap_p50_ms` and `gap_max_ms` over the reported measurements,
  `n_discontiguous`, and a `contiguous` object of the same shape as `ingress` giving the
  MRL to the start of uninterrupted speech. Where `n_discontiguous` is zero the
  `contiguous` figures equal the `ingress` figures, which is the expected case and is
  reported rather than omitted so that its absence never has to be inferred.

`advisory_flags`:
: An object mapping each advisory condition in {{qc}} to the number of reported
  measurements carrying it.

### measurements and captures

`measurements` SHOULD carry one object per individual measurement, each with the
measurement's identifier, its t0 and t1 in nanoseconds on the instrument's monotonic
clock, its ingress and playout MRL under every variant, the continuity gap and contiguous
onset from {{whatcounts}}, the end of any unprompted audio as required by {{greeting}},
and any flags raised. `captures`
SHOULD carry one object per capture with the measurement identifier, a `sha256` of the
capture file, and a URI at which it can be obtained.

Both members are optional because a party may be unable to publish raw material.
Omitting them removes the reader's ability to re-derive the figures under a different
onset definition, which {{onset}} identifies as the dominant uncertainty term, so a
report omitting them is weaker evidence than one that includes them.

### Example

The following is a report with the per-measurement and capture arrays elided.

~~~ json
{
  "schema": "mrl-report/1",
  "instrument": {
    "name": "voice-ai-latency-harness",
    "version": "0.1.1",
    "calibration": {
      "conditions": "clean channel, 20 ms grid, PCMU",
      "ingress": { "bias_ms": -0.40, "p95_abs_error_ms": 2.38 },
      "playout": { "bias_ms": -0.40, "p95_abs_error_ms": 2.38 },
      "reference": "https://doi.org/10.5281/zenodo.22124823"
    }
  },
  "measurement": {
    "reference_point": "rtp-endpoint",
    "codec": "PCMU",
    "frame_period_ms": 20.0,
    "sample_rate_hz": 8000,
    "playout_target_ms": 40.0,
    "onset_variants": [
      { "name": "sensitive", "margin_db": 6.0,
        "absolute_dbov": -55.0, "sustain_ms": 10.0 },
      { "name": "headline", "margin_db": 10.0,
        "absolute_dbov": -50.0, "sustain_ms": 20.0 },
      { "name": "strict", "margin_db": 12.0,
        "absolute_dbov": -45.0, "sustain_ms": 30.0 }
    ],
    "headline_variant": "headline",
    "continuity_window_ms": 2000.0,
    "continuity_gap_threshold_ms": 150.0
  },
  "subject": {
    "sut_identifier": "system-A",
    "sut_config_sha256": "9f2b...c41e",
    "stimulus_id": "eval-set-1/utt-017",
    "stimulus_sha256": "3ad1...77b0"
  },
  "results": {
    "n_attempted": 20,
    "n_reported": 18,
    "n_discarded": 2,
    "discard_reasons": {
      "onset_not_found": 1, "tx_pacing_deviation": 1
    },
    "ingress": {
      "mean_ms": 812.4, "p50_ms": 796.0,
      "p95_ms": 1043.2, "max_ms": 1101.7
    },
    "playout": {
      "mean_ms": 852.4, "p50_ms": 836.0,
      "p95_ms": 1083.2, "max_ms": 1141.7
    },
    "onset_definition_uncertainty_ms": { "p50": 4.7, "max": 9.8 },
    "continuity": {
      "gap_p50_ms": 48.0,
      "gap_max_ms": 512.0,
      "n_discontiguous": 4,
      "contiguous": {
        "mean_ms": 941.7, "p50_ms": 802.0,
        "p95_ms": 1418.6, "max_ms": 1461.0
      }
    },
    "advisory_flags": {
      "high_loss": 1,
      "high_late_discard": 0,
      "discontiguous_response": 4
    }
  }
}
~~~

> \[\[EDITOR'S NOTE: this structure is deliberately close to what the reference
> implementation already emits, which keeps at least one producer honest, and it is the
> part of the document most likely to change on review. Two questions in particular.
> Whether the format should be registered as a media type. And whether `reference_point`
> should be an enumeration with values for carrier-side and bridge-side recording, so
> that efforts observing elsewhere can produce conforming reports that declare the
> difference, rather than being unable to conform at all. The second would widen adoption
> considerably and is probably worth doing.\]\]

# Use and Applications

The metric supports:

* comparison of conversational voice systems from the position of a caller;
* characterisation of a single system across configurations or load levels;
* regression testing of a deployed system over time.

MRL measures an interval and carries no information about what the response contained.
Response quality, recognition accuracy and the usefulness of the reply are separate
quantities needing separate instruments, and a system that answers quickly and wrongly
will score well here. Cases in which the metric does not apply, or applies only with
care, are set out in {{limits}}.

# Applicability and Limitations {#limits}

The metric as defined applies to systems that respond to a completed caller utterance
with a discrete response. The following cases are outside its current scope or require
care:

Filler and non-lexical audio:
: Addressed by the continuity measurement in {{whatcounts}}, which separates first audio
  from first uninterrupted audio without interpreting content. A caller comparing systems
  should read both figures, since MRL alone rewards a system for making a noise.

Unprompted audio:
: Handled by {{greeting}}, which requires detection to begin after any greeting. Without
  that constraint the measurement locates the greeting, and the figure it produces
  describes a different event.

Barge-in:
: Where the caller interrupts the system, the interval defined here is not the quantity
  of interest and the method does not address it.

Incremental and streaming responses:
: Where a system emits partial audio that it subsequently revises, first-audio onset does
  not characterise the response.

Path contribution:
: As noted in the measurement domain, the figure is a property of the pairing of path and
  SUT.

Conditioning across turns:
: See the open item under Measurement Timing.

# Security Considerations

The method described here generates traffic directed at a system under test and elicits
responses from it. Measurement of a system operated by another party without that party's
authorisation may constitute unauthorised use, may breach terms of service, and at
sufficient volume is indistinguishable from a denial of service attempt. Parties
performing measurement:

* SHOULD obtain authorisation from the operator of the system under test;
* SHOULD limit the measurement rate to a level agreed with that operator;
* SHOULD identify their measurement traffic where a mechanism to do so exists.

Captures produced by this method contain audio. Where stimulus material contains recorded
human speech, that material is personal data in many jurisdictions and may carry
biometric significance, and captures also hold the SUT's response audio, which can
reflect the content of the stimulus. Implementers:

* SHOULD prefer synthetic or consented stimulus material;
* SHOULD apply access control to stored captures;
* SHOULD set a retention limit rather than keeping captures indefinitely.

Publication of captures as measurement evidence, which the method otherwise encourages,
has to be weighed against these considerations.

Reported figures may be commercially sensitive to the operator of the system under test.
The configuration identifier described in {{reporting}} is specified as an identifier
rather than as the configuration itself so that reproducibility and confidentiality can
coexist.

# IANA Considerations

> \[\[TODO: if registry entry is pursued, this section requests registration of the
> entry in {{registry}} in the Performance Metrics Registry established by {{RFC8911}}.
> If not, this section reads "This document has no IANA actions."\]\]

# Future Work {#future}

Conveying MRL between endpoints in band, by means of an RTCP Extended Report block in the
manner of {{RFC3611}}, would allow a system to report the metric about itself rather than
requiring an external caller to measure it. That is a separate document and a different
working group.

Time to greeting, the interval from session establishment to the onset of the unprompted
audio described in {{greeting}}, is a second quantity the method already observes without
defining. It is at least as visible to a caller as MRL, and it appears to be published by
nobody. Defining it here would widen this document beyond a single metric, so it is noted
rather than specified, and it would sit naturally in whatever document this one becomes
part of.

--- back

# Draft Performance Metrics Registry Entry {#registry}

> \[\[EDITOR'S NOTE: filled in against the column structure defined in Section 7 of
> {{RFC8911}}, using the blank template in Section 11 of that document, as far as the
> current text supports. Incomplete deliberately; the gaps are the same gaps flagged in
> the body. Note that Section 7.1.2 imposes a structured naming convention on registered
> metrics, which the Name entry below has yet to satisfy.\]\]

Identifier:
: TBD by IANA

Name:
: TBD, following the naming convention of Section 7.1.2 of {{RFC8911}}

URI:
: TBD

Description:
: The interval between transmission of the final speech sample of a caller's utterance
  and arrival of the first sample of a conversational voice system's response, observed
  at the calling endpoint's RTP reference point.

Change Controller:
: IETF

Version:
: 1

Reference Definition:
: This document, {{t0}} through {{onset}}.

Fixed Parameters:
: Onset variant thresholds as tabulated in {{onset}}; de-jitter anchor rule as specified
  in {{playout}}.

Reference Method:
: This document, Method of Measurement.

Packet Stream Generation:
: Prerecorded stimulus transmitted at the nominal frame rate of the codec in use.

Traffic Filter:
: The RTP stream of the session under measurement.

Sampling Distribution:
: TBD; see the open item under Measurement Timing.

Runtime Parameters:
: Codec, frame period, playout target depth, stimulus identifier and hash, SUT
  configuration identifier.

Roles:
: Calling endpoint; system under test.

Output Type:
: Signed scalar, reported in two variants, with an uncertainty term.

Metric Units:
: Milliseconds.

Calibration:
: As specified in {{errors}}. An implementation reports its own calibrated accuracy and
  the conditions of calibration.

# Reference Implementation

An open-source implementation of this method exists and is archived at {{HARNESS}}. It
implements the metric definition, the onset variants, the quality control conditions and
the calibration procedure described here, and it publishes per-host calibration results.

This appendix is informative. Conformance is to this document, and any disagreement
between this document and that implementation is a defect in the implementation.

# RFC 6390 Template Coverage {#coverage}

> \[\[EDITOR'S NOTE: remove before submission. Retained here so that gaps are visible
> while the draft is being written.\]\]

| RFC 6390 Section 5.4 item | Class | Where | State |
|---|---|---|---|
| Metric Name | normative | Metric Definition | done |
| Metric Description | normative | Metric Definition | done |
| Method of Measurement or Calculation | normative | Method of Measurement | mostly done; annotator conformance open |
| Units of Measurement | normative | Units of Measurement | done |
| Measurement Point(s) with Potential Measurement Domain | normative | Measurement Points | done |
| Measurement Timing | normative | Measurement Timing | open; multi-turn conditioning unspecified |
| Implementation | informative | Appendix, Reference Implementation | done |
| Verification | informative | Sources of Error and Calibration | done |
| Use and Applications | informative | Use and Applications | done |
| Reporting Model | informative | Reporting | done; media type registration open |

# Open Questions for Review {#questions}

> \[\[EDITOR'S NOTE: remove before submission.\]\]

1. Filler and non-lexical audio is now specified in {{whatcounts}} by a structural
   discriminator rather than by content recognition, and implemented. What remains open is
   whether 150 ms and 2000 ms are the right constants. They were chosen to sit well above
   the pauses inside ordinary speech, measured at around 50 ms on the reference
   implementation's material, and no corpus of real filler behaviour informed them yet.
   Evidence welcome.
2. Whether the stimulus annotation algorithm is specified normatively, replaced by a
   conformance test against a published reference signal, or left to the implementer with
   a publication requirement.
3. Whether multi-turn measurement within one session is in scope, and what has to be
   reported about warm-up effects.
4. The interchange record in {{format}}. Whether it warrants a registered media type,
   and whether `reference_point` should enumerate observation points other than the RTP
   endpoint so that efforts measuring from a carrier recording can produce conforming
   reports which declare that difference.
5. Whether Informational is the right category, or whether the conformance language
   argues for Standards Track.
6. Venue. Whether IPPM's charter admits a metric of this kind, and if not whether
   DISPATCH or the Independent Submission stream is the better route. See the editor's
   note in the Introduction.
7. Whether registry registration is appropriate for an application-layer metric of this
   kind.
8. British spelling is used throughout this source. Confirm against current RFC Editor
   style before submission and convert if required.

# Acknowledgements
{:numbered="false"}

TBD.
