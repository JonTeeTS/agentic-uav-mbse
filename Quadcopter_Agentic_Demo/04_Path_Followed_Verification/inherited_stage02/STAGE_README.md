# Stage 02: Executable Quadcopter Model

Created from a complete local copy of stage 01 on 2026-11-16 using MATLAB R2026b Update 1. The authoritative baseline remains `Quadcopter_MVP_Requirements_v1.md`. All 18 requirements and the existing 40 architecture links are retained in the stage-local `Quadcopter_MVP_AI.slreqx` and `QuadArchitecture_AI~mdl.slmx`.

**Actual status: the integrated model compiles and the final smoke simulation runs.** The final run stopped through the landed-mode stop block at **28.160 simulated seconds**, with **zero simulation warnings** and finite logged vehicle state. Observed flight modes were `[0 1 2 3 4 5 6]`. This is execution smoke evidence; no visual verification or requirements-test verdict is established.

Stage 01 remains unchanged: all 11 original file hashes and the file count matched the snapshot taken before stage-02 work. No stage-01 file is a working dependency of this model. The models, dictionary, MATLAB algorithms, requirements, and all 40 link endpoints were checked to resolve within this stage.

## Open and run

Required products are Simulink, System Composer, UAV Toolbox, and Stateflow. Requirements Toolbox is needed to open the requirements and traceability. No Aerospace Blockset component, external autopilot, or hardware connection is used.

Close any other-stage model with the same name before opening this copy. The initialization helper detects such a conflict and stops without saving or closing the other copy.

```matlab
cd('C:\Demos\agentic-uav-mbse\Quadcopter_Agentic_Demo\02_Executable_Model')
init_stage02
arch = systemcomposer.openModel('QuadArchitecture_AI.slx');
reqs = slreq.open('Quadcopter_MVP_AI.slreqx');
[out, status] = run_stage02_smoke;
```

Alternatively, after opening the architecture, click **Run**. Its initialization callback invokes `init_stage02`. `run_stage02_smoke` explicitly updates the diagram, uses `Simulink.SimulationInput`, records the execution observations, and saves `smoke_result.mat` and `smoke_status.json`. Clicking Run alone does not regenerate those two report files.

The model has a 90-second maximum stop time and normally stops earlier when GCS receives the landed mode. The smoke helper returns the complete `Simulink.SimulationOutput` object as `out`. Initialization resolves this stage's local dictionary and redirects all cache and generated simulation-target files into `cache/` and `codegen/` below this folder. There is no MATLAB Project file or dependency on a project startup path.

## Implemented behavior

| Component | Implementation |
|---|---|
| GroundControlStation | Predefined takeoff and exactly three waypoint targets; position-feedback mission sequencing; one-second settling/hover dwell; mission commands; position and mode telemetry handling; stop after landed telemetry. |
| ModeLogic | Ground, takeoff, waypoint 1, waypoint 2, waypoint 3, landing, and landed mode selection. Landing proximity and speed gates use actual simulated state. |
| Guidance | Mode-based position reference, three waypoint selections, NED position-error calculation, and a rate-limited descent reference over the final waypoint. |
| FeedbackControl | Discrete position PID with measured-velocity derivative, bounded conditional integral action, acceleration/tilt/thrust limits, and mapping to Roll, Pitch, YawRate, and Thrust. |
| VehicleModel | Supported UAV Toolbox **Guidance Model** block, configured as MultirotorGuidance with reduced-order inner attitude and thrust loops. State adapter exposes position, velocity, body angular rates, and orientation quaternion. |
| Visualization | Executable state and waypoint logging sink. Receives the state needed for a later animation. No 3D animation is implemented or visually assessed in this stage. |

The top-level hierarchy remains GroundControlStation, AirVehicle, and Visualization; AirVehicle contains FCS and VehicleModel; FCS contains ModeLogic, Guidance, and FeedbackControl. Six local Simulink behavior models are attached to the leaf components. No excluded payload, avoidance, endurance, fault-management, or hardware-deployment function was added.

