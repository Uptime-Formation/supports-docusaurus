# 004 — TPs Advanced_2 : cert-manager + Vault

## Scope

- **110_tp_matin.md** : cert-manager avec CA auto-signée (pas de dépendance domaine/internet)
- **210_tp_apres_midi.md** : Vault en mode dev + Vault Secrets Operator
- Cilium et Istio : abandonnés — nécessitent un cluster dédié

## Workflow

Scripts dans `/tmp/TP-Advanced2/` — copiés et testés sur le serveur remote, puis rédigés dans les fichiers TP.

## État

### cert-manager (110_tp_matin.md)

| Étape | Script | Status |
|---|---|---|
| 01 — Installer cert-manager | stage-cm-01.sh | ✅ |
| 02 — ClusterIssuers Let's Encrypt | stage-cm-02.sh | ✅ |
| 03 — Déployer rancher-demo + Ingress TLS | stage-cm-03.sh | ✅ |
| 04 — Observer la chaîne cert-manager | stage-cm-04.sh | ✅ |

### Vault (210_tp_apres_midi.md)

| Étape | Script | Status |
|---|---|---|
| 01 — Reinstall k3s + etcd + etcdctl | stage-01.sh | ✅ |
| 02 — Secret en clair dans etcd | stage-02.sh | ✅ |
| 03 — Reinstall avec --secrets-encryption | stage-03.sh | ✅ |
| 04 — Vault dev + secret via API | stage-04.sh | ✅ |
| 05 — VSO + VaultStaticSecret | stage-05.sh | ✅ |
| 06 — Pod + rotation automatique | stage-06.sh | ✅ |

## Statut global : ✅ Les deux TPs rédigés et testés
