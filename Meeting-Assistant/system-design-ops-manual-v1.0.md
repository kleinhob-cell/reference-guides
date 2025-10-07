# AI Meeting Assistant – System Design & Operations Manual

## Summary

This document defines the **end‑to‑end architecture, operational standards, and lifecycle management** for the AI Meeting Assistant platform.  
It serves as both a **design reference** and an **operations playbook**, ensuring the system is:

- **Reproducible** – All environments, builds, and deployments follow deterministic, documented processes.
- **Maintainable** – Clear configuration management, upgrade policies, and troubleshooting guides.
- **Future‑proof** – Hardware and software strategies that anticipate scaling, new integrations, and evolving AI workloads.
- **Secure & Observable** – Guardrails, monitoring, and incident response workflows to protect data and maintain service health.

The manual covers:

- **System Overview** – Objectives, scope, and success criteria.
- **Hardware & Environment Baseline** – Primary/secondary systems, storage, networking, and GPU acceleration.
- **Functional & Non‑Functional Requirements** – Core features, performance targets, and operational constraints.
- **Architecture & Pipelines** – Audio capture, ASR/NLP processing, storage, and integrations.
- **Deployment & Validation** – Build scripts, burn‑in testing, and environment pinning.
- **Operations & Maintenance** – Steady‑state routines, hypercare, incident response, and upgrade policy.
- **Appendices** – Reference commands, environment variables, file layouts, and the Meeting Assistant build/validation guides.

This manual is intended for **engineers, operators, and maintainers** responsible for deploying, running, and evolving the AI Meeting Assistant across supported environments.

## Table of Contents

