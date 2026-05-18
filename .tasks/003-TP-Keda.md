# 003 — TP Après-midi Advanced_1 : KEDA

## Objectif pédagogique

Un seul TP qui couvre simultanément :
- Le **pattern Operator** : KEDA s'installe via Helm, crée ses CRDs, sa boucle de réconciliation est observable
- Le **HPA** : KEDA crée un HPA Kubernetes sous-jacent automatiquement
- Les **métriques custom** : scaling sur autre chose que le CPU

## Plan du TP

1. Installer KEDA via Helm
2. Déployer une app simple (php-apache)
3. Créer un `ScaledObject` — observer que KEDA crée un HPA automatiquement
4. Générer de la charge et observer le scaling
5. Modifier les seuils, observer le flapping et le `stabilizationWindowSeconds`

## Workflow de développement

- Scripts dans `/tmp/TP-Keda/` (stage-01.sh, stage-02.sh, etc.)
- Copiés et testés sur le serveur remote
- Le fichier TP est créé dans `docs/5_Kubernetes_Advanced_1/210_tp_apres_midi.md` quand tout fonctionne

## État

| Étape | Script | Status |
|---|---|---|
| 01 — Namespace + Metrics Server | stage-01.sh | ✅ |
| 02 — Installer KEDA | stage-02.sh | ✅ |
| 03 — Déployer php-apache | stage-03.sh | ✅ |
| 04 — ScaledObject + observer HPA | stage-04.sh | ✅ |
| 05 — Générer charge + observer scaling | stage-05.sh | ✅ |

## TODO cours théorique

Ajouter une section KEDA dans `docs/5_Kubernetes_Advanced_1/200_cours_apres_midi.md` :
- Après la section HPA existante
- Positionner KEDA comme operator qui étend le HPA
- Montrer le ScaledObject, expliquer que KEDA crée le HPA sous-jacent
- Mentionner quelques scalers clés (cpu, cron, kafka, rabbitmq)

## Statut global : ✅ TP rédigé — section théorique KEDA à ajouter dans 200_cours_apres_midi.md
