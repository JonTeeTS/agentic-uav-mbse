# Quadcopter System — Minimum Viable Product Requirements

**Document ID:** UAV-MVP-REQ-001  
**Version:** 1.0  
**Status:** Demonstration baseline  
**System:** Autonomous Quadcopter

## 1. Purpose

This document defines the minimum functional and demonstration requirements for a quadcopter system developed using model-based systems engineering. The system shall support a short autonomous mission consisting of takeoff, traversal of predefined waypoints, and landing. Its architecture and behavior shall be modeled and simulated, with a clearly visible 3D quadcopter animation.

The objective is a small, executable, understandable engineering prototype—not a flight-ready aircraft or a complete search-and-rescue platform.

## 2. System Overview

The system comprises a **Ground Control Station**, an **Air Vehicle**, and a **Visualization** subsystem. The Air Vehicle includes a **Flight Control System (FCS)** and a **Vehicle Model**. The FCS contains **Mode Logic**, **Guidance**, and **Feedback Control** functions.

The Ground Control Station provides mission commands and waypoint data. The FCS uses the waypoint targets and simulated vehicle state to calculate flight-control commands. The Vehicle Model responds to these commands and reports its state for control, telemetry, and visualization.

## 3. Functional Requirements

| ID | Requirement | Priority | Demonstration evidence |
|---|---|---|---|
| **UAV-MVP-FR-01** | The system shall execute an autonomous mission consisting of takeoff, traversal of three predefined waypoints, and landing. | Mandatory | Executable mission simulation |
| **UAV-MVP-FR-02** | The flight control system shall provide closed-loop guidance and control to track commanded waypoints and maintain stable simulated flight. | Mandatory | Control-system implementation and simulation plots |
| **UAV-MVP-FR-03** | The flight control system shall accept mission commands and waypoint targets from the Ground Control Station. | Mandatory | Simulated command input and model interfaces |
| **UAV-MVP-FR-04** | The system shall transmit simulated vehicle position and flight-mode information to the Ground Control Station. | Mandatory | Telemetry signals within the executable model |
| **UAV-MVP-FR-05** | The system should maintain a hover at a designated waypoint before continuing the mission. | Optional | Visible hover segment, if implemented |
| **UAV-MVP-FR-06** | The system shall follow a predefined waypoint flight path during simulation. | Mandatory | **Formal verification target:** Path Followed test |

## 4. Architecture Requirements

| ID | Requirement | Priority |
|---|---|---|
| **UAV-MVP-AR-01** | The system architecture shall include GroundControlStation, AirVehicle, and Visualization components. | Mandatory |
| **UAV-MVP-AR-02** | AirVehicle shall comprise FCS and VehicleModel components. | Mandatory |
| **UAV-MVP-AR-03** | FCS shall comprise ModeLogic, Guidance, and FeedbackControl components. | Mandatory |
| **UAV-MVP-AR-04** | Model interfaces shall carry the mission commands, waypoint targets, control outputs, vehicle state, and telemetry needed for closed-loop simulation. | Mandatory |

## 5. Simulation and Visualization Requirements

| ID | Requirement | Priority |
|---|---|---|
| **UAV-MVP-SV-01** | The system shall run as an executable, closed-loop Simulink simulation using a low-fidelity quadcopter vehicle model. | Mandatory |
| **UAV-MVP-SV-02** | The visualization shall display a recognizable, opaque **3D quadcopter/multirotor body**, not only a point or dot marker. | Mandatory |
| **UAV-MVP-SV-03** | The visualization shall show the vehicle moving through the mission and shall display the target waypoints and actual flight trajectory. | Mandatory |
| **UAV-MVP-SV-04** | The animation shall present the vehicle's position and orientation consistently with the simulation coordinate convention. | Mandatory |

A simple 3D scene using UAV Toolbox animation is sufficient. A photorealistic environment is not required.

## 6. Verification Requirements

**Only UAV-MVP-FR-06 (predefined waypoint following) is a formal verification target for this MVP.** Other requirements shall be demonstrated by model inspection or simulation, but shall not be reported as formally verified without separate test evidence.

| ID | Requirement | Acceptance approach |
|---|---|---|
| **UAV-MVP-VR-01** | A simulation-based test case named **Path Followed** shall assess UAV-MVP-FR-06. | Execute the mission and compare actual vehicle positions with the intended waypoint path. |
| **UAV-MVP-VR-02** | The waypoint-following test shall use a numerical position tolerance agreed before execution. | Record the approved tolerance and calculation method in the test definition. |
| **UAV-MVP-VR-03** | The test shall record measured tracking performance and report pass, fail, or inconclusive based on actual evidence. | Test results and plots. |
| **UAV-MVP-VR-04** | The verification test shall be traceable to UAV-MVP-FR-06 and its relevant architecture or implementation elements. | Requirement–model–test links or equivalent traceability record. |

**Verification boundary:** Passing *Path Followed* establishes only the defined waypoint-following criterion under the simulated conditions. It does not establish overall flight safety, hardware performance, or operational suitability.

## 7. Scope Exclusions

The following are outside this MVP: obstacle avoidance; camera, infrared, and other sensor payloads; target detection; reconnaissance processing; endurance and detailed battery modeling; detailed aerodynamics; PX4 integration; physical hardware; MIL/SIL/HIL workflows; shipboard recovery; and comprehensive fault-management or off-nominal safety modes.

## 8. Deliverables

The demonstration shall produce:

1. A requirements set containing the requirements defined in this document.
2. A System Composer architecture with the components and interfaces specified above.
3. An executable Simulink quadcopter model and a predefined mission.
4. A visible 3D quadcopter animation with waypoints and trajectory.
5. A **Path Followed** verification test, results, and traceability to UAV-MVP-FR-06.

## 9. Engineering Reference

The following MathWorks example is the reference implementation and workflow guide for architecture, simulation, visualization, and verification:

[Develop and Verify a Quadcopter System Architecture](https://www.mathworks.com/help/systemcomposer/ug/develop-verify-quadcopter-system-architecture.html)

The implementation may reuse suitable supported MathWorks components and design patterns to meet the MVP requirements. Any deviations affecting requirement satisfaction shall be documented.
