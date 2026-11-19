# Stage 04: Path Followed Verification

**Result: PASS for UAV-MVP-FR-06 under the user-approved PF-CRITERIA-v1 criterion.** This is the MVP's only formal verification target. One fresh Simulink Test case named **Path Followed** executed successfully: **1 passed, 0 failed, 0 incomplete**. Its three custom-criteria checks all passed.

The numerical limit and calculation were proposed in `PATH_FOLLOWED_CRITERIA.md`. The user explicitly selected **“Approve PF-CRITERIA-v1”** before the test ran. Approval is recorded in `criteria_approval.json` and the approved settings in `path_followed_criteria.json`. No assumed limit, prior demonstration result, controller retuning, or forced passing result was substituted.

This stage is a complete local copy of stage 03 with a local test definition, result archive, assessment source, and evidence. All 45 requirement-link endpoints and runtime dependencies resolve inside stage 04. Stages 01–03 remain unchanged.

The [MathWorks quadcopter example](https://www.mathworks.com/help/systemcomposer/ug/develop-verify-quadcopter-system-architecture.html) informed the requirement–model–test workflow. Assessment uses supported [Simulink Test custom criteria](https://www.mathworks.com/help/sltest/ug/process-test-results-with-custom-scripts.html) against the fresh simulation output. The 0.20 m limit is the locally proposed and user-approved criterion, not a numerical limit supplied by that example or the requirements baseline.

## What was verified

The test assesses the sampled **3D geometric cruise path** during flight modes 2, 3, and 4. The fixed intended NED vertices in meters are:

```text
Cruise entry: [0, 0, -2]
WP1:          [2, 0, -2]
WP2:          [2, 2, -2]
WP3:          [0, 2, -2]
```

Each position is compared with its **active finite segment**, selected by the logged flight mode. The error is Euclidean distance to the clamped orthogonal projection onto that segment. This includes altitude error and excursions past segment endpoints. It does not use the nearest arbitrary segment or distance to the next waypoint while traveling toward it.

The approved criteria require:

- Every assessed sample to be within **0.20 m**, inclusive, of the active segment, with no ignored transient/grace period and no permitted corridor violations.
- All three waypoint endpoints to be reached within **0.20 m**, in order during their assigned legs.
- Waypoint-path completion within the **90-second** maximum simulation duration.

Actual GCS-received NED position and mode logs were used. They contained matching timestamps at a measured median period of **0.02 s**. Position data were not smoothed, decimated, shifted, or interpolated. RMS error is reported as descriptive evidence, not as a separate acceptance limit.

Takeoff, landing approach, and landed modes are excluded from this approved criterion. The complete autonomous simulation still ran to its ordinary landing-proximity stop.

## Actual measured results

| Measurement | Actual result |
|---|---:|
| Native Simulink Test outcome | Passed |
| Requirements Toolbox FR-06 summary after refresh | 1 passed verification item |
| Assessed position samples | 686 |
| Total recorded position samples | 1,409 |
| Maximum 3D path error | **0.114152567 m** |
| Overall RMS 3D path error | **0.095863290 m** |
| Approved corridor / waypoint limit | 0.20 m / 0.20 m |
| First within-limit WP1 arrival | 7.80 s |
| First within-limit WP2 arrival | 12.34 s |
| First within-limit WP3 arrival / path completion | 17.08 s |
| Complete mission simulation end | 28.16 s |
| Simulation warnings | 0 |

| Leg | Assessed interval (s) | Samples | Maximum error (m) | RMS error (m) | Closest endpoint distance (m) |
|---|---|---:|---:|---:|---:|
| Cruise entry → WP1 | 5.00–9.44 | 223 | 0.088753061 | 0.077087261 | 0.068591220 |
| WP1 → WP2 | 9.46–13.90 | 223 | 0.111776338 | 0.105870766 | 0.105448570 |
| WP2 → WP3 | 13.92–18.70 | 240 | 0.114152567 | 0.101642653 | 0.097634985 |

The run occurred after approval on 2026-11-16. Native result timestamps are 10:47:46–10:52:29 local time (Asia/Kuala_Lumpur); wall-clock duration was approximately 282.43 seconds. The longer wall-clock duration includes model compilation, animation, custom criteria, plotting, and native result processing. It is distinct from simulated mission time.

No criterion breach, missing waypoint, or technical inconclusive condition occurred in this run. The results preserve the nonzero tracking deviations rather than replacing measured positions with reference positions. Parameters and all five inherited mission/controller/adapter source files remain byte-identical to stage 03.

## Open the saved result and links

Use MATLAB R2026b Update 1 with Simulink Test, Requirements Toolbox, System Composer, Simulink, Stateflow, and UAV Toolbox. Close another-stage model with the same name first; initialization detects a conflicting loaded model without saving or editing it.

```matlab
cd('C:\Demos\agentic-uav-mbse\Quadcopter_Agentic_Demo\04_Path_Followed_Verification')
init_stage04
sltest.testmanager.load('QuadcopterTests_AI.mldatx');
sltest.testmanager.importResults('PathFollowed_Results.mldatx');
sltest.testmanager.view
reqs = slreq.open('Quadcopter_MVP_AI.slreqx','UAV-MVP-FR-06');
updateVerificationStatus(reqs);
```

Test Manager's **Results and Artifacts** contains `Path Followed - FR-06 - PF-CRITERIA-v1`, with one passed case. The stored Custom Criteria result contains three passed qualifications and one MATLAB evidence figure. Requirements Editor is open on FR-06, with Implemented by links for **FCS**, **Guidance**, and **WaypointGuidance**, and a Verified by link to **Path Followed**. The supported verification-status refresh reports FR-06 passed; no status was manually assigned.

Brief walkthrough:

1. Show the single passed test and its FR-06-only description and approved criteria version.
2. Open the stored custom-criteria figure: actual versus intended path, error versus the 0.20 m limit, per-leg statistics, and ordered waypoint arrivals.
3. Follow the FR-06 requirement's architecture/implementation and test links; explain that this result applies only to the agreed sampled cruise-path criterion.

The exported PNG and FIG are also available directly in `verification_evidence/`. Importing the saved result reopens evidence without rerunning the model.

## Re-run the approved test

```matlab
init_stage04
[resultSet, metrics] = run_stage04_verification;
```

The helper loads exactly one local test case, checks the approved criterion/version and finite stop time, runs the case through Simulink Test, and exports the native results. It does not reuse copied stage-03 outputs. The custom criteria produce fresh metrics, raw run evidence, and figures. The initial evidence CSV and configuration/traceability reports are retained with this checkpoint; rerunning the test refreshes its native result, raw run MAT, metric JSON, and criterion figure files.

The test uses normal desktop simulation, a 90-second limit, and the inherited fixed-step `ode4` solver with a 0.005 s step. It has no parameter override or added hardware execution mode. Its custom criteria are the only pass/fail assessments. The current approved configuration can run without another approval request; changing the approved limits/path/scope requires a new criteria version and explicit agreement.

`init_stage04` resolves local files, uses the stage-local dictionary, and keeps generated simulation-target/cache files under `cache/` and `codegen/`. No MATLAB Project or working file in an earlier stage is required.

## Test and evidence files

| File | Purpose |
|---|---|
| `QuadcopterTests_AI.mldatx` | Persistent Simulink Test definition: one suite, one simulation case named Path Followed. |
| `PathFollowed_Results.mldatx` | Exported native result set from the fresh approved execution. |
| `PathFollowed_run.mat` | Actual `Simulink.SimulationOutput`, approved criteria, computed metrics, and per-sample assessment data. |
| `PathFollowed_metrics.json` | Actual overall/per-leg errors, endpoint distances, timing, sample counts, and criterion verdict. |
| `verification_evidence/PathFollowed_tracking_evidence.png` and `.fig` | Actual-versus-intended 3D path, error/time, per-leg errors, and waypoint-arrival plots. Inspected visually. |
| `verification_evidence/PathFollowed_samples.csv` | All 1,409 recorded position/mode samples. AssessedLeg=0 and NaN tracking error identify explicitly unassessed phases. |
| `PATH_FOLLOWED_CRITERIA.md`, `path_followed_criteria.json`, `criteria_approval.json` | Exact criterion, machine-readable approved settings, and explicit user approval record. |
| `stage04_path_metrics.m`, `stage04_custom_criteria.m`, `stage04_plot_evidence.m` | Actual-data calculation, native qualifications, and evidence plotting. |
| `stage04_require_approval.m`, `run_stage04_verification.m`, `init_stage04.m` | Approval/version checks, reproducible native test execution, and local initialization. |
| `FR06_traceability.json`, `requirement_verification_status.json` | FR-06's four incoming links and actual native verification-status summaries. |
| `verification_run_configuration.json`, `dependency_audit.json`, `validation_report.json` | Recorded settings, native outcome, local paths, and stage summary. |
| `earlier_stages_integrity.json`, `stage03_original_hashes.json` | Hash/file-count evidence that earlier stages were preserved. Provenance only. |
| `CHECKPOINT_SHA256.txt` | Deliverable inventory, excluding regenerable cache/build output and the inventory itself. |

The copied model, all six behavior models, `QuadInterfaces_AI.sldd`, `Quadcopter_MVP_AI.slreqx`, and the unchanged requirements Markdown remain local. `QuadArchitecture_AI~mdl.slmx` and `Visualization_MVP_AI~mdl.slmx` retain prior design links. `Guidance_MVP_AI~mdl.slmx` adds the FR-06 implementation link, and `QuadcopterTests_AI~mldatx.slmx` stores the sole formal Verify link.

`inherited_stage03/`, older inherited folders, `flight_evidence/`, and `walkthrough/` contain copied historical demonstration material. Those data were not used to determine the formal verdict. Their historical paths do not create runtime dependencies.

## Unverified areas and limits

Only **UAV-MVP-FR-06**, against PF-CRITERIA-v1 in the recorded nominal simulated conditions, is reported as formally verified. The other five functional requirements, all architecture and visualization requirements, and the verification-process requirements are not separate formal verification targets. VR-01 through VR-04 are supported here by the named test, explicit criterion approval, actual results, and traceability evidence.

This test does not establish takeoff/landing performance, hover performance as a separate requirement, intersample behavior, off-nominal robustness, environmental variation, hardware readiness, flight safety, or overall UAV compliance. The plant remains low fidelity, with an idealized landing-proximity stop rather than physical ground contact. No MIL/SIL/HIL workflow, autopilot, or hardware deployment was added.

Passing this one simulation test demonstrates only the agreed waypoint-following criterion under these simulated conditions. Preserve stages 01–04 and use a new sibling stage for later work.
