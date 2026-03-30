# 001 - Kubernetes Split

## 1. Workflow, Constraints & Objectives

**Objective**: Restructure the existing Kubernetes training content into 4 distinct formations:
- **Kubernetes Bases**
- **Kubernetes Développeur**
- **Kubernetes Tips**
- **Kubernetes Avancé**

**Target structure per formation**:
- Each formation = 1 full day of work
- Each day = 2 half-days = 2 TPs minimum (morning TP + afternoon TP)
- Morning half-days are usually shorter
- TPs are central — course content supports them, not the other way around

**Constraints**:
- No assumptions about file content — explore with user before assigning
- Each file goes into exactly one target (no duplication)
- No file content modified during restructuring — move/rename only
- Directory naming follows project convention: `X_Module_Name/`
- Numeric prefixes must be consistent within each target folder
- Every structural decision requires user validation before execution

**Workflow**:
1. Explore source directories together, file by file
2. User decides which file goes where
3. Record the mapping here (section 3)
4. User validates the full mapping
5. Execute moves with `git mv`
6. Verify with `npm start`

---

## 2. How to Do It

- Show the user the file list of one source directory at a time
- For each file: read title/first lines, present to user, ask for target
- Record decisions in section 3 as we go
- Only execute moves once the full mapping is validated by user
- Use `git mv` to preserve git history
- Test navigation after moves

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

### File mapping
_To be filled during exploration_

| Source file | Target formation | Notes |
|---|---|---|
| | | |

---

## 4. Plan & Progress

- [ ] **Step 1** — Define what goes in each target formation (with user)
- [ ] **Step 2** — Explore source dirs with user, assign each file
- [ ] **Step 3** — User validates full mapping
- [ ] **Step 4** — Execute moves with `git mv`
- [ ] **Step 5** — Verify build and navigation (`npm start`)
- [ ] **Step 6** — Clean up empty/obsolete directories
