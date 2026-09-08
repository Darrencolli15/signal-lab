# Signal Lab
An audio DSP project scaffold prepared for Darren Lu with AI assistance.

## Run the web workbench
Run `python3 -m http.server 8000`, then open localhost:8000.
No web dependencies or backend. Audio files are decoded locally, averaged to mono,
and limited to the first 15 seconds. Built-in signals are four seconds.
The sample rate follows the browser decoder for uploaded audio.

## Implemented
- Hamming-window low-pass, high-pass and band-pass FIR design (31/63/127 taps).
- Floating-point causal convolution and signed Q1.15 comparison.
- Filter response, 2048-point Hann-window spectrum, waveform.
- Original/filtered/fixed-point playback and 16-bit mono WAV export.
- Python reference and parallel SystemVerilog FIR core with vector testbench.

## Reproduce reference checks
`cd engineering`
`python3 reference.py`
Tests cover coefficient symmetry, unity DC gain, passband/stopband,
zero input, signed arithmetic and positive/negative saturation.
Reference vectors include impulse, multitone and deterministic random input.

## RTL simulation (pending execution)
With Icarus Verilog installed, from engineering:
```
iverilog -g2012 -s tb_fir -o sim fir.sv tb_fir.sv
vvp sim
```
The testbench compares 1125 expected samples, input-valid gaps and reset.
The simulator was unavailable during creation; no RTL pass is claimed.
The default core is a 63-tap 1.8 kHz low-pass at 48 kHz. Browser parameter
changes do not configure the RTL. Regenerate matching coefficients and
vectors before changing RTL parameters. Synthesis support for coefficient
initialization depends on the selected FPGA toolchain.

## Arithmetic and timing
Samples and coefficients use signed Q1.15; input conversion is
floor(x*32768+0.5) with saturation. The accumulator is shifted right by 15
(arithmetic floor) then saturated to [-32768,32767]. Browser integer sums
are exact within the JavaScript safe integer range for supported tap counts.
The 48-bit RTL accumulator covers the default 63-tap sum. Browser floating
output is stored as Float32; comparisons measure pre-storage FIR output
against the fixed-point result. WAV export clips values outside int16 range.

Group delay is (taps-1)/(2*sample rate). This excludes audio buffering,
codec and interface latency. Spectrum plots use only the first 2048
samples, including startup transient; they are illustrative, not complete
steady-state spectral measurements. The RTL computes a full combinational
multiply-accumulate per accepted sample and registers the result; pipelining,
resource sharing and timing closure remain hardware tasks.

## Hardware work remaining
Select board and audio codec; add I2S/ADC/DAC interfaces; run RTL simulation,
synthesis and timing analysis; implement clock/reset crossings; validate
against loopback recordings and publish measured latency/resources/SNR.
No FPGA run, timing closure, utilization or physical measurements are claimed.
Frequency filters cannot separate vocals, drums or instruments into stems.

## Ownership and use
This is a starting implementation, not evidence of completed independent
research. Review the math and RTL, reproduce tests, make your own design
choices and document results before presenting the work on a resume.
GitHub profile: https://github.com/Darrencolli15

## GitHub Pages
Upload these extracted files directly to the root of a public repository named signal-lab. In Settings > Pages, choose Deploy from a branch, main, /(root), then Save. The intended URL is https://Darrencolli15.github.io/signal-lab/ after successful publication.