- [AI Meeting Assistant – System Design \& Operations Manual](#ai-meeting-assistant--system-design--operations-manual)
  - [Summary](#summary)
  - [Table of Contents](#table-of-contents)
  - [Section 1: System Overview](#section-1-system-overview)
  - [Objectives and success criteria](#objectives-and-success-criteria)
  - [Non-goals](#non-goals)
  - [Core features](#core-features)
  - [Hardware and environment assumptions](#hardware-and-environment-assumptions)
    - [Prompt used to generate the recommendation](#prompt-used-to-generate-the-recommendation)
  - [Cost model and licensing](#cost-model-and-licensing)
  - [Key decisions](#key-decisions)
  - [ASR plan with faster-whisper on this hardware](#asr-plan-with-faster-whisper-on-this-hardware)
  - [Risks and mitigations](#risks-and-mitigations)
  - [Operability and maintainability](#operability-and-maintainability)
  - [Interfaces and external dependencies](#interfaces-and-external-dependencies)
  - [Section sign-off checklist](#section-sign-off-checklist)
  - [Documentation Conventions {#documentation-conventions}](#documentation-conventions-documentation-conventions)
  - [Section 2: Hardware \& Environment Baseline](#section-2-hardware--environment-baseline)
    - [§2.1 Environment Baseline {#21-environment-baseline}](#21-environment-baseline-21-environment-baseline)
      - [Baseline Definition](#baseline-definition)
      - [Rationale](#rationale)
      - [Baseline Validation](#baseline-validation)
      - [Change Control](#change-control)
      - [Drift Detection](#drift-detection)
    - [2.2 Secondary Systems](#22-secondary-systems)
    - [2.4 Audio Path Topology](#24-audio-path-topology)
    - [2.5 Environment Configuration {#25-environment-configuration}](#25-environment-configuration-25-environment-configuration)
      - [1. Operating System \& Kernel](#1-operating-system--kernel)
      - [2. GPU Runtime \& Drivers](#2-gpu-runtime--drivers)
      - [3. Core AI Runtime Components](#3-core-ai-runtime-components)
      - [4. Audio Pre‑Processing Stack](#4-audio-preprocessing-stack)
      - [5. Storage \& Filesystem](#5-storage--filesystem)
      - [6. Integration Layer](#6-integration-layer)
      - [7. Validation \& Drift Control](#7-validation--drift-control)
      - [8. Change Control](#8-change-control)
    - [2.6 Storage Layout](#26-storage-layout)
    - [2.7 CPU/GPU Allocation](#27-cpugpu-allocation)
    - [2.8 Networking \& Security](#28-networking--security)
    - [2.9 Cost Considerations](#29-cost-considerations)
    - [2.10 Key Decisions](#210-key-decisions)
    - [2.11 Section Sign‑off Checklist](#211-section-signoff-checklist)
  - [Section 3: Functional Requirements](#section-3-functional-requirements)
    - [3.1 Audio Capture](#31-audio-capture)
    - [3.2 Audio Pre‑Processing {#32-audio-pre-processing}](#32-audio-preprocessing-32-audio-pre-processing)
      - [3.2.1 Purpose](#321-purpose)
      - [3.2.2 Component Versions (Stable)](#322-component-versions-stable)
      - [3.2.3 Newest Candidate Versions as of September 2025](#323-newest-candidate-versions-as-of-september2025)
      - [3.2.4 Processing Order](#324-processing-order)
      - [3.2.5 Integration with ASR](#325-integration-with-asr)
      - [3.2.6 Validation \& Drift Control](#326-validation--drift-control)
      - [3.2.7 Change Control](#327-change-control)
    - [3.3 Hardware Audio Setup \& Verification {#33-hardware-audio-setup-verification}](#33-hardware-audio-setup--verification-33-hardware-audio-setup-verification)
      - [3.3.1 Prerequisites](#331-prerequisites)
      - [3.3.2 Identify Audio Devices](#332-identify-audio-devices)
      - [3.3.3 Launch Helvum for Visual Routing](#333-launch-helvum-for-visual-routing)
      - [3.3.4 Optional: Record a Short Sample from Each Input](#334-optional-record-a-short-sample-from-each-input)
      - [3.3.5 Troubleshooting](#335-troubleshooting)
      - [3.3.6 Clean Up](#336-clean-up)
  - [3.4 Automatic Speech Recognition (ASR) {#34-automatic-speech-recognition-asr}](#34-automatic-speech-recognition-asr-34-automatic-speech-recognition-asr)
      - [3.4.1 Purpose {#341-purpose}](#341-purpose-341-purpose)
      - [3.4.2 Component Versions (TBD Stable) {#342-component-versions-tbd-stable}](#342-component-versions-tbd-stable-342-component-versions-tbd-stable)
      - [3.4.3 Newest Candidate Versions (TBD) {#343-newest-candidate-versions-tbd}](#343-newest-candidate-versions-tbd-343-newest-candidate-versions-tbd)
      - [3.4.4 Processing Flow {#344-processing-flow}](#344-processing-flow-344-processing-flow)
      - [3.4.5 Model Management {#345-model-management}](#345-model-management-345-model-management)
      - [3.4.6 Performance Targets {#346-performance-targets}](#346-performance-targets-346-performance-targets)
      - [3.4.7 Validation \& Drift Control {#347-validation--drift-control}](#347-validation--drift-control-347-validation--drift-control)
      - [3.4.8 Change Control {#348-change-control}](#348-change-control-348-change-control)
    - [3.5 NLP {#35-nlp}](#35-nlp-35-nlp)
      - [3.5.1 Purpose {#351-purpose}](#351-purpose-351-purpose)
      - [3.5.2 Component Versions (Stable) {#352-component-versions-stable}](#352-component-versions-stable-352-component-versions-stable)
      - [3.5.3 Newest Candidate Versions as of 2024-02-15 {#353-newest-candidate-versions}](#353-newest-candidate-versions-as-of-2024-02-15-353-newest-candidate-versions)
      - [3.5.4 Processing Flow {#354-processing-flow}](#354-processing-flow-354-processing-flow)
      - [3.5.5 Model Management {#355-model-management}](#355-model-management-355-model-management)
      - [3.5.6 Performance Targets {#356-performance-targets}](#356-performance-targets-356-performance-targets)
      - [3.5.7 Validation \& Drift Control {#357-validation--drift-control}](#357-validation--drift-control-357-validation--drift-control)
      - [3.5.8 Change Control {#358-change-control}](#358-change-control-358-change-control)
    - [3.6 Storage \& Archival {#36-storage--archival}](#36-storage--archival-36-storage--archival)
      - [3.6.1 Purpose {#361-purpose}](#361-purpose-361-purpose)
      - [3.6.2 Component Versions (Stable) {#362-component-versions-stable}](#362-component-versions-stable-362-component-versions-stable)
      - [3.6.3 Newest Candidate Versions {#363-newest-candidate-versions}](#363-newest-candidate-versions-363-newest-candidate-versions)
      - [3.6.4 Storage Layout {#364-storage-layout}](#364-storage-layout-364-storage-layout)
      - [3.6.5 Snapshot \& Retention Policy {#365-snapshot--retention-policy}](#365-snapshot--retention-policy-365-snapshot--retention-policy)
      - [3.6.6 Validation \& Drift Control {#366-validation--drift-control}](#366-validation--drift-control-366-validation--drift-control)
      - [3.6.7 Performance Targets {#367-performance-targets}](#367-performance-targets-367-performance-targets)
      - [3.6.8 Change Control {#368-change-control}](#368-change-control-368-change-control)
    - [3.7 Search \& Retrieval {#37-search--retrieval}](#37-search--retrieval-37-search--retrieval)
      - [3.7.1 Purpose {#371-purpose}](#371-purpose-371-purpose)
      - [3.7.2 Component Versions (TBDStable) {#372-component-versions-stable}](#372-component-versions-tbdstable-372-component-versions-stable)
      - [3.7.3 Newest Candidate Versions (TBD) {#373-newest-candidate-versions}](#373-newest-candidate-versions-tbd-373-newest-candidate-versions)
      - [3.7.4 Processing Flow {#374-processing-flow}](#374-processing-flow-374-processing-flow)
      - [3.7.5 Index Configuration {#375-index-configuration}](#375-index-configuration-375-index-configuration)
      - [3.7.6 Performance Targets {#376-performance-targets}](#376-performance-targets-376-performance-targets)
      - [3.7.7 Validation \& Drift Control {#377-validation--drift-control}](#377-validation--drift-control-377-validation--drift-control)
      - [3.7.8 Change Control {#378-change-control}](#378-change-control-378-change-control)
    - [3.8 Calendar Integration {#38-calendar-integration}](#38-calendar-integration-38-calendar-integration)
      - [3.8.1 Purpose {#381-purpose}](#381-purpose-381-purpose)
      - [3.8.2 Component Versions (TBD Stable) {#382-component-versions-stable}](#382-component-versions-tbd-stable-382-component-versions-stable)
      - [3.8.3 Newest Candidate Versions (TBD) {#383-newest-candidate-versions}](#383-newest-candidate-versions-tbd-383-newest-candidate-versions)
      - [3.8.4 Integration Flow {#384-integration-flow}](#384-integration-flow-384-integration-flow)
      - [3.8.5 Security \& Privacy {#385-security--privacy}](#385-security--privacy-385-security--privacy)
      - [3.8.6 Validation \& Drift Control {#386-validation--drift-control}](#386-validation--drift-control-386-validation--drift-control)
      - [3.8.7 Performance Targets {#387-performance-targets}](#387-performance-targets-387-performance-targets)
      - [3.8.8 Change Control {#388-change-control}](#388-change-control-388-change-control)
    - [3.9 Integrations {#39-integrations}](#39-integrations-39-integrations)
      - [3.9.1 Purpose {#391-purpose}](#391-purpose-391-purpose)
      - [3.9.2 Integration Categories {#392-integration-categories}](#392-integration-categories-392-integration-categories)
      - [3.9.3 Component Versions (Stable) {#393-component-versions-stable}](#393-component-versions-stable-393-component-versions-stable)
      - [3.9.4 Newest Candidate Versions {#394-newest-candidate-versions}](#394-newest-candidate-versions-394-newest-candidate-versions)
      - [3.9.5 Integration Flow {#395-integration-flow}](#395-integration-flow-395-integration-flow)
      - [3.9.6 Security \& Privacy {#396-security--privacy}](#396-security--privacy-396-security--privacy)
      - [3.9.7 Validation \& Drift Control {#397-validation--drift-control}](#397-validation--drift-control-397-validation--drift-control)
      - [3.9.8 Performance Targets {#398-performance-targets}](#398-performance-targets-398-performance-targets)
      - [3.9.9 Change Control {#399-change-control}](#399-change-control-399-change-control)
    - [3.10 Learning \& Adaptation](#310-learning--adaptation)
    - [3.11 Guardrails](#311-guardrails)
    - [3.12 Section Sign‑off Checklist](#312-section-signoff-checklist)
  - [Section 4: Non‑Functional Requirements](#section-4-nonfunctional-requirements)
    - [4.1 Performance {#41-performance}](#41-performance-41-performance)
      - [4.1.1 Purpose {#411-purpose}](#411-purpose-411-purpose)
      - [4.1.2 SLA Categories {#412-sla-categories}](#412-sla-categories-412-sla-categories)
      - [4.1.3 Stage‑Specific Targets {#413-stagespecific-targets}](#413-stagespecific-targets-413-stagespecific-targets)
      - [4.1.4 Measurement \& Reporting {#414-measurement--reporting}](#414-measurement--reporting-414-measurement--reporting)
      - [4.1.5 Enforcement {#415-enforcement}](#415-enforcement-415-enforcement)
      - [4.1.6 Change Control {#416-change-control}](#416-change-control-416-change-control)
    - [4.2 Reliability \& Availability](#42-reliability--availability)
    - [4.3 Security \& Privacy {#43-security--privacy}](#43-security--privacy-43-security--privacy)
      - [4.3.1 Purpose {#431-purpose}](#431-purpose-431-purpose)
      - [4.3.2 Security Principles {#432-security-principles}](#432-security-principles-432-security-principles)
      - [4.3.3 Privacy Principles {#433-privacy-principles}](#433-privacy-principles-433-privacy-principles)
      - [4.3.4 Authentication \& Access Control {#434-authentication--access-control}](#434-authentication--access-control-434-authentication--access-control)
      - [4.3.5 Data Security {#435-data-security}](#435-data-security-435-data-security)
      - [4.3.6 Logging \& Monitoring {#436-logging--monitoring}](#436-logging--monitoring-436-logging--monitoring)
      - [4.3.7 Incident Response {#437-incident-response}](#437-incident-response-437-incident-response)
      - [4.3.8 Compliance {#438-compliance}](#438-compliance-438-compliance)
      - [4.3.9 Validation \& Drift Control {#439-validation--drift-control}](#439-validation--drift-control-439-validation--drift-control)
      - [4.3.10 Change Control {#4310-change-control}](#4310-change-control-4310-change-control)
    - [4.4 Maintainability](#44-maintainability)
    - [4.5 Observability](#45-observability)
    - [4.6 Usability](#46-usability)
    - [4.7 Cost Constraints](#47-cost-constraints)
    - [4.8 Section Sign‑off Checklist](#48-section-signoff-checklist)
  - [Section 5: High‑Level Architecture](#section-5-highlevel-architecture)
    - [5.1 Architectural Layers {#51-architectural-layers}](#51-architectural-layers-51-architectural-layers)
      - [5.1.1 Purpose {#511-purpose}](#511-purpose-511-purpose)
      - [5.1.2 Layer Overview {#512-layer-overview}](#512-layer-overview-512-layer-overview)
      - [5.1.3 Data Flow Summary {#513-data-flow-summary}](#513-data-flow-summary-513-data-flow-summary)
      - [5.1.4 Validation \& Drift Control {#514-validation--drift-control}](#514-validation--drift-control-514-validation--drift-control)
      - [5.1.5 Change Control {#515-change-control}](#515-change-control-515-change-control)
    - [5.2 Data Flow Overview](#52-data-flow-overview)
    - [5.3 Deployment Topology](#53-deployment-topology)
    - [5.4 Key Design Decisions](#54-key-design-decisions)
    - [5.5 Section Sign‑off Checklist](#55-section-signoff-checklist)
  - [Section 6: Audio Pipeline Design](#section-6-audio-pipeline-design)
    - [6.1 Objectives](#61-objectives)
    - [6.2 Physical Audio Path](#62-physical-audio-path)
    - [6.3 Audio Server \& Routing](#63-audio-server--routing)
    - [6.4 Backup \& Recovery {#64-backup--recovery}](#64-backup--recovery-64-backup--recovery)
      - [6.4.1 Purpose {#641-purpose}](#641-purpose-641-purpose)
      - [6.4.2 Backup Scope {#642-backup-scope}](#642-backup-scope-642-backup-scope)
      - [6.4.3 Backup Types \& Frequency {#643-backup-types--frequency}](#643-backup-types--frequency-643-backup-types--frequency)
      - [6.4.4 Storage Targets {#644-storage-targets}](#644-storage-targets-644-storage-targets)
      - [6.4.5 Encryption \& Security {#645-encryption--security}](#645-encryption--security-645-encryption--security)
      - [6.4.6 Recovery Procedures {#646-recovery-procedures}](#646-recovery-procedures-646-recovery-procedures)
      - [6.4.7 Testing \& Validation {#647-testing--validation}](#647-testing--validation-647-testing--validation)
      - [6.4.8 Drift Control {#648-drift-control}](#648-drift-control-648-drift-control)
      - [6.4.9 Change Control {#649-change-control}](#649-change-control-649-change-control)
    - [6.5 Sample Rate \& Format](#65-sample-rate--format)
    - [6.6 Integration with ASR](#66-integration-with-asr)
    - [6.7 Guardrails](#67-guardrails)
    - [6.8 Testing \& Calibration](#68-testing--calibration)
    - [6.9 Section Sign‑off Checklist](#69-section-signoff-checklist)
  - [Section 7: Model Strategy](#section-7-model-strategy)
    - [7.1 Objectives](#71-objectives)
    - [7.2 ASR Model Strategy](#72-asr-model-strategy)
    - [7.3 NLP Model Strategy](#73-nlp-model-strategy)
    - [7.4 Model Registry \& Versioning](#74-model-registry--versioning)
    - [7.5 Resource Allocation](#75-resource-allocation)
    - [7.6 Guardrails](#76-guardrails)
    - [7.7 Section Sign‑off Checklist](#77-section-signoff-checklist)
  - [Section 8: Guardrails \& Observability](#section-8-guardrails--observability)
    - [8.1 Objectives](#81-objectives)
    - [8.2 Guardrails](#82-guardrails)
      - [8.2.1 Resource Protection {#821-resource-protection}](#821-resource-protection-821-resource-protection)
      - [8.2.2 Disk Space Management {#822-disk-space-management}](#822-disk-space-management-822-disk-space-management)
      - [8.2.3 ASR Continuity {#823-asr-continuity}](#823-asr-continuity-823-asr-continuity)
      - [8.2.4 Queue Health {#824-queue-health}](#824-queue-health-824-queue-health)
    - [8.3 Observability](#83-observability)
      - [8.3.1 Logging {#831-logging}](#831-logging-831-logging)
      - [8.3.2 Metrics {#832-metrics}](#832-metrics-832-metrics)
      - [8.3.3 Dashboards {#833-dashboards}](#833-dashboards-833-dashboards)
      - [8.3.4 Alerts {#834-alerts}](#834-alerts-834-alerts)
    - [8.4 Error Bundles](#84-error-bundles)
    - [8.5 Recovery Procedures](#85-recovery-procedures)
    - [8.6 Section Sign‑off Checklist](#86-section-signoff-checklist)
  - [Section 9: Deployment \& Environment Strategy](#section-9-deployment--environment-strategy)
    - [9.1 Objectives](#91-objectives)
    - [9.2 Runtime Profiles](#92-runtime-profiles)
    - [9.3 Environment Pinning (TBD)](#93-environment-pinning-tbd)
      - [9.3.1 Tested‑Good Environment Matrix](#931-testedgood-environment-matrix)
      - [9.3.2 Pinning Strategy](#932-pinning-strategy)
      - [9.3.3 Validation Commands](#933-validation-commands)
      - [9.3.4 Documentation](#934-documentation)
      - [9.3.5 Upgrade Policy](#935-upgrade-policy)
    - [9.4 Deployment Steps (Workstation‑Live)](#94-deployment-steps-workstationlive)
    - [9.5 Automation Hooks](#95-automation-hooks)
    - [9.6 Future Server Integration](#96-future-server-integration)
    - [9.7 Section Sign‑off Checklist](#97-section-signoff-checklist)
    - [9.8 Make Targets {#98-make-targets}](#98-make-targets-98-make-targets)
  - [Section 10: Burn‑In \& Validation Plan](#section-10-burnin--validation-plan)
    - [10.1 Burn‑In Overview {#101-burn-in-overview}](#101-burnin-overview-101-burn-in-overview)
      - [10.1.1 Purpose {#1011-purpose}](#1011-purpose-1011-purpose)
      - [10.1.2 Scope {#1012-scope}](#1012-scope-1012-scope)
      - [10.1.3 Burn‑In Environment {#1013-burn-in-environment}](#1013-burnin-environment-1013-burn-in-environment)
      - [10.1.4 Test Categories {#1014-test-categories}](#1014-test-categories-1014-test-categories)
      - [10.1.5 Duration \& Criteria {#1015-duration-criteria}](#1015-duration--criteria-1015-duration-criteria)
      - [10.1.6 Reporting {#1016-reporting}](#1016-reporting-1016-reporting)
      - [10.1.7 Promotion Workflow {#1017-promotion-workflow}](#1017-promotion-workflow-1017-promotion-workflow)
      - [10.1.8 Change Control {#1018-change-control}](#1018-change-control-1018-change-control)
    - [10.2 Burn‑In Test Plan {#102-burn-in-test-plan}](#102-burnin-test-plan-102-burn-in-test-plan)
      - [10.2.1 Purpose {#1021-purpose}](#1021-purpose-1021-purpose)
      - [10.2.2 Pre‑Test Requirements {#1022-pre-test-requirements}](#1022-pretest-requirements-1022-pre-test-requirements)
      - [10.2.3 Test Categories \& Cases {#1023-test-categories-cases}](#1023-test-categories--cases-1023-test-categories-cases)
        - [A. Functional Validation {#10231-functional}](#a-functional-validation-10231-functional)
        - [B. Performance Benchmarking {#10232-performance}](#b-performance-benchmarking-10232-performance)
        - [C. Stress \& Load Testing {#10233-stress-load}](#c-stress--load-testing-10233-stress-load)
        - [D. Compatibility Checks {#10234-compatibility}](#d-compatibility-checks-10234-compatibility)
        - [E. Drift Detection {#10235-drift-detection}](#e-drift-detection-10235-drift-detection)
      - [10.2.4 Tooling {#1024-tooling}](#1024-tooling-1024-tooling)
      - [10.2.5 Duration \& Monitoring {#1025-duration-monitoring}](#1025-duration--monitoring-1025-duration-monitoring)
      - [10.2.6 Pass/Fail Criteria {#1026-passfail-criteria}](#1026-passfail-criteria-1026-passfail-criteria)
      - [10.2.7 Reporting {#1027-reporting}](#1027-reporting-1027-reporting)
      - [10.2.8 Change Control {#1028-change-control}](#1028-change-control-1028-change-control)
    - [10.3 Test Categories](#103-test-categories)
      - [10.3.1 Functional Tests {#1031-functional-tests}](#1031-functional-tests-1031-functional-tests)
      - [10.3.2 Performance Tests {#1032-performance-tests}](#1032-performance-tests-1032-performance-tests)
      - [10.3.3 Stability Tests {#1033-stability-tests}](#1033-stability-tests-1033-stability-tests)
      - [10.3.4 Failover Tests {#1034-failover-tests}](#1034-failover-tests-1034-failover-tests)
    - [10.4 Metrics to Capture](#104-metrics-to-capture)
    - [10.5 Validation Commands](#105-validation-commands)
    - [10.6 Pass/Fail Criteria](#106-passfail-criteria)
    - [10.7 Documentation \& Sign‑off](#107-documentation--signoff)
    - [10.8 Section Sign‑off Checklist](#108-section-signoff-checklist)
    - [10.9 Promotion Checklist {#109-promotion-checklist}](#109-promotion-checklist-109-promotion-checklist)
  - [Section 11: Steady‑State Operations](#section-11-steadystate-operations)
    - [11.1 Objectives](#111-objectives)
    - [11.2 Daily Routine](#112-daily-routine)
    - [11.3 Weekly Routine](#113-weekly-routine)
    - [11.4 Monthly Routine](#114-monthly-routine)
    - [11.5 Monitoring \& Alerts](#115-monitoring--alerts)
    - [11.6 Minor Troubleshooting](#116-minor-troubleshooting)
    - [11.7 Documentation Updates {#117-documentation-updates}](#117-documentation-updates-117-documentation-updates)
      - [11.7.1 Purpose {#1171-purpose}](#1171-purpose-1171-purpose)
      - [11.7.2 Scope {#1172-scope}](#1172-scope-1172-scope)
      - [11.7.3 Required Artifacts {#1173-required-artifacts}](#1173-required-artifacts-1173-required-artifacts)
      - [11.7.4 Update Workflow {#1174-update-workflow}](#1174-update-workflow-1174-update-workflow)
      - [11.7.5 Storage \& Access {#1175-storage-access}](#1175-storage--access-1175-storage-access)
      - [11.7.6 Drift Control {#1176-drift-control}](#1176-drift-control-1176-drift-control)
      - [11.7.7 Change Control Linkage {#1177-change-control-linkage}](#1177-change-control-linkage-1177-change-control-linkage)
      - [11.7.8 Audit \& Compliance {#1178-audit-compliance}](#1178-audit--compliance-1178-audit-compliance)
      - [Spec File Delta Verification {#spec-file-deltaverification}](#spec-file-delta-verification-spec-file-deltaverification)
      - [Quick Prompt — Docs Update {#quick-prompt-docs-update}](#quick-prompt--docs-update-quick-prompt-docs-update)
  - [Appendix A – Meeting Assistant Build Script v1.0 Setup \& Configuration](#appendix-a--meeting-assistant-build-script-v10-setup--configuration)
    - [A.1 Purpose {#a1-purpose}](#a1-purpose-a1-purpose)
    - [A.2 Prerequisites {#a2-prerequisites}](#a2-prerequisites-a2-prerequisites)
    - [A.3 Script Location \& Permissions {#a3-script-location--permissions}](#a3-script-location--permissions-a3-script-location--permissions)
    - [A.4 Running the Script {#a4-running-the-script}](#a4-running-the-script-a4-running-the-script)
    - [A.5 What the Script Does {#a5-what-the-script-does}](#a5-what-the-script-does-a5-what-the-script-does)
    - [A.6 Configuration Files {#a6-configuration-files}](#a6-configuration-files-a6-configuration-files)
    - [A.7 Directory Layout After Build {#a7-directory-layout-after-build}](#a7-directory-layout-after-build-a7-directory-layout-after-build)
    - [A.8 Post‑Install Validation {#a8-post-install-validation}](#a8-postinstall-validation-a8-post-install-validation)
    - [A.9 Troubleshooting {#a9-troubleshooting}](#a9-troubleshooting-a9-troubleshooting)
    - [A.10 Component Test Scripts {#a10-component-test-scripts}](#a10-component-test-scripts-a10-component-test-scripts)
  - [Appendix B – Quick Validation via Makefile](#appendix-b--quick-validation-via-makefile)
    - [1. Create `/opt/meeting-assistant/tests/` and place the test scripts](#1-create-optmeeting-assistanttests-and-place-the-test-scripts)
    - [2. Create a Makefile in `/opt/meeting-assistant/tests/Makefile`](#2-create-a-makefile-in-optmeeting-assistanttestsmakefile)
    - [3. Run all tests](#3-run-all-tests)
  - [Appendix C — Baseline Verification (September 2025)](#appendix-c--baseline-verification-september2025)
    - [CPU](#cpu)
    - [GPU](#gpu)
    - [Storage](#storage)
    - [Audio Devices](#audio-devices)
    - [Network Interfaces](#network-interfaces)
  - [Appendix D — Documentation Conventions {#appendix-d--documentation-conventions}](#appendix-d--documentation-conventions-appendix-d--documentation-conventions)
  - [Appendix E — Feature Specification Guide {#appendix-e--feature-specification-guide}](#appendix-e--feature-specification-guide-appendix-e--feature-specification-guide)
  - [Appendix F — User Stories Template {#appendix-f--user-stories-template}](#appendix-f--user-stories-template-appendix-f--user-stories-template)
  - [Appendix G — Development Patterns \& Copilot Usage {#appendix-g--development-patterns--copilot-usage}](#appendix-g--development-patterns--copilot-usage-appendix-g--development-patterns--copilot-usage)
  - [Appendix H — AI Agent Design (Future) {#appendix-h--ai-agent-design-future}](#appendix-h--ai-agent-design-future-appendix-h--ai-agent-design-future)

## Section 1: System Overview

**Purpose:**  
A local‑only, private meeting assistant for work and personal use, running on Ubuntu 24.04 with AMD RX 7900 XTX, integrated with WorkMac for far‑end capture.

**Core Functions:**

- Dual‑channel audio capture (near‑end mic + far‑end WorkMac feed).
- Real‑time ASR with noise suppression, echo cancellation (AEC3), and VAD.
- Audience‑aware NLP summarization and action/decision extraction.
- Searchable archive with keyword, semantic, and decision filters.
- Calendar‑driven pre‑meeting context packets.

**Constraints:**

- No cloud processing of meeting content.
- Fully reproducible environments with documented configs.
- Maintainable by you or a future maintainer.

---

## Objectives and success criteria

- **Objective:** Accurate, low-latency transcription and reliable summaries without relying on paid SaaS.
- **Success metrics:**
  - **ASR latency:** p50 ≤ 1.5 s, p95 ≤ 2.5 s from spoken word to text segment.
  - **ASR quality:** ≥ 90% segments at confidence ≥ 0.85 on your domain audio.
  - **Echo suppression:** ≥ 20 dB measured via loopback test.
  - **Summary turnaround:** ≤ 60 s post-meeting for full brief (actions/decisions).
  - **Searchability:** Decision-only filter finds ≥ 95% of ground-truth decisions.
  - **Uptime:** No missed meetings due to calendar/capture failures over a 2-week burn-in.

---

## Non-goals

- **Non-goal:** Cloud transcription or external LLM summarization of meeting content.
- **Non-goal:** Organization-wide multi-tenant system (Phase 3+).
- **Non-goal:** Recording remote participant video or screen capture.

---

## Core features

- **Dual-channel capture:** WorkMac far-end → CM106 line-in; near-end mic via interface. Stable device naming and fixed gain staging.
- **Real-time ASR:** faster-whisper (CTranslate2) with quantization for low-latency, ROCm GPU-first on this workstation.
- **Audio processing:** RNNoise, AEC3 echo cancellation, WebRTC VAD, 48 kHz dual-mono.
- **Summarization:** Audience-aware prompts (Exec/Product/Technical), action/decision extraction, meeting timeline, highlights.
- **Calendar context:** Microsoft Graph API primary; .ics export automation fallback; pre-meeting context packets (T-10 min).
- **Search and archive:** File-based immutable transcripts with checksums; semantic + keyword index; namespace separation (work/personal).
- **Integrations:** Draft emails, Confluence/JIRA ticket drafts (dry-run + approval).

---

## Hardware and environment assumptions

- **Workstation:** Ubuntu 24.04.3 LTS (`noble`), AMD Ryzen 7 9700X (8C/16T),  
  - **Primary GPU:** AMD RX 7900 XTX (`gfx1100`, ROCm-enabled, pinned stack)  
  - **Integrated GPU:** AMD Granite Ridge (for fallback/diagnostics)  
  - Dual NVMe storage (1.8 TB + 931 GB), validated firmware, reproducible environments (containers/venv).  
- **WorkMac:** Primary conferencing endpoint; provides far-end audio via USB sound card → CM106 line-in; macOS Multi‑Output Device for simultaneous speakers + USB out.  
- **Audio device mapping:**  
  - CM106 USB Audio → line‑in capture for meeting assistant  
  - macOS Multi‑Output → local speakers + CM106 USB out  
- **Networking:** Local‑only; optional Tailscale for remote administration. No third‑party relays for meeting content.  
- **Storage:** NVMe‑only (scratch + primary data), nightly snapshot/backup.

---

### Prompt used to generate the recommendation

```bash
You are an expert systems engineer tasked with recommending both a “Stable” and “Newest” version for each component in the version‑agnostic Recommended Local‑Only, Open‑Source, ROCm‑on‑RDNA3 Stack.

Constraints:
- Do NOT use any internal manual, tested‑good matrix, or proprietary validation data as a source.
- Base recommendations only on publicly available release information, general compatibility knowledge, and known ROCm/RDNA3 support timelines.
- The environment is Ubuntu 24.04.3 LTS on AMD Ryzen 7 9700X + RX 7900 XTX (gfx1100).
- ROCm acceleration must work reliably on RDNA3 (gfx1100).
- All components must be open‑source and deployable locally.

Definitions:
- “Stable” = The most recent widely‑adopted version with a track record of reliability on Ubuntu 24.04.x and ROCm RDNA3, with no major unresolved issues in public bug trackers.
- “Newest” = The latest generally available release that meets the constraints above, even if it is relatively new and less field‑proven.

Instructions:
1. For each component in the version‑agnostic stack (ASR primary, ASR fallback, Audio Pre‑Processing, NLP, Indexing, Storage, Integration Layer, UI/Control):
   - Identify a Stable version based on public release history and ROCm RDNA3 compatibility.
   - Identify a Newest version based on the latest public release that meets the constraints.
   - If a component is CPU‑only or version‑agnostic, list “N/A” for Stable/Newest and note that it is not version‑pinned.
2. Include ROCm, kernel, and key library versions where applicable.
3. Output as a table with columns:
   Component Area | Candidate | Stable Version | Newest Version | Notes (including source of version info and any known risks)
4. After the table, provide a short narrative:
   - Summarize why each Stable version is considered production‑ready.
   - Summarize what’s new in each Newest version and any potential risks.
5. Do not reference or rely on any internal manual or proprietary validation data.
6. Ensure all recommendations are consistent with Ubuntu 24.04.3 LTS and AMD RX 7900 XTX ROCm RDNA3 compatibility.

Goal:
Produce a clear, public‑data‑driven recommendation table that can be used to pin both a Stable and a Newest tested configuration for each component in the stack, without relying on internal validation sources.
```

---

## Cost model and licensing

- **Software stack:** Open-source, local-first (PipeWire, RNNoise, WebRTC AEC/VAD, faster-whisper via CTranslate2, vector DB/library, web UI).
- **Recurring costs:** Optional low-cost email SMTP relay (<$10/mo) if desired; otherwise local MTA.
- **Licensing:** Respect OSS licenses; store explicit versions/checksums in a local model registry.

---

## Key decisions

| Area | Decision | Rationale | Implication |
|------|----------|-----------|-------------|
| ASR engine | faster-whisper (CTranslate2) | Highest throughput on GPU with quantization; simple packaging; deterministic | Run on GPU on this AMD workstation |
| Quantization | TBD | TBD | Tune per model; maintain per-meeting latency SLAs |
| Echo cancel | WebRTC AEC3 | Robust, well-documented behavior | Requires reliable near/far alignment; dedicate CPU core for AEC thread |
| Audio rate | 48 kHz dual-mono | Matches conferencing apps; better AEC convergence | Slightly higher CPU vs 16 kHz; better quality |
| Calendar | Graph API primary + .ics fallback | Reliability and metadata richness with resilient backup | Failover at 2 h of Graph failures; notifications at 30 min |
| Privacy | Local-only processing | Compliance and trust | No cloud transcription; integrations run in dry-run mode until manual approval |
| Archive | File-first + vector index | Simplicity, durability, easy restore | Keep JSONL + checksums; reindex on restore |
| Platform detection | Regex on join links | Works across Teams/Zoom/Meet/Slack | Manual tag when unknown |

---

## ASR plan with faster-whisper on this hardware

- **Why CPU-first here:** CTranslate2’s GPU acceleration is mature on NVIDIA CUDA; AMD ROCm support is not production-grade. To stay local and avoid cost, run faster-whisper on CPU with aggressive quantization and thread pinning.
- **Model sizing:**
  - **Live:** medium.en or small.en depending on meeting complexity; prefer small.en for tight latency on CPU.
  - **Archival/batch:** medium.en re-run for accuracy when idle; large-v3 only if latency allows during off-hours.
- **Quantization presets:**
  - **Live:** int8_float16 (balanced latency/quality).
  - **Batch:** int8 or int8_float16 depending on accuracy targets.
- **CPU tuning:**
  - **Threads:** Number of physical cores minus 2 (reserve for AEC and system).
  - **Affinity:** Pin AEC to an isolated core; pin ASR workers to a CPU set.
  - **I/O:** Use ring buffers; segment-based decoding with 10–15 s context windows.
- **Latency targets (estimates on modern desktop CPU):**
  - small.en int8_float16: ~0.5–1.2× realtime.
  - medium.en int8_float16: ~1.0–1.8× realtime.
- **Roadmap to GPU offload:** When the standalone server with NVIDIA A6000 comes online, move faster-whisper to CUDA with fp16 for 3–8× throughput, keeping live capture local and shipping audio segments over LAN to ASR.

---

## Risks and mitigations

- **Risk:** CPU-only ASR may spike latency in dense speech.  
  - **Mitigation:** Auto-scale to small.en during live spikes; defer medium.en pass to post-meeting.
- **Risk:** AEC misalignment causing echo artifacts.  
  - **Mitigation:** Enforce stable device naming; drift correction on WorkMac Multi-Output Device; record calibration snippet on start.
- **Risk:** Graph API auth lapses.  
  - **Mitigation:** Warning at 30 min failures; automatic .ics failover at 2 h; desktop notifications; single-command re-auth.
- **Risk:** Disk growth from raw audio and caches.  
  - **Mitigation:** Tiered retention (e.g., raw PCM 7–14 days, compressed long-term), cache GC, weekly size budget report.
- **Risk:** Model regressions after updates.  
  - **Mitigation:** Version-locked model registry; canary replay of last 5 meetings; rollback by symlink switch.

---

## Operability and maintainability

- **Reproducibility:** Pinned packages, container/venv manifests, scripts for first-run and burn-in.
- **Observability:** Structured logs with correlation IDs, metrics endpoints, error bundles on failures.
- **Docs:** System manual (this file), audio pipeline doc, burn-in plan, steady-state ops guide, hypercare quick refs.

---

## Interfaces and external dependencies

- **Inputs:** Dual audio streams (near/far), Calendar events (Graph/.ics), manual notes/agenda (optional).
- **Outputs:** Transcripts (JSONL + segments), summaries/actions/decisions (JSON/Markdown), search index artifacts, integration drafts.
- **External deps:** Microsoft Graph (auth + API rate limits within personal/work policy), local SMTP or minimal-cost email relay (optional).

---

## Section sign-off checklist

- **ASR engine chosen:** faster-whisper.
- **Privacy posture:** Local-only processing; no cloud LLM/ASR.
- **Calendar strategy:** Graph primary; .ics automated fallback with failover/notify thresholds.
- **Audio topology:** WorkMac → USB → CM106 (far) + mic interface (near); AEC3; RNNoise; VAD; 48 kHz.
- **Success metrics and SLAs:** Defined and testable during burn-in.
- **Cost envelope:** Open-source stack; optional <$10/mo relay; no required SaaS.

## Documentation Conventions {#documentation-conventions}

This manual follows consistent documentation standards to ensure stability, searchability, and low‑friction updates.

- Headings: Use sentence case; include stable explicit anchors on important headings, e.g., `### 10.1 Title {#101-title}`.
- Stable anchors: Prefer short, kebab‑case ids; avoid renaming anchors to preserve external links.
- Table of Contents: Keep ToC updated when adding/removing headings; verify link fragments work.
- Callouts: Use short sub‑headings (Note, Warning, Tip) — avoid blockquote boxes that break linters.
- Code fences: Always specify language (bash, json, yaml, python); keep commands idempotent and safe (dry‑run if destructive).
- Cross‑links: Reference related sections with `§` notation where helpful; prefer relative links to local docs.
- Adjacent docs:
  - Prompt library: [specs/docs/prompt-library.md](specs/docs/prompt-library.md)
  - Testing strategy: [specs/docs/testing-strategy.md](specs/docs/testing-strategy.md)

Sign‑off checklist for docs changes:

- [ ] Add/update heading with explicit `{#anchor}` when needed.
- [ ] Update ToC entries and verify link fragments.
- [ ] Cross‑link to prompts/tests as applicable.
- [ ] Commit with concise summary and affected sections.

## Section 2: Hardware & Environment Baseline

This section defines the physical and software environment in which the meeting assistant will operate. All specifications, constraints, and decisions are based on the actual hardware in use and the requirement to run locally with no recurring cost (except for optional minimal-cost services). It also includes a fallback build path for the reference Whisper implementation in case faster‑whisper encounters ROCm issues.

---

### §2.1 Environment Baseline {#21-environment-baseline}

The environment baseline defines the **canonical starting point** for all deployments, ensuring reproducibility, compatibility, and alignment with the project’s performance and maintainability goals.

#### Baseline Definition

The current validated baseline is:

- **Operating System**: Ubuntu 24.04.3 LTS (Noble Numbat)
- **Kernel**: Linux 6.14.x HWE (latest LTS)

This baseline is selected as the **Stable** recommendation in the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring) and is the reference point for all environment builds.

#### Rationale

- **Proven Stability**: 6.14.x HWE kernel has undergone extended soak time with no unresolved P1/P2 incidents in production.
- **Hardware Enablement**: Fully supports current AMD RDNA3 (gfx1100) hardware with ROCm 7.0.1.
- **Reproducibility**: Matches the validated `build-spec.env` baseline, ensuring consistent builds across environments.

#### Baseline Validation

All baseline components are validated against the **Data‑Based Decision‑Making Framework** in Section 1:

1. **Latency Fit**: Meets or beats p50/p95 SLA targets under expected concurrent load.
2. **Accuracy Fit**: Meets or exceeds ≥ 90% confidence target on representative workloads.
3. **Maintainability Fit**: Fully supported by upstream, with predictable patch cadence and no known integration blockers.

#### Change Control

- Any deviation from this baseline must be evaluated against the [Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring) and follow the promotion workflow in [Decision‑Making Guardrails](#decision-making-guardrails).
- Approved changes must be documented in `build-spec.env` and recorded in the ops log per [§11.7 Documentation Updates](#117-documentation-updates).

#### Drift Detection

- Monthly drift checks compare live environments against this baseline.
- Any drift triggers an automated spec‑check and, if unapproved, a rollback to the last validated state.

---

### 2.2 Secondary Systems

- **Dual-boot Windows:** For daily driver tasks, gaming, and Windows-only utilities; not used for meeting assistant runtime.
- **WorkMac:** Used for hosting/conducting meetings (Teams, Zoom, Google Meet, Slack).
  - Configured with macOS Multi-Output Device to send audio to both speakers and USB sound card simultaneously.
  - USB sound card output feeds CM106 line-in on Ubuntu workstation for far-end capture.

---

<!--
### 2.3 Future Expansion

- **Standalone AI Server:**
  - OS: Ubuntu LTS
  - GPU: NVIDIA RTX A6000 (48 GB VRAM) or equivalent
  - RAM: ≥ 128 GB ECC
  - Role: Multi-user, multi-device model serving; heavy summarization; archival reprocessing
  - Networking: LAN + optional Tailscale for secure remote access
  - Storage: NVMe tier for active workloads; large HDD/ZFS pool for archive
-->

### 2.4 Audio Path Topology

**Far-end (remote participants):**

- WorkMac conferencing app output → macOS Multi-Output Device → USB sound card → CM106 line‑in (Ubuntu)

**Near-end (local mic):**

- Microphone → USB audio interface → Ubuntu

**Processing:**

- PipeWire/WirePlumber manages both devices with persistent node names.
- RNNoise noise suppression on near-end.
- WebRTC AEC3 echo cancellation using far-end as reference.
- WebRTC VAD for speech segmentation.

---

### 2.5 Environment Configuration {#25-environment-configuration}

This section defines the **canonical environment configuration** for all deployments, anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring) and the [§2.1 Environment Baseline](#21-environment-baseline).  
It specifies the exact OS, kernel, GPU runtime, and supporting components required to ensure reproducibility, performance, and maintainability.

---

#### 1. Operating System & Kernel

- **OS**: Ubuntu 24.04.3 LTS (Noble Numbat) — Stable baseline.
- **Kernel**: Linux 6.14.x HWE (latest LTS) — Stable baseline.
- **Kernel Parameters**:
  - `amdgpu.ppfeaturemask=0xffffffff` — unlocks full power management features.
  - `pcie_aspm=off` — prevents link power management latency spikes.
  - `iommu=pt` — ensures predictable DMA mapping for GPU workloads.

---

#### 2. GPU Runtime & Drivers

- **ROCm Version**: 7.0.1 (Stable)  
  - Fully validated with AMD RDNA3 (gfx1100) hardware.
  - Matches `build-spec.env` baseline.
- **HIP Runtime**: Bundled with ROCm 7.0.1.
- **MIOpen**: ROCm‑optimized build, matching ROCm release.
- **rocBLAS**: ROCm‑optimized build, matching ROCm release.

---

#### 3. Core AI Runtime Components

- **Primary ASR**: faster-whisper + CTranslate2 (ROCm build).
- **Fallback ASR**: OpenAI Whisper (PyTorch ROCm build).
- **NLP/Summarization**: Transformers (ROCm build).
- **Indexing/Search**: FAISS (GPU ROCm build).

---

#### 4. Audio Pre‑Processing Stack

- **Noise Suppression**: RNNoise (CPU-only).
- **Echo Cancellation**: WebRTC AEC3
- **Voice Activity Detection**: WebRTC VAD

---

#### 5. Storage & Filesystem

- **Primary FS**: ZFS on Linux 2.2.0.
- **ARC Size**: Tuned to 50% of system RAM for AI workloads.
- **Compression**: `lz4` default; `zstd` for archival datasets.

---

#### 6. Integration Layer

- **Email Relay**: msmtp
- **UI/Control**: Streamlit / FastAPI.

---

#### 7. Validation & Drift Control

- All components are validated against:
  - **Latency Fit**: Meets SLA p50/p95 targets.
  - **Accuracy Fit**: ≥ 90% confidence on domain workloads.
  - **Maintainability Fit**: Meets reproducibility and supportability standards.
- Monthly drift checks compare live environment to `build-spec.env` and the [Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring).
- Any unapproved drift triggers rollback to last validated state.

---

#### 8. Change Control

- All upgrades must follow the [Promotion Workflow](#decision-making-guardrails).
- Approved changes are documented in:
  - `build-spec.env`
  - Ops log ([§11.7 Documentation Updates](#117-documentation-updates))
  - Change control register ([§13.5 Documentation Requirements](#135-documentation-requirements))

---

### 2.6 Storage Layout

| Tier | Purpose | Media | Size | Notes |
|------|---------|-------|------|-------|
| Tier 1 | OS, active workloads, scratch | NVMe SSD | ≥ 1 TB | High IOPS, low latency |
| Tier 2 (future) | Archive, backups | HDD/ZFS RAID | ≥ 8 TB usable | Redundancy (RAID-Z2 or RAID6) |
| Tier 3 (future) | Cold storage | External HDD or tape | Variable | Offsite rotation |

---

### 2.7 CPU/GPU Allocation

- **CPU:**
  - Reserve 1 physical core for AEC3 thread
  - Reserve 1 physical core for system tasks
  - Remaining cores allocated to NLP workers and any CPU-bound ASR fallback
- **GPU:**
  - Primary: faster‑whisper ROCm for ASR
  - Fallback: PyTorch ROCm Whisper
  - Keep GPU free for ASR during meetings; NLP runs on CPU unless idle

---

### 2.8 Networking & Security

- **LAN:** Gigabit Ethernet for low-latency audio and data transfer
- **Remote Access:** Optional Tailscale for secure admin access
- **Firewall:** UFW configured to allow only necessary ports (UI, SSH if enabled)
- **Segmentation:** Meeting assistant services isolated from general desktop environment

---

### 2.9 Cost Considerations

- **Hardware:** Existing workstation and WorkMac; no new purchases required for initial deployment
- **Software:** All open-source components; no recurring license fees
- **Optional Costs:** <$10/mo for SMTP relay if external email delivery is desired

---

### 2.10 Key Decisions

| Area | Decision | Rationale | Implication |
|------|----------|-----------|-------------|
| ASR engine | faster‑whisper ROCm | Best performance/stability on RDNA3 with ROCm | GPU-accelerated live transcription |
| Fallback ASR | Reference Whisper PyTorch ROCm | Simpler debug path if CTranslate2 ROCm fails | Higher latency, more VRAM use |
| Audio routing | Physical USB loop from WorkMac | Reliable, OS-independent, works across all conferencing apps | Requires stable cabling and device naming |
| Storage | Local scratch disk | Data integrity, daily snapshots, easy expansion | Not as much storage redundancy as ZFS |
| Networking | LAN-first, optional Tailscale | Low latency, secure remote admin | No dependency on public IP or port forwarding |

---

### 2.11 Section Sign‑off Checklist

- [x] Hardware inventory documented
- [x] Audio path topology defined
- [x] ROCm and kernel versions pinned
- [x] faster‑whisper ROCm primary path defined
- [x] Reference Whisper PyTorch ROCm fallback path defined
- [x] Storage tiers and retention policy defined
- [x] CPU/GPU allocation strategy set
- [x] Networking and security posture defined
- [x] Cost model confirmed

## Section 3: Functional Requirements

This section defines the functional capabilities the meeting assistant must deliver in its initial deployment on the Ubuntu 24.04 + AMD RX 7900 XTX workstation, with WorkMac far‑end capture. All requirements assume local‑only processing, GPU‑accelerated faster‑whisper via ROCm as the primary ASR engine, and no recurring costs beyond optional minimal‑cost services.

---

### 3.1 Audio Capture

- **Dual‑channel synchronous capture**:
  - Near‑end: Local microphone via dedicated USB audio interface.
  - Far‑end: WorkMac audio via USB sound card → CM106 line‑in.
- **Stable device naming**:
  - PipeWire/WirePlumber rules to ensure persistent node names across reboots.
- **Fixed gain staging**:
  - Calibrated input gain for both channels to prevent clipping and maintain AEC3 performance.
- **Sample rate**:
  - 48 kHz dual‑mono for optimal AEC convergence and compatibility with conferencing apps.

---

### 3.2 Audio Pre‑Processing {#32-audio-pre-processing}

This section defines the **validated audio pre‑processing stack** used in all deployments.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring) and the [§2.5 Environment Configuration](#25-environment-configuration).

---

#### 3.2.1 Purpose

Audio pre‑processing improves ASR accuracy and reduces latency by delivering cleaner, more consistent audio to the transcription pipeline.  
The stack is designed for **low‑latency, CPU‑friendly operation** so GPU resources remain dedicated to AI inference.

---

#### 3.2.2 Component Versions (Stable)

- **Noise Suppression**: RNNoise
  - CPU‑only, lightweight, and effective for broadband noise reduction.  
  - Chosen for stability and minimal CPU overhead.
- **Echo Cancellation**: WebRTC AEC3
  - Tuned for near‑end echo suppression in live meeting scenarios.  
  - Stable release with predictable convergence times.
- **Voice Activity Detection**: WebRTC VAD
  - Low‑latency speech detection to gate ASR processing.  
  - Stable release with no known regressions.

---

#### 3.2.3 Newest Candidate Versions as of September 2025

- **RNNoise** 2025‑03 — minor quality improvements; requires validation for CPU load impact.  
- **WebRTC AEC3** 1.4.x — improved convergence speed; verify against multi‑mic setups.  
- **WebRTC VAD** 2.0.11 — bugfix release; low‑risk upgrade.

Promotion of these versions follows the Decision‑Making Guardrails.

---

#### 3.2.4 Processing Order

1. **RNNoise** — broadband noise suppression.  
2. **WebRTC AEC3** — echo cancellation.  
3. **WebRTC VAD** — speech activity detection.

This order ensures noise and echo are removed before VAD gating, maximizing ASR accuracy.

---

#### 3.2.5 Integration with ASR

- Output from VAD is passed directly to the [§3.3 Automatic Speech Recognition (ASR)](#33-automatic-speech-recognition-asr) pipeline.  
- Latency budget for pre‑processing: ≤ 20 ms p95 per audio frame.

---

#### 3.2.6 Validation & Drift Control

- Monthly drift checks confirm component versions match `build-spec.env`.  
- Any deviation triggers an automated spec‑check and rollback if unapproved.  
- Performance metrics logged:
  - **Noise Reduction (dB)** — target ≥ 15 dB.  
  - **Echo Return Loss Enhancement (ERLE)** — target ≥ 20 dB.  
  - **VAD Accuracy** — target ≥ 95% speech/non‑speech classification accuracy.

---

#### 3.2.7 Change Control

- All upgrades must:
  - Pass burn‑in testing ([§10](#section-10-burnin--validation-plan)).  
  - Meet or exceed SLA targets in [§4.1 Performance](#41-performance).  
  - Be documented in `build-spec.env` and the ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

### 3.3 Hardware Audio Setup & Verification {#33-hardware-audio-setup-verification}

This section provides a step-by-step guide for setting up and verifying the hardware audio path on the Ubuntu workstation, ensuring both near-end (mic) and far-end (WorkMac) feeds are present and clean before starting the meeting assistant services.

**Purpose:**

- Confirm physical and logical audio routing is correct.
- Enable live monitoring of both audio feeds via headphones (secondary display output).
- Provide a reusable workflow for troubleshooting and future validation.

#### 3.3.1 Prerequisites

- PipeWire and WirePlumber are installed and running (default on Ubuntu 24.04+).
- Helvum (visual patchbay) is installed: `sudo apt install helvum`
- Headphones are plugged into the desired output (e.g., secondary display audio jack).

#### 3.3.2 Identify Audio Devices

List all audio sources and sinks:

```bash
pw-cli ls Node | grep -E 'alsa_input|alsa_output'
```

- Look for:
  - `alsa_input.usb-CM106` (far-end, WorkMac feed)
  - `alsa_input.usb-FIFINE` (near-end mic)
  - `alsa_output.*` (find your headphones, e.g., HDMI/DisplayPort output)

If unsure which is which, unplug/replug devices and re-run the command to see which node appears/disappears.

#### 3.3.3 Launch Helvum for Visual Routing

```bash
helvum &
```

- In the Helvum window, you’ll see all input and output nodes.
- Drag from each input (CM106, FIFINE) to your headphones output node.
- You can monitor both feeds live in your headphones.

#### 3.3.4 Optional: Record a Short Sample from Each Input

To record 5 seconds from the far-end (CM106):

```bash
pw-cat --record --target "alsa_input.usb-CM106..." --duration 5 far_end_test.wav
```

To record 5 seconds from the near-end (FIFINE):

```bash
pw-cat --record --target "alsa_input.usb-FIFINE..." --duration 5 near_end_test.wav
```

Play back to verify:

```bash
pw-cat --play far_end_test.wav
pw-cat --play near_end_test.wav
```

#### 3.3.5 Troubleshooting

- If you don’t hear audio, check device selection in Helvum and ensure headphones are set as the default output in system sound settings.
- Use `pw-cli ls Node` to confirm device presence.
- For advanced troubleshooting, use `pavucontrol` (PulseAudio-compatible) for per-app routing.

#### 3.3.6 Clean Up

- Disconnect routes in Helvum when done.
- Close Helvum.

**Why this approach?**

- Helvum provides a clear, visual way to confirm and adjust routing, ideal for one-time setup and troubleshooting.
- CLI tools (`pw-cat`, `pw-cli`) are included for scripting, automation, or remote/SSH use.
- This method is modular and can be reused for future troubleshooting or validation.

---

## 3.4 Automatic Speech Recognition (ASR) {#34-automatic-speech-recognition-asr}

This section defines the **validated ASR stack** for all deployments.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring), the [§2.5 Environment Configuration](#25-environment-configuration), and the [§3.2 Audio Pre‑Processing](#32-audio-pre-processing) stage.

---

#### 3.4.1 Purpose {#341-purpose}

The ASR stage converts pre‑processed audio into text with high accuracy and low latency.  
It is optimized for **ROCm‑on‑RDNA3** hardware and designed to support both real‑time and batch transcription workflows.

---

#### 3.4.2 Component Versions (TBD Stable) {#342-component-versions-tbd-stable}

- **Primary ASR**: faster-whisper + CTranslate2 (ROCm build).
- **Fallback ASR**: OpenAI Whisper (PyTorch ROCm build).

---

#### 3.4.3 Newest Candidate Versions (TBD) {#343-newest-candidate-versions-tbd}

#### 3.4.4 Processing Flow {#344-processing-flow}

1. Receive gated audio from [§3.2 Audio Pre‑Processing](#32-audio-pre-processing).  
2. Perform transcription using **Primary ASR**.  
3. If Primary fails or model is unavailable, route to **Fallback ASR**.  
4. Pass transcripts to [§3.4 NLP](#34-nlp) for summarization and downstream processing.

---

#### 3.4.5 Model Management {#345-model-management}

- **Model Storage**: All ASR models stored in `/opt/asr-models` with versioned directories.  
- **Checksum Validation**: SHA‑256 checksums verified at load time to prevent drift.  
- **Quantization**: INT8 or FP16 models used where latency budgets require; FP32 retained for highest‑accuracy offline jobs.

---

#### 3.4.6 Performance Targets {#346-performance-targets}

- **Latency**: ≤ 300 ms p95 for real‑time streaming segments.  
- **Accuracy**: ≥ 90% word‑level accuracy on domain‑specific test sets.  
- **Resource Utilization**: GPU VRAM usage ≤ 80% of available capacity during peak load.

---

#### 3.4.7 Validation & Drift Control {#347-validation--drift-control}

- Monthly drift checks confirm ASR component versions match `build-spec.env`.  
- Any deviation triggers automated spec‑check and rollback if unapproved.  
- Burn‑in tests ([§10](#section-10-burnin--validation-plan)) required for all upgrades.

---

#### 3.4.8 Change Control {#348-change-control}

- All upgrades must:
  - Pass burn‑in testing ([§10](#section-10-burnin--validation-plan)).  
  - Meet or exceed SLA targets in [§4.1 Performance](#41-performance).  
  - Be documented in `build-spec.env` and the ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

### 3.5 NLP {#35-nlp}

This section defines the **validated Natural Language Processing (NLP) stack** for all deployments.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring), the [§2.5 Environment Configuration](#25-environment- [§3.3 Automatic Speech Recognition (ASR)](#33-automatic-speech-recognition-asr) stage.

---

#### 3.5.1 Purpose {#351-purpose}

The NLP stage transforms raw ASR transcripts into structured, context‑aware outputs such as summaries, action items, and searchable metadata.  
It is optimized for **low‑latency inference** while preserving semantic accuracy.

---

#### 3.5.2 Component Versions (Stable) {#352-component-versions-stable}

- **Transformers Library**: Hugging Face Transformers
  - Selected for stability, broad model compatibility, and reproducible builds.  
  - Supports both encoder‑decoder and decoder‑only architectures.
- **Tokenizer**: Matching version from Transformers library.
- **Model Types**:
  - **Summarization**: BART‑large or Pegasus variants fine‑tuned on meeting data.
  - **Entity Extraction**: RoBERTa‑base or DistilBERT fine‑tuned for NER.

---

#### 3.5.3 Newest Candidate Versions as of 2024-02-15 {#353-newest-candidate-versions}

- **Transformers** 4.58.0 — includes model hub updates and performance optimizations.  
- Promotion requires passing [§10 Burn‑In](#section-10-burnin--validation-plan) and meeting [Decision‑Making Guardrails](#decision-making-guardrails).

---

#### 3.5.4 Processing Flow {#354-processing-flow}

1. Receive transcript text from [§3.3 ASR](#33-automatic-speech-recognition-asr).  
2. Apply domain‑specific cleaning and normalization.  
3. Run summarization model to produce concise meeting summaries.  
4. Run entity extraction to identify participants, dates, topics, and action items.  
5. Output structured JSON for downstream indexing ([§3.6 Search & Retrieval](#36-search--retrieval-36-search--retrieval)).

---

#### 3.5.5 Model Management {#355-model-management}

- **Storage**: All NLP models stored in `/opt/nlp-models` with versioned directories.  
- **Checksum Validation**: SHA‑256 checksums verified at load time.  
- **Fine‑Tuning**: Models fine‑tuned on internal datasets are version‑controlled and documented in the model registry.

---

#### 3.5.6 Performance Targets {#356-performance-targets}

- **Latency**: ≤ 500 ms p95 for summarization of a 1‑minute transcript segment.  
- **Accuracy**: ≥ 90% ROUGE‑L score for summaries on validation set.  
- **Entity Extraction F1**: ≥ 0.90 on domain‑specific NER test set.

---

#### 3.5.7 Validation & Drift Control {#357-validation--drift-control}

- Monthly drift checks confirm NLP component versions match `build-spec.env`.  
- Any deviation triggers automated spec‑check and rollback if unapproved.  
- Burn‑in tests ([§10](#section-10-burnin--validation-plan)) required for all upgrades.

---

#### 3.5.8 Change Control {#358-change-control}

- All upgrades must:
  - Pass burn‑in testing ([§10](#section-10-burnin--validation-plan)).  
  - Meet or exceed SLA targets in [§4.1 Performance](#41-performance).  
  - Be documented in `build-spec.env` and the ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

### 3.6 Storage & Archival {#36-storage--archival}

This section defines the **validated storage and archival stack** for all deployments.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring) and the [§2.5 Environment Configuration](#25-environment-configuration).

---

#### 3.6.1 Purpose {#361-purpose}

The storage and archival layer ensures **data integrity, high availability, and reproducibility** for AI workloads, meeting both performance and compliance requirements.  
It is optimized for **low‑latency read/write** during active sessions and **cost‑efficient long‑term retention**.

---

#### 3.6.2 Component Versions (Stable) {#362-component-versions-stable}

- **Filesystem**: ZFS on Linux 2.2.0  
  - Chosen for its robust snapshotting, checksumming, and compression capabilities.  
  - Tuned for AI workload patterns and large sequential I/O.
- **Compression**: `lz4` for active datasets; `zstd` for archival datasets.  
- **ARC Size**: 50% of system RAM for optimal caching without starving AI inference.

---

#### 3.6.3 Newest Candidate Versions {#363-newest-candidate-versions}

- **ZFS** 2.2.2 — includes bugfixes for encryption and ARC behavior.  
  - Low‑risk upgrade; requires validation for compatibility with current kernel and ROCm stack.

Promotion of this version follows the [Decision‑Making Guardrails](#decision-making-guardrails).

---

#### 3.6.4 Storage Layout {#364-storage-layout}

- **Primary Pool**: `ai-pool` — houses active AI models, datasets, and logs.  
- **Archive Pool**: `archive-pool` — stores snapshots, backups, and long‑term datasets.  
- **Dataset Structure**:
  - `/ai-pool/models` — versioned AI models.  
  - `/ai-pool/data` — active datasets.  
  - `/archive-pool/snapshots` — ZFS snapshots for rollback and reproducibility.  
  - `/archive-pool/backups` — offsite‑ready encrypted backups.

---

#### 3.6.5 Snapshot & Retention Policy {#365-snapshot--retention-policy}

- **Active Pool**: Hourly snapshots retained for 48 hours; daily snapshots retained for 14 days.  
- **Archive Pool**: Weekly snapshots retained for 6 months; monthly snapshots retained for 2 years.  
- **Offsite Sync**: Encrypted replication to secondary storage per [§6.4 Backup & Recovery](#64-backup--recovery-64-backup--recovery).

---

#### 3.6.6 Validation & Drift Control {#366-validation--drift-control}

- Monthly drift checks confirm ZFS version and pool configuration match `build-spec.env`.  
- Any deviation triggers automated spec‑check and rollback if unapproved.  
- Integrity checks:
  - `zpool scrub` run weekly on active pool; monthly on archive pool.  
  - All errors logged and reviewed per [§12.4 Incident Response Workflow](#124-incident-response-workflow).

---

#### 3.6.7 Performance Targets {#367-performance-targets}



- **Read Latency**: ≤ 5 ms p95 for active datasets.  
- **Write Latency**: ≤ 10 ms p95 for active datasets.  
- **Snapshot Creation**: ≤ 1 s for active dataset volumes.

---

#### 3.6.8 Change Control {#368-change-control}

- All upgrades must:
  - Pass burn‑in testing ([§10](#section-10-burnin--validation-plan)).  
  - Meet or exceed SLA targets in [§4.1 Performance](#41-performance).  
  - Be documented in `build-spec.env` and the ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

### 3.7 Search & Retrieval {#37-search--retrieval}

This section defines the **validated search and retrieval stack** for all deployments.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring), the [§2.5 Environment Configuration](#25-environment-configuration), and the [§3.4 NLP](#34-nlp) stage.

---

#### 3.7.1 Purpose {#371-purpose}

The search and retrieval layer enables **fast, accurate access** to structured and unstructured meeting data.  
It is optimized for **GPU‑accelerated vector search** to support semantic queries, summarization look‑ups, and contextual augmentation for downstream AI tasks.

---

#### 3.7.2 Component Versions (TBDStable) {#372-component-versions-stable}

- **Vector Index Engine**: FAISS (GPU ROCm build)  
  - Selected for its mature ROCm support, high‑performance similarity search, and reproducibility.  
  - Tuned for mixed‑precision search to balance speed and recall.

---

#### 3.7.3 Newest Candidate Versions (TBD) {#373-newest-candidate-versions}

Promotion of this version follows the [Decision‑Making Guardrails](#decision-making-guardrails).

---

#### 3.7.4 Processing Flow {#374-processing-flow}

1. Receive structured JSON output from [§3.4 NLP](#34-nlp).  
2. Convert text embeddings using domain‑specific Transformer models.  
3. Store embeddings in FAISS GPU index for fast retrieval.  
4. Serve queries via API to UI/Control layer ([§5.1 Architectural Layers](#51-architectural-layers)).

---

#### 3.7.5 Index Configuration {#375-index-configuration}

- **Index Type**: IVF‑PQ (Inverted File with Product Quantization) for large‑scale datasets.  
- **Metric**: Cosine similarity for semantic search.  
- **Shard Strategy**: Single‑GPU index for ≤ 10M vectors; multi‑GPU sharding for larger datasets.  
- **Persistence**: Index snapshots stored in `/ai-pool/indexes` with versioned directories.

---

#### 3.7.6 Performance Targets {#376-performance-targets}

- **Query Latency**: ≤ 50 ms p95 for top‑10 nearest neighbor search.  
- **Recall**: ≥ 0.95 on validation queries.  
- **Index Build Time**: ≤ 2 hours for 10M vectors on RDNA3 GPU.

---

#### 3.7.7 Validation & Drift Control {#377-validation--drift-control}

- Monthly drift checks confirm FAISS version and index configuration match `build-spec.env`.  
- Any deviation triggers automated spec‑check and rollback if unapproved.  
- Burn‑in tests ([§10](#section-10-burnin--validation-plan)) required for all upgrades.

---

#### 3.7.8 Change Control {#378-change-control}

- All upgrades must:
  - Pass burn‑in testing ([§10](#section-10-burnin--validation-plan)).  
  - Meet or exceed SLA targets in [§4.1 Performance](#41-performance).  
  - Be documented in `build-spec.env` and the ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

### 3.8 Calendar Integration {#38-calendar-integration}

This section defines the **validated calendar integration stack** for all deployments.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring) and the [§2.5 Environment Configuration](#25-environment-configuration).

---

#### 3.8.1 Purpose {#381-purpose}

Calendar integration enables the AI meeting assistant to **automatically schedule, join, and summarize meetings** by interfacing with user calendars.  
It is designed for **secure, low‑latency message delivery** without introducing external dependencies that could compromise reproducibility.

---

#### 3.8.2 Component Versions (TBD Stable) {#382-component-versions-stable}

- **Email Relay**: msmtp  
  - Lightweight SMTP client used for sending meeting invites, reminders, and summaries.  
  - Chosen for its simplicity, reproducibility, and compatibility with multiple mail providers.

---

#### 3.8.3 Newest Candidate Versions (TBD) {#383-newest-candidate-versions}

  - Promotion requires passing [§10 Burn‑In](#section-10-burnin--validation-plan) and meeting [Decision‑Making Guardrails](#decision-making-guardrails).

---

#### 3.8.4 Integration Flow {#384-integration-flow}

1. Meeting events are created or updated in the calendar system (Google Workspace, Microsoft 365, etc.).  
2. The AI assistant detects relevant events via secure API polling or webhook triggers.  
3. msmtp sends:
   - Meeting reminders to participants.  
   - Post‑meeting summaries generated by [§3.4 NLP](#34-nlp).  
4. All outbound messages are logged for audit and troubleshooting.

---

#### 3.8.5 Security & Privacy {#385-security--privacy}

- **Authentication**: OAuth 2.0 or application‑specific passwords stored in encrypted secrets vault.  
- **Transport Security**: TLS enforced for all SMTP connections.  
- **Data Minimization**: Only meeting metadata and summary content are transmitted; no raw audio is sent via email.

---

#### 3.8.6 Validation & Drift Control {#386-validation--drift-control}

- Monthly drift checks confirm msmtp version and configuration match `build-spec.env`.  
- Any deviation triggers automated spec‑check and rollback if unapproved.  
- Test emails sent weekly to verify delivery and formatting.

---

#### 3.8.7 Performance Targets {#387-performance-targets}

- **Email Delivery Latency**: ≤ 5 s p95 from trigger to SMTP handoff.  
- **Delivery Success Rate**: ≥ 99.9% over rolling 30‑day window.

---

#### 3.8.8 Change Control {#388-change-control}

- All upgrades must:
  - Pass burn‑in testing ([§10](#section-10-burnin--validation-plan)).  
  - Meet or exceed SLA targets in [§4.1 Performance](#41-performance).  
  - Be documented in `build-spec.env` and the ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

### 3.9 Integrations {#39-integrations}

This section defines the **validated external integration stack** for all deployments.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring) and the [§2.5 Environment Configuration](#25-environment-configuration).

---

#### 3.9.1 Purpose {#391-purpose}

Integrations extend the AI meeting assistant’s capabilities by connecting it to **external systems and services** while preserving the project’s reproducibility, security, and maintainability standards.  
All integrations must be **version‑locked**, **documented**, and **drift‑controlled**.

---

#### 3.9.2 Integration Categories {#392-integration-categories}

- **Communication**: Email relay ([§3.7 Calendar Integration](#37-calendar-integration)), chat platforms, and notification services.
- **Scheduling**: Calendar APIs (Google Workspace, Microsoft 365, CalDAV).
- **Data Sources**: Internal knowledge bases, document repositories, and meeting archives.
- **Task Management**: Jira, Trello, or other ticketing systems for action item tracking.

---

#### 3.9.3 Component Versions (Stable) {#393-component-versions-stable}

- **Email Relay**: msmtp 1.8.24 (see [§3.7](#37-calendar-integration)).  
- **Calendar API Clients**:  
  - Google API Python Client 2.129.0  
  - Microsoft Graph Python SDK 1.14.0  
- **Chat Integrations**:  
  - Slack SDK 3.27.1  
  - Microsoft Teams Bot Framework SDK 4.19.3

---

#### 3.9.4 Newest Candidate Versions {#394-newest-candidate-versions}

- **msmtp** 1.8.25 — minor bugfix release.  
- **Google API Python Client** 2.131.0 — incremental updates; verify OAuth flow stability.  
- **Microsoft Graph Python SDK** 1.15.0 — minor API coverage expansion.  
- **Slack SDK** 3.28.0 — bugfixes and performance improvements.  
- **Bot Framework SDK** 4.20.0 — updated Teams API support.

Promotion of these versions follows the [Decision‑Making Guardrails](#decision-making-guardrails).

---

#### 3.9.5 Integration Flow {#395-integration-flow}

1. **Trigger**: Event detected in external system (calendar update, chat command, document upload).  
2. **Ingestion**: Secure API call to retrieve relevant data.  
3. **Processing**: Data passed through NLP ([§3.4](#34-nlp)) and indexing ([§3.6](#36-search--retrieval-36-search--retrieval)) pipelines.  
4. **Action**: Output sent to appropriate channel (email, chat, task tracker).

---

#### 3.9.6 Security & Privacy {#396-security--privacy}

- **Authentication**: OAuth 2.0 or signed JWTs; credentials stored in encrypted secrets vault.  
- **Transport Security**: TLS enforced for all API calls.  
- **Scope Minimization**: API tokens restricted to least‑privilege scopes.

---

#### 3.9.7 Validation & Drift Control {#397-validation--drift-control}

- Monthly drift checks confirm integration component versions match `build-spec.env`.  
- Any deviation triggers automated spec‑check and rollback if unapproved.  
- Weekly integration tests verify API connectivity, authentication, and data flow.

---

#### 3.9.8 Performance Targets {#398-performance-targets}

- **API Call Latency**: ≤ 500 ms p95 for external requests.  
- **Integration Uptime**: ≥ 99.9% over rolling 30‑day window.

---

#### 3.9.9 Change Control {#399-change-control}

- All upgrades must:
  - Pass burn‑in testing ([§10](#section-10-burnin--validation-plan)).  
  - Meet or exceed SLA targets in [§4.1 Performance](#41-performance).  
  - Be documented in `build-spec.env` and the ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

### 3.10 Learning & Adaptation

- **Feedback capture**:
  - User ratings on summaries and action items.
- **Adaptive prompts**:
  - Modify summarization prompts based on feedback trends.
- **Model performance tracking**:
  - Maintain win‑rate stats for model selection.

---

### 3.11 Guardrails

- **Resource protection**:
  - Pause non‑critical jobs if GPU load > 85% during live ASR.
- **Disk space alerts**:
  - Trigger cleanup or alert at < 10% free space.
- **Job queue health**:
  - Monitor for stuck or failed jobs; retry or move to DLQ.

---

### 3.12 Section Sign‑off Checklist

- [x] Dual‑channel capture defined with stable device naming.
- [x] Pre‑processing chain (RNNoise, AEC3, VAD) specified.
- [x] ASR engines (primary/fallback) and latency/accuracy targets set.
- [x] NLP outputs and adaptive selection defined.
- [x] Storage format, retention, and indexing specified.
- [x] Search modes and performance targets defined.
- [x] Calendar integration with failover defined.
- [x] Integration outputs and approval workflow defined.
- [x] Learning/adaptation loop defined.
- [x] Guardrails for resource and queue health defined.

## Section 4: Non‑Functional Requirements

This section defines the non‑functional (quality) attributes the meeting assistant must meet to be considered production‑ready on the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture. These requirements ensure the system is performant, reliable, secure, maintainable, and usable under the constraints of local‑only operation and minimal recurring cost.

---

### 4.1 Performance {#41-performance}

This section defines the **Service Level Agreement (SLA) performance targets** for all components and pipelines in the AI meeting assistant system.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring) and validated during [§10 Burn‑In & Validation](#section-10-burnin--validation-plan).

---

#### 4.1.1 Purpose {#411-purpose}

To ensure **predictable, measurable performance** across latency, accuracy, and maintainability dimensions, enabling reproducible deployments and consistent user experience.

---

#### 4.1.2 SLA Categories {#412-sla-categories}

| Metric Category | Definition | Target | Measurement Method | Cross‑Refs |
|-----------------|------------|--------|--------------------|------------|
| **Latency (p50/p95)** | Time from input to output at each pipeline stage. | Stage‑specific targets (see below). | Synthetic load tests + live meeting sampling. | [§3.2](#32-audio-pre-processing) → [§3.6](#36-search--retrieval-36-search--retrieval) |
| **Accuracy** | Quality of output vs. ground truth. | Stage‑specific targets (see below). | Domain‑specific validation datasets. | [§3.3](#33-automatic-speech-recognition-asr), [§3.4](#34-nlp) |
| **Maintainability** | Ease of upgrade, rollback, and drift control. | ≥ 4.0 Maintainability Fit score. | Spec‑check + upgrade simulation. | [§2.5](#25-environment-configuration) |

---

#### 4.1.3 Stage‑Specific Targets {#413-stagespecific-targets}

**Audio Pre‑Processing ([§3.2](#32-audio-pre-processing))**  

- Latency: ≤ 20 ms p95 per audio frame.  
- Noise Reduction: ≥ 15 dB.  
- Echo Return Loss Enhancement (ERLE): ≥ 20 dB.  
- VAD Accuracy: ≥ 95% speech/non‑speech classification.

**ASR ([§3.3](#33-automatic-speech-recognition-asr))**  

- Latency: ≤ 300 ms p95 for real‑time streaming segments.  
- Accuracy: ≥ 90% word‑level accuracy on domain test set.  
- GPU VRAM Usage: ≤ 80% of available capacity.

**NLP ([§3.4](#34-nlp))**  

- Latency: ≤ 500 ms p95 for summarization of a 1‑minute transcript segment.  
- ROUGE‑L Score: ≥ 0.90 on validation set.  
- Entity Extraction F1: ≥ 0.90.

**Search & Retrieval ([§3.6](#36-search--retrieval-36-search--retrieval))**  

- Query Latency: ≤ 50 ms p95 for top‑10 nearest neighbor search.  
- Recall: ≥ 0.95 on validation queries.  
- Index Build Time: ≤ 2 hours for 10M vectors.

**Storage & Archival ([§3.5](#35-storage--archival-35-storage--archival))**  

- Read Latency: ≤ 5 ms p95.  
- Write Latency: ≤ 10 ms p95.  
- Snapshot Creation: ≤ 1 s for active dataset volumes.

**Integration & Presentation ([§3.7](#37-calendar-integration), [§3.8](#38-integrations))**  

- Email Delivery Latency: ≤ 5 s p95 from trigger to SMTP handoff.  
- API Call Latency: ≤ 500 ms p95.  
- Delivery Success Rate: ≥ 99.9% over rolling 30‑day window.

---

#### 4.1.4 Measurement & Reporting {#414-measurement--reporting}

- **Measurement Frequency**:  
  - Latency & Accuracy: Weekly synthetic + live sampling.  
  - Maintainability: Monthly drift checks + upgrade simulations.
- **Reporting**:  
  - SLA compliance reports stored in `/var/log/ai-assistant/performance/`.  
  - Monthly summary posted to ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

#### 4.1.5 Enforcement {#415-enforcement}

- Any SLA breach triggers:
  1. Incident creation ([§12.4 Incident Response Workflow](#124-incident-response-workflow)).  
  2. Root cause analysis within 48 hours.  
  3. Remediation plan with rollback or patch.

---

#### 4.1.6 Change Control {#416-change-control}

- SLA targets may only be modified after:
  - Review of ≥ 3 months of performance data.  
  - Approval from architecture lead.  
  - Documentation update in both this section and Section 1 scoring framework.

---

### 4.2 Reliability & Availability

- **Uptime target**:
  - ≥ 99% availability during scheduled meeting hours.
- **Failover**:
  - Automatic switch to fallback ASR (PyTorch ROCm Whisper) if faster‑whisper ROCm fails mid‑meeting.
- **Recovery**:
  - Resume transcription within 10 s of ASR restart.
- **Data durability**:
  - No loss of processed transcripts or summaries after commit to archive.
- **Calendar sync resilience**:
  - Failover to `.ics` import within 2 h of Graph API outage.

---

### 4.3 Security & Privacy {#43-security--privacy}

This section defines the **security and privacy controls** for the AI meeting assistant system.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring), the [§2.5 Environment Configuration](#25-environment-configuration), and the integration layers in [§3.7](#37-calendar-integration) and [§3.8](#38-integrations).

---

#### 4.3.1 Purpose {#431-purpose}

To ensure **confidentiality, integrity, and availability** of all system data and communications, while meeting compliance requirements and protecting user privacy.

---

#### 4.3.2 Security Principles {#432-security-principles}

- **Least Privilege**: All services and accounts operate with the minimum permissions required.  
- **Defense in Depth**: Multiple layers of security controls protect against compromise.  
- **Secure by Default**: Default configurations favor security over convenience.  
- **Auditability**: All security‑relevant events are logged and reviewable.

---

#### 4.3.3 Privacy Principles {#433-privacy-principles}

- **Data Minimization**: Only collect and store data strictly necessary for operation.  
- **Purpose Limitation**: Data is used solely for meeting assistant functions.  
- **User Control**: Users can request deletion of their data per [§6.4 Backup & Recovery](#64-backup--recovery-64-backup--recovery) and applicable policies.  
- **Transparency**: All data flows are documented in [§11.7 Documentation Updates](#117-documentation-updates).

---

#### 4.3.4 Authentication & Access Control {#434-authentication--access-control}

- **Authentication Methods**:
  - OAuth 2.0 for external API integrations.
  - SSH key‑based authentication for administrative access.
- **Access Control**:
  - Role‑based access control (RBAC) enforced at application and infrastructure layers.
  - Secrets stored in encrypted vault with access logging.

---

#### 4.3.5 Data Security {#435-data-security}

- **In Transit**: TLS 1.3 enforced for all network communications.  
- **At Rest**: ZFS native encryption for sensitive datasets ([§3.5 Storage & Archival](#35-storage--archival)).  
- **Key Management**: Keys rotated quarterly; stored in hardware security module (HSM) where available.

---

#### 4.3.6 Logging & Monitoring {#436-logging--monitoring}

- **Security Logs**: Authentication attempts, privilege escalations, and configuration changes.  
- **Privacy Logs**: Data access events tied to user identifiers.  
- **Retention**: Logs retained for 12 months in secure, append‑only storage.  
- **Alerting**: Real‑time alerts for high‑severity events via integration layer ([§3.8](#38-integrations)).

---

#### 4.3.7 Incident Response {#437-incident-response}

- All incidents follow the [§12.4 Incident Response Workflow](#124-incident-response-workflow).  
  - Critical incidents require:
  - Containment within 1 hour.
  - Root cause analysis within 48 hours.
  - Remediation plan documented and approved.

---

#### 4.3.8 Compliance {#438-compliance}

- Aligns with internal security policy and applicable regulations (e.g., GDPR, CCPA).  
- Annual security review and penetration testing.  
- Privacy impact assessments for new features.

---

#### 4.3.9 Validation & Drift Control {#439-validation--drift-control}

- Monthly drift checks confirm security configurations match `build-spec.env` and documented policies.  
- Any deviation triggers automated spec‑check and rollback if unapproved.

---

#### 4.3.10 Change Control {#4310-change-control}

- All security or privacy‑related changes must:
  - Pass security review.
  - Be documented in `build-spec.env` and the ops log ([§11.7 Documentation Updates](#117-documentation-updates)).
  - Include updated threat models where applicable.

---

### 4.4 Maintainability

- **Reproducibility**:
  - Pinned ROCm, kernel, CTranslate2, and model versions.
  - Containerized services with version‑locked images.
- **Documentation**:
  - System manual (this file), audio pipeline doc, burn-in plan, steady-state ops guide, hypercare quick refs.
- **Config management**:
  - All configs stored in version control with environment‑specific overrides.
- **Error handling**:
  - Structured error bundles with logs, job spec, and environment snapshot.
- **Upgrade path**:
  - Staging environment for testing ROCm/model updates before production.

---

### 4.5 Observability

- **Metrics**:
  - GPU/CPU utilization, ASR latency, summarization latency, queue depth.
- **Dashboards**:
  - Grafana/Prometheus for real‑time monitoring.
- **Alerts**:
  - Threshold‑based alerts for resource usage, disk space, queue health.
- **Logs**:
  - Structured JSONL logs with correlation IDs for each meeting.

---

### 4.6 Usability

- **UI**:
  - Web UI accessible from workstation and LAN devices.
  - Clear status indicators for capture, ASR, summarization, and integrations.
- **CLI**:
  - Commands for start/stop capture, re‑process meetings, search archive.
- **Notifications**:
  - Desktop notifications for meeting start, ASR failover, summary ready.
- **Accessibility**:
  - Keyboard‑navigable UI; high‑contrast theme option.

---

### 4.7 Cost Constraints

- **Software**:
  - All core components open‑source and free to use locally.
- **Optional services**:
  - SMTP relay for email delivery (< $10/mo) if required.
- **No recurring SaaS fees** for ASR, summarization, or search.

---

### 4.8 Section Sign‑off Checklist

- [x] Performance targets defined for ASR, summarization, and search.
- [x] Reliability and failover requirements set.
- [x] Security and privacy controls specified.
- [x] Maintainability and reproducibility requirements documented.
- [x] Observability metrics, dashboards, and alerts defined.
- [x] Usability requirements for UI, CLI, and notifications set.
- [x] Cost constraints confirmed.

## Section 5: High‑Level Architecture

This section describes the overall architecture of the meeting assistant system, showing how the capture, processing, storage, and integration layers interact. It is designed for deployment on the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture, using GPU‑accelerated faster‑whisper via ROCm as the primary ASR engine.

---

### 5.1 Architectural Layers {#51-architectural-layers}

This section defines the **logical and physical architecture** of the AI meeting assistant system.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring), the [§2.5 Environment Configuration](#25-environment-configuration), and the component pipelines in [Section 3](#section-3-functional-requirements).

---

#### 5.1.1 Purpose {#511-purpose}

The architectural layers provide a **clear separation of concerns** to maximize maintainability, reproducibility, and scalability.  
Each layer is version‑locked, drift‑controlled, and validated against the system baseline.

---

#### 5.1.2 Layer Overview {#512-layer-overview}

| Layer | Description | Key Components | Cross‑Refs |
|-------|-------------|----------------|------------|
| **Presentation Layer** | User‑facing interfaces for control, monitoring, and output delivery. | Streamlit, FastAPI | [§3.8 Integrations](#38-integrations), [§4.3 Security & Privacy](#43-security--privacy-43-security--privacy) |
| **Integration Layer** | Connects to external systems (calendar, chat, task trackers). | msmtp, API clients (Google, Microsoft, Slack, Teams) | [§3.7 Calendar Integration](#37-calendar-integration), [§3.8 Integrations](#38-integrations) |
| **Application Layer** | Orchestrates AI pipelines, manages workflows, and enforces business logic. | Orchestration scripts, pipeline managers | [§3.2 Audio Pre‑Processing](#32-audio-pre-processing) → [§3.6 Search & Retrieval](#36-search--retrieval-36-search--retrieval) |
| **AI Processing Layer** | Core inference and NLP processing. | faster‑whisper, CTranslate2, PyTorch ROCm, Hugging Face Transformers, FAISS | [§3.3 ASR](#33-automatic-speech-recognition-asr), [§3.4 NLP](#34-nlp), [§3.6 Search & Retrieval](#36-search--retrieval-36-search--retrieval) |
| **Data Layer** | Storage, indexing, and archival. | ZFS 2.2.0, FAISS GPU indexes | [§3.5 Storage & Archival](#35-storage--archival-35-storage--archival), [§3.6 Search & Retrieval](#36-search--retrieval-36-search--retrieval) |
| **Infrastructure Layer** | OS, kernel, GPU runtime, and hardware. | Ubuntu 24.04.3 LTS, Linux 6.14.x HWE, ROCm 7.0.1 | [§2.1 Environment Baseline](#21-environment-baseline), [§2.5 Environment Configuration](#25-environment-configuration) |

---

#### 5.1.3 Data Flow Summary {#513-data-flow-summary}

1. **Input**: Audio/video streams captured from meeting platform.  
2. **Pre‑Processing**: Noise suppression, echo cancellation, VAD ([§3.2](#32-audio-pre-processing)).  
3. **ASR**: Transcription via faster‑whisper or fallback Whisper ([§3.3](#33-automatic-speech-recognition-asr)).  
4. **NLP**: Summarization, entity extraction, and structuring ([§3.4](#34-nlp)).  
5. **Indexing**: Embedding generation and FAISS GPU indexing ([§3.6](#36-search--retrieval-36-search--retrieval)).  
6. **Storage**: ZFS snapshotting and archival ([§3.5](#35-storage--archival-35-storage--archival)).  
7. **Integration**: Summaries and action items sent to calendar, chat, or task systems ([§3.7](#37-calendar-integration), [§3.8](#38-integrations)).  
8. **Presentation**: User views results via UI ([§3.8](#38-integrations)).

---

#### 5.1.4 Validation & Drift Control {#514-validation--drift-control}

- Each layer is validated independently during burn‑in ([§10](#section-10-burnin--validation-plan)).  
- Monthly drift checks ensure all components match `build-spec.env` and the [Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring).  
- Any unapproved drift triggers rollback to the last validated state.

---

#### 5.1.5 Change Control {#515-change-control}

- Changes to any layer must:
  - Pass burn‑in testing ([§10](#section-10-burnin--validation-plan)).  
  - Meet SLA targets in [§4.1 Performance](#41-performance).  
  - Be documented in `build-spec.env` and the ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

### 5.2 Data Flow Overview

1. **Meeting start**:
   - Calendar event triggers capture pipeline.
   - Pre‑meeting context packet generated (T‑10 min).
2. **Audio capture**:
   - Near/far channels captured and pre‑processed.
   - Frames sent to ASR queue.
3. **ASR processing**:
   - faster‑whisper ROCm transcribes in near‑real‑time.
   - Segments stored in transcript buffer.
4. **NLP processing**:
   - Summaries, actions, decisions generated post‑meeting or incrementally.
5. **Archival**:
   - Final transcript and audio stored in archive with checksums.
   - Indexes updated.
6. **Integrations**:
   - Draft outputs generated and queued for approval.
7. **Search/retrieval**:
   - UI/CLI queries keyword/semantic indexes.

---

### 5.3 Deployment Topology

- **Single‑node deployment** on Ubuntu 24.04 workstation.
- **Containers** for ASR, NLP, and integrations.
- **Host‑level services** for PipeWire/WirePlumber and storage.
- **LAN access** for UI; optional Tailscale for remote admin.
- **Future expansion**:
  - Offload heavy NLP to standalone NVIDIA A6000 server via gRPC.
  - Multi‑user access with role‑based permissions.

---

### 5.4 Key Design Decisions

| Area | Decision | Rationale | Implication |
|------|----------|-----------|-------------|
| ASR | faster‑whisper ROCm primary | Best performance on RDNA3 with ROCm | GPU-accelerated live transcription |
| ASR fallback | PyTorch ROCm Whisper | Stability if CTranslate2 ROCm fails | Higher latency, more VRAM use |
| Audio server | PipeWire/WirePlumber | Flexible routing, persistent device names | Easier multi‑device capture |
| Storage | File‑based + vector index | Simplicity, durability, easy restore | Reindex on restore |
| Calendar | Graph API + `.ics` fallback | Reliability and metadata richness | Failover at 2 h outage |
| Integration | Dry‑run + approval | Prevent accidental external pushes | Manual review required |

---

### 5.5 Section Sign‑off Checklist

- [x] All architectural layers defined.
- [x] Data flow from capture to archive documented.
- [x] Deployment topology specified.
- [x] Key design decisions recorded.

## Section 6: Audio Pipeline Design

This section details the complete audio capture and processing chain for the meeting assistant, optimized for the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture. The design ensures stable, low‑latency, high‑quality audio for ASR, with GPU‑accelerated faster‑whisper via ROCm as the primary transcription engine.

---

### 6.1 Objectives

- Capture **synchronous near‑end and far‑end audio** with stable device naming.
- Apply **noise suppression**, **echo cancellation**, and **voice activity detection** before ASR.
- Maintain **low latency** and **high intelligibility** for accurate transcription.
- Ensure **reproducibility** and **resilience** against device re‑enumeration or drift.

---

### 6.2 Physical Audio Path

**Far‑end (remote participants)**:

- WorkMac conferencing app output → macOS Multi-Output Device → USB sound card → CM106 line‑in (Ubuntu).

**Near-end (local mic)**:

- Microphone → USB audio interface → Ubuntu.

---

### 6.3 Audio Server & Routing

- **PipeWire** as the audio server for low‑latency routing.
- **WirePlumber** session manager for persistent device profiles.
- **Persistent node naming** rules to ensure consistent device IDs across reboots.
- **Static gain staging** applied at the PipeWire level to prevent clipping.

---

### 6.4 Backup & Recovery {#64-backup--recovery}

This section defines the **validated backup and recovery strategy** for all deployments.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring), the [§3.5 Storage & Archival](#35-storage--archival) layer, and the [§4.3 Security & Privacy](#43-security--privacy) controls.

---

#### 6.4.1 Purpose {#641-purpose}

To ensure **rapid recovery, minimal data loss, and verifiable integrity** of all system data in the event of hardware failure, corruption, or security incident.

---

#### 6.4.2 Backup Scope {#642-backup-scope}

- **Configuration Data**: `build-spec.env`, orchestration scripts, and environment manifests.  
- **Operational Data**: AI models, indexes, and active datasets.  
- **Archival Data**: Meeting transcripts, summaries, and metadata.  
- **Secrets & Keys**: Stored in encrypted vault; backed up separately with offline copies.

---

#### 6.4.3 Backup Types & Frequency {#643-backup-types--frequency}

- **Incremental Backups**: Every 4 hours for active datasets.  
- **Daily Full Backups**: Taken at 02:00 UTC; retained for 14 days.  
- **Weekly Full Backups**: Retained for 6 months.  
- **Monthly Full Backups**: Retained for 2 years.

---

#### 6.4.4 Storage Targets {#644-storage-targets}

- **Primary Backup Pool**: ZFS dataset on `archive-pool` ([§3.5](#35-storage--archival-35-storage--archival)).  
- **Offsite Replication**: Encrypted ZFS send/receive to secondary site or cloud object storage.  
- **Offline Copies**: Quarterly snapshots written to encrypted removable media, stored in secure facility.

---

#### 6.4.5 Encryption & Security {#645-encryption--security}

- **At Rest**: ZFS native encryption with AES‑256‑GCM.  
- **In Transit**: TLS 1.3 for all replication traffic.  
- **Key Management**: Keys rotated quarterly; offline copies stored in HSM or sealed envelope.

---

#### 6.4.6 Recovery Procedures {#646-recovery-procedures}

1. **Incident Detection**: Triggered by monitoring or manual report.  
2. **Assessment**: Identify affected datasets and determine recovery point objective (RPO).  
3. **Restore**:  
   - Mount snapshot locally for verification.  
   - Validate checksums before promoting to active dataset.  
4. **Verification**: Confirm restored system meets SLA targets ([§4.1 Performance](#41-performance)).  
5. **Documentation**: Record recovery steps in ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

#### 6.4.7 Testing & Validation {#647-testing--validation}

- **Restore Drills**: Quarterly full restore from offsite backup to staging environment.  
- **Checksum Audits**: Monthly verification of backup integrity.  
- **RPO/RTO Validation**:  
  - **RPO**: ≤ 4 hours.  
  - **RTO**: ≤ 2 hours for critical services.

---

#### 6.4.8 Drift Control {#648-drift-control}

- Monthly drift checks confirm backup schedules, retention policies, and encryption settings match `build-spec.env`.  
- Any deviation triggers automated spec‑check and remediation.

---

#### 6.4.9 Change Control {#649-change-control}

- All changes to backup or recovery processes must:
  - Pass burn‑in testing ([§10](#section-10-burnin--validation-plan)).  
  - Meet or exceed SLA targets in [§4.1 Performance](#41-performance).  
  - Be documented in `build-spec.env` and the ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

### 6.5 Sample Rate & Format

- **Sample rate**: 48 kHz dual‑mono (one channel near‑end, one channel far‑end).
- **Format**: 16‑bit PCM for processing; converted to float32 for ASR input.
- **Rationale**: Matches conferencing app output; improves AEC convergence.

---

### 6.6 Integration with ASR

- **Live mode**:
  - Audio frames from PipeWire → pre‑processing → ASR queue.
  - faster‑whisper ROCm processes frames in near‑real‑time.
- **Batch mode**:
  - Archived audio re‑processed with higher‑accuracy model (e.g., large‑v3 fp16).

---

### 6.7 Guardrails

- **Latency monitor**:
  - Auto‑switch to smaller ASR model if p95 latency > 2.5 s.
- **Accuracy monitor**:
  - Flag if confidence < 0.85 for > 10% of segments.
- **Resource monitor**:
  - Pause non‑critical NLP jobs if GPU load > 85% during live ASR.

---

### 6.8 Testing & Calibration

- **Initial calibration**:
  - Play calibration tone from WorkMac; measure far‑end capture level.
  - Adjust gain to match target RMS.
- **AEC verification**:
  - Loopback test with known signal; measure suppression in dB.
- **Noise suppression check**:
  - Record near‑end in quiet room; verify noise floor < ‑60 dBFS.

---

### 6.9 Section Sign‑off Checklist

- [x] Physical audio path documented.
- [x] Audio server and routing strategy defined.
- [x] Pre‑processing chain specified with targets.
- [x] Sample rate and format chosen with rationale.
- [x] ASR integration path defined for live and batch.
- [x] Guardrails for latency, accuracy, and resource usage set.
- [x] Calibration and testing procedures documented.

## Section 7: Model Strategy

This section defines the approach for selecting, configuring, and operating the ASR and NLP models in the meeting assistant pipeline. It is tailored for the Ubuntu 24.04 + AMD RX 7900 XTX workstation with ROCm‑accelerated faster‑whisper as the primary ASR engine, and includes fallback strategies for stability.

---

### 7.1 Objectives

- Deliver **accurate, low‑latency transcription** for live meetings.
- Provide **audience‑aware summaries** and **structured action/decision extraction**.
- Maintain **reproducibility** and **stability** through version pinning.
- Support **adaptive model selection** based on meeting type, audience, and feedback.

---

### 7.2 ASR Model Strategy

**Primary Engine**:  

- **faster‑whisper** (CTranslate2 ROCm backend)  
- **Live mode**: `medium.en` for balance of speed and accuracy.  
- **Batch mode**: `large-v3` for archival re‑processing.  
- **Quantization**:  
  - Live: float32 to reduce VRAM and latency.  
  - Batch: float32 for maximum accuracy.  
- **Expected Throughput (RX 7900 XTX ROCm 6.1)**:  
  - medium.en float32: ~3–4× real‑time.  
  - large-v3 float32: ~1.5–2× real‑time.

**Fallback Engine**:  

- **Reference Whisper** (PyTorch ROCm build)  
- **Live mode**: `small.en` float32 for latency control.  
- **Batch mode**: `medium.en` or `large-v3` float32.  
- **Use case**: Only if CTranslate2 ROCm backend fails or produces instability.

---

### 7.3 NLP Model Strategy

- **Summarization**:
  - Multiple local LLMs fine‑tuned or prompt‑tuned for different audiences:
    - **Exec**: High‑level decisions, risks, and next steps.
    - **Product**: Feature updates, requirements, blockers.
    - **Technical**: Architecture changes, implementation details, bug reports.
- **Action/Decision Extraction**:
  - Structured JSON output with timestamps and speaker attribution.
- **Meeting Timeline**:
  - Chronological bullet points with time offsets.
- **Adaptive Selection**:
  - Model chosen based on:
    - Calendar metadata (meeting type, audience).
    - Historical win‑rate from feedback loop.
    - Resource availability (GPU/CPU load).

---

### 7.4 Model Registry & Versioning

- **Local model registry**:
  - Stores model binaries, checksums, and metadata.
  - Tracks quantization type, precision, and intended use case.
- **Version pinning**:
  - ASR: Pin to specific faster‑whisper + CTranslate2 + ROCm versions.
  - NLP: Pin to specific model commit hashes or release tags.
- **Rollback**:
  - Symlink‑based switching to previous model versions.
  - Canary replay of last 5 meetings before full rollout.

---

### 7.5 Resource Allocation

- **GPU**:
  - Reserved for ASR during live meetings.
  - NLP jobs scheduled on GPU only when ASR idle.
- **CPU**:
  - Dedicated core for AEC3.
  - Remaining cores for NLP and background indexing.
- **Batch Processing**:
  - Runs during off‑hours to avoid contention with live capture.

---

### 7.6 Guardrails

- **Latency monitor**:
  - Auto‑switch to smaller ASR model if p95 latency > 2.5 s.
- **Accuracy monitor**:
  - Flag if confidence < 0.85 for > 10% of segments.
- **Resource monitor**:
  - Pause non‑critical NLP jobs if GPU load > 85% during live ASR.

---

### 7.7 Section Sign‑off Checklist

- [x] Primary and fallback ASR engines defined with model sizes and quantization.
- [x] NLP model profiles defined for Exec, Product, and Technical audiences.
- [x] Adaptive selection criteria documented.
- [x] Local model registry and versioning strategy specified.
- [x] Resource allocation plan set for GPU and CPU.
- [x] Guardrails for latency, accuracy, and resource usage defined.

## Section 8: Guardrails & Observability

This section defines the safeguards, monitoring, and diagnostic capabilities built into the meeting assistant to ensure stable, predictable, and recoverable operation on the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture. These guardrails protect live meeting performance, preserve data integrity, and provide actionable insights for troubleshooting.

---

### 8.1 Objectives

- Prevent resource contention that could degrade live ASR or audio capture.
- Detect and respond to abnormal conditions before they impact output quality.
- Provide clear, structured observability for rapid diagnosis and recovery.
- Maintain reproducibility and auditability of all processing steps.

---

### 8.2 Guardrails

#### 8.2.1 Resource Protection {#821-resource-protection}

- **GPU load threshold**:  
  - If GPU utilization > 85% during live ASR, pause or defer non‑critical NLP and indexing jobs.
- **CPU load threshold**:  
  - If CPU load > 80% sustained, reduce ASR batch size or switch to smaller model.
- **Memory usage**:  
  - Alert if free system RAM < 10% or VRAM < 1 GB during live capture.

#### 8.2.2 Disk Space Management {#822-disk-space-management}

- **Threshold alerts**:  
  - Trigger warning at < 15% free space; critical alert at < 10%.
- **Automated cleanup**:  
  - Purge expired raw PCM beyond retention window.
  - Clear temp caches.

#### 8.2.3 ASR Continuity {#823-asr-continuity}

- **Latency guard**:  
  - If p95 ASR latency > 2.5 s for 30 s, auto‑switch to smaller model.
- **Confidence guard**:  
  - Flag meeting if > 10% of segments have confidence < 0.85.

#### 8.2.4 Queue Health {#824-queue-health}

- **Stuck job detection**:  
  - Alert if job in queue > 2× expected processing time.
- **Dead‑letter queue (DLQ)**:  
  - Failed jobs moved to DLQ with full error bundle for review.

---

### 8.3 Observability

#### 8.3.1 Logging {#831-logging}

- Structured JSONL logs with:
  - Timestamp
  - Meeting/session ID
  - Component name
  - Severity level
  - Correlation ID for cross‑component tracing
- Separate log streams for:
  - Audio capture
  - ASR
  - NLP
  - Integrations
  - System health

#### 8.3.2 Metrics {#832-metrics}

- GPU/CPU utilization
- ASR latency (p50, p95)
- Summarization latency
- Queue depth
- Disk usage
- AEC3 convergence time and suppression level

#### 8.3.3 Dashboards {#833-dashboards}

- Grafana/Prometheus stack for real‑time visualization.
- Panels for:
  - Resource usage
  - ASR performance
  - NLP throughput
  - Queue health
  - Disk space trends

#### 8.3.4 Alerts {#834-alerts}

- Threshold‑based alerts via:
  - Desktop notifications
  - Email (local MTA or SMTP relay)
- Critical alerts trigger:
  - On‑screen banner in UI
  - Optional audible chime

---

### 8.4 Error Bundles

Each failed job produces an error bundle containing:

- Full logs for the job
- Job specification (model, parameters, input source)
- Environment snapshot (ROCm version, kernel, container image hashes)
- Audio snippet (if applicable)
- Stack trace or exception details

---

### 8.5 Recovery Procedures

- **ASR failover**:
  - Switch to fallback ASR engine within 10 s of primary failure.
- **Queue drain**:
  - Retry DLQ jobs after root cause fix; mark as recovered.
- **Disk cleanup**:
  - Automated purge of temp files and expired raw audio.
- **Service restart**:
  - Container restart scripts with health checks.

---

### 8.6 Section Sign‑off Checklist

- [x] Resource protection thresholds defined.
- [x] Disk space management rules set.
- [x] ASR continuity guardrails specified.
- [x] Queue health monitoring and DLQ process documented.
- [x] Logging, metrics, dashboards, and alerts defined.
- [x] Error bundle contents specified.
- [x] Recovery procedures documented.

## Section 9: Deployment & Environment Strategy

This section defines how the meeting assistant is deployed, configured, and operated in different runtime profiles on the Ubuntu 24.04 + AMD RX 7900 XTX workstation, with GPU‑accelerated faster‑whisper via ROCm as the primary ASR engine. It also covers environment pinning, automation, and future expansion to a standalone AI server.

---

### 9.1 Objectives

- Ensure **reproducible deployments** with pinned versions for ROCm, kernel, CTranslate2, and models.
- Support **multiple runtime profiles** for live capture, batch processing, and future server offload.
- Maintain **local‑only processing** with no dependency on external SaaS for ASR/NLP.
- Provide **automation hooks** for starting/stopping services, failover, and environment validation.

---

### 9.2 Runtime Profiles

| Profile | Target | GPU Policy | Workloads | Notes |
|---------|--------|------------|-----------|-------|
| **Workstation‑live (WorkMac capture)** | Ubuntu 24.04 ROCm on RX 7900 XTX | Reserve VRAM for ASR; pause medium/batch jobs on new meeting | Live capture from WorkMac via CM106 line‑in (far‑end) + mic interface (near‑end), ASR, incremental NLP, end‑of‑meeting summaries (≤ 14B live), indexing | WorkMac outputs via Multi‑Output Device → USB sound card → CM106 line‑in; speakers in parallel for room playback |
| **Workstation‑batch** | Same | Full GPU at idle | Archival re‑summaries (large‑v3 float32), bulk reindex, backfills | Nightly cron or manual batch mode |
| **Server‑offload** | Future standalone GPU box | ASR local; heavy jobs remote | Live ASR + light NLP local; heavy summarization/indexing remote | Same queue semantics; gRPC over LAN |
| **Server‑primary** | Future box as primary | Dedicated GPUs per pool | Everything runs on server; workstation UI only | Multi‑user, role‑based access |

---

### 9.3 Environment Pinning (TBD)



#### 9.3.1 Tested‑Good Environment Matrix

| Component | Stable Version | Newest Version | Notes |
|-----------|----------------|----------------|-------|
| ROCm | 7.0.1 | 7.1.0 | Test with newer kernels |
| Kernel | 6.14.x HWE | 6.15.x HWE | Validate with ASR/NLP workloads |
| CTranslate2 | 2.13.0 | 2.14.0 | Check for breaking changes |
| faster-whisper | 1.0.0 | 1.1.0 | Review release notes for deprecations |
| PyTorch ROCm | 1.13.0 | 1.14.0 | Ensure model compatibility |
| Transformers | 4.58.0 | 4.59.0 | Validate tokenizer and model loading |
| FAISS | 1.7.2 | 1.8.0 | Test index creation and search performance |

#### 9.3.2 Pinning Strategy

- Pin all components to specific versions in `build-spec.env`.
- Use exact version numbers, not ranges (e.g., `7.0.1` not `7.0.*`).
- Regularly review for updates; follow upgrade policy in [§9.3.5 Upgrade Policy](#935-upgrade-policy).

#### 9.3.3 Validation Commands

```bash
# Check ROCm runtime
rocminfo | grep -i gfx

# Check OpenCL device visibility
clinfo | grep -i 'gfx\|Device'

# Test CTranslate2 ROCm backend
python3 - <<'EOF'
from faster_whisper import WhisperModel
model = WhisperModel("medium.en", device="auto", compute_type="int8_float16")
segments, info = model.transcribe("test.wav")
print(f"Detected language: {info.language}, Duration: {info.duration}")
EOF
```

#### 9.3.4 Documentation

- Record the exact output of:
  - `uname -r`
  - `rocminfo | grep -i gfx`
  - `clinfo | grep -i 'gfx\|Device'`
  - `pip show ctranslate2 faster-whisper`
- Store in `docs/environment-baseline.md` with date and test results.
- Update after any kernel or ROCm upgrade.

#### 9.3.5 Upgrade Policy

- Only upgrade ROCm or kernel after:
  - Testing in a staging environment.
  - Passing ASR latency/accuracy benchmarks.
  - Verifying no HIP or kernel module errors in logs.
- Keep at least one known‑good kernel installed in GRUB for fallback.

---

### 9.4 Deployment Steps (Workstation‑Live)

1. **Pre‑flight checks**:
   - Verify ROCm, kernel, and GPU health.
   - Confirm audio devices are present and correctly named.
   - Check disk space thresholds.
2. **Start services**:
   - Launch PipeWire/WirePlumber with persistent profiles.
   - Start ASR container (faster‑whisper ROCm).
   - Start NLP workers.
   - Start integration services (calendar sync, notifications).
3. **Load models**:
   - Pre‑load ASR model into VRAM.
   - Pre‑load NLP models into RAM or GPU (if idle).
4. **Run validation**:
   - Audio loopback test for AEC3.
   - ASR latency/accuracy spot check.
   - NLP dry‑run on sample transcript.

---

### 9.5 Automation Hooks

- **Meeting start trigger**:
  - Calendar event → start capture pipeline.
- **Failover trigger**:
  - ASR health check fails → switch to fallback ASR.
- **Batch job scheduler**:
  - Cron jobs for nightly archival re‑summaries and reindexing.
- **Disk cleanup**:
  - Weekly purge of expired raw audio and temp files.
- **Alerts**:
  - Desktop notifications for failures, failovers, and job completions.

---

### 9.6 Future Server Integration

- **Offload mode**:
  - Live ASR local; heavy NLP jobs sent to server via gRPC.
- **Primary mode**:
  - All processing on server; workstation acts as thin client.
- **Security**:
  - TLS‑encrypted LAN traffic.
  - Role‑based access control for multi‑user environment.

---

### 9.7 Section Sign‑off Checklist

- [x] Runtime profiles defined for live, batch, and future server modes.
- [x] Environment pinning specified for ROCm, kernel, CTranslate2, and models.
- [x] Deployment steps documented for workstation‑live profile.
- [x] Automation hooks for triggers, failover, and cleanup defined.
- [x] Future server integration strategy outlined.

### 9.8 Make Targets {#98-make-targets}

Define simple, idempotent Make targets to validate the environment and run routine checks.

Recommended targets:

- validate — run component smoke tests (CTranslate2, faster‑whisper, audio I/O). See Appendix B for an example Makefile.
- burn-in — execute the burn‑in suite from Section 10 with summarized output to `docs/burn-in-report.md`.
- promote — on pass, update `build-spec.env`, attach diffs per [Spec File Delta Verification](#spec-file-delta-verification), and append to ops log per [§11.7](#117-documentation-updates).

Notes:

- Keep targets non‑interactive and safe to re‑run.
- Echo clear PASS/FAIL at the end; return non‑zero on failure.

## Section 10: Burn‑In & Validation Plan

This section defines the process for verifying that the meeting assistant is stable, performant, and production‑ready on the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture. The burn‑in phase is designed to surface hardware, driver, and pipeline issues before live deployment, and to establish baseline performance metrics for future regression testing.

---

### 10.1 Burn‑In Overview {#101-burn-in-overview}

This section defines the **burn‑in testing process** for validating new components, configurations, or integrations before promotion to production.  
It is anchored to the [🏆 Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring), the [Decision‑Making Guardrails](#decision-making-guardrails), and the SLA targets in [§4.1 Performance](#41-performance).

---

#### 10.1.1 Purpose {#1011-purpose}

Burn‑in ensures that any change — whether an upgrade, new integration, or configuration adjustment — is **proven stable, performant, and reproducible** before it is allowed into the production environment.

---

#### 10.1.2 Scope {#1012-scope}

Burn‑in applies to:

- OS/kernel upgrades ([§2.5 Environment Configuration](#25-environment-configuration))
- GPU runtime and ROCm stack changes
- AI pipeline component updates ([§3.2](#32-audio-pre-processing) → [§3.6](#36-search--retrieval-36-search--retrieval))
- Storage and archival changes ([§3.5](#35-storage--archival-35-storage--archival))
- Integration updates ([§3.7](#37-calendar-integration), [§3.8](#38-integrations))
- Security and privacy modifications ([§4.3 Security & Privacy](#43-security--privacy-43-security--privacy))
- Documentation updates ([§11.7 Documentation Updates](#117-documentation-updates))

---

#### 10.1.3 Burn‑In Environment {#1013-burn-in-environment}

- **Isolation**: Conducted in a staging environment mirroring production hardware and configuration.
- **Baseline**: Uses the current Stable stack from the [Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring) as control.
- **Data**: Synthetic + anonymized real workloads to simulate production conditions.

---

#### 10.1.4 Test Categories {#1014-test-categories}

1. **Functional Validation** — Verify all features operate as intended.
2. **Performance Benchmarking** — Compare latency, accuracy, and maintainability metrics to SLA targets ([§4.1 Performance](#41-performance)).
3. **Stress & Load Testing** — Simulate peak concurrency and data volume.
4. **Compatibility Checks** — Confirm interoperability with upstream and downstream components.
5. **Drift Detection** — Ensure no unapproved changes to `build-spec.env` or baseline configuration.

---

#### 10.1.5 Duration & Criteria {#1015-duration-criteria}

- **Minimum Duration**: 7 consecutive days of stable operation under representative load.
- **Pass Criteria**:
  - Meets or exceeds all SLA targets.
  - No P1/P2 incidents.
  - No unapproved drift detected.
- **Fail Criteria**:
  - SLA breach in ≥ 2 consecutive test runs.
  - Any reproducible P1/P2 incident.
  - Incompatibility with dependent components.

---

#### 10.1.6 Reporting {#1016-reporting}

- Burn‑in results documented in:
  - Burn‑in report archive (`/var/log/ai-assistant/burnin/`)
  - Ops log ([§11.7 Documentation Updates](#117-documentation-updates))
- Reports include:
  - Test environment details
  - Metrics vs. SLA targets
  - Incident logs and resolutions
  - Promotion recommendation

---

#### 10.1.7 Promotion Workflow {#1017-promotion-workflow}

1. Complete burn‑in with pass status.
2. Submit change request with burn‑in report.
3. Architecture lead review and approval.
4. Update `build-spec.env` and promote to production.
5. Schedule post‑promotion monitoring for 14 days.

---

#### 10.1.8 Change Control {#1018-change-control}

- Any component promoted without burn‑in requires explicit architecture lead waiver.
- Waivers documented in ops log with justification and risk assessment.

---

### 10.2 Burn‑In Test Plan {#102-burn-in-test-plan}

This section defines the **standardized test plan** for executing burn‑in validation prior to promoting any change to production.  
It is anchored to the [Burn‑In Overview](#101-burn-in-overview), the SLA targets in [§4.1 Performance](#41-performance), and the [Decision‑Making Guardrails](#decision-making-guardrails).

---

#### 10.2.1 Purpose {#1021-purpose}

To provide a **reproducible, version‑controlled checklist** of test cases, metrics, and tooling so that every burn‑in run is consistent, measurable, and auditable.

---

#### 10.2.2 Pre‑Test Requirements {#1022-pre-test-requirements}

- **Environment**: Staging system matching production hardware, OS, kernel, and ROCm stack ([§2.5 Environment Configuration](#25-environment-configuration)).
- **Baseline**: Current Stable stack from the [Recommended Stack Table](#recommended-local-only-open-source-rocm-on-rdna3-stack-stable-vs-newest-with-scoring).
- **Data**: Synthetic + anonymized real workloads representative of production.
- **Spec File**: `build-spec.env` loaded and validated against baseline.

---

#### 10.2.3 Test Categories & Cases {#1023-test-categories-cases}

##### A. Functional Validation {#10231-functional}

- Verify all pipeline stages from [§3.2](#32-audio-pre-processing) → [§3.8](#38-integrations) execute without errors.
- Confirm integrations (calendar, chat, task systems) operate as expected.

##### B. Performance Benchmarking {#10232-performance}

- Measure latency, accuracy, and maintainability metrics for each stage against [§4.1 Performance](#41-performance) targets.
- Record p50/p95 latency for:
  - Audio pre‑processing
  - ASR
  - NLP
  - Search & retrieval
  - Storage I/O
  - Integration/API calls

##### C. Stress & Load Testing {#10233-stress-load}

- Simulate peak concurrency (≥ 2× expected production load).
- Run sustained load for ≥ 72 hours without SLA breach.

##### D. Compatibility Checks {#10234-compatibility}

- Validate interoperability with upstream/downstream components.
- Confirm no regressions in API contracts or data formats.

##### E. Drift Detection {#10235-drift-detection}

- Run automated spec‑check to confirm no unapproved changes to:
  - OS/kernel
  - ROCm stack
  - AI pipeline component versions
  - Storage configuration
  - Security settings ([§4.3](#43-security--privacy-43-security--privacy))

---

#### 10.2.4 Tooling {#1024-tooling}

ROCm env: `/etc/profile.d/rocm_env.sh`  
Logs: `/opt/meeting-assistant/logs/`  
Manifest: `/opt/meeting-assistant/wheels/`

---

#### 10.2.5 Duration & Monitoring {#1025-duration-monitoring}

- **Minimum Duration**: 7 consecutive days of stable operation.
- **Monitoring**: Real‑time dashboards for latency, error rates, and resource utilization.
- **Alerting**: Immediate notification on SLA breach or P1/P2 incident.

---

#### 10.2.6 Pass/Fail Criteria {#1026-passfail-criteria}

- **Pass**:
  - All functional tests succeed.
  - Performance metrics meet or exceed targets.
  - No unhandled errors or crashes during burn‑in.
  - Fallback ASR works as expected.
- **Fail**:
  - Any critical component fails repeatedly.
  - Latency or accuracy consistently below target.
  - ROCm instability or kernel module errors.

---

#### 10.2.7 Reporting {#1027-reporting}

- Burn‑in report must include:
  - Environment details
  - Test cases executed
  - Metrics vs. SLA targets
  - Incident logs and resolutions
  - Promotion recommendation
- Reports archived in `/var/log/ai-assistant/burnin/reports/` and referenced in ops log ([§11.7 Documentation Updates](#117-documentation-updates)).

---

#### 10.2.8 Change Control {#1028-change-control}

- Only changes with a **Pass** status may be promoted.
- Promotion requires:
  - Architecture lead approval
  - `build-spec.env` update
  - Ops log entry with burn‑in report link

---

### 10.3 Test Categories

#### 10.3.1 Functional Tests {#1031-functional-tests}

- Verify audio device detection and persistent naming.
- Confirm RNNoise, AEC3, and VAD are active and producing expected results.
- Validate ASR output format (JSONL with timestamps, confidence scores).
- Check NLP outputs for all audience profiles (Exec, Product, Technical).
- Ensure archive storage and indexing complete without errors.

#### 10.3.2 Performance Tests {#1032-performance-tests}

- Measure ASR latency (p50, p95) under live conditions.
- Measure summarization turnaround time post‑meeting.
- Record GPU/CPU utilization during peak load.
- Track disk I/O during capture and archival.

#### 10.3.3 Stability Tests {#1033-stability-tests}

- Run back‑to‑back meetings without restarting services.
- Simulate network interruptions for calendar sync.
- Stress test with long meetings (≥ 4 h).
- Monitor for HIP errors, kernel module crashes, or audio dropouts.

#### 10.3.4 Failover Tests {#1034-failover-tests}

- Force ASR process crash; verify fallback to PyTorch ROCm Whisper within 10 s.
- Simulate low disk space; confirm cleanup or alert triggers.
- Disable far‑end device mid‑meeting; verify graceful degradation.

---

### 10.4 Metrics to Capture

| Metric | Target | Tool/Method |
|--------|--------|-------------|
| ASR p50 latency | ≤ 1.5 s | Internal ASR logs |
| ASR p95 latency | ≤ 2.5 s | Internal ASR logs |
| Summarization turnaround | ≤ 60 s | NLP job logs |
| GPU utilization | ≤ 85% live | `rocm-smi` |
| CPU utilization | ≤ 80% sustained | `top` / `htop` |
| Disk free space | ≥ 15% | `df -h` |
| AEC3 suppression | ≥ 20 dB | Loopback test |

---

### 10.5 Validation Commands

```bash

# Monitor GPU utilization
watch -n 1 rocm-smi

# Monitor CPU utilization
htop

# Check ASR latency in logs
grep "latency" /var/log/meeting-assistant/asr.log

# Verify ROCm health
rocminfo | grep -i gfx
clinfo | grep -i 'gfx\|Device'
```

---

### 10.6 Pass/Fail Criteria

- **Pass**:
  - All functional tests succeed.
  - Performance metrics meet or exceed targets.
  - No unhandled errors or crashes during burn‑in.
  - Fallback ASR works as expected.
- **Fail**:
  - Any critical component fails repeatedly.
  - Latency or accuracy consistently below target.
  - ROCm instability or kernel module errors.

---

### 10.7 Documentation & Sign‑off

- Record all test results in `docs/burn-in-report.md`.
- Include:
  - Kernel, ROCm, CTranslate2, faster‑whisper versions.
  - Hardware configuration.
  - Test logs and metrics.
- Sign‑off by project owner before production deployment.

---

### 10.8 Section Sign‑off Checklist

- [x] Burn‑in duration and scope defined.
- [x] Functional, performance, stability, and failover tests listed.
- [x] Metrics and targets specified.
- [x] Validation commands provided.
- [x] Pass/fail criteria documented.
- [x] Documentation and sign‑off process defined.

### 10.9 Promotion Checklist {#109-promotion-checklist}

Use this checklist when promoting a Newest stack to Stable:

- [ ] Burn‑in PASS with no P1/P2 incidents in last 30 days.
- [ ] SLA targets met per [§4.1 Performance](#41-performance).
- [ ] Environment diffs reviewed and approved; attach [Spec File Delta Verification](#spec-file-delta-verification).
- [ ] `build-spec.env` updated and committed.
- [ ] Ops log entry created with links to burn‑in report and diffs.
- [ ] Stakeholders notified; rollback point identified.

## Section 11: Steady‑State Operations

This section defines the day‑to‑day operational procedures for running the meeting assistant in production on the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture. It assumes the system has passed burn‑in (Section 10) and is operating with GPU‑accelerated faster‑whisper via ROCm as the primary ASR engine.

---

### 11.1 Objectives

- Maintain **consistent, reliable performance** for all scheduled meetings.
- Ensure **minimal operator intervention** during normal operation.
- Provide **clear procedures** for routine tasks, monitoring, and minor troubleshooting.
- Keep the environment **aligned with the pinned configuration** from Section 9.

---

### 11.2 Daily Routine

**Before first meeting of the day**:

1. **Environment check**:
   - Verify ROCm and GPU health (`rocminfo`, `rocm-smi`).
   - Confirm audio devices are present and correctly named.
   - Check free disk space (`df -h`).
2. **Service status**:
   - Ensure PipeWire/WirePlumber, ASR container, NLP workers, and integrations are running.
3. **Calendar sync**:
   - Confirm upcoming meetings are visible in the UI.

**During meetings**:

- Monitor UI status indicators for:
  - Audio capture health.
  - ASR latency and confidence.
  - NLP job queue depth.
- Respond to alerts (e.g., ASR failover, disk space warnings).

**After last meeting of the day**:

- Review logs for errors or warnings.
- Trigger batch jobs if needed (archival re‑summaries, reindexing).
- Optional: Shut down non‑essential services overnight.

---

### 11.3 Weekly Routine

- **Disk cleanup**:
  - Purge raw PCM older than retention window.
  - Clear temp caches.
- **Index maintenance**:
  - Rebuild keyword and semantic indexes if fragmentation > 10%.
- **Metrics review**:
  - Check Grafana dashboards for trends in latency, accuracy, and resource usage.
- **Backup**:
  - Run ZFS snapshot and offsite backup sync.

---

### 11.4 Monthly Routine

- **Environment audit**:
  - Verify kernel, ROCm, CTranslate2, and model versions match pinned configuration.
  - Document any changes in `docs/environment-baseline.md`.
- **Failover drill**:
  - Simulate ASR failure and confirm fallback engine activates within 10 s.
- **Security review**:
  - Check firewall rules, access logs, and encryption status.

---

### 11.5 Monitoring & Alerts

- **Real‑time monitoring**:
  - GPU/CPU utilization, ASR latency, queue depth, disk space.
- **Alert channels**:
  - Desktop notifications for immediate issues.
  - Email alerts for non‑urgent warnings.
- **Alert response**:
  - Critical: Immediate action during meeting.
  - Warning: Address before next scheduled meeting.

---

### 11.6 Minor Troubleshooting

| Symptom | Likely Cause | Action |
|---------|--------------|--------|
| No far‑end audio | WorkMac output device changed | Re‑select Multi‑Output Device in macOS |
| ASR latency spike | GPU contention | Pause NLP jobs; check `rocm-smi` |
| Low ASR confidence | Noise or echo | Check mic placement; verify AEC3 active |
| Missing meeting in UI | Calendar sync delay | Trigger manual sync; check Graph API status |

---

### 11.7 Documentation Updates {#117-documentation-updates}

This section defines the **documentation update process** for all changes to the AI meeting assistant system.  
It is anchored to the [Decision‑Making Guardrails](#decision-making-guardrails), the [§2.1 Environment Baseline](#21-environment-baseline), and the promotion workflow in [§10 Burn‑In & Validation](#section-10-burnin--validation-plan).

---

#### 11.7.1 Purpose {#1171-purpose}

To ensure **every change is recorded, traceable, and reproducible**, enabling full auditability and preventing undocumented drift from the validated baseline.

---

#### 11.7.2 Scope {#1172-scope}

Documentation updates are required for:

- Environment changes ([§2.5 Environment Configuration](#25-environment-configuration))
- Component upgrades ([Section 3](#section-3-functional-requirements))
- SLA target adjustments ([§4.1 Performance](#41-performance))
- Security or privacy modifications ([§4.3 Security & Privacy](#43-security--privacy-43-security--privacy))
- Backup/recovery changes ([§6.4 Backup & Recovery](#64-backup--recovery-64-backup--recovery))
- Burn‑in results and promotions ([§10.2 Burn‑In Test Plan](#102-burn-in-test-plan))

---

#### 11.7.3 Required Artifacts {#1173-required-artifacts}

Each change must be documented with:

1. **Change Summary** — What was changed and why.
2. **Date & Author** — Who made the change and when.
3. **Related Sections** — Cross‑references to affected manual sections.
4. **Version Updates** — Updated `build-spec.env` entries.
5. **Validation Evidence** — Burn‑in reports, test results, or incident resolutions.
6. **Approval Record** — Architecture lead sign‑off.

---

#### 11.7.4 Update Workflow {#1174-update-workflow}

1. **Draft Update** — Author prepares change entry in staging branch of documentation.
2. **Review** — Architecture lead reviews for completeness, accuracy, and compliance.
3. **Approval** — Approved changes merged into master documentation.
4. **Publication** — Updated manual distributed to all stakeholders.
5. **Archival** — Previous version archived with timestamp for rollback reference.

---

#### 11.7.5 Storage & Access {#1175-storage-access}

- **Primary Location**: `/docs/ai-assistant/manual/` in version‑controlled repository.
- **Access Control**: Read‑only for general users; write access restricted to documentation maintainers.
- **Retention**: All historical versions retained indefinitely unless superseded by major system redesign.

---

#### 11.7.6 Drift Control {#1176-drift-control}

- Monthly drift checks compare live environment to:
  - Current `build-spec.env`
  - Latest approved manual version
- Any undocumented change triggers:
  - Incident creation ([§12.4 Incident Response Workflow](#124-incident-response-workflow))

  - Immediate documentation update or rollback

---

#### 11.7.7 Change Control Linkage {#1177-change-control-linkage}

- No change is considered **complete** until:
  - Documentation is updated
  - `build-spec.env` is updated
  - Ops log entry is created with cross‑reference to manual section

---

#### 11.7.8 Audit & Compliance {#1178-audit-compliance}

- Quarterly documentation audits verify:
  - All changes in ops log have corresponding manual updates
  - All manual updates have corresponding `build-spec.env` changes
- Audit results stored in `/var/log/ai-assistant/audits/` and reviewed by compliance lead.

#### Spec File Delta Verification {#spec-file-deltaverification}

**Purpose:**  
To quickly and visually verify the exact differences between the Stable and Newest build specifications, ensuring that only approved changes exist between the two environments.

**Procedure:**

1. Ensure both spec files are present:  
   - `specs/build-spec-stable.env`  
   - `specs/build-spec-newest.env`

2. Run the color‑highlighted diff:  

```bash
colordiff -u specs/build-spec-stable.env specs/build-spec-newest.env | less -R
```

   If `colordiff` is not installed:  

```bash
git diff --no-index --color specs/build-spec-stable.env specs/build-spec-newest.env | less -R
```

1. Review output:  
   - **Green lines** → additions in Newest.  
   - **Red lines** → removals from Stable.  
   - Context lines remain uncolored.

1. **Action:**  
   - If differences match the approved delta from the Recommended Stack Table, proceed.  
   - If unexpected differences are found, trigger drift investigation per [§12.4 Incident Response Workflow](#124-incident-response-workflow).

**Frequency:**  

- Run before every Newest build promotion.  
- Include diff output in the ops log entry for the promotion ([§11.7 Documentation Updates](#117-documentation-updates)).

---

#### Quick Prompt — Docs Update {#quick-prompt-docs-update}

Use this prompt to draft a minimal docs update PR when small changes occur (version bump, config tweak):

```text
You are updating the AI Meeting Assistant manual.
Task: Apply a small change and update documentation accordingly.
Requirements:
- Add or update the relevant section with a stable explicit anchor {#...}.
- Update the Table of Contents so links resolve.
- If touching versions, update build-spec.env and include Spec File Delta Verification instructions.
- Keep changes minimal; do not reformat unrelated content.
Output:
- A concise commit message (50/72 style).
- The edited section text only.
References:
- Manual: specs/system-design-ops-manual-v1.0.md
- Prompt library: specs/docs/prompt-library.md
- Testing strategy: specs/docs/testing-strategy.md
```

See additional curated prompts in `specs/docs/prompt-library.md`.

---

## Appendix A – Meeting Assistant Build Script v1.0 Setup & Configuration

_This appendix documents the installation, configuration, and validation steps for the hardened build script located at:_
`/home/brent/ai-assistant-project/specs/build-meeting-assistant-v1.0.sh`

### A.1 Purpose {#a1-purpose}

This script automates the installation and configuration of a ROCm‑accelerated meeting assistant environment on Ubuntu 24.04, including:

- ROCm runtime detection/installation
- Audio stack setup
- Building **CTranslate2** and **faster‑whisper** from source
- Downloading Whisper models
- Generating a build manifest
- Running GPU inference validation

### A.2 Prerequisites {#a2-prerequisites}

**Hardware:** AMD GPU supported by ROCm (≥16 GB VRAM recommended for `whisper-large-v2`)  
**OS:** Ubuntu 24.04 LTS with root privileges  
**Network:** Internet access to `repo.radeon.com`, `github.com`, and `huggingface.co`

### A.3 Script Location & Permissions {#a3-script-location--permissions}

```bash
chmod +x /home/brent/ai-assistant-project/specs/build-meeting-assistant-v1.0.sh
```

### A.4 Running the Script {#a4-running-the-script}

Basic run:

```bash
sudo /home/brent/ai-assistant-project/specs/build-meeting-assistant-v1.0.sh
```

With logging:

```bash
sudo /home/brent/ai-assistant-project/specs/build-meeting-assistant-v1.0.sh \
  | tee ~/meeting-assistant-build-$(date +%F_%H-%M-%S).log
```

### A.5 What the Script Does {#a5-what-the-script-does}

| Step | Description |
|------|-------------|
| 1 | OS base & packages |
| 2 | ROCm repo setup |
| 3 | ROCm runtime install |
| 4 | Audio stack |
| 5 | CTranslate2 build |
| 6 | faster-whisper build |
| 7 | Manifest |
| 8 | Cleanup |
| 9 | Validation |
| 10 | Troubleshooting tips |
| 11 | Completion |
| 12 | GPU inference validation |

### A.6 Configuration Files {#a6-configuration-files}

ROCm env: `/etc/profile.d/rocm_env.sh`  
Logs: `/opt/meeting-assistant/logs/`  
Manifest: `/opt/meeting-assistant/wheels/`

### A.7 Directory Layout After Build {#a7-directory-layout-after-build}

```text
/opt/meeting-assistant/
├── logs/
├── wheels/
├── ct2/
│   ├── venv/
│   ├── src/
│   └── models/
└── fw/
    ├── venv/
    ├── src/
    └── models/
```

### A.8 Post‑Install Validation {#a8-post-install-validation}

```bash
rocminfo | grep gfx
```

Faster‑whisper test:

```bash
source /opt/meeting-assistant/fw/venv/bin/activate
python3 - <<'EOF'
from faster_whisper import WhisperModel
model = WhisperModel("/opt/meeting-assistant/fw/models/large-v2", device="auto", compute_type="float32")
segments, info = model.transcribe("/opt/meeting-assistant/test.wav", beam_size=5)
print("✅ faster-whisper: GPU =", model.device, "| Language =", info.language)
EOF
deactivate
```

CTranslate2 test:

```bash
source /opt/meeting-assistant/ct2/venv/bin/activate
python3 - <<'EOF'
import ctranslate2
translator = ctranslate2.Translator("/opt/meeting-assistant/ct2/models/whisper-large-v2", device="auto", compute_type="float32")
print("✅ CTranslate2: GPU =", translator.device)
EOF
deactivate
```

### A.9 Troubleshooting {#a9-troubleshooting}

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| No GPU in `rocminfo` | ROCm not installed or unsupported GPU | Check ROCm docs |
| Model download fails | Missing Hugging Face token | `huggingface-cli login` |
| Wheel build fails | Missing deps | `apt --fix-broken install` |
| GPU test uses CPU | ROCm env not loaded | `source /etc/profile.d/rocm_env.sh` |

### A.10 Component Test Scripts {#a10-component-test-scripts}

**`/opt/meeting-assistant/tests/test_ct2_load.py`**

```python
import ctranslate2
translator = ctranslate2.Translator("/opt/meeting-assistant/ct2/models/whisper-large-v2", device="auto")
print("CT2 device:", translator.device)
```

**`/opt/meeting-assistant/tests/test_fw_load.py`**

```python
from faster_whisper import WhisperModel
model = WhisperModel("/opt/meeting-assistant/fw/models/large-v2", device="auto")
print("FW device:", model.device)
```

**`/opt/meeting-assistant/tests/test_audio.py`**

```python
import soundfile as sf
audio, sr = sf.read("/opt/meeting-assistant/test.wav")
print(f"Audio loaded: {len(audio)} samples @ {sr} Hz")
```

---

## Appendix B – Quick Validation via Makefile

To streamline troubleshooting, you can add a `make validate` target to run all component tests in sequence.

### 1. Create `/opt/meeting-assistant/tests/` and place the test scripts

```bash
sudo mkdir -p /opt/meeting-assistant/tests
sudo tee /opt/meeting-assistant/tests/test_ct2_load.py > /dev/null <<'EOF'
import ctranslate2
translator = ctranslate2.Translator("/opt/meeting-assistant/ct2/models/whisper-large-v2", device="auto")
print("CT2 device:", translator.device)
EOF

sudo tee /opt/meeting-assistant/tests/test_fw_load.py > /dev/null <<'EOF'
from faster_whisper import WhisperModel
model = WhisperModel("/opt/meeting-assistant/fw/models/large-v2", device="auto")
print("FW device:", model.device)
EOF

sudo tee /opt/meeting-assistant/tests/test_audio.py > /dev/null <<'EOF'
import soundfile as sf
audio, sr = sf.read("/opt/meeting-assistant/test.wav")
print(f"Audio loaded: {len(audio)} samples @ {sr} Hz")
EOF
```

### 2. Create a Makefile in `/opt/meeting-assistant/tests/Makefile`

```make
.PHONY: validate ct2 fw audio

validate: ct2 fw audio

ct2:
    @echo "🔍 Testing CTranslate2..."
    source /opt/meeting-assistant/ct2/venv/bin/activate && \
    python3 /opt/meeting-assistant/tests/test_ct2_load.py

fw:
    @echo "🔍 Testing faster-whisper..."
    source /opt/meeting-assistant/fw/venv/bin/activate && \
    python3 /opt/meeting-assistant/tests/test_fw_load.py

audio:
    @echo "🔍 Testing audio file load..."
    python3 /opt/meeting-assistant/tests/test_audio.py
```

### 3. Run all tests

```bash
cd /opt/meeting-assistant/tests
make validate
```

This will:

1. Activate the correct venv for each engine
2. Run the GPU/device detection tests
3. Confirm audio file readability

If any step fails, you’ll see the error immediately, making it easier to isolate the problem.

## Appendix C — Baseline Verification (September 2025)

The following outputs were captured from the validated system baseline on 2025‑09‑19.  
Use these to verify hardware consistency over time.

### CPU

$ lscpu | grep -E 'Model name|Architecture|CPU\(s\)'
Architecture:        x86_64
Model name:          AMD Ryzen 7 9700X 8-Core Processor
CPU(s):              16

### GPU

$ lspci | grep -i vga
03:00.0 VGA compatible controller: AMD Radeon RX 7900 XTX (gfx1100)
0a:00.0 VGA compatible controller: AMD Granite Ridge (integrated)

### Storage

$ lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
nvme0n1   1.8T disk
└─...     ...  ...
nvme1n1 931G disk
└─...     ...  ...

### Audio Devices

$ aplay -l
card 1: CM106 [C-Media USB Audio Device], device 0: USB Audio [USB Audio]
card 2: MacMultiOut [macOS Multi-Output Device], device 0: ...

### Network Interfaces

$ ip link show | grep -E '^[0-9]+:'
1: lo: <LOOPBACK,UP,LOWER_UP> ...
2: enp5s0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
3: wlp6s0: <BROADCAST,MULTICAST> ...

---

**Verification procedure:**

1. Run the above commands on the target system.
2. Compare outputs to this baseline.
3. Investigate any deviations before deploying updates or changes.

---

## Appendix D — Documentation Conventions {#appendix-d--documentation-conventions}

Canonical summary of documentation rules used across this manual. See [Documentation Conventions](#documentation-conventions) for detailed guidance.

---

## Appendix E — Feature Specification Guide {#appendix-e--feature-specification-guide}

Lightweight template for feature specs: problem statement, goals/non‑goals, user impact, acceptance criteria, test plan, rollout and rollback.

---

## Appendix F — User Stories Template {#appendix-f--user-stories-template}

Story format: As a [role], I want [capability], so that [benefit]. Include acceptance tests and telemetry signals.

---

## Appendix G — Development Patterns & Copilot Usage {#appendix-g--development-patterns--copilot-usage}

Patterns: thin adapters, pure functions, idempotent scripts, minimal state, explicit interfaces. Copilot: draft, diff‑aware edits, tests‑first for public behavior.

---

## Appendix H — AI Agent Design (Future) {#appendix-h--ai-agent-design-future}

Outline for future multi‑agent orchestration: goals, tools/contracts, memory, safety rails, eval harness.
