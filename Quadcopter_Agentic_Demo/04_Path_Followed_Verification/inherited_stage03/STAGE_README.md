# Stage 03: 3D Flight Simulation

This stage contains a complete local copy of stage 02 plus a working UAV Toolbox animation in the Visualization component. The authoritative baseline remains `Quadcopter_MVP_Requirements_v1.md`. The controller, three-waypoint mission, low-fidelity plant, and idealized landing logic are inherited from stage 02.

**Actual result:** the integrated model compiles and runs with native UAV Animation. The complete mission stopped at **28.160 simulated seconds**, with **zero simulation warnings**, finite logged state, and observed modes `[0 1 2 3 4 5 6]`. The animation and position/trajectory figures are open for review.

The live figure, takeoff preview, final 3D view, and position plots were inspected. They show an opaque red quadcopter with four rotor discs and connecting arms, three blue target waypoint squares, and the actual black flight trajectory. Body axes and displayed position are consistent with the documented coordinate conversion. This is a visual engineering demonstration of UAV-MVP-SV-02, SV-03, and SV-04; no formal requirements-test result is claimed.

## Reproduce the flight

Use MATLAB R2026b Update 1 with Simulink, System Composer, UAV Toolbox, and Stateflow. Requirements Toolbox is needed to inspect the requirements and links. Close any other-stage model with the same name first; the initializer detects a conflicting loaded copy without saving or modifying it.

```matlab
cd('C:\Demos\agentic-uav-mbse\Quadcopter_Agentic_Demo\03_3D_Flight_Simulation')
init_stage03
[out, report] = run_stage03_flight;
```

The script opens the local `QuadArchitecture_AI.slx`, updates/compiles it, runs the mission using `Simulink.SimulationInput`, frames the native animation, opens companion position/trajectory plots, and writes `flight_result.mat`, `flight_status.json`, and the figures in `flight_evidence/`.

To run directly from the model:

```matlab
init_stage03
systemcomposer.openModel('QuadArchitecture_AI.slx');
```

Click **Run**. The UAV Animation block automatically opens its output figure. To add the labelled review layout and companion plots after a direct run, call `stage03_review_figures(out)` with that run's simulation output. The top-level model's initialization callback is `init_stage03`; all generated cache and simulation-target files stay under this stage's `cache/` and `codegen/` directories.

To inspect the saved final views without rerunning:

```matlab
openfig(fullfile('flight_evidence','flight_3d_final.fig'));
openfig(fullfile('flight_evidence','mission_position_trajectory.fig'));
```

Saved FIG files are static final views. `run_stage03_flight` reproduces the moving flight.

## Visualization implementation

The copied `Visualization_MVP_AI.slx` retains the state/waypoint logging sinks and adds:

1. A Bus Selector for the simulated `PositionNED` and `OrientationQuaternion`.
2. Reshape blocks producing the required 1-by-3 translation and 1-by-4 quaternion inputs.
3. A waypoint selector and marker configuration producing exactly three blue square markers.
4. The supported `uavutilslib/UAV Animation` block, with its built-in Multirotor mesh. No external mesh file, point-only substitute, Unreal Engine scene, or photorealistic environment is used.

| Setting | Saved value |
|---|---|
| Number / mesh | One UAV, built-in Multirotor mesh |
| Mesh size / RGB color | `0.8` / `[0.9 0.05 0.04]` |
| Mesh and trajectory alpha | `1`, fully opaque |
| Position input convention | North-East-Down, meters; positive Down means negative altitude |
| Attitude input | Scalar-first Hamilton quaternion `[w x y z]`, active body-to-NED orientation |
| Inertial Z direction / rotation format | `Down` / `Quaternion` |
| Animation period | `0.05` seconds, 20 frames per simulated second |
| Trajectory buffer | 100,000 samples; the complete mission is retained |
| Markers | Three target rows, blue filled squares; positions come from the same waypoint bus used by Guidance |
| ENU plot bounds | East and North `[-0.8, 2.8]` m; Up `[-0.25, 2.8]` m |
| Review camera | Orthographic, azimuth 42°, elevation 25° |

The fixed bounds and orthographic projection keep the mesh at a consistent visible scale across the small mission area. The four red rotor discs and connecting arms remain distinguishable. The review script positions the animation and plots side by side on the demonstration's 2560-by-1440 display.

**Coordinate conversion:** R2026b UAV Animation accepts NED translations/rotations when configured with Z direction `Down`, and converts the displayed scene and markers to **East-North-Up**. The model supplies its native NED data directly; it does not apply another axis swap or Z negation before the block. Thus model `[North, East, Down]` appears at displayed `[East, North, Up] = [East, North, -Down]`. Yaw-zero body X points North, body Y East, and body Z Down. The visible body axes were checked against this convention. The logged quaternion norm differs from one by at most approximately `2.22e-16`; no quaternion rescaling or attitude substitution was used.

