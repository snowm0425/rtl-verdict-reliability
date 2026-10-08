# rtl-verdict-reliability

Evaluation artifacts for *Beyond Mutation Coverage: Auditing Verdict
Reliability in RTL Generation Benchmarks* (NeurIPS 2026 Workshop on
AI for Chip Design).

## Environment
- Icarus Verilog 12.0 (v12_0), flag `-g2012`
- RTLLM v2.0 @ 41b26896e33b536940116a975626455eed3de65e
- Models: Qwen2.5-Coder-32B-Instruct-AWQ (K=10), Qwen3.8-27B BF16, thinking disabled (K=5)
- Sampling: temperature 0.8, top-p 0.95, no top-k, no repetition penalty, 16384 output tokens

## Contents
- `harness/` — differential oracle, wrapper generator, analysis scripts
- `catalog.yaml` — per-design port, clock/reset and parameter metadata
- `results/generated/` — 690 generated RTL candidates
- `results/mutants/` — 775 regenerated mutants (ids match the published audit)
- `results/dual_verdicts.csv` — per-sample official vs differential verdicts
- `results/oracle_strength.csv` — per-mutant verdicts under both oracles
- `results/self_consistency.csv`, `results/seed_stability.csv`
- `results/adjudication_index.csv`, `results/adjudication.txt` — the 14 adjudicated cases
- `results/case_square_wave.txt` — the false-pass case study (Figure 1)
- `results/baseline_stdout/` — official testbench output for the baseline run
- `tool_versions.txt` — run log with versions, commits and headline numbers

Simulation logs under `results/` contain absolute paths from the machine on
which they were produced; they are kept verbatim as execution records.

## Reproducing
RTLLM and the GateTruth audit are not vendored. Clone them at the pinned
commits and place them at `RTLLM/` and `GateTruth/` under this directory
(or adjust `harness/config.py`), then:

    python3 -m harness.run_diff
    python3 -m harness.final_stats

## License
MIT (see LICENSE). RTLLM, the GateTruth audit and both models remain under
their own licenses.
