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

# Table of Contents

- [AI Meeting Assistant – System Design \& Operations Manual](#ai-meeting-assistant--system-design--operations-manual)
  - [Summary](#summary)
- [Table of Contents](#table-of-contents)
  - [Section 1: System Overview](#section-1-system-overview)
  - [Objectives and success criteria](#objectives-and-success-criteria)
  - [Non-goals](#non-goals)
  - [Core features](#core-features)
  - [Hardware and environment assumptions](#hardware-and-environment-assumptions)
  - [Cost model and licensing](#cost-model-and-licensing)
  - [Key decisions](#key-decisions)
  - [ASR plan with faster-whisper on this hardware](#asr-plan-with-faster-whisper-on-this-hardware)
  - [Risks and mitigations](#risks-and-mitigations)
  - [Operability and maintainability](#operability-and-maintainability)
  - [Interfaces and external dependencies](#interfaces-and-external-dependencies)
  - [Section sign-off checklist](#section-sign-off-checklist)
  - [Section 2: Hardware \& Environment Baseline](#section-2-hardware--environment-baseline)
    - [2.1 Primary Workstation](#21-primary-workstation)
    - [2.2 Secondary Systems](#22-secondary-systems)
    - [2.3 Future Expansion](#23-future-expansion)
    - [2.4 Audio Path Topology](#24-audio-path-topology)
    - [2.5 Environment Configuration](#25-environment-configuration)
      - [ROCm GPU-Accelerated faster‑whisper (Primary Path)](#rocm-gpu-accelerated-fasterwhisper-primary-path)
  - [Section 2: Hardware \& Environment Baseline](#section-2-hardware--environment-baseline-1)
    - [2.1 Primary Workstation](#21-primary-workstation-1)
    - [2.2 Secondary Systems](#22-secondary-systems-1)
    - [2.3 Future Expansion](#23-future-expansion-1)
    - [2.4 Audio Path Topology](#24-audio-path-topology-1)
    - [2.5 Environment Configuration](#25-environment-configuration-1)
      - [ROCm GPU-Accelerated faster‑whisper (Primary Path)](#rocm-gpu-accelerated-fasterwhisper-primary-path-1)
      - [Reference Whisper (Fallback Path)](#reference-whisper-fallback-path)
    - [2.6 Storage Layout](#26-storage-layout)
    - [2.7 CPU/GPU Allocation](#27-cpugpu-allocation)
    - [2.8 Networking \& Security](#28-networking--security)
    - [2.9 Cost Considerations](#29-cost-considerations)
    - [2.10 Key Decisions](#210-key-decisions)
    - [2.11 Section Sign-off Checklist](#211-section-sign-off-checklist)
  - [Section 3: Functional Requirements](#section-3-functional-requirements)
    - [3.1 Audio Capture](#31-audio-capture)
    - [3.2 Audio Pre‑Processing](#32-audio-preprocessing)
    - [3.3 Automatic Speech Recognition (ASR)](#33-automatic-speech-recognition-asr)
    - [3.4 Natural Language Processing (NLP)](#34-natural-language-processing-nlp)
    - [3.5 Storage \& Archival](#35-storage--archival)
    - [3.6 Search \& Retrieval](#36-search--retrieval)
    - [3.7 Calendar Integration](#37-calendar-integration)
    - [3.8 Integrations](#38-integrations)
    - [3.9 Learning \& Adaptation](#39-learning--adaptation)
    - [3.10 Guardrails](#310-guardrails)
    - [3.11 Section Sign‑off Checklist](#311-section-signoff-checklist)
  - [Section 4: Non‑Functional Requirements](#section-4-nonfunctional-requirements)
    - [4.1 Performance](#41-performance)
    - [4.2 Reliability \& Availability](#42-reliability--availability)
    - [4.3 Security \& Privacy](#43-security--privacy)
    - [4.4 Maintainability](#44-maintainability)
    - [4.5 Observability](#45-observability)
    - [4.6 Usability](#46-usability)
    - [4.7 Cost Constraints](#47-cost-constraints)
    - [4.8 Section Sign‑off Checklist](#48-section-signoff-checklist)
  - [Section 5: High‑Level Architecture](#section-5-highlevel-architecture)
    - [5.1 Architectural Layers](#51-architectural-layers)
    - [5.2 Data Flow Overview](#52-data-flow-overview)
    - [5.3 Deployment Topology](#53-deployment-topology)
    - [5.4 Key Design Decisions](#54-key-design-decisions)
    - [5.5 Section Sign‑off Checklist](#55-section-signoff-checklist)
  - [Section 6: Audio Pipeline Design](#section-6-audio-pipeline-design)
    - [6.1 Objectives](#61-objectives)
    - [6.2 Physical Audio Path](#62-physical-audio-path)
    - [6.3 Audio Server \& Routing](#63-audio-server--routing)
    - [6.4 Pre‑Processing Chain](#64-preprocessing-chain)
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
    - [8.3 Observability](#83-observability)
    - [8.4 Error Bundles](#84-error-bundles)
    - [8.5 Recovery Procedures](#85-recovery-procedures)
    - [8.6 Section Sign‑off Checklist](#86-section-signoff-checklist)
  - [Section 9: Deployment \& Environment Strategy](#section-9-deployment--environment-strategy)
    - [9.1 Objectives](#91-objectives)
    - [9.2 Runtime Profiles](#92-runtime-profiles)
    - [9.3 Environment Pinning (Updated for Current Kernel)](#93-environment-pinning-updated-for-current-kernel)
      - [9.3.1 Tested‑Good Environment Matrix](#931-testedgood-environment-matrix)
      - [9.3.2 Pinning Strategy](#932-pinning-strategy)
      - [9.3.3 Validation Commands](#933-validation-commands)
      - [9.3.4 Documentation](#934-documentation)
      - [9.3.5 Upgrade Policy](#935-upgrade-policy)
    - [9.4 Deployment Steps (Workstation‑Live)](#94-deployment-steps-workstationlive)
    - [9.5 Automation Hooks](#95-automation-hooks)
    - [9.6 Future Server Integration](#96-future-server-integration)
    - [9.7 Section Sign‑off Checklist](#97-section-signoff-checklist)
  - [Section 10: Burn‑In \& Validation Plan](#section-10-burnin--validation-plan)
    - [10.1 Objectives](#101-objectives)
    - [10.2 Burn‑In Duration \& Scope](#102-burnin-duration--scope)
    - [10.3 Test Categories](#103-test-categories)
    - [10.4 Metrics to Capture](#104-metrics-to-capture)
    - [10.5 Validation Commands](#105-validation-commands)
    - [10.6 Pass/Fail Criteria](#106-passfail-criteria)
    - [10.7 Documentation \& Sign‑off](#107-documentation--signoff)
    - [10.8 Section Sign‑off Checklist](#108-section-signoff-checklist)
  - [Section 11: Steady‑State Operations](#section-11-steadystate-operations)
    - [11.1 Objectives](#111-objectives)
    - [11.2 Daily Routine](#112-daily-routine)
    - [11.3 Weekly Routine](#113-weekly-routine)
    - [11.4 Monthly Routine](#114-monthly-routine)
    - [11.5 Monitoring \& Alerts](#115-monitoring--alerts)
    - [11.6 Minor Troubleshooting](#116-minor-troubleshooting)
    - [11.7 Documentation Updates](#117-documentation-updates)
    - [11.8 Section Sign‑off Checklist](#118-section-signoff-checklist)
  - [Section 12: Hypercare \& Incident Response](#section-12-hypercare--incident-response)
    - [12.1 Objectives](#121-objectives)
    - [12.2 Hypercare Period](#122-hypercare-period)
    - [12.3 Incident Severity Levels](#123-incident-severity-levels)
    - [12.4 Incident Response Workflow](#124-incident-response-workflow)
    - [12.5 Communication Protocol](#125-communication-protocol)
    - [12.6 Tooling](#126-tooling)
    - [12.7 Exit Criteria for Hypercare](#127-exit-criteria-for-hypercare)
    - [12.8 Section Sign‑off Checklist](#128-section-signoff-checklist)
  - [Section 13: Maintenance \& Upgrade Policy](#section-13-maintenance--upgrade-policy)
    - [13.1 Objectives](#131-objectives)
    - [13.2 Maintenance Schedule](#132-maintenance-schedule)
    - [13.3 Upgrade Policy](#133-upgrade-policy)
    - [13.4 Compatibility Testing](#134-compatibility-testing)
    - [13.5 Documentation Requirements](#135-documentation-requirements)
    - [13.6 Security Maintenance](#136-security-maintenance)
    - [13.7 Hardware Lifecycle](#137-hardware-lifecycle)
    - [13.8 End‑of‑Life (EOL) Planning](#138-endoflife-eol-planning)
    - [13.9 Section Sign‑off Checklist](#139-section-signoff-checklist)
  - [Section 14: Documentation \& Knowledge Management](#section-14-documentation--knowledge-management)
    - [14.1 Objectives](#141-objectives)
    - [14.2 Documentation Structure](#142-documentation-structure)
    - [14.3 Version Control](#143-version-control)
    - [14.4 Update Policy](#144-update-policy)
    - [14.5 Onboarding Materials](#145-onboarding-materials)
    - [14.6 Knowledge Sharing](#146-knowledge-sharing)
    - [14.7 Archival Policy](#147-archival-policy)
    - [14.8 Section Sign‑off Checklist](#148-section-signoff-checklist)
  - [Section 15: Future Roadmap](#section-15-future-roadmap)
    - [15.1 Objectives](#151-objectives)
    - [15.2 Short‑Term (0–6 months)](#152-shortterm-06-months)
    - [15.3 Medium‑Term (6–18 months)](#153-mediumterm-618-months)
    - [15.4 Long‑Term (18+ months)](#154-longterm-18-months)
    - [15.5 Guiding Principles for Roadmap Execution](#155-guiding-principles-for-roadmap-execution)
    - [15.6 Section Sign‑off Checklist](#156-section-signoff-checklist)
  - [Section 16: Risk Management](#section-16-risk-management)
    - [16.1 Objectives](#161-objectives)
    - [16.2 Risk Categories](#162-risk-categories)
    - [16.3 Risk Assessment Matrix](#163-risk-assessment-matrix)
    - [16.4 Preventive Measures](#164-preventive-measures)
    - [16.5 Contingency Plans](#165-contingency-plans)
    - [16.6 Monitoring for Early Warning](#166-monitoring-for-early-warning)
    - [16.7 Section Sign‑off Checklist](#167-section-signoff-checklist)
  - [Section 17: Decommissioning \& Migration](#section-17-decommissioning--migration)
    - [17.1 Objectives](#171-objectives)
    - [17.2 Triggers for Decommissioning](#172-triggers-for-decommissioning)
    - [17.3 Pre‑Decommissioning Checklist](#173-predecommissioning-checklist)
    - [17.4 Migration Process](#174-migration-process)
    - [17.5 Post‑Migration Decommissioning](#175-postmigration-decommissioning)
    - [17.6 Risk Mitigation](#176-risk-mitigation)
    - [17.7 Section Sign‑off Checklist](#177-section-signoff-checklist)
  - [Section 18: Appendix](#section-18-appendix)
    - [18.1 Reference commands](#181-reference-commands)
    - [18.2 Environment variables](#182-environment-variables)
    - [18.3 File and directory layout](#183-file-and-directory-layout)
    - [18.4 Known‑good version triplets](#184-knowngood-version-triplets)
    - [18.5 Glossary](#185-glossary)
    - [18.6 External references](#186-external-references)
    - [18.7 Section sign‑off checklist](#187-section-signoff-checklist)
  - [Appendix A – Meeting Assistant Build Script v1.0 Setup \& Configuration](#appendix-a--meeting-assistant-build-script-v10-setup--configuration)
    - [1. Purpose](#1-purpose)
    - [2. Prerequisites](#2-prerequisites)
    - [3. Script Location \& Permissions](#3-script-location--permissions)
    - [4. Running the Script](#4-running-the-script)
    - [5. What the Script Does](#5-what-the-script-does)
    - [6. Configuration Files](#6-configuration-files)
    - [7. Directory Layout After Build](#7-directory-layout-after-build)
    - [8. Post‑Install Validation](#8-postinstall-validation)
    - [9. Troubleshooting](#9-troubleshooting)
    - [10. Component Test Scripts](#10-component-test-scripts)
  - [Appendix B – Quick Validation via Makefile](#appendix-b--quick-validation-via-makefile)
    - [1. Create `/opt/meeting-assistant/tests/` and place the test scripts:](#1-create-optmeeting-assistanttests-and-place-the-test-scripts)
    - [2. Create a Makefile in `/opt/meeting-assistant/tests/Makefile`:](#2-create-a-makefile-in-optmeeting-assistanttestsmakefile)
    - [3. Run all tests:](#3-run-all-tests)



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
- **Real-time ASR:** faster-whisper (CTranslate2) with quantization for low-latency, CPU-first on this workstation; GPU offload deferred to a future NVIDIA A6000 server.
- **Audio processing:** RNNoise, AEC3 echo cancellation, WebRTC VAD, 48 kHz dual-mono.
- **Summarization:** Audience-aware prompts (Exec/Product/Technical), action/decision extraction, meeting timeline, highlights.
- **Calendar context:** Microsoft Graph API primary; .ics export automation fallback; pre-meeting context packets (T-10 min).
- **Search and archive:** File-based immutable transcripts with checksums; semantic + keyword index; namespace separation (work/personal).
- **Integrations:** Draft emails, Confluence/JIRA ticket drafts (dry-run + approval).

---

## Hardware and environment assumptions

- **Workstation:** Ubuntu 24.04, AMD RX 7900 XTX (ROCm stack pinned), fast NVMe, ZFS/RAID pool, validated firmware, reproducible environments (containers/venv).
- **WorkMac:** Primary conferencing endpoint; provides far-end audio via USB sound card → CM106 line-in; macOS Multi-Output Device for simultaneous speakers + USB out.
- **Networking:** Local-only; optional Tailscale for remote admin by you. No third-party relays for meeting content.
- **Storage:** Tiered (NVMe scratch, HDD/ZFS archive), nightly snapshot/backup.

---

## Cost model and licensing

- **Software stack:** Open-source, local-first (PipeWire, RNNoise, WebRTC AEC/VAD, faster-whisper via CTranslate2, vector DB/library, web UI).
- **Recurring costs:** Optional low-cost email SMTP relay (<$10/mo) if desired; otherwise local MTA.
- **Licensing:** Respect OSS licenses; store explicit versions/checksums in a local model registry.

---

## Key decisions

| Area | Decision | Rationale | Implication |
|------|----------|-----------|-------------|
| ASR engine | faster-whisper (CTranslate2) | Highest throughput on CPU with quantization; simple packaging; deterministic | Run on CPU on this AMD workstation; plan GPU offload when NVIDIA A6000 server is added |
| Quantization | INT8/INT8_float16 | Lower latency and RAM; acceptable accuracy trade-off | Tune per model; maintain per-meeting latency SLAs |
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

- **ASR engine chosen:** faster-whisper (CPU-first here; CUDA when NVIDIA server exists).
- **Privacy posture:** Local-only processing; no cloud LLM/ASR.
- **Calendar strategy:** Graph primary; .ics automated fallback with failover/notify thresholds.
- **Audio topology:** WorkMac → USB → CM106 (far) + mic interface (near); AEC3; RNNoise; VAD; 48 kHz.
- **Success metrics and SLAs:** Defined and testable during burn-in.
- **Cost envelope:** Open-source stack; optional <$10/mo relay; no required SaaS.

## Section 2: Hardware & Environment Baseline

This section defines the physical and software environment in which the meeting assistant will operate. All specifications, constraints, and decisions are based on the actual hardware in use and the requirement to run locally with no recurring cost (except for optional minimal-cost services). It also includes a fallback build path for the reference Whisper implementation in case faster‑whisper encounters ROCm issues.

---

### 2.1 Primary Workstation

- **OS:** Ubuntu 24.04 LTS (primary boot)
- **CPU:** ≥ 8 physical cores / 16 threads desktop-class processor
- **GPU:** AMD RX 7900 XTX (24 GB VRAM) with ROCm stack pinned to validated version
- **RAM:** ≥ 64 GB DDR5 (ECC preferred)
- **Storage:**
  - **Tier 1:** NVMe SSD (≥ 1 TB) for OS, active workloads, scratch space
  - **Tier 2:** HDD/ZFS RAID pool (≥ 8 TB usable) for archive and backups
- **Audio I/O:**
  - CM106 USB sound card (line-in for far-end audio from WorkMac)
  - Dedicated USB audio interface for near-end microphone
- **Networking:** Gigabit Ethernet preferred; Wi-Fi as backup
- **Firmware:** Validated and documented versions for motherboard, GPU, and storage controllers

---

### 2.2 Secondary Systems

- **Dual-boot Windows:** For daily driver tasks, gaming, and Windows-only utilities; not used for meeting assistant runtime.
- **WorkMac:** Used for hosting/conducting meetings (Teams, Zoom, Google Meet, Slack).
  - Configured with macOS Multi-Output Device to send audio to both speakers and USB sound card simultaneously.
  - USB sound card output feeds CM106 line-in on Ubuntu workstation for far-end capture.

---

### 2.3 Future Expansion

- **Standalone AI Server:**
  - OS: Ubuntu LTS
  - GPU: NVIDIA RTX A6000 (48 GB VRAM) or equivalent
  - RAM: ≥ 128 GB ECC
  - Role: Multi-user, multi-device model serving; heavy summarization; archival reprocessing
  - Networking: LAN + optional Tailscale for secure remote access
  - Storage: NVMe tier for active workloads; large HDD/ZFS pool for archive

---

### 2.4 Audio Path Topology

**Far-end (remote participants):**
- WorkMac conferencing app output → macOS Multi-Output Device → USB sound card → CM106 line-in (Ubuntu)

**Near-end (local mic):**
- Microphone → USB audio interface → Ubuntu

**Processing:**
- PipeWire/WirePlumber manages both devices with persistent node names.
- RNNoise noise suppression on near-end.
- WebRTC AEC3 echo cancellation using far-end as reference.
- WebRTC VAD for speech segmentation.

---

### 2.5 Environment Configuration

#### ROCm GPU-Accelerated faster‑whisper (Primary Path)
- **ROCm version:** 6.1.x (validated for RDNA3 / gfx1100)
- **Kernel:** Match ROCm compatibility matrix (e.g., Linux 6.8.x LTS)
- **CTranslate2:** ≥ 4.3.0 with ROCm backend enabled
- **faster‑whisper:** Matching CTranslate2 build; install via:

## Section 2: Hardware & Environment Baseline

This section defines the physical and software environment in which the meeting assistant will operate. All specifications, constraints, and decisions are based on the actual hardware in use and the requirement to run locally with no recurring cost (except for optional minimal-cost services). It also includes a fallback build path for the reference Whisper implementation in case faster‑whisper encounters ROCm issues.

---

### 2.1 Primary Workstation

- **OS:** Ubuntu 24.04 LTS (primary boot)
- **CPU:** ≥ 8 physical cores / 16 threads desktop-class processor
- **GPU:** AMD RX 7900 XTX (24 GB VRAM) with ROCm stack pinned to validated version
- **RAM:** ≥ 64 GB DDR5 (ECC preferred)
- **Storage:**
  - **Tier 1:** NVMe SSD (≥ 1 TB) for OS, active workloads, scratch space
  - **Tier 2:** HDD/ZFS RAID pool (≥ 8 TB usable) for archive and backups
- **Audio I/O:**
  - CM106 USB sound card (line-in for far-end audio from WorkMac)
  - Dedicated USB audio interface for near-end microphone
- **Networking:** Gigabit Ethernet preferred; Wi‑Fi as backup
- **Firmware:** Validated and documented versions for motherboard, GPU, and storage controllers

---

### 2.2 Secondary Systems

- **Dual-boot Windows:** For daily driver tasks, gaming, and Windows-only utilities; not used for meeting assistant runtime.
- **WorkMac:** Used for hosting/conducting meetings (Teams, Zoom, Google Meet, Slack).
  - Configured with macOS Multi-Output Device to send audio to both speakers and USB sound card simultaneously.
  - USB sound card output feeds CM106 line-in on Ubuntu workstation for far-end capture.

---

### 2.3 Future Expansion

- **Standalone AI Server:**
  - OS: Ubuntu LTS
  - GPU: NVIDIA RTX A6000 (48 GB VRAM) or equivalent
  - RAM: ≥ 128 GB ECC
  - Role: Multi-user, multi-device model serving; heavy summarization; archival reprocessing
  - Networking: LAN + optional Tailscale for secure remote access
  - Storage: NVMe tier for active workloads; large HDD/ZFS pool for archive

---

### 2.4 Audio Path Topology

**Far-end (remote participants):**
- WorkMac conferencing app output → macOS Multi-Output Device → USB sound card → CM106 line-in (Ubuntu)

**Near-end (local mic):**
- Microphone → USB audio interface → Ubuntu

**Processing:**
- PipeWire/WirePlumber manages both devices with persistent node names.
- RNNoise noise suppression on near-end.
- WebRTC AEC3 echo cancellation using far-end as reference.
- WebRTC VAD for speech segmentation.

---

### 2.5 Environment Configuration

#### ROCm GPU-Accelerated faster‑whisper (Primary Path)
- **ROCm version:** 6.1.x (validated for RDNA3 / gfx1100)
- **Kernel:** Match ROCm compatibility matrix (e.g., Linux 6.8.x LTS)
- **CTranslate2:** ≥ 4.3.0 with ROCm backend enabled
- **faster‑whisper:** Matching CTranslate2 build; install via:
~~~bash
pip install faster-whisper --extra-index-url https://download.pytorch.org/whl/rocm6.1
~~~
- **Environment variables:**
~~~bash
export CT2_USE_ROCM=1
export HSA_OVERRIDE_GFX_VERSION=11.0.0
~~~
- **Model sizing:**
  - Live: `medium.en` fp16 or int8_float16
  - Batch: `large-v3` fp16
- **Quantization:** int8_float16 for live to reduce VRAM; fp16 for archival accuracy
- **Expected throughput (RX 7900 XTX ROCm 6.1):**
  - medium.en fp16: ~2–3× real-time
  - large-v3 fp16: ~1.5–2× real-time

#### Reference Whisper (Fallback Path)
If ROCm faster‑whisper becomes unstable:
- **PyTorch ROCm build:**
~~~bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1
~~~
- **Whisper install:**
~~~bash
pip install git+https://github.com/openai/whisper.git
~~~
- **Environment variables:**
~~~bash
export HIP_VISIBLE_DEVICES=0
export HSA_OVERRIDE_GFX_VERSION=11.0.0
~~~
- **Model sizing:**
  - Live: `small.en` fp16 for latency control
  - Batch: `medium.en` or `large-v3` fp16
- **Trade-offs:** Higher VRAM use and slower inference than faster‑whisper; simpler debugging path if CTranslate2 ROCm backend fails.

---

### 2.6 Storage Layout

| Tier | Purpose | Media | Size | Notes |
|------|---------|-------|------|-------|
| Tier 1 | OS, active workloads, scratch | NVMe SSD | ≥ 1 TB | High IOPS, low latency |
| Tier 2 | Archive, backups | HDD/ZFS RAID | ≥ 8 TB usable | Redundancy (RAID-Z2 or RAID6) |
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
| ASR engine | faster‑whisper ROCm | Best performance/stability on RDNA3 with ROCm 6.1 | GPU-accelerated live transcription |
| Fallback ASR | Reference Whisper PyTorch ROCm | Simpler debug path if CTranslate2 ROCm fails | Higher latency, more VRAM use |
| Audio routing | Physical USB loop from WorkMac | Reliable, OS-independent, works across all conferencing apps | Requires stable cabling and device naming |
| Storage | ZFS RAID for archive | Data integrity, snapshots, easy expansion | Slightly higher RAM usage for ARC |
| Networking | LAN-first, optional Tailscale | Low latency, secure remote admin | No dependency on public IP or port forwarding |

---

### 2.11 Section Sign-off Checklist

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

### 3.2 Audio Pre‑Processing

- **Noise suppression**:
  - RNNoise applied to near‑end channel.
- **Echo cancellation**:
  - WebRTC AEC3 using far‑end as reference; convergence < 1 s, ≥ 20 dB suppression.
- **Voice activity detection (VAD)**:
  - WebRTC VAD for speech segmentation and ASR load reduction.
- **Channel alignment**:
  - Drift correction between near/far channels to maintain AEC performance.

---

### 3.3 Automatic Speech Recognition (ASR)

- **Primary engine**:
  - faster‑whisper (CTranslate2 ROCm) with int8_float16 quantization for live; fp16 for archival.
- **Fallback engine**:
  - Reference Whisper (PyTorch ROCm) with fp16 precision.
- **Latency targets**:
  - Live: p50 ≤ 1.5 s, p95 ≤ 2.5 s from speech to transcript segment.
- **Accuracy targets**:
  - ≥ 90% of segments at confidence ≥ 0.85 on domain audio.
- **Language model**:
  - English‑only (`*.en` models) for improved speed and accuracy.

---

### 3.4 Natural Language Processing (NLP)

- **Summarization**:
  - Audience‑aware summaries (Exec, Product, Technical) using tailored prompts.
- **Action/decision extraction**:
  - Structured JSON output with timestamps and speaker attribution.
- **Meeting timeline**:
  - Chronological list of key points with time offsets.
- **Adaptive model selection**:
  - Choose summarization model based on meeting type, audience, and feedback loop.

---

### 3.5 Storage & Archival

- **Immutable transcripts**:
  - JSONL format with per‑segment metadata and checksums.
- **Namespace separation**:
  - Work vs personal meeting archives stored in separate directories.
- **Retention policy**:
  - Raw PCM retained 7–14 days; compressed audio and transcripts archived long‑term.
- **Indexing**:
  - Keyword and semantic vector indexes for fast search.

---

### 3.6 Search & Retrieval

- **Search modes**:
  - Keyword search across transcripts.
  - Semantic search via local vector store.
  - Decision‑only filter for action items.
- **Performance**:
  - Query latency ≤ 1 s for keyword; ≤ 2 s for semantic on local index.

---

### 3.7 Calendar Integration

- **Primary source**:
  - Microsoft Graph API for event metadata and join links.
- **Fallback**:
  - Automated `.ics` export/import if Graph API unavailable > 2 h.
- **Pre‑meeting context packets**:
  - Generated T‑10 min with agenda, participants, and past meeting summaries.

---

### 3.8 Integrations

- **Draft outputs**:
  - Email summaries, Confluence pages, JIRA tickets.
- **Approval workflow**:
  - All external pushes require manual approval in UI.
- **Dry‑run mode**:
  - Generate integration payloads without sending.

---

### 3.9 Learning & Adaptation

- **Feedback capture**:
  - User ratings on summaries and action items.
- **Adaptive prompts**:
  - Modify summarization prompts based on feedback trends.
- **Model performance tracking**:
  - Maintain win‑rate stats for model selection.

---

### 3.10 Guardrails

- **Resource protection**:
  - Pause non‑critical jobs if GPU load > 85% during live ASR.
- **Disk space alerts**:
  - Trigger cleanup or alert at < 10% free space.
- **Job queue health**:
  - Monitor for stuck or failed jobs; retry or move to DLQ.

---

### 3.11 Section Sign‑off Checklist

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

### 4.1 Performance

- **ASR latency targets (live transcription)**:
  - p50 ≤ 1.5 s from speech to text segment.
  - p95 ≤ 2.5 s from speech to text segment.
- **Summarization turnaround**:
  - ≤ 60 s from meeting end to full summary (actions, decisions, highlights).
- **Search query latency**:
  - Keyword search ≤ 1 s.
  - Semantic search ≤ 2 s.
- **Throughput**:
  - Support continuous transcription for meetings up to 4 h without degradation.
- **Resource utilization**:
  - GPU load ≤ 85% during live ASR.
  - CPU load ≤ 80% sustained during live capture/processing.

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

### 4.3 Security & Privacy

- **Local‑only processing**:
  - No meeting audio or transcripts sent to external cloud services.
- **Encryption**:
  - Archive storage encrypted at rest (ZFS native encryption or LUKS).
  - Backups encrypted before offsite transfer.
- **Access control**:
  - Role‑based access to UI and CLI.
  - Separate namespaces for work vs personal data.
- **Audit logging**:
  - All access to transcripts and summaries logged with timestamp and user ID.

---

### 4.4 Maintainability

- **Reproducibility**:
  - Pinned ROCm, kernel, CTranslate2, and model versions.
  - Containerized services with version‑locked images.
- **Documentation**:
  - System manual (this file), audio pipeline doc, burn‑in plan, steady‑state ops guide, hypercare quick refs.
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

### 5.1 Architectural Layers

1. **Capture Layer**
   - **Inputs**:
     - Near‑end microphone via USB audio interface.
     - Far‑end WorkMac audio via USB sound card → CM106 line‑in.
   - **Audio server**: PipeWire with WirePlumber session manager.
   - **Pre‑processing**:
     - RNNoise noise suppression (near‑end).
     - WebRTC AEC3 echo cancellation (far‑end reference).
     - WebRTC VAD for speech segmentation.
   - **Output**: Dual‑mono 48 kHz audio frames to ASR queue.

2. **Processing Layer**
   - **ASR Service**:
     - Primary: faster‑whisper (CTranslate2 ROCm) with int8_float16 for live, fp16 for batch.
     - Fallback: Reference Whisper (PyTorch ROCm).
     - Outputs timestamped text segments with confidence scores.
   - **NLP Workers**:
     - Summarization (Exec/Product/Technical profiles).
     - Action/decision extraction.
     - Meeting timeline generation.
   - **Scheduler/Queue**:
     - Prioritizes live ASR over batch jobs.
     - Supports retry and DLQ for failed jobs.

3. **Storage Layer**
   - **Transcript archive**:
     - JSONL per meeting with per‑segment metadata and checksums.
   - **Audio archive**:
     - Raw PCM (short‑term), compressed audio (long‑term).
   - **Indexes**:
     - Keyword index (inverted file).
     - Semantic vector store for similarity search.
   - **Namespaces**:
     - Separate storage for work and personal meetings.

4. **Integration Layer**
   - **Calendar sync**:
     - Primary: Microsoft Graph API.
     - Fallback: `.ics` import/export automation.
   - **External outputs**:
     - Draft emails, Confluence pages, JIRA tickets (dry‑run + approval).
   - **Notification system**:
     - Desktop notifications for meeting start, ASR failover, summary ready.

5. **Control Layer**
   - **Web UI**:
     - Status dashboard (capture, ASR, NLP, integrations).
     - Search and retrieval interface.
     - Approval workflow for integrations.
   - **CLI tools**:
     - Start/stop capture.
     - Re‑process meetings.
     - Search archive.

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
| ASR | faster‑whisper ROCm primary | Best performance on RDNA3 with ROCm 6.1 | GPU‑accelerated live transcription |
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
- WorkMac conferencing app output → macOS Multi‑Output Device → USB sound card → CM106 line‑in (Ubuntu).

**Near‑end (local mic)**:
- Microphone → USB audio interface → Ubuntu.

---

### 6.3 Audio Server & Routing

- **PipeWire** as the audio server for low‑latency routing.
- **WirePlumber** session manager for persistent device profiles.
- **Persistent node naming** rules to ensure consistent device IDs across reboots.
- **Static gain staging** applied at the PipeWire level to prevent clipping.

---

### 6.4 Pre‑Processing Chain

1. **Noise Suppression**:
   - RNNoise applied to near‑end channel.
   - Tuned for conversational speech; minimal distortion.

2. **Echo Cancellation**:
   - WebRTC AEC3 with far‑end channel as reference.
   - Convergence target: < 1 s.
   - Echo suppression target: ≥ 20 dB.

3. **Voice Activity Detection (VAD)**:
   - WebRTC VAD to segment speech and reduce ASR load.
   - Sensitivity tuned to minimize false positives in silence.

4. **Channel Alignment**:
   - Drift correction between near/far channels to maintain AEC performance.

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

- **Device monitoring**:
  - Alert if expected devices are not present at meeting start.
- **Gain monitoring**:
  - Alert if input levels exceed ‑3 dBFS for > 1 s.
- **AEC health**:
  - Log convergence time and suppression level; alert if below target.

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
- [x] Guardrails for device, gain, and AEC health set.
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
- **Live mode**: `medium.en` int8_float16 for balance of speed and accuracy.  
- **Batch mode**: `large-v3` fp16 for archival re‑processing.  
- **Quantization**:  
  - Live: int8_float16 to reduce VRAM and latency.  
  - Batch: fp16 for maximum accuracy.  
- **Expected Throughput (RX 7900 XTX ROCm 6.1)**:  
  - medium.en int8_float16: ~3–4× real‑time.  
  - large-v3 fp16: ~1.5–2× real‑time.

**Fallback Engine**:  
- **Reference Whisper** (PyTorch ROCm build)  
- **Live mode**: `small.en` fp16 for latency control.  
- **Batch mode**: `medium.en` or `large-v3` fp16.  
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

**Resource Protection**
- **GPU load threshold**:  
  - If GPU utilization > 85% during live ASR, pause or defer non‑critical NLP and indexing jobs.
- **CPU load threshold**:  
  - If CPU load > 80% sustained, reduce ASR batch size or switch to smaller model.
- **Memory usage**:  
  - Alert if free system RAM < 10% or VRAM < 1 GB during live capture.

**Disk Space Management**
- **Threshold alerts**:  
  - Trigger warning at < 15% free space; critical alert at < 10%.
- **Automated cleanup**:  
  - Purge expired raw PCM beyond retention window; clear temp caches.

**ASR Continuity**
- **Latency guard**:  
  - If p95 ASR latency > 2.5 s for 30 s, auto‑switch to smaller model.
- **Confidence guard**:  
  - Flag meeting if > 10% of segments have confidence < 0.85.

**Queue Health**
- **Stuck job detection**:  
  - Alert if job in queue > 2× expected processing time.
- **Dead‑letter queue (DLQ)**:  
  - Failed jobs moved to DLQ with full error bundle for review.

---

### 8.3 Observability

**Logging**
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

**Metrics**
- GPU/CPU utilization
- ASR latency (p50, p95)
- Summarization latency
- Queue depth
- Disk usage
- AEC3 convergence time and suppression level

**Dashboards**
- Grafana/Prometheus stack for real‑time visualization.
- Panels for:
  - Resource usage
  - ASR performance
  - NLP throughput
  - Queue health
  - Disk space trends

**Alerts**
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
| **Workstation‑batch** | Same | Full GPU at idle | Archival re‑summaries (large‑v3 fp16), bulk reindex, backfills | Nightly cron or manual batch mode |
| **Server‑offload** | Future standalone GPU box | ASR local; heavy jobs remote | Live ASR + light NLP local; heavy summarization/indexing remote | Same queue semantics; gRPC over LAN |
| **Server‑primary** | Future box as primary | Dedicated GPUs per pool | Everything runs on server; workstation UI only | Multi‑user, role‑based access |

---

### 9.3 Environment Pinning (Updated for Current Kernel)

Your current kernel is:

- **Kernel**: `6.11.0-1027-oem`

This kernel is newer than the ROCm 6.1.x GA/LTS recommendations, so it must be explicitly tested and documented.

#### 9.3.1 Tested‑Good Environment Matrix

| ROCm Version | Kernel Version         | GPU Architecture | CTranslate2 Version | faster‑whisper Version | Status       | Notes |
|--------------|------------------------|------------------|---------------------|------------------------|--------------|-------|
| 6.1.2        | 6.8.x LTS (GA)         | RDNA3 gfx1100    | ≥ 4.3.0              | Match CTranslate2      | ✅ Stable    | Officially supported combo |
| 6.1.2        | 6.11.0-1027-oem        | RDNA3 gfx1100    | ≥ 4.3.0              | Match CTranslate2      | ⚠ Testing   | Works in initial tests; monitor for HIP errors |
| 6.0.x        | 6.5.x LTS              | RDNA3 gfx1100    | ≥ 4.2.0              | Match CTranslate2      | ✅ Stable    | Slightly older stack; slower than 6.1.x |

#### 9.3.2 Pinning Strategy

- **Primary target**: ROCm 6.1.2 + Kernel 6.11.0-1027-oem + CTranslate2 4.3.0+  
  - Use if stability confirmed in burn‑in tests.
- **Fallback target**: ROCm 6.1.2 + Kernel 6.8.x LTS + CTranslate2 4.3.0+  
  - Boot into this kernel if instability occurs with 6.11.0‑1027‑oem.

#### 9.3.3 Validation Commands

~~~bash
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
~~~

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
   - Confirm audio devices present and correctly named.
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

## Section 10: Burn‑In & Validation Plan

This section defines the process for verifying that the meeting assistant is stable, performant, and production‑ready on the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture. The burn‑in phase is designed to surface hardware, driver, and pipeline issues before live deployment, and to establish baseline performance metrics for future regression testing.

---

### 10.1 Objectives

- Validate **end‑to‑end functionality** of the capture → ASR → NLP → archive → integration pipeline.
- Confirm **stability** of ROCm + kernel + CTranslate2 + faster‑whisper under sustained load.
- Establish **baseline performance metrics** for latency, accuracy, and resource usage.
- Identify and resolve **environment‑specific issues** before production use.

---

### 10.2 Burn‑In Duration & Scope

- **Duration**: Minimum 7 consecutive days of simulated and real meeting workloads.
- **Scope**:
  - Live capture from WorkMac (dual‑channel audio).
  - Continuous ASR processing with faster‑whisper ROCm.
  - NLP summarization and indexing.
  - Integration dry‑runs (no external pushes).
  - Fallback ASR tests with PyTorch ROCm Whisper.

---

### 10.3 Test Categories

**1. Functional Tests**
- Verify audio device detection and persistent naming.
- Confirm RNNoise, AEC3, and VAD are active and producing expected results.
- Validate ASR output format (JSONL with timestamps, confidence scores).
- Check NLP outputs for all audience profiles (Exec, Product, Technical).
- Ensure archive storage and indexing complete without errors.

**2. Performance Tests**
- Measure ASR latency (p50, p95) under live conditions.
- Measure summarization turnaround time post‑meeting.
- Record GPU/CPU utilization during peak load.
- Track disk I/O during capture and archival.

**3. Stability Tests**
- Run back‑to‑back meetings without restarting services.
- Simulate network interruptions for calendar sync.
- Stress test with long meetings (≥ 4 h).
- Monitor for HIP errors, kernel module crashes, or audio dropouts.

**4. Failover Tests**
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

~~~bash
# Monitor GPU utilization
watch -n 1 rocm-smi

# Monitor CPU utilization
htop

# Check ASR latency in logs
grep "latency" /var/log/meeting-assistant/asr.log

# Verify ROCm health
rocminfo | grep -i gfx
clinfo | grep -i 'gfx\|Device'
~~~

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

### 11.7 Documentation Updates

- Update `docs/ops-log.md` with:
  - Any incidents and resolutions.
  - Changes to hardware, software, or configuration.
  - Performance anomalies and corrective actions.

---

### 11.8 Section Sign‑off Checklist

- [x] Daily, weekly, and monthly routines defined.
- [x] Monitoring and alerting procedures documented.
- [x] Minor troubleshooting guide included.
- [x] Documentation update process specified.

## Section 12: Hypercare & Incident Response

This section defines the short‑term heightened monitoring period immediately following production go‑live (“hypercare”), and the structured process for responding to incidents in the meeting assistant system. It applies to the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture, running GPU‑accelerated faster‑whisper via ROCm as the primary ASR engine.

---

### 12.1 Objectives

- Provide **rapid detection and resolution** of issues during the critical early adoption phase.
- Minimize **impact on live meetings** by ensuring swift failover and recovery.
- Capture **root cause data** for all incidents to prevent recurrence.
- Transition smoothly from hypercare to steady‑state operations (Section 11).

---

### 12.2 Hypercare Period

- **Duration**: First 30 calendar days after production go‑live.
- **Monitoring intensity**:
  - Real‑time dashboards open during all meetings.
  - Daily review of logs and metrics.
  - Immediate alert escalation for any critical event.
- **Change control**:
  - No non‑critical upgrades or configuration changes during hypercare.
  - All changes documented in `docs/hypercare-change-log.md`.

---

### 12.3 Incident Severity Levels

| Severity | Description | Example | Response Target |
|----------|-------------|---------|-----------------|
| **Critical (P1)** | Outage or severe degradation affecting live meetings | ASR service crash with no failover | Immediate, < 5 min |
| **High (P2)** | Major feature impaired, workaround available | Calendar sync failure, fallback to `.ics` | < 30 min |
| **Medium (P3)** | Minor feature impaired, no impact on core | Dashboard panel not updating | < 4 h |
| **Low (P4)** | Cosmetic or documentation issue | Typo in UI | Next maintenance window |

---

### 12.4 Incident Response Workflow

1. **Detection**:
   - Automated alerts (metrics thresholds, health checks).
   - User reports via UI feedback or direct message.
2. **Triage**:
   - Assign severity level.
   - Identify affected components (capture, ASR, NLP, integrations).
3. **Containment**:
   - Activate failover (e.g., switch to fallback ASR).
   - Pause non‑critical workloads if resource contention.
4. **Resolution**:
   - Apply fix or workaround.
   - Validate system health and performance.
5. **Recovery**:
   - Resume normal operations.
   - Monitor closely for recurrence.
6. **Post‑mortem**:
   - Document root cause, resolution steps, and prevention plan in `docs/incidents/YYYY-MM-DD-ID.md`.

---

### 12.5 Communication Protocol

- **Internal**:
  - Critical/High: Immediate notification via desktop alert + email.
  - Medium/Low: Logged in daily ops report.
- **External**:
  - If incident affects meeting output, notify impacted stakeholders with:
    - Summary of issue.
    - Impacted timeframe.
    - Resolution status.

---

### 12.6 Tooling

- **Monitoring**: Grafana/Prometheus dashboards.
- **Logging**: Structured JSONL logs with correlation IDs.
- **Alerting**: Desktop notifications + email relay.
- **Ticketing**: Local issue tracker for incident logging and follow‑up.

---

### 12.7 Exit Criteria for Hypercare

- No Critical (P1) or High (P2) incidents in the final 14 days of hypercare.
- All Medium/Low incidents resolved or scheduled for resolution.
- Baseline performance metrics consistently met or exceeded.
- Stakeholder sign‑off on readiness for steady‑state operations.

---

### 12.8 Section Sign‑off Checklist

- [x] Hypercare duration and monitoring intensity defined.
- [x] Incident severity levels and examples documented.
- [x] Incident response workflow specified.
- [x] Communication protocol for internal/external stakeholders set.
- [x] Tooling for monitoring, logging, alerting, and ticketing listed.
- [x] Exit criteria for hypercare established.

## Section 13: Maintenance & Upgrade Policy

This section defines the long‑term maintenance and upgrade strategy for the meeting assistant system running on the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture. It ensures the environment remains stable, secure, and performant while accommodating hardware and software evolution.

---

### 13.1 Objectives

- Keep the system **secure, stable, and performant** over its lifecycle.
- Maintain **reproducibility** by controlling and documenting all changes.
- Minimize **downtime** during upgrades.
- Ensure **compatibility** between ROCm, kernel, CTranslate2, faster‑whisper, and NLP models.

---

### 13.2 Maintenance Schedule

| Frequency | Task |
|-----------|------|
| **Weekly** | Review logs for warnings/errors; check disk space; verify backups; run index health check. |
| **Monthly** | Audit environment versions against pinned configuration; test failover; review security posture. |
| **Quarterly** | Apply OS security updates; update container base images; re‑validate ROCm + kernel pairing. |
| **Annually** | Hardware inspection (fans, thermals, cabling); review storage capacity; evaluate hardware upgrade needs. |

---

### 13.3 Upgrade Policy

**General Principles**:
- **Test before production**: All upgrades tested in staging or on alternate boot environment.
- **One change at a time**: Avoid simultaneous upgrades of kernel, ROCm, and CTranslate2.
- **Rollback ready**: Maintain previous kernel and ROCm packages for quick reversion.

**Order of Operations**:
1. Upgrade **kernel** only if required for security, hardware support, or ROCm compatibility.
2. Upgrade **ROCm** to match AMD’s compatibility matrix for the target kernel.
3. Upgrade **CTranslate2** and **faster‑whisper** to versions built against the new ROCm.
4. Upgrade **NLP models** only after ASR stack is stable.

---

### 13.4 Compatibility Testing

- **Functional tests**:
  - Dual‑channel audio capture.
  - RNNoise, AEC3, VAD operation.
  - ASR transcription accuracy and latency.
- **Performance tests**:
  - GPU/CPU utilization under load.
  - Summarization turnaround.
- **Stability tests**:
  - 2‑hour continuous meeting simulation.
  - Failover to fallback ASR.

---

### 13.5 Documentation Requirements

For every upgrade:
- Record:
  - Date/time of change.
  - Components upgraded (with versions).
  - Reason for upgrade.
  - Test results (pass/fail).
- Store in `docs/upgrade-log.md`.
- Update `docs/environment-baseline.md` if pinned versions change.

---

### 13.6 Security Maintenance

- Apply OS security patches monthly (or sooner if critical).
- Keep firewall rules and access controls reviewed quarterly.
- Rotate encryption keys and credentials annually or after suspected compromise.

---

### 13.7 Hardware Lifecycle

- **Workstation**:
  - Expected lifecycle: 4–5 years.
  - Mid‑cycle upgrades: Storage expansion, RAM increase.
- **Future AI server**:
  - Expected lifecycle: 5–6 years.
  - GPU upgrades aligned with model VRAM requirements.

---

### 13.8 End‑of‑Life (EOL) Planning

- **Software EOL**:
  - Migrate to supported OS/ROCm/kernel before EOL date.
- **Hardware EOL**:
  - Plan replacement 6–12 months before expected failure risk increases.
- **Data migration**:
  - Validate archive integrity after migration.

---

### 13.9 Section Sign‑off Checklist

- [x] Maintenance schedule defined (weekly, monthly, quarterly, annually).
- [x] Upgrade policy with order of operations documented.
- [x] Compatibility testing requirements listed.
- [x] Documentation requirements for upgrades specified.
- [x] Security maintenance tasks defined.
- [x] Hardware lifecycle expectations set.
- [x] EOL planning process documented.

## Section 14: Documentation & Knowledge Management

This section defines how all operational knowledge, configurations, and historical records for the meeting assistant are created, maintained, and shared. It ensures that the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture can be operated, maintained, and evolved by you or any future maintainer without loss of context or reproducibility.

---

### 14.1 Objectives

- Maintain **complete, accurate, and up‑to‑date documentation** for all components.
- Ensure **reproducibility** of the environment and workflows.
- Provide **clear onboarding materials** for new operators or maintainers.
- Preserve **historical records** for audits, troubleshooting, and future upgrades.

---

### 14.2 Documentation Structure

**Core Documents** (stored in `docs/` directory in version control):
- **System Manual**: This document, covering architecture, requirements, and procedures.
- **Environment Baseline**: Current pinned versions of kernel, ROCm, CTranslate2, faster‑whisper, NLP models, and container images.
- **Upgrade Log**: Chronological record of all upgrades, changes, and test results.
- **Ops Log**: Daily/weekly operational notes, incidents, and resolutions.
- **Burn‑In Report**: Results from Section 10 validation.
- **Incident Reports**: One file per incident, with root cause and prevention plan.
- **Audio Pipeline Guide**: Detailed setup and calibration instructions.
- **Integration Guide**: Configuration for calendar sync, external outputs, and approval workflows.

---

### 14.3 Version Control

- All documentation stored in **Git** repository alongside configuration files.
- Changes tracked via commits with descriptive messages.
- Tags used for major environment changes (e.g., `env-2025-09-18`).
- Branching model:
  - `main` for production‑ready docs.
  - `staging` for draft updates pending validation.

---

### 14.4 Update Policy

- **Immediate updates**:
  - After any change to environment, configuration, or workflow.
  - After resolving incidents or applying fixes.
- **Scheduled reviews**:
  - Monthly review of all core documents for accuracy.
  - Quarterly review of onboarding materials.

---

### 14.5 Onboarding Materials

- **Quick‑start guide**:
  - Step‑by‑step instructions for starting/stopping the system.
  - Common troubleshooting steps.
- **Architecture overview**:
  - Diagram and description of capture → ASR → NLP → archive → integration flow.
- **Role‑specific guides**:
  - Operator: Daily/weekly routines, monitoring, and alerts.
  - Maintainer: Upgrade process, environment pinning, and rollback.
  - Developer: Adding/modifying NLP models, integrations, or UI features.

---

### 14.6 Knowledge Sharing

- **Internal wiki** (optional):
  - Mirrors `docs/` content for easier browsing.
  - Includes FAQs and “lessons learned” section.
- **Change announcements**:
  - Email or chat notifications for significant updates.
- **Training sessions**:
  - Live or recorded walkthroughs for new features or processes.

---

### 14.7 Archival Policy

- **Immutable archives**:
  - Store historical versions of all core documents.
- **Retention**:
  - Keep all documentation indefinitely unless superseded by major system redesign.
- **Access control**:
  - Read‑only access for historical archives; write access restricted to maintainers.

---

### 14.8 Section Sign‑off Checklist

- [x] Documentation structure defined with core documents listed.
- [x] Version control strategy specified.
- [x] Update policy for immediate and scheduled changes documented.
- [x] Onboarding materials outlined for different roles.
- [x] Knowledge sharing methods described.
- [x] Archival policy for historical documents set.

## Section 15: Future Roadmap

This section outlines the planned evolution of the meeting assistant beyond its initial deployment on the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture. It covers short‑, medium‑, and long‑term enhancements, hardware expansion, and potential new capabilities, while maintaining the core principles of local‑only processing, reproducibility, and maintainability.

---

### 15.1 Objectives

- Guide the **strategic growth** of the system in alignment with your long‑term goals.
- Prioritize **high‑impact features** that improve usability, accuracy, and integration.
- Ensure **hardware and software scalability** without compromising stability.
- Maintain **clear documentation** and reproducibility at every stage.

---

### 15.2 Short‑Term (0–6 months)

- **Finalize ROCm stability** on Kernel 6.11.0‑1027‑oem and document as tested‑good.
- **UI enhancements**:
  - Real‑time transcript view with speaker labels.
  - Live confidence and latency indicators.
- **Improved NLP prompts** for more concise, audience‑specific summaries.
- **Integration refinements**:
  - Streamlined approval workflow for external pushes.
  - Optional Slack/Teams notifications for meeting summaries.
- **Expanded search**:
  - Add fuzzy keyword matching.
  - Improve semantic search accuracy with domain‑specific embeddings.

---

### 15.3 Medium‑Term (6–18 months)

- **Standalone AI server deployment**:
  - NVIDIA RTX A6000 or equivalent.
  - Multi‑user, multi‑device model serving.
  - Heavy summarization and archival re‑processing offloaded from workstation.
- **Multi‑language ASR**:
  - Add support for non‑English meetings with automatic language detection.
- **Adaptive ASR model switching**:
  - Dynamically choose model size based on meeting type and resource load.
- **Advanced NLP features**:
  - Sentiment analysis.
  - Topic clustering for long meetings.
- **Integration expansion**:
  - Direct export to project management tools (Asana, Trello).
  - API for third‑party integrations.

---

### 15.4 Long‑Term (18+ months)

- **Personal AI cloud**:
  - Always‑on, private AI services for family and work.
  - Unified authentication and role‑based access.
- **IoT integration**:
  - Voice‑activated meeting controls.
  - Smart room devices for automated recording start/stop.
- **Cross‑platform capture**:
  - Native capture agents for Windows and macOS feeding into central ASR/NLP pipeline.
- **Self‑optimizing pipeline**:
  - Automated tuning of ASR/NLP parameters based on historical performance.
- **Knowledge graph**:
  - Link meeting content to related documents, emails, and prior discussions.

---

### 15.5 Guiding Principles for Roadmap Execution

- **Local‑first**: All processing remains on owned hardware unless explicitly approved for offload.
- **Reproducibility**: Every change documented with environment snapshots.
- **Security by default**: Encryption, access control, and audit logging for all new features.
- **Modularity**: New components added as independent services to minimize impact on core pipeline.
- **User feedback loop**: Feature prioritization driven by operator and stakeholder input.

---

### 15.6 Section Sign‑off Checklist

- [x] Short‑term enhancements listed and prioritized.
- [x] Medium‑term expansion goals defined.
- [x] Long‑term vision articulated.
- [x] Guiding principles for roadmap execution documented.

## Section 16: Risk Management

This section identifies potential risks to the meeting assistant system, assesses their likelihood and impact, and defines mitigation and contingency plans. It applies to the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture, running GPU‑accelerated faster‑whisper via ROCm as the primary ASR engine.

---

### 16.1 Objectives

- Proactively identify **technical, operational, and security risks**.
- Assess **likelihood** and **impact** to prioritize mitigation.
- Define **preventive measures** and **contingency plans**.
- Maintain **system resilience** and **business continuity**.

---

### 16.2 Risk Categories

**1. Technical Risks**
- **ROCm/kernel incompatibility** after updates.
- **GPU hardware failure** (RX 7900 XTX or future A6000).
- **Audio device enumeration changes** breaking capture pipeline.
- **Model regression** after upgrading faster‑whisper or NLP models.

**2. Operational Risks**
- **Disk space exhaustion** due to unpurged raw audio or logs.
- **Operator error** during configuration changes.
- **Missed meetings** due to calendar sync failure.

**3. Security & Privacy Risks**
- **Unauthorized access** to transcripts or archives.
- **Data leakage** via misconfigured integrations.
- **Loss of encrypted backups** or keys.

**4. External Risks**
- **Power outages** during meetings.
- **Network outages** affecting calendar sync or integrations.
- **Supply chain delays** for replacement hardware.

---

### 16.3 Risk Assessment Matrix

| Risk | Likelihood | Impact | Priority | Mitigation | Contingency |
|------|------------|--------|----------|------------|-------------|
| ROCm/kernel incompatibility | Medium | High | High | Pin versions; test in staging | Boot into known‑good kernel |
| GPU hardware failure | Low | High | High | Maintain spare GPU or backup ASR path | Switch to CPU ASR; expedite RMA |
| Audio device re‑enumeration | Medium | Medium | Medium | Persistent PipeWire node naming | Manual remap before meeting |
| Model regression | Medium | Medium | Medium | Canary test before rollout | Rollback to previous model |
| Disk space exhaustion | Medium | High | High | Weekly cleanup; alerts at 15% | Purge temp files; expand storage |
| Unauthorized access | Low | High | High | RBAC; encryption; firewall | Revoke access; restore from backup |
| Power outage | Low | High | Medium | UPS for workstation | Resume from archive; re‑process audio |
| Network outage | Medium | Low | Low | Local cache of calendar events | Manual meeting start |

---

### 16.4 Preventive Measures

- **Version pinning** for ROCm, kernel, CTranslate2, and models.
- **Automated cleanup** of expired raw audio and temp files.
- **UPS** to protect against short power interruptions.
- **RBAC and encryption** for all sensitive data.
- **Staging environment** for testing upgrades.
- **Spare audio interface** and cables on‑hand.

---

### 16.5 Contingency Plans

- **ASR failover**: Switch to fallback PyTorch ROCm Whisper within 10 s.
- **Kernel rollback**: Boot into known‑good kernel from GRUB menu.
- **Manual capture**: Use portable recorder if workstation unavailable.
- **Offline mode**: Continue capture/ASR without calendar sync; merge metadata later.
- **Hardware replacement**: Maintain vendor support contracts for GPUs and storage.

---

### 16.6 Monitoring for Early Warning

- **Logs**: Watch for HIP errors, kernel module warnings, audio device changes.
- **Metrics**: Track GPU/CPU utilization, ASR latency, disk usage.
- **Alerts**: Trigger on thresholds defined in Section 8.

---

### 16.7 Section Sign‑off Checklist

- [x] Risks identified across technical, operational, security, and external categories.
- [x] Risk assessment matrix completed with priorities.
- [x] Preventive measures documented.
- [x] Contingency plans defined.
- [x] Early warning monitoring points specified.

## Section 17: Decommissioning & Migration

This section defines the process for retiring the current meeting assistant deployment on the Ubuntu 24.04 + AMD RX 7900 XTX workstation with WorkMac far‑end capture, and migrating workloads, data, and configurations to a new environment if required. It ensures that decommissioning is controlled, secure, and fully documented, with no loss of critical data or functionality.

---

### 17.1 Objectives

- Ensure **secure and complete data migration** to the target environment.
- Prevent **data loss** or **service disruption** during transition.
- Maintain **auditability** and **reproducibility** of the retired system.
- Dispose of or repurpose hardware in a **secure and environmentally responsible** manner.

---

### 17.2 Triggers for Decommissioning

- **Hardware EOL**: Workstation or components reach end of lifecycle (see Section 13.7).
- **Platform migration**: Move to standalone AI server or cloud‑adjacent private cluster.
- **Major redesign**: Architecture changes incompatible with current environment.
- **Security compliance**: Requirement to upgrade to newer OS/kernel/ROCm stack.

---

### 17.3 Pre‑Decommissioning Checklist

- [ ] Confirm target environment is fully operational and tested.
- [ ] Validate that all pinned versions and configurations are documented.
- [ ] Verify backups of:
  - Transcripts and audio archives.
  - Indexes (keyword and semantic).
  - Configuration files and environment variables.
  - Documentation (`docs/` directory).
- [ ] Confirm encryption keys and credentials are securely stored and accessible.
- [ ] Notify stakeholders of planned migration timeline.

---

### 17.4 Migration Process

1. **Freeze changes**:
   - Stop non‑critical updates and configuration changes.
   - Pause batch jobs to prevent divergence.
2. **Data export**:
   - Use ZFS send/receive or rsync for archives and indexes.
   - Export database dumps if applicable.
3. **Configuration export**:
   - Copy all configs, environment files, and container manifests.
4. **Validation on target**:
   - Run functional and performance tests.
   - Verify ASR/NLP outputs match baseline.
5. **Cutover**:
   - Switch calendar sync and integrations to target environment.
   - Redirect UI/CLI access.
6. **Parallel run (optional)**:
   - Operate both environments for 1–2 weeks to confirm stability.

---

### 17.5 Post‑Migration Decommissioning

- **Data sanitization**:
  - Securely wipe disks (e.g., `shred`, `blkdiscard`, or ZFS `zpool destroy` with encryption key discard).
- **Hardware repurpose or disposal**:
  - Reassign to non‑production role or recycle per e‑waste guidelines.
- **License and account cleanup**:
  - Remove any environment‑specific credentials or API keys.
- **Final documentation**:
  - Archive final environment baseline and decommissioning report.

---

### 17.6 Risk Mitigation

- Maintain **rollback plan** to revert to old environment if migration fails.
- Keep **read‑only access** to old environment for 30 days post‑cutover.
- Validate **data integrity** with checksums before and after migration.

---

### 17.7 Section Sign‑off Checklist

- [x] Triggers for decommissioning defined.
- [x] Pre‑decommissioning checklist created.
- [x] Migration process documented.
- [x] Post‑migration cleanup and hardware disposal steps defined.
- [x] Risk mitigation measures specified.


## Section 18: Appendix

This appendix contains reference material, command snippets, configuration templates, and other supporting information for the meeting assistant system.

---

### 18.1 Reference commands

**System health**
```bash
# Check kernel version
uname -r

# Check ROCm GPU detection
rocminfo | grep -i gfx

# Check OpenCL device visibility
clinfo | grep -i 'gfx\|Device'

# Monitor GPU utilization
watch -n 1 rocm-smi

# Monitor CPU utilization
htop
```

**Audio devices**
```bash
# List PipeWire devices
pw-cli ls Node | grep -i alsa

# Verify persistent device names
pactl list short sources
pactl list short sinks
```

**ASR quick test**
```bash
python3 - <<'EOF'
from faster_whisper import WhisperModel
model = WhisperModel("medium.en", device="auto", compute_type="int8_float16")
segments, info = model.transcribe("test.wav")
print(f"Detected language: {info.language}, Duration: {info.duration}")
EOF
```

---

### 18.2 Environment variables

**faster‑whisper ROCm**
```bash
export CT2_USE_ROCM=1
export HSA_OVERRIDE_GFX_VERSION=11.0.0
```

**Fallback Whisper (PyTorch ROCm)**
```bash
export HIP_VISIBLE_DEVICES=0
export HSA_OVERRIDE_GFX_VERSION=11.0.0
```

---

### 18.3 File and directory layout

```
/opt/meeting-assistant/
├── config/                  # YAML/ENV configs
├── models/                  # ASR and NLP models
├── logs/                    # Structured JSONL logs
├── archive/
│   ├── transcripts/         # JSONL transcripts
│   ├── audio/               # Compressed audio
│   └── raw/                 # Short-term PCM
├── scripts/                 # Utility scripts
└── docs/                    # Documentation
```

---

### 18.4 Known‑good version triplets

| ROCm Version | Kernel Version     | CTranslate2 Version | faster‑whisper Version | Status    |
|--------------|--------------------|---------------------|------------------------|-----------|
| 6.1.2        | 6.8.x LTS          | ≥ 4.3.0             | Match CTranslate2      | ✅ Stable |
| 6.1.2        | 6.11.0-1027-oem    | ≥ 4.3.0             | Match CTranslate2      | ⚠ Testing |
| 6.0.x        | 6.5.x LTS          | ≥ 4.2.0             | Match CTranslate2      | ✅ Stable |

---

### 18.5 Glossary

- **AEC3:** Acoustic Echo Cancellation, version 3 (WebRTC).
- **ASR:** Automatic Speech Recognition.
- **CT2:** CTranslate2, inference engine used by faster‑whisper.
- **DLQ:** Dead‑Letter Queue, holding failed jobs for review.
- **NLP:** Natural Language Processing.
- **RNNoise:** Lightweight neural network noise suppression.
- **ROCm:** Radeon Open Compute, AMD’s GPU compute stack.
- **VAD:** Voice Activity Detection.

---

### 18.6 External references

- AMD ROCm Documentation: https://rocmdocs.amd.com  
- CTranslate2 Documentation: https://opennmt.net/CTranslate2/  
- faster‑whisper GitHub: https://github.com/guillaumekln/faster-whisper  
- Whisper GitHub: https://github.com/openai/whisper  
- PipeWire Documentation: https://docs.pipewire.org/  
- WebRTC AEC3 Overview: https://webrtc.org/

---

### 18.7 Section sign‑off checklist

- [x] Reference commands for health checks and testing included.  
- [x] Environment variables for primary and fallback ASR documented.  
- [x] File and directory layout specified.  
- [x] Known‑good version triplets listed.  
- [x] Glossary of key terms provided.  
- [x] External references linked.  

## Appendix A – Meeting Assistant Build Script v1.0 Setup & Configuration

_This appendix documents the installation, configuration, and validation steps for the hardened build script located at:_
`/home/brent/ai-assistant-project/specs/build-meeting-assistant-v1.0.sh`

### 1. Purpose
This script automates the installation and configuration of a ROCm‑accelerated meeting assistant environment on Ubuntu 24.04, including:
- ROCm runtime detection/installation
- Audio stack setup
- Building **CTranslate2** and **faster‑whisper** from source
- Downloading Whisper models
- Generating a build manifest
- Running GPU inference validation

### 2. Prerequisites
**Hardware:** AMD GPU supported by ROCm (≥16 GB VRAM recommended for `whisper-large-v2`)  
**OS:** Ubuntu 24.04 LTS with root privileges  
**Network:** Internet access to `repo.radeon.com`, `github.com`, and `huggingface.co`

### 3. Script Location & Permissions
```bash
chmod +x /home/brent/ai-assistant-project/specs/build-meeting-assistant-v1.0.sh
```

### 4. Running the Script
Basic run:
```bash
sudo /home/brent/ai-assistant-project/specs/build-meeting-assistant-v1.0.sh
```
With logging:
```bash
sudo /home/brent/ai-assistant-project/specs/build-meeting-assistant-v1.0.sh \
  | tee ~/meeting-assistant-build-$(date +%F_%H-%M-%S).log
```

### 5. What the Script Does
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

### 6. Configuration Files
ROCm env: `/etc/profile.d/rocm_env.sh`  
Logs: `/opt/meeting-assistant/logs/`  
Manifest: `/opt/meeting-assistant/wheels/`

### 7. Directory Layout After Build
```
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

### 8. Post‑Install Validation
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

### 9. Troubleshooting
| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| No GPU in `rocminfo` | ROCm not installed or unsupported GPU | Check ROCm docs |
| Model download fails | Missing Hugging Face token | `huggingface-cli login` |
| Wheel build fails | Missing deps | `apt --fix-broken install` |
| GPU test uses CPU | ROCm env not loaded | `source /etc/profile.d/rocm_env.sh` |

### 10. Component Test Scripts

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

### 1. Create `/opt/meeting-assistant/tests/` and place the test scripts:
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

### 2. Create a Makefile in `/opt/meeting-assistant/tests/Makefile`:
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

### 3. Run all tests:
```bash
cd /opt/meeting-assistant/tests
make validate
```

This will:
1. Activate the correct venv for each engine
2. Run the GPU/device detection tests
3. Confirm audio file readability

If any step fails, you’ll see the error immediately, making it easier to isolate the problem.
