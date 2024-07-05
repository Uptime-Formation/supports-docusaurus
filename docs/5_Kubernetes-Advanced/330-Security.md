---
title: Run 3 - Security 
weight: 330
---


### Quickstart : Installation de l'outil de sécurité Kube-bench

On va lancer un test de sécurité de notre cluster Kubernetes avec [Kube-bench](https://github.com/aquasecurity/kube-bench).

- **Télécharger le manifeste YAML de Kube-bench** :
   ```sh
   curl -L -o kube-bench.yaml https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
   ```

- **Appliquer le manifeste pour créer le job Kube-bench** :
   ```sh
   kubectl apply -f kube-bench.yaml
   ```

- **Vérifier l'état du job Kube-bench** :
   ```sh
   kubectl get pods -n kube-system | grep kube-bench
   ```

- **Afficher les logs pour voir les résultats de l'audit** :
   ```sh
   kubectl logs <kube-bench-pod> -n kube-system
   ```

- **Supprimer le job Kube-bench après vérification** :
   ```sh
   kubectl delete -f kube-bench.yaml
   ```
---

## La sécurité 

Voici plusieurs domaines de sécurité à considérer lors de la gestion d'un cluster Kubernetes.

Gestion des identités et des accès (IAM) :
- **Contrôle d'accès** : Qui peut accéder à quoi et comment les autorisations sont gérées.

Sécurité du réseau :
- **Sécurité des communications** : Comment les données sont sécurisées en transit.
- **Configuration du réseau** : Comment les politiques réseau protègent les communications internes.

Sécurité des applications :
- **Sécurité des images** : Comment assurer que les images de conteneurs sont sécurisées.
- **Sécurité des pods et des conteneurs** : Comment les conteneurs et les pods sont sécurisés.

Sécurité des données :
- **Gestion des secrets** : Comment les informations sensibles sont stockées et gérées.

Conformité et audit :
- **Audit et monitoring** : Comment surveiller et auditer les activités et les configurations.
- **Sécurité des noeuds du cluster** : Comment le cluster est protégé contre les attaques externes.

---

### Application à la boucle DevOps 

**Pour aligner la sécurité Kubernetes avec la boucle DevOps, chaque phase du cycle de vie DevOps doit intégrer des pratiques de sécurité spécifiques.** 

Voici comment la sécurité peut être intégrée dans chaque phase de la boucle DevOps :

1. **Plan**
   - **Menaces et exigences de sécurité** : Identifier les menaces potentielles et définir les exigences de sécurité pour les applications et les infrastructures Kubernetes.
   - **Politiques de sécurité** : Établir des politiques de sécurité pour guider le développement et les opérations.

2. **Code**
   - **Revue de code sécurisée** : Intégrer des pratiques de revue de code pour détecter et corriger les vulnérabilités de sécurité.
   - **Utilisation de bibliothèques sécurisées** : Choisir et utiliser des bibliothèques et des dépendances qui ont été vérifiées pour la sécurité.

3. **Build**
   - **Scannage des images** : Scanner les images de conteneurs pour les vulnérabilités avant de les construire et de les intégrer dans le pipeline CI/CD.
   - **Build sécurisé** : Configurer le pipeline CI/CD pour inclure des étapes de vérification de la sécurité.

4. **Test**
   - **Tests de sécurité automatisés** : Intégrer des tests de sécurité automatisés (analyse statique, analyse dynamique, tests de pénétration) dans le pipeline de test.
   - **Tests de conformité** : Vérifier que les configurations respectent les politiques de sécurité et les normes de conformité.

5. **Release**
   - **Validation de sécurité** : Avant la mise en production, valider que toutes les mesures de sécurité ont été respectées et que les tests de sécurité sont passés.
   - **Gestion des versions** : Assurer une gestion sécurisée des versions et des artefacts.

6. **Deploy**
   - **Configurations sécurisées** : Utiliser des configurations sécurisées pour le déploiement des applications et des clusters Kubernetes.
   - **Gestion des secrets** : Déployer les applications en utilisant des mécanismes sécurisés pour la gestion des secrets (comme Kubernetes Secrets).

7. **Operate**
   - **Contrôle d'accès** : Gérer les permissions et les accès avec RBAC (Role-Based Access Control) pour sécuriser les opérations.
   - **Sécurité des communications** : Assurer que les communications entre les services et les composants sont sécurisées (TLS/SSL).

8. **Monitor**
   - **Surveillance continue** : Utiliser des outils de monitoring pour surveiller les activités et les anomalies en temps réel.
   - **Audit et logs** : Collecter et analyser les logs pour détecter les comportements suspects et les incidents de sécurité.
   - **Réponse aux incidents** : Mettre en place des procédures pour répondre rapidement aux incidents de sécurité détectés.

---

### Des outils Kubernetes pour chaque phase

### Plan 

 - [OPA (Open Policy Agent)](https://www.openpolicyagent.org/docs/latest/)
 - [Kyverno](https://kyverno.io/docs/)

**Ces outils permettent de définir et d'appliquer des politiques de sécurité et de conformité au sein du cluster Kubernetes.**

Leur rôle est d'assurer que toutes les actions et configurations respectent les règles établies par l'organisation, ce qui aide à prévenir les erreurs de configuration et à renforcer la sécurité dès la phase de planification.

Pour le développeur, cela signifie travailler dans un cadre clair et sécurisé, où les politiques sont automatiquement appliquées et vérifiées, réduisant ainsi les risques et les corrections tardives.

--- 

### Code 

- [Snyk](https://snyk.io/product/kubernetes-security/)
- [Trivy](https://aquasecurity.github.io/trivy/)

**Outils de sécurité qui scannent le code et les dépendances à la recherche de vulnérabilités.**

Leur rôle est de détecter les failles de sécurité dans les bibliothèques et les composants utilisés par les développeurs avant que le code ne soit déployé.

Les développeurs peuvent intégrer la sécurité directement dans le flux de développement, permettant de corriger les problèmes de sécurité dès les premières étapes et de garantir que le code livré est sécurisé.

---

### Build 

- [Gitlab](https://docs.gitlab.com/ee/ci/)
- [Tekton](https://tekton.dev/docs/)


**Le rôle des systèmes d'intégration continue (CI) est de garantir que les builds sont effectués dans des environnements isolés et sécurisés, avec des images stockées dans des registries privés comme GitHub Container Registry ou GitLab Container Registry.**

Les promotions d'images entre environnements (par exemple, de développement à production) sont conditionnées par des contrôles de sécurité, garantissant que seules les images validées et sécurisées progressent à travers le pipeline CI/CD.

Leur automatisation offre une assurance que les builds sont sécurisés et que les images ne sont promues qu'après avoir passé des contrôles rigoureux, minimisant ainsi les risques de sécurité.


---

### Test 

- [JUnit](https://junit.org/junit5/docs/current/user-guide/)
- [PyTest](https://docs.pytest.org/en/6.2.x/)
- [JMeter](https://jmeter.apache.org/usermanual/index.html)
- [SonarQube](https://docs.sonarqube.org/latest/)
- [Trivy](https://aquasecurity.github.io/trivy/)
- [Clair](https://github.com/quay/clair)
- [Helmper](https://github.com/ChristofferNissen/helmper)

**Les tests dans un environnement Kubernetes incluent des tests unitaires, des tests d'intégration, des tests de performance, et des analyses de sécurité automatisées.**

Les tests unitaires et d'intégration peuvent être gérés avec des frameworks comme JUnit ou PyTest, tandis que les tests de performance peuvent utiliser des outils comme JMeter.

Pour la sécurité, des outils comme SonarQube peuvent être intégrés pour l'analyse statique du code, et Trivy ou Clair pour scanner les images Docker à la recherche de vulnérabilités.

Helmper automatise les tests des recettes Helm et de leurs images associéees.

Ils évitent beaucoup de failles de sécurité et des problèmes de performance, garantissant ainsi des déploiements fiables et sécurisés.

---

### Release 
- [Gitleaks](https://github.com/gitleaks/gitleaks)
- [Snyk](https://snyk.io/docs/infrastructure-as-code/)

**Outils essentiels pour garantir que les versions de votre application sont sécurisées avant d'être déployées.**

Gitleaks scanne les dépôts Git pour détecter des secrets exposés, comme des clés API ou des mots de passe, tandis que Snyk analyse les Helm Charts (Infrastructure as Code) pour identifier et corriger les problèmes de sécurité.


Leur rôle est de valider la sécurité de votre code et des configurations avant la mise en production.

---

### Deploy 


- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
- [Flux](https://fluxcd.io/docs/)

**Les outils GitOps permettent de gérer et de déployer les applications dans Kubernetes en utilisant des dépôts Git comme source de vérité.**

Leur rôle est de s'assurer que le déploiement des applications est automatisé et sécurisé, permettant de déployer dans des environnements de production auxquels les développeurs n'ont pas directement accès.

Cela garantit que toutes les modifications de configuration et de code passent par des processus de validation et d'approbation définis dans le dépôt Git, avant d'être automatiquement appliquées au cluster Kubernetes.

Pour les développeurs, cela signifie un processus de déploiement plus sûr et transparent, où les modifications sont traçables et auditées, tout en réduisant le risque d'erreurs humaines et en maintenant un haut niveau de sécurité et de conformité.

---

### Operate 

- [HashiCorp Vault](https://www.vaultproject.io/docs)
- [Vault Kubernetes Operator](https://www.vaultproject.io/docs/platform/k8s)


**Ces outils garantissent que les secrets sont protégés et gérés tout au long de leur cycle de vie.**

Le Vault Operator permet de déployer et de gérer Vault directement dans votre cluster Kubernetes, fournissant une intégration native pour la gestion des secrets.

Vault offre des fonctionnalités avancées de stockage, d'accès et de gestion des secrets, avec des politiques d'accès détaillées, des audits et des capacités de chiffrement.



Vault assure également que seules les applications et les utilisateurs autorisés peuvent accéder aux informations sensibles, en fournissant des audits complets des accès aux secrets pour répondre aux exigences de conformité et de sécurité, tout en simplifiant le processus de rotation des secrets.

Cela signifie que les secrets sensibles, comme les mots de passe, les clés API et les certificats, sont stockés et accessibles de manière sécurisée.




--- 

### Monitor 


- [Falco](https://falco.org/docs/)
- [Tracee](https://aquasecurity.github.io/tracee/latest/)

**Ces outils permettent une surveillance proactive des environnements Kubernetes, avec des alertes instantanées en cas de détection de comportements anormaux, renforçant ainsi la sécurité globale et facilitant la détection et la réponse aux incidents.**

Cela permet de collecter des métriques détaillées et des traces sans impact significatif sur les performances.

En configurant des règles de détection spécifiques, Falco peut alerter en temps réel sur les activités potentiellement malveillantes ou non autorisées.

---

### TP : Gestion des secrets avec HashiCorp Vault et Vault Operator dans Kubernetes

#### Objectif

**Mettre en place HashiCorp Vault pour la gestion des secrets dans un cluster Kubernetes en utilisant le Vault Operator.**

Pour plus de détails, vous pouvez consulter le [tutoriel de HashiCorp Vault](https://developer.hashicorp.com/vault/tutorials/kubernetes/vault-secrets-operator).
