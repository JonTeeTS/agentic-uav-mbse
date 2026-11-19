# Stage 01: Requirements and Architecture

Created on 2026-11-16 with MATLAB R2026b Update 1, Requirements Toolbox, and System Composer.

This folder is the completed **requirements and architecture checkpoint**. Leave it untouched after this stage. Continue development in a new stage by copying the necessary artifacts and using new model and requirement filenames as appropriate. Do not save later implementation, simulation, cache, or test results into this folder.

## Files

| File | Purpose |
|---|---|
| `Quadcopter_MVP_Requirements_v1.md` | Unchanged local copy of the authoritative requirements baseline. |
| `Quadcopter_MVP_AI.slreqx` | All 18 identified baseline requirements, retaining their exact UAV-MVP IDs and rendered wording. |
| `QuadArchitecture_AI.slx` | System Composer architecture with the requested hierarchy and interfaces. |
| `QuadArchitecture_AI~mdl.slmx` | Saved component-to-requirement traceability links; keep beside the model. |
| `QuadInterfaces_AI.sldd` | Seven shared data interface definitions used by all 30 ports. |
| `validation_report.json` | Actual requirement, priority, link, interface, reload, and visual-review results. Includes a requirement-by-requirement link inventory. |
| `walkthrough/01_TopLevel.png` | Top-level architecture walkthrough image. |
| `walkthrough/02_AirVehicle.png` | AirVehicle decomposition image. |
| `walkthrough/03_FCS.png` | FCS decomposition image. |
| `STAGE_README.md` | Reopening instructions, design decisions, and checkpoint status. |
| `CHECKPOINT_SHA256.txt` | SHA-256 inventory of the checkpoint files, excluding the inventory itself. |

The empty `cache/` and `codegen/` directories were created to constrain MATLAB-generated outputs to this stage during creation. No simulation or generated code was produced. No MATLAB Project file was created or required to reopen these standalone artifacts.

Baseline SHA-256, checked against the original file before import:

`F49FECEADD4037DF8886FD06C1455E38405BB697C0EED4DE7A4F194AB0EA3FA8`

## Reopen for review

Keep the model, dictionary, requirements set, and link set together. In MATLAB:

```matlab
cd('C:\Demos\agentic-uav-mbse\Quadcopter_Agentic_Demo\01_Requirements_Architecture')
arch = systemcomposer.openModel('QuadArchitecture_AI.slx');
reqs = slreq.open('Quadcopter_MVP_AI.slreqx');
```

Both artifacts were saved, closed, reopened, and left open at stage completion. The architecture had `Dirty = off` following reopening. Review the files without saving changes into this checkpoint. For subsequent development, work from a copy in a new stage and redirect cache/code-generation folders there.

## Architecture walkthrough

1. GroundControlStation sends MissionCommand and WaypointTargets to AirVehicle. It receives Position and FlightMode telemetry.
2. Visualization receives VehicleState from AirVehicle and the same WaypointTargets from GroundControlStation.
3. AirVehicle contains FCS and VehicleModel. FCS sends ControlOutputs to VehicleModel; VehicleModel feeds VehicleState back to FCS. VehicleModel also supplies Position telemetry, and FCS supplies FlightMode telemetry.
4. FCS contains ModeLogic, Guidance, and FeedbackControl. ModeLogic consumes mission commands and vehicle state and distributes flight mode. Guidance consumes the three waypoint targets, flight mode, and vehicle state, and supplies PositionReference. FeedbackControl consumes that reference, flight mode, and state, and supplies control outputs.

Eight components and 23 connectors were created. There are no additional top-level external ports, payloads, obstacle-avoidance functions, endurance models, hardware interfaces, or test components.

## Interface design decisions

These are stage-specific design choices, not additional mandatory requirements. All data elements currently use `double`. Command/mode encodings and timing remain to be defined during implementation.

| Interface | Elements and dimensions |
|---|---|
| `MissionCommand_IF` | `Command`: scalar |
| `WaypointTargets_IF` | `PositionNED`: 3-by-3, one waypoint per row, three NED coordinates per waypoint |
| `ControlOutputs_IF` | `Roll`, `Pitch`, `YawRate`, `Thrust`: scalars |
| `VehicleState_IF` | `PositionNED`: 3-by-1; `VelocityNED`: 3-by-1; `OrientationQuaternion`: 4-by-1; `AngularVelocityBody`: 3-by-1 |
| `Position_IF` | `PositionNED`: 3-by-1 |
| `FlightMode_IF` | `Mode`: scalar |
| `PositionReference_IF` | `PositionNED`: 3-by-1 |

NED was selected to align with the reference example. Units, quaternion ordering/frame direction, command/mode enumerations, control-output interpretation, sample times, actual waypoint coordinates, and landing sequencing must be made explicit and kept consistent in the future executable model. The three waypoint targets are a typed interface here; no actual mission data has been invented. PositionReference is the internal guidance-to-control signal needed for the requested decomposition. VehicleModel's Position output is intended to expose the same position as its VehicleState.PositionNED element; behavior will need to enforce that consistency.

## Requirements and traceability

