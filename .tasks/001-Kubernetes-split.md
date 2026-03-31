# 001 - Kubernetes Split

## 1. Workflow, Constraints & Objectives

**Objective**: Restructure the existing Kubernetes training content into 4 distinct formations:
- **Kubernetes Bases**
- **Kubernetes Développeur**
- **Kubernetes Tips**
- **Kubernetes Avancé**

**Target structure per formation**:
- Each formation = 1 full day of work (Avancé = 2 days)
- Each day = 2 half-days = exactly **2 cours + 2 TPs** per day
- Each half-day = 1 cours file + 1 TP file
- Morning half-days are usually shorter
- TPs are central — course content supports them, not the other way around
- **Do not add more files than this structure allows** — max 4 content files per day (2 cours + 2 TP)

**Constraints**:
- No assumptions about file content — explore with user before assigning
- Each file goes into exactly one target (no duplication)
- No file content modified during restructuring — move/rename only
- Directory naming follows project convention: `X_Module_Name/`
- Numeric prefixes must be consistent within each target folder
- Every structural decision requires user validation before execution

**Workflow**:
1. For each target formation, create empty target files named `target_cours_[topic].md` and `target_tp_[topic].md` based on the pedagogical topics defined in section 3
2. For each source directory, read each file and match content against target files
3. If content matches and offers value: copy relevant content into the target file (no duplication, no invention)
4. If in doubt: ask the user before copying
5. Record all source→target mappings in section 3
6. User validates the full mapping and content
7. Rename target files to final names with numeric prefixes
8. Verify with `npm start`

---

## 2. How to Do It

- Create target files first (`target_cours_[topic].md`, `target_tp_[topic].md`) — one cours + one TP per half-day
- Each target formation has exactly **2 cours + 2 TPs** per day (max 4 content files per day)
- Read source files and extract only content that matches the target topic
- No duplication across target files — each piece of content goes to exactly one target
- No invention — only copy content that exists in source files
- Do not put too much information — be selective, the TP is the core unit
- When in doubt about a match, ask the user
- Record source→target decisions in section 3 as we go
- Use `git mv` or `cp` as appropriate (moves for unique content, copies for shared sources)
- Test navigation after final renaming

---

## 3. Sources and Targets

### Source directories
| Directory | Notes |
|---|---|
| `docs/3_Docker+Kube/` | Mixed Docker+Kube — only files 220+ are Kubernetes |
| `docs/4_CKAD/` | CKAD certification content |
| `docs/4_Kubernetes/` | Main Kubernetes course |
| `docs/4_Kubernetes_Bases/` | Currently empty |
| `docs/5_Kubernetes-Advanced/` | Advanced Kubernetes |

### Target formations

#### Kubernetes Bases — `docs/4_Kubernetes_Bases/`
Core concepts for beginners. 1 full day.
- Containers and Docker (why we need them)
- The need for Kubernetes (orchestration problem)
- Kubernetes architecture and patterns
- Core objects and concepts
- DevOps angle: **IaC** (declarative YAML, kubectl apply)
- Cluster mutualization: quotas and container limits (cgroups)
- Security: HTTPS, user certificates, user roles, namespaces as compartmentalization
- Add: Namespaces as a core concept in this formation
- Debugging: run interactive containers, kubectl exec
- CI/CD: understanding the platform advantage — everything is an API
- Multi-cluster: switch context, different kubeconfig files
- Packaging & templating: IaC is mandatory
- Cost & capacity: various ways to get a cluster
- **TP matin** : Running a basic pod workload — basics of kubeconfig
- **TP après-midi** : Deployment with a pod and two containers

#### Kubernetes Développeur — `docs/4_Kubernetes_Dev/`
Developer-focused usage. 1 full day.
- Starts from scratch, progressive discovery of main objects with general best practices
- ConfigMaps, Secrets
- Deployments with strategies
- StatefulSets, (Cron)Jobs
- Services and exposition via Ingress and Gateway
- Volumes and PVCs
- DevOps angle: **GitOps** (manage manifests via Git, ArgoCD or similar)
- Cluster mutualization: define resources (requests/limits) for workloads
- Security: image scanning, versioning for security, registry access in pods, secrets and external secrets, introduction to NetworkPolicy
- Debugging: common troubleshooting problems, logs, events
- CI/CD: IaC tools (Kustomize, Helm) and when to use them; build a deployment pipeline with promotion and environments
- Multi-cluster: different environments, different parameters
- Packaging & templating: pick your poison (Helm vs Kustomize)
- Cost & capacity: autoscaling
- **TP matin** : Jobs and Deployments
- **TP après-midi** : Expose an app with a PVC

