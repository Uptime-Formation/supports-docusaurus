# 002 — Kubernetes Advanced : contenus en attente

Sujets identifiés lors de la session de nettoyage (mai 2026). À traiter quand un TP backing existe ou quand le format est décidé.

> **Hors périmètre** : `docs/5_Kubernetes-Advanced/` (avec tiret) — ne pas toucher.

## En attente

### 1. GitOps platform from scratch
**Fichier** : `docs/5_Kubernetes_Advanced_1/100_cours_matin.md` — déplacé après Observabilité
**Contenu rédigé** :
- Structure repo multi-env (Kustomize overlays + Helm values files)
- App of Apps pattern, limites, mention ApplicationSet
- Promotion entre environnements (branches vs dossiers, script CI)
- Secrets GitOps : Sealed Secrets vs External Secrets Operator, piège rechargement en mémoire

**Statut** : ✅ Terminé (2026-05-18)

---

### 2. Packaging clusters — Full IaC
**Fichier** : `docs/5_Kubernetes_Advanced_2/100_cours_matin.md` — section "Installation de Kubernetes" restructurée
**Contenu rédigé** :
- Question de fond managed vs self-managed, cas de justification du self-managed
- Spectre à 5 niveaux : kubeadm → outils génériques (Kubespray, k3s, k0s) → OS natifs (Talos, Flatcar) → progiciels (RKE2, OpenShift, Tanzu) → services managés
- Approche Full IaC : Terraform (infra) + Kubespray/Talos (K8s) + ArgoCD bootstrap (composants cluster)
- Note sur la gestion des secrets de bootstrapping (SOPS, Vault)

**Statut** : ✅ Terminé (2026-05-18)

---

### 3. Multi-cluster : PS1 et context switching
**Fichier** : `docs/5_Kubernetes_Advanced_2/100_cours_matin.md`
**Contenu rédigé** :
- Kubeconfig multi-fichiers, variable `KUBECONFIG`, fusion avec `--flatten`
- kubectx / kubens : installation, usage, sélection interactive avec fzf
- Starship et PS1 natif pour afficher le contexte dans le prompt
- k9s en multi-cluster, `:ctx` pour switcher à chaud
- Bonnes pratiques de nommage des contextes, tableau exemples

**Statut** : ✅ Terminé (2026-05-18)

---

### 4. DevSecOps pour les workloads existants
**Fichier** : `docs/5_Kubernetes_Advanced_2/200_cours_apres_midi.md`
**Décision** : stub supprimé — le contenu était une méthodologie de projet, pas un cours technique. Les outils (Trivy, Falco, Network Policies, Vault) sont déjà couverts ailleurs.
**Remplacement** : conclusion de fin de journée "Greenfield vs Brownfield" ajoutée en fin de fichier — synthèse en 3 paragraphes sur comment appliquer les mêmes outils selon le contexte.

**Statut** : ✅ Terminé (2026-05-18)

---

### 5. Placement des pods dans le cluster / Topologie
**Fichier** : `docs/4_Kubernetes_Dev/200_cours_apres_midi.md` — section "Topologie des workloads"
**Contenu rédigé** :
- Taints/Tolerations et Node Affinity (déjà présents)
- Topology Spread Constraints (déjà présent)
- Pod Anti-Affinity : contrainte dure (`required`) et souple (`preferred`), exemples YAML, note sur `IgnoredDuringExecution`
- Tip avancé : Kyverno `ClusterPolicy` `insert-pod-antiaffinity` pour injecter l'anti-affinité automatiquement sur tous les Deployments

**Statut** : ✅ Terminé (2026-05-18)

---

### 6. Sidecars en initContainers avec restart policy
**Fichier** : `docs/4_Kubernetes_Bases/200_cours_apres_midi.md` — section "Les Pods"
**Contenu rédigé** :
- Pattern sidecar classique (app + logs + proxy), tableau des rôles, exemple YAML Fluent Bit
- Sidecar natif K8s ≥ 1.29 : `initContainers` avec `restartPolicy: Always`
- Cycle de vie hybride (démarre avant app, reste actif, SIGTERM après app)
- Tableau comparatif sidecar classique vs natif

**Statut** : ✅ Terminé (2026-05-17)
