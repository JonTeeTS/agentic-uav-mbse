# Path Followed: proposed acceptance criteria

**Version:** PF-CRITERIA-v1  
**Approval:** APPROVED by the user's explicit “Approve PF-CRITERIA-v1” response on 2026-11-16; see `criteria_approval.json`.  
**Only formal requirement target:** UAV-MVP-FR-06.  
**Test file / case:** `QuadcopterTests_AI.mldatx` / `Path Followed`.

## Proposed scope

Assess the geometric three-dimensional cruise path through the three predefined waypoints, using the integrated stage-04 model in normal simulation mode. The assessed interval consists of flight modes 2, 3, and 4 (WP1, WP2, and WP3). Ground, takeoff, landing approach, and landed modes are outside this criterion. The model still runs its complete autonomous mission, with a finite 90-second maximum duration.

The intended NED path vertices, in meters, are fixed before execution:

| Vertex | North | East | Down |
|---|---:|---:|---:|
| Cruise entry / end of takeoff | 0 | 0 | -2 |
| WP1 | 2 | 0 | -2 |
| WP2 | 2 | 2 | -2 |
| WP3 | 0 | 2 | -2 |

Mode 2 selects the segment from cruise entry to WP1; mode 3 selects WP1 to WP2; mode 4 selects WP2 to WP3. Selection is based on the logged mode and the fixed intended path, never on whichever segment happens to be closest to the observed vehicle.

## Proposed numerical criteria

**Tolerance: 0.20 meters**, inclusive, for both the path corridor and waypoint endpoint arrival. This is a proposed engineering demonstration limit, equal to 10% of a nominal 2 m leg; it is absent from the requirements baseline and is not an approved limit until the user accepts it. Earlier demonstration results exist, but they will not be reused as formal evidence or treated as an independent qualification run. No controller or mission retuning is proposed.

At every available position sample during modes 2–4, use actual NED vehicle position `p` and that mode's finite segment endpoints `A` and `B`:

```text
u = clamp(dot(p - A, B - A) / dot(B - A, B - A), 0, 1)
closest_point = A + u * (B - A)
tracking_error = norm(p - closest_point, 2)
```

This is Euclidean distance in all three coordinates to the **finite active path segment**, including altitude error and excursions beyond its endpoints. It is not distance to the infinite supporting line, minimum distance to any segment, or instantaneous distance to the next waypoint. The latter would incorrectly classify normal travel along a leg as a large tracking error.

Use the existing GCS-received actual position telemetry and flight-mode logs at their native nominal 0.02-second sampling period. Align by recorded timestamps; discrete mode association uses zero-order hold only if needed. Do not smooth, decimate, shift, or interpolate the measured positions to improve the result. Missing/invalid samples, mismatched frames, or unusable time alignment must be reported rather than silently dropped.

The single Path Followed verdict combines:

1. Every assessed sample has `tracking_error <= 0.20 m`.
2. All three legs are exercised in order, and actual position reaches within `0.20 m` Euclidean distance of WP1, WP2, and WP3 during the respective leg, before advancing beyond it. Reaching a nearby portion of the path without visiting all endpoints is insufficient.
3. The waypoint path is completed within the 90-second simulation limit. Completion of the waypoint path does not require assessing landing performance.

No settling grace period is excluded from modes 2–4, and no percentage of out-of-corridor samples is allowed.

## Outcomes and evidence

- **Pass:** all agreed corridor, ordered waypoint-arrival, and path-completion criteria are met on the actual test run.
- **Fail:** usable evidence shows a corridor breach, missed/out-of-order waypoint or leg, or failure to complete the waypoint path within 90 seconds.
- **Inconclusive:** a technical execution/logging problem prevents a defensible assessment. Preserve diagnostic details; do not label an unexecuted or unusable assessment as passed.

Record per-leg and overall maximum tracking error, RMS tracking error, waypoint closest-approach distances/times, evaluated sample counts, mode/leg timing, run settings, and diagnostics. Produce an actual-versus-intended 3D/plan-view path plot and tracking-error-versus-time plot with the approved 0.20 m line. RMS values are descriptive evidence; they are not an extra pass threshold.

Save the native Simulink Test results, raw run data, assessment metrics, plots, and the approval record inside stage 04. Link only FR-06 to the Path Followed test with a Verify link. VR-01 through VR-04 govern test preparation/evidence/traceability; they are not separate formal verification targets.

Passing establishes only this agreed, sampled geometric waypoint-following criterion in the nominal simulated conditions. It does not certify flight safety, hardware readiness, takeoff/landing performance, visualization correctness, or overall UAV compliance. Other requirements remain outside formal verification.