The [MathWorks quadcopter example](https://www.mathworks.com/help/systemcomposer/ug/develop-verify-quadcopter-system-architecture.html) informed the animation workflow. The [UAV Animation documentation](https://www.mathworks.com/help/uav/ref/uavanimation.html) specifies the mesh, marker, input-format, and R2026b display-coordinate behavior used here.

## Observed mission result and limitations

The actual telemetry recorded these mode transitions:

| Time (s) | Mode |
|---|---|
| 0.00 | Ground |
| 1.00 | Takeoff |
| 5.00 | Waypoint 1 |
| 9.46 | Waypoint 2 |
| 13.92 | Waypoint 3 |
| 18.72 | Landing |
| 28.14 | Landed |

GCS stopped the simulation at 28.16 seconds. The final telemetered NED position was approximately `[-0.0428043, 2.0518581, -0.0216500]` m. Peak altitude was about 2.0888 m for a 2 m cruise command. The unfiltered plots show the small altitude and corner overshoots; they are not hidden or replaced with the commanded path.

No mission abort, numerical failure, or missing mission mode was observed. The inherited landing implementation declares a proximity stop within 0.025 m of the ground plane and below 0.12 m/s speed, rather than modeling physical contact. The final position is about 2.2 cm above the ground plane. Physical touchdown, rotor shutdown, and contact dynamics remain outside this demonstration model; the animation does not move the drone onto the ground to conceal that limitation.

At the 20 Hz animation period, the last rendered/logged visualization sample is at 28.15 seconds, while final GCS position telemetry is at 28.16 seconds. `flight_status.json` records both separately. The final rendered center therefore corresponds to the last actual visualization sample, approximately `[-0.0428276, 2.0518866, -0.0227610]` m NED. There is no interpolation or fabricated endpoint in the saved view.

Optional one-second settling/hover dwells remain enabled. UAV-MVP-FR-05 stays Optional. The sequencer's arrival/proximity settings are implementation parameters, not an approved Path Followed verification tolerance.

## Files and evidence

| File or folder | Purpose |
|---|---|
| `QuadArchitecture_AI.slx` | Stage-local integrated executable architecture; initializes with `init_stage03`. |
| `Visualization_MVP_AI.slx` | Working native animation, marker connections, and retained data logging. |
| Other five `*_MVP_AI.slx` behavior models | Copied mission, mode logic, guidance, PID control, and supported multirotor plant. |
| `QuadInterfaces_AI.sldd` | Local shared interfaces, plant buses, and model parameters. |
| `Quadcopter_MVP_AI.slreqx`, `Quadcopter_MVP_Requirements_v1.md` | The copied 18-requirement baseline and unchanged authoritative Markdown. |
| `QuadArchitecture_AI~mdl.slmx` | 40 inherited architectural allocation/planning links, resolved locally. |
| `Visualization_MVP_AI~mdl.slmx` | Three new Implement links from the animation block to SV-02, SV-03, and SV-04. |
| `run_stage03_flight.m`, `init_stage03.m` | Reproducible mission run and local initialization. |
| `stage03_review_figures.m`, `stage03_rows.m` | Camera/labels/companion plots and logged-signal reshaping. |
| `quad_mvp_parameters.m`, `stage02_*.m`, `init_stage02.m`, `run_stage02_smoke.m` | Copied local stage-02 parameters, algorithms, and earlier helpers. Their filenames retain provenance; they do not reference stage 02's working files. Use `run_stage03_flight` for current visualization evidence. |
| `flight_result.mat`, `flight_status.json` | Actual full simulation output and run observations. |
| `flight_evidence/takeoff_preview.png` | Visually inspected native takeoff preview showing the red mesh. |
| `flight_evidence/flight_3d_final.png`, `.fig` | Visually inspected final native 3D scene with mesh, all three target markers, and actual trajectory. |
| `flight_evidence/mission_position_trajectory.png`, `.fig` | Actual plan-view trajectory, altitude/reference, North/East position, and telemetered modes. |
| `visualization_configuration.json` | Values read from the saved animation block plus review camera settings. |
| `dependency_audit.json`, `visual_review.json`, `validation_report.json` | Local resolution checks, documented visual observations, and current stage status. |
| `stage02_original_hashes.json`, `stage02_integrity.json` | Integrity evidence for all 97 stage-02 files, including cache/support files. Provenance only. |
| `inherited_stage02/`, `inherited_stage01/`, `walkthrough/` | Copied historical reports and architecture images, not current-stage simulation evidence. |
| `cache/`, `codegen/` | Local regenerable simulation-target/cache output. |
| `CHECKPOINT_SHA256.txt` | Stage-03 deliverable hashes, excluding transient cache/build output and the inventory itself. |

The copied earlier-stage reports that contain historical absolute paths are provenance records only. The runtime models, dictionary references, MATLAB helpers, requirements, and all 43 traceability-link endpoints were checked to resolve within stage 03. No MATLAB Project is needed.

## Validation and checkpoint

The integrated architecture and Visualization behavior report healthy connectivity in `model_check`; diagram update and the full animated mission completed successfully. The initializer/run/review helpers were exercised in this folder. The run/review source files also had no Code Analyzer issues in the checks performed.

All 18 requirement IDs and rendered statements match the copied Markdown. There are 43 local links: the inherited 40 plus the three visualization Implement links. No Verify links or additional mandatory requirements were created. Formal verification remains reserved for **UAV-MVP-FR-06** and a future **Path Followed** test with an agreed tolerance and calculation method.

Stage 02's file count and all 97 pre-copy file hashes remain unchanged. It retains the executable model and logging-only Visualization behavior that existed before this stage. Stage 01 is likewise retained as the architecture-only snapshot. Continue future work in another sibling stage to preserve these checkpoints.