#### Kubernetes Tips — `docs/4_Kubernetes_Tips/`
Practical tips, tricks, best practices. 1 full day.
- Source: `/home/alban/Documents/projets/RackFlow/80-99 Formation/K8S-docs/k8s best practices - rev 3b_.txt`
- Topics: image hygiene, resource requests/limits, liveness/readiness probes, namespaces, Git/GitOps for YAML, deprecated APIs, Ingress/Gateway, NetworkPolicy, hostPath/hostAccess, vulnerability scanning, cluster audit tools
- TPs and DevOps angle: TBD on the spot
- Cluster mutualization: QoS (Quality of Service classes)
- Security: in-depth NetworkPolicy
- Debugging: kubectl debug
- CI/CD: deploy Cloud resources with CrossPlane / Config Connector; rollback strategies
- Multi-cluster: use k9s and other tools
- Packaging & templating: (covered in CI/CD and Dev)

#### Kubernetes Avancé — `docs/5_Kubernetes_Advanced/`
Advanced topics. **2 full days.**
- DevOps angle: **DevSecOps**
- Cluster mutualization: eviction, topology, node typologies, cordon
- Security: DevSecOps — running old workloads, and more (TBD)
- Debugging: debugging nodes and operators
- CI/CD: deploy a GitOps platform from scratch
- Multi-cluster: use PS1 to show cluster and namespace
- Cost & capacity: right-sizing
- Packaging & templating: package your clusters — full IaC to streamline cluster provisioning

**Jour 1**
- Operator pattern
- Observability (logs, metrics)
- Autoscaling (HPA, VPA)
- **TP matin** : TBD
- **TP après-midi** : TBD

**Jour 2**
- Installing Kubernetes
- Network: CNI, Service Mesh, Certificates, in-depth Ingress and Gateway
- User management: roles, service accounts, team management
- Build your own operator
- **TP matin** : TBD
- **TP après-midi** : TBD

### File mapping — Kubernetes Développeur

#### Content topics checklist

