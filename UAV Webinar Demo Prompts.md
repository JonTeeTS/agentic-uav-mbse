# Agentic UAV Development Demo — Prompts

## Prompt 1 — Requirements and system architecture

> We are creating a minimum viable autonomous quadcopter system for an engineering demonstration.
> 
> Read the attached `Quadcopter_MVP_Requirements_v1.md` as the **authoritative requirements baseline**. Use this MathWorks example as a reference for architecture and workflow: [https://www.mathworks.com/help/systemcomposer/ug/develop-verify-quadcopter-system-architecture.html](https://www.mathworks.com/help/systemcomposer/ug/develop-verify-quadcopter-system-architecture.html)
> 
> **Stage folder:** Create `Quadcopter_Agentic_Demo/01_Requirements_Architecture/` and make it the working directory. Copy `Quadcopter_MVP_Requirements_v1.md` into this folder as an unchanged local requirements baseline. Save every generated artifact for this prompt here (and any necessary files in subfolders); do not write generated project files outside this stage.
> 
> Using Requirements Toolbox and System Composer:
> 
> 1. Create a new requirements set named `Quadcopter_MVP_AI.slreqx` containing the requirements defined in the Markdown document. **Preserve the exact `UAV-MVP-*` IDs, priorities, and wording**; do not invent additional mandatory requirements or refer to any older source files.
> 2. Create a new System Composer architecture model named `QuadArchitecture_AI.slx` with **GroundControlStation**, **AirVehicle**, and **Visualization**. Under AirVehicle, add **FCS** and **VehicleModel**. Under FCS, add **ModeLogic**, **Guidance**, and **FeedbackControl**.
> 3. Add only the ports and connections needed for mission commands, three waypoint targets, control outputs, vehicle state, position/flight-mode telemetry, and visualization (requirements `UAV-MVP-AR-01` through `UAV-MVP-AR-04`).
> 4. Link the relevant requirements to the corresponding architectural components. Keep `UAV-MVP-FR-05` optional, and reserve **formal verification** for `UAV-MVP-FR-06` only.
> 5. Check the architecture for disconnected or inconsistent interfaces. Arrange the diagram for a clear customer-facing walkthrough.
> 
> Save and open the requirements set and top-level architecture. Write a `STAGE_README.md` listing the files created, how to reopen the architecture, and the actual validation/traceability status. Briefly report unresolved issues. Do not claim implementation or test completion yet.
> 
> **Checkpoint:** The `01_Requirements_Architecture` folder must remain untouched after this prompt.

## Prompt 2 — Build the executable quadcopter model

> **Stage folder:** Create `Quadcopter_Agentic_Demo/02_Executable_Model/` as a **sibling** of `01_Requirements_Architecture`. Copy the **contents** of `01_Requirements_Architecture` into this new folder, including the requirements set, architecture model, requirements Markdown, local scripts, and supporting files. Do not link to working files in the stage-01 folder. Make the stage-02 folder the working directory and update model/project references to resolve from this local copy. Keep stage 01 unchanged.
> 
> Continue using the copied `Quadcopter_MVP_AI.slreqx`, `QuadArchitecture_AI.slx`, and Markdown requirements baseline in this stage-02 folder.
> 
> Build the **minimum viable executable model** following the implementation pattern in the MathWorks quadcopter architecture example.
> 
> 1. Implement **GroundControlStation** to provide a predefined mission: autonomous takeoff, three waypoints, and landing (`UAV-MVP-FR-01`, `UAV-MVP-FR-03`).
> 2. Implement **ModeLogic**, **Guidance**, and **FeedbackControl** to support basic mission modes, waypoint position error, and closed-loop flight control (`UAV-MVP-FR-02`). Use simple, supportable reference components and PID-based control where practical.
> 3. Implement **VehicleModel** with a low-fidelity quadcopter dynamics model. Reuse suitable supported MathWorks components or design patterns to minimize development effort; do not introduce detailed aerodynamics or a hardware autopilot.
> 4. Return simulated vehicle position and flight mode to GroundControlStation as telemetry (`UAV-MVP-FR-04`). Connect the state required by Visualization.
> 5. Use one consistent coordinate convention and document it. Implement hovering (`UAV-MVP-FR-05`) only if it is straightforward and does not jeopardize the mandatory mission.
> 6. Save the integrated executable model, update diagrams, compile it, and run a basic smoke-test simulation. Correct connection, data-type, and execution errors that you can identify.
> 
> Stay within `UAV-MVP-SV-01` and the scope exclusions of the Markdown document: **no obstacle avoidance, camera/sensor payloads, PX4, MIL/SIL/HIL, or hardware deployment**.
> 
> Open the top-level executable model and show a concise status: model compiles or does not compile, simulation runs or does not run, and which capabilities are implemented. Update the stage-local `STAGE_README.md` with instructions to run the simulation and its actual status. Do not present visual verification or requirements-test pass status yet.
> 
> **Checkpoint:** Keep all stage-02 artifacts under `02_Executable_Model`, while the stage-01 folder remains an independently openable architecture-only snapshot.

## Prompt 3 — Simulate and show a recognizable 3D drone

> **Stage folder:** Create `Quadcopter_Agentic_Demo/03_3D_Flight_Simulation/` as a **sibling** of stages 01 and 02. Copy the **contents** of `02_Executable_Model` to the new folder, including the runnable model and all support files. Work only on the stage-03 copies. Correct relative paths, model references, data dictionaries, and requirements links so this stage runs independently. Do not modify stage 02.
> 
> Use the executable quadcopter model copied into this folder and implement `UAV-MVP-SV-02`, `UAV-MVP-SV-03`, and `UAV-MVP-SV-04`.
> 
> 1. Configure the Visualization component using the **UAV Animation** functionality in UAV Toolbox, following the MathWorks reference example.
> 2. Show **one clearly recognizable, opaque 3D multirotor/quadcopter body** (preferably red), with visible arms and rotors or an equivalent supported multirotor mesh. **A moving point, sphere, or dot by itself is not acceptable.**
> 3. Connect simulated **position and orientation** to the animation. Match the animation's coordinate system and attitude representation to the model; use North-East-Down and quaternion orientation if consistent with the implementation.
> 4. Set camera framing, mesh scale, and axes so the drone remains large enough to recognize throughout the flight. Display the **three target waypoints** and **actual flight trajectory** as supplementary graphics.
> 5. Run the autonomous mission and demonstrate takeoff, traversal of the waypoints, and landing. Show position/trajectory plots alongside the 3D visualization if practical.
> 6. If the drone is too small, incorrectly oriented, or represented only by a marker, correct the visualization and rerun before calling this step complete.
> 
> Keep the scene simple: **no Unreal Engine or photorealistic environment is required**. Save the working model and visualization configuration **inside the stage-03 folder**, then open the animation for review. Update `STAGE_README.md` with the command/script to reproduce the flight and the actual result. State any observed mission failures rather than masking them.
> 
> **Checkpoint:** Stage 03 must be runnable from its own directory and stage 02 must still show the earlier executable model before 3D visualization was added.

## Prompt 4 — Verify waypoint following and show traceability

> **Stage folder:** Create `Quadcopter_Agentic_Demo/04_Path_Followed_Verification/` as a **sibling** of stages 01–03. Copy the **contents** of `03_3D_Flight_Simulation` into this folder, including the requirements set, models, visualization setup, and all run dependencies. Work exclusively within stage 04, without editing stages 01–03. Adjust links and paths so the copied models, requirements, and tests are local to stage 04.
> 
> Using the local `Quadcopter_MVP_AI.slreqx`, executable model, and `Quadcopter_MVP_Requirements_v1.md`, perform the MVP's **single formal verification activity**.
> 
> 1. Select **`UAV-MVP-FR-06`** ("The system shall follow a predefined waypoint flight path during simulation") as the **only requirement to verify formally**. Do not claim formal verification for other functional, architecture, or visualization requirements.
> 2. Following the MathWorks reference example's verification workflow, create a Simulink Test file `QuadcopterTests_AI.mldatx` with a test case called **Path Followed** (`UAV-MVP-VR-01`).
> 3. Compare simulated vehicle positions with the specified waypoint path. Propose a **numerical position tolerance and a clearly defined tracking-error calculation**, because the requirements baseline does not provide numerical limits. **Ask me to approve these criteria before running a pass/fail assessment** (`UAV-MVP-VR-02`).
> 4. After approval, execute the test, record actual tracking errors, and report **pass, fail, or inconclusive** with plots and evidence (`UAV-MVP-VR-03`). Never force a passing verdict or substitute an assumed threshold without noting it.
> 5. Create or inspect traceability from `UAV-MVP-FR-06` to the relevant architecture/implementation elements and the **Path Followed** test (`UAV-MVP-VR-04`).
> 6. Open the Simulink Test results and requirements links for a brief customer-facing walkthrough. Summarize any unverified areas explicitly.
> 
> Passing this one simulation test demonstrates only the agreed waypoint-following criterion under the simulated conditions. It **does not certify flight safety, hardware readiness, takeoff/landing performance, or overall UAV compliance**.