The requirements set contains 6 FR, 4 AR, 4 SV, and 4 VR requirements. It introduces no additional requirement IDs. Summaries and descriptions retain the baseline requirement wording; Markdown bold delimiters are presentation markup and were removed when importing plain text. The unchanged Markdown copy preserves all original formatting and surrounding scope/verification context.

The custom `Priority` attribute preserves Mandatory or Optional exactly where specified. VR requirements have an empty Priority because the baseline VR table does not specify priorities; no priority was inferred. `EvidenceOrAcceptance` preserves the corresponding evidence or acceptance text. `FormalVerificationTarget` is Yes only for UAV-MVP-FR-06.

All 18 requirements have architecture links: **40 links total**, comprising **33 Implement links** for architectural responsibility and **7 Relate links** for optional/planned work. Implement is the Requirements Toolbox link type for design allocation; it is not proof of executable implementation, satisfaction, or test completion. Each link explicitly records that limitation. There are **zero Verify links** and no test artifacts or results.

| Requirement | Architectural responsibility / planning association |
|---|---|
| UAV-MVP-FR-01 | AirVehicle, ModeLogic, Guidance |
| UAV-MVP-FR-02 | FCS, Guidance, FeedbackControl |
| UAV-MVP-FR-03 | GroundControlStation, FCS |
| UAV-MVP-FR-04 | GroundControlStation, AirVehicle, VehicleModel, ModeLogic |
| UAV-MVP-FR-05 | ModeLogic, Guidance: Relate only; remains Optional and unimplemented |
| UAV-MVP-FR-06 | FCS, Guidance: sole formal verification target, not yet verified |
| UAV-MVP-AR-01 | GroundControlStation, AirVehicle, Visualization |
| UAV-MVP-AR-02 | FCS, VehicleModel |
| UAV-MVP-AR-03 | ModeLogic, Guidance, FeedbackControl |
| UAV-MVP-AR-04 | GroundControlStation, AirVehicle, FCS, VehicleModel, Visualization |
| UAV-MVP-SV-01 | FCS, VehicleModel |
| UAV-MVP-SV-02 | Visualization |
| UAV-MVP-SV-03 | Visualization |
| UAV-MVP-SV-04 | VehicleModel, Visualization |
| UAV-MVP-VR-01 | Guidance: Relate for future Path Followed test planning |
| UAV-MVP-VR-02 | Guidance: Relate for future tolerance/method definition |
| UAV-MVP-VR-03 | Guidance: Relate for future measurement/results reporting |
| UAV-MVP-VR-04 | FCS, Guidance: Relate for future requirement-model-test traceability |

Formal verification is reserved for **UAV-MVP-FR-06**, through a future simulation-based test named **Path Followed**. VR-01 through VR-04 define that test's obligations; they are not additional formal test targets. No tolerance has been selected or approved. Other requirements require inspection or demonstration evidence and are not formally verified. Optional hover is not a mandatory commitment or an additional formal verification target.

## Actual validation status

| Check | Actual result |
|---|---|
| Baseline preservation | Source and copied file SHA-256 values match. |
| Import completeness | 18/18 IDs and rendered requirement statements match the local baseline. All source priorities preserved. |
| Requested hierarchy | All eight requested components exist at their specified levels. |
| Connectivity | `model_check` reports healthy: no disconnected ports or dangling lines. Rechecked after final layout and after reopening. |
| Shared interfaces | 30/30 component/boundary ports have the expected shared interface. All 23 connectors have matching source/destination interface names, referring to the same shared definitions. |
| Save/reload | Saved model and requirements reopened successfully; 40 links, 30 typed ports, and 23 compatible connectors remained present. |
| Diagram presentation | All three walkthrough images visually inspected; component widths and boundary-port positions adjusted to separate labels. Command/control flow reads left to right, with feedback routed around components. |
| Diagram update / compilation | Attempted. MATLAB stops with `Simulink:Engine:NoBehaviorsForArchitectureModel`: all components are virtual and have no executable behaviors. Full compiled interface validation is therefore not established. |
| Implementation and simulation | Not started in this stage. No control logic, vehicle dynamics, mission execution, or 3D animation is implemented. |
| Formal verification | Not started. No Path Followed test, approved tolerance, execution, pass/fail result, or Verify link exists. |

The architectural connectivity and shared-interface checks passed. The compilation limitation is expected for this architecture-only checkpoint, but must be resolved by adding executable behavior in a later stage before claiming simulation/type-compilation success. Syntactic architecture links do not establish behavioral satisfaction.

## Reference and unresolved work

[MathWorks: Develop and Verify a Quadcopter System Architecture](https://www.mathworks.com/help/systemcomposer/ug/develop-verify-quadcopter-system-architecture.html) informed the hierarchy, closed-loop signal flow, NED convention, and workflow. No older requirement files or example requirement sets were imported. The example's broader trajectories, endurance scope, and multiple automated checks were not adopted as MVP requirements.

Unresolved work: implement the leaf behaviors and actual three-waypoint mission in a later stage; define the interface semantics listed above; create the required opaque 3D multirotor visualization; agree the numerical position tolerance and calculation method before running Path Followed; create the FR-06-only test and its requirement-model-test links; and record measured evidence and results. Optional hover remains a future choice. No implementation or test-completion claim is made.