- [x] ConfigMaps (création, utilisation comme env vars et volumes)
- [x] Secrets (création, types, utilisation dans pods)
- [ ] Deployments avec strategies (Recreate, RollingUpdate, paramètres) — covered in Bases, not repeated
- [x] StatefulSets (cas d'usage, headless service, stable identité)
- [x] Jobs et CronJobs
- [x] Services (ClusterIP, LoadBalancer) + DNS interne
- [x] Ingress (règles, TLS, annotations)
- [ ] Gateway API (intro, différences avec Ingress) — déplacé en Avancé
- [x] Volumes et PVCs (StorageClass, ReadWriteMany vs Once)
- [x] PersistentVolumes + dynamic provisioning

#### Transversal threads checklist

- [x] **GitOps** : gestion manifests via Git, intro ArgoCD
- [x] **Cluster mutualization** : requests/limits pour workloads
- [x] **Security** : image scanning (Trivy), versioning images, intro NetworkPolicy, SecurityContext
- [x] **Debugging** : troubleshooting commun, logs, events, kubectl describe
- [x] **CI/CD** : IaC tools (Kustomize, Helm), pipeline de déploiement avec promotion et environnements
- [x] **Multi-cluster** : différents environnements, différents paramètres (Kustomize overlays)
- [x] **Packaging & templating** : Helm vs Kustomize — choisir son outil
- [x] **Cost & capacity** : autoscaling (HPA)

#### Source files used

| Source file | Target file | Notes |
|---|---|---|
| `4_Kubernetes/144_cours_configuration_objects.md` | `100_cours_matin` | ConfigMaps + Secrets |
| `4_Kubernetes/152_cours_alt_pod_controllers.md` | `100_cours_matin` | Jobs, CronJobs, StatefulSets, DaemonSets |
| `4_Kubernetes/140_cours_k8s_storage.md` | `100_cours_matin` | Volumes, PVC, StorageClass |
| `4_CKAD/205_TP3.md` | `110_tp_matin` | ConfigMaps/Secrets/Volumes/SecurityContext |
| `4_CKAD/215_TP4.md` | `110_tp_matin` | StatefulSets/Redis/PVCs |
| `4_Kubernetes/142_cours_k8s_networks.md` | `200_cours_apres_midi` | Services, Ingress, certmanager, CNI |
| `4_Kubernetes/314_cours_opt_k8s_security.md` | `200_cours_apres_midi` | NetworkPolicy, RBAC, image security |
| `4_Kubernetes/150_cours_methodes_install_apps.md` | `200_cours_apres_midi` | Kustomize, Helm, Operators, CRDs |
| `4_Kubernetes/305_tp_opt_k8s_install_argocd.md` | `200_cours_apres_midi` | ArgoCD/GitOps concept |
| `4_Kubernetes/340_cours_opt_k8s_design_architecture_components.md` | `200_cours_apres_midi` | HPA/Metrics Server |
| `4_CKAD/305_TP5.md` | `210_tp_apres_midi` | NetworkPolicies/CronJobs |
| `4_CKAD/315_TP6.md` | `target_tp_apres_midi` | Ingress |
| `4_Kubernetes/112_tp_deploy_using_files.md` | already in Bases | skip |

---

### File mapping — Kubernetes Bases

| Source file | Target file | Notes |
|---|---|---|
| `3_Docker+Kube/101_Pourquoi_Docker_Les_pratiques_de_déploiement.md` | `target_cours_matin` | Deployment problem history |
| `3_Docker+Kube/103_Pourquoi_Docker_Qu_est_ce_qu_un_process.md` | `target_cours_matin` | Docker as process manager |
| `3_Docker+Kube/201_L_évolution_de_l_écosystème_des_orchestrateurs.md` | `target_cours_matin` | Why orchestration / why K8s |
| `3_Docker+Kube/220_histoire_k8s.md` | `target_cours_matin` | K8s history |
| `3_Docker+Kube/221_objectifs_k8s.md` | `target_cours_matin` | K8s objectives |
| `3_Docker+Kube/225_aperçu_de_K8S.md` | `target_cours_matin` | K8s overview |
| `4_Kubernetes/120_cours_different_cluster_types.md` | `target_cours_matin` | Cluster types / cost & capacity |
| `3_Docker+Kube/214_Passer_des_informations_Les_variables_d_environnement.md` | `target_cours_matin` | Env variables |
| `3_Docker+Kube/230_tp_k8s_cli.md` | `target_tp_matin` | kubectl CLI exploration |
| `4_CKAD/105_TP1.md` | `target_tp_matin` | Deploy single pod + kubeconfig |
| `3_Docker+Kube/240_le_langage_kubernetes.md` | `target_cours_apres_midi` | K8s API, YAML, kubectl apply |
| `3_Docker+Kube/250_cours_basic_deploy_objects.md` | `target_cours_apres_midi` | Pods, Deployments, Labels |
| `4_Kubernetes/112_tp_deploy_using_files.md` | `target_tp_apres_midi` | Deploy with YAML files |
| `4_CKAD/115_TP2.md` | `target_tp_apres_midi` | Deployment + scaling + probes + rollout |
| `3_Docker+Kube/108_*`, `109_*`, `110_*`, `121_*` | Docker formation | Docker internals — not for Bases |
| `4_CKAD/100_Day1_Matin.md`, `110_Day1_Apresmidi.md` | skipped | Agenda files, structure reference only |

---

## 4. Plan & Progress

- [ ] **Step 1** — Define what goes in each target formation (with user)
- [ ] **Step 2** — Explore source dirs with user, assign each file
- [ ] **Step 3** — User validates full mapping
- [ ] **Step 4** — Execute moves with `git mv`
- [ ] **Step 5** — Verify build and navigation (`npm start`)
- [ ] **Step 6** — Clean up empty/obsolete directories