The implementation follows the [MathWorks quadcopter architecture workflow](https://www.mathworks.com/help/systemcomposer/ug/develop-verify-quadcopter-system-architecture.html): architecture components linked to Simulink behaviors, position-error feedback, PID-based control, and a supported reduced-order multirotor plant. The plant is documented in [Guidance Model](https://www.mathworks.com/help/uav/ref/guidancemodel.html). The example's larger mission, endurance model, and multiple verification checks were not imported.

## Mission, coordinates, and timing

All values are demonstration design choices in `quad_mvp_parameters.m`; they do not add requirements or define an approved formal-test tolerance.

| Item | Value |
|---|---|
| World frame | North-East-Down (NED), meters; Z is positive down; altitude is negative Z. |
| Initial position | `[0; 0; 0]` m. |
| Autonomous start | 1 second. |
| Takeoff target | `[0; 0; -2]` m. |
| Three waypoint rows | `[2 0 -2; 2 2 -2; 0 2 -2]` m. |
| Landing location | North/East of waypoint 3; Down reference ramps toward 0 at at most 0.25 m/s. |
| Sequencer arrival gates | Distance below 0.12 m and sampled position-derived speed below 0.15 m/s, continuously for 1 second before advancing. These are implementation settings, not Path Followed acceptance criteria. |
| Optional hover | The same one-second settling/hover dwell is enabled after takeoff and at each waypoint; no visual hover claim is made. FR-05 remains Optional. |
| Mode encoding | 0 Ground, 1 Takeoff, 2 Waypoint1, 3 Waypoint2, 4 Waypoint3, 5 Landing, 6 Landed. |
| Controller and sequencer period | 0.02 seconds (50 Hz). |
| Numerical solver | Fixed-step `ode4`, step 0.005 seconds. |
| Explicit delays | One controller sample (20 ms) for actuator commands; one sample for GCS position and flight-mode processing. Telemetry logs record the received signals before those GCS processing delays. |
| Plant mass / gravity | 1 kg / 9.81 m/s². |
| Control units | Roll/Pitch radians; YawRate radians/second; Thrust newtons. YawRate is zero and initial yaw is zero. |
| Orientation | Scalar-first Hamilton quaternion `[w; x; y; z]`, active body-to-NED rotation, converted from the plant's ZYX yaw-pitch-roll angles. |
| Body axes | X forward, Y right, Z down; body angular rates in radians/second. |

`PositionReference_IF` was extended locally with a 3-by-1 `PositionErrorNED` element, alongside its original `PositionNED` reference. This carries Guidance's computed error without adding architectural ports. The unchanged `VehicleState_IF` and `Position_IF` position values are generated from the same plant `WorldPosition` signal.

The low-fidelity plant has no ground-contact mechanics. Ground mode uses level weight-balancing thrust to hold its initial state. Landing completion is an idealized proximity event: Down position at least -0.025 m and speed below 0.12 m/s while commanded to land. Simulation stops immediately after that event is telemetered. It does not model physical touchdown, rotor shutdown, or post-landing contact dynamics. The numerical landing gates are demonstration logic, not an approved verification tolerance.

## Actual smoke observations

The final run recorded these mode transition times:

| Time (s) | Mode |
|---|---|
| 0.00 | Ground |
| 1.00 | Takeoff |
| 5.00 | Waypoint1 |
| 9.46 | Waypoint2 |
| 13.92 | Waypoint3 |
| 18.72 | Landing |
| 28.14 | Landed |

The stop block ended simulation at 28.16 seconds. Final NED position was approximately `[-0.0428043, 2.05186, -0.0216500]` m, and final NED velocity approximately `[0.00233599, -0.00284433, 0.110482]` m/s. These are observed values, not requirement pass/fail judgments.

The saved output contains:

| Output | Contents |
|---|---|
| `out.telemetryPosition.PositionNED` | Position received by GCS. |
| `out.telemetryFlightMode.Mode` | Flight mode received by GCS. |
| `out.missionCommand.Command` | Mission phase commanded by GCS. |
| `out.guidanceReference` | Reference position and computed position error. |
| `out.controlOutputs` | Roll, Pitch, YawRate, and Thrust commands. |
| `out.visualizationState` | Position, velocity, orientation quaternion, and body angular rates. |
| `out.visualizationWaypoints.PositionNED` | The three waypoint targets delivered to Visualization. |

Bus outputs are structures of timeseries. For a column-vector signal, its data can have shape 3-by-1-by-N rather than N-by-3. `run_stage02_smoke` normalizes this before extracting the reported final state. No trajectory plots or animation evidence were produced.

## Validation and traceability status

- The integrated architecture successfully completed diagram update/compilation. The previous stage's architecture-only no-behavior limitation is resolved in this copy.
- The final smoke run completed with no simulation warnings and finite state data.
- `model_check` reports healthy for the top-level architecture and all six behavior models: no disconnected ports or dangling lines were reported.
- All working model files, the shared dictionary, algorithm helpers, initialization/run helpers, and all 40 architecture-link endpoints resolve within this stage. No stage-01 working reference is used.
- All 18 IDs and rendered requirement statements were checked against the copied authoritative Markdown. Priorities and the FR-06-only formal-target designation remain as imported; FR-05 remains Optional.
- The existing 33 Implement links are architectural responsibility allocations, and the 7 Relate links retain optional/planning associations. The architecture now references executable behaviors, but these links do not themselves establish requirement satisfaction. Their original stage-01 design-intent notes remain provenance.
- There are zero Verify links. No Path Followed test, approved tracking tolerance, formal requirement result, or visual-verification result has been created.

Connection/execution issues corrected during integration included the supported plant's nonvirtual control-bus requirement, MATLAB code-generation structure initialization, and referenced-model execution loops. The final model includes explicit sampling delays and loop-minimization settings rather than suppressing compile diagnostics.

## Files and supporting folders

| Files | Purpose |
|---|---|
| `QuadArchitecture_AI.slx` | Saved integrated executable System Composer model; top-level entry point. |
| `GCS_MVP_AI.slx`, `ModeLogic_MVP_AI.slx`, `Guidance_MVP_AI.slx`, `FeedbackControl_MVP_AI.slx`, `VehicleModel_MVP_AI.slx`, `Visualization_MVP_AI.slx` | Stage-local leaf behaviors. |
| `QuadInterfaces_AI.sldd` | Shared interfaces, plant bus definitions, and the `MVP` parameter structure. |
| `Quadcopter_MVP_AI.slreqx`, `QuadArchitecture_AI~mdl.slmx`, `Quadcopter_MVP_Requirements_v1.md` | Copied requirements, architecture links, and unchanged Markdown baseline. |
| `quad_mvp_parameters.m` | Central design parameters. Initialization synchronizes them into the dictionary; compiled algorithms use the same helper. |
| `stage02_gcs.m`, `stage02_mode_logic.m`, `stage02_guidance.m`, `stage02_feedback_control.m`, `stage02_state_adapter.m` | Local algorithm source called by the behavior models' MATLAB Function blocks. |
| `init_stage02.m`, `run_stage02_smoke.m` | Initialization, local-file safeguards, and repeatable compile/smoke-run entry points. |
| `smoke_result.mat`, `smoke_status.json` | Final raw simulation output and execution observations. |
| `structural_checks.json`, `dependency_audit.json`, `validation_report.json` | Actual structural checks, resolved working-file paths/link endpoints, and stage-02 status summary. |
| `stage01_original_hashes.json`, `stage01_integrity.json` | Read-only integrity evidence for stage 01. These are provenance records, not working dependencies. |
| `CHECKPOINT_SHA256.txt` | Hash inventory for the stage-02 deliverables, excluding transient cache/build output and the inventory itself. |
| `inherited_stage01/` | Preserved copies of the stage-01 README, validation report, and original hash inventory. Historical only; their architecture-only status does not describe this executable stage. |
| `walkthrough/` | The three copied stage-01 architecture images. Historical hierarchy views; they are not stage-02 simulation or visual-verification evidence. |
| `cache/`, `codegen/` | Local generated simulation-target/cache output; regenerable. |

Keep this stage's models, dictionary, requirements/link set, and MATLAB sources together. Future work should use another sibling stage so that stage 01 remains an independently openable architecture-only snapshot and this executable stage retains its smoke evidence.

## Remaining work

Create the opaque 3D multirotor animation, waypoint markers, and trajectory display in a later stage; assess coordinate consistency visually there. Separately agree the numerical tracking tolerance and calculation method before creating and executing the **Path Followed** test for **UAV-MVP-FR-06 only**. No additional mandatory requirement or formal test target was introduced here.
