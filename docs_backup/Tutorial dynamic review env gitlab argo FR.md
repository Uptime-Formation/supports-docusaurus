# Créer des environnements de révision dynamiques en utilisant les demandes de fusion (merge requests) et Argo CD

Nous avons récemment découvert une nouvelle contribution au projet Argo CD, plus précisément le [générateur de demandes de fusion pour GitLab](https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/applicationset/Generators-Pull-Request.md#gitlab), et avons décidé de l'essayer. Ce qui rend cela intéressant, c'est que maintenant des [environnements de révision dynamiques](https://docs.gitlab.com/ee/ci/review_apps/index.html) peuvent être provisionnés de manière intuitive à partir de la demande de fusion (MR) en utilisant un flux de travail [GitOps](https://about.gitlab.com/topics/gitops/). L'avantage est que les examinateurs de code ou les concepteurs peuvent rapidement examiner les modifications apportées à votre cluster Kubernetes, le tout depuis la demande de fusion.

Dans les flux de travail de test traditionnels, vous auriez peut-être poussé vos modifications dans un environnement de développement, attendu que l'équipe de contrôle qualité (QA) et l'équipe UX intègrent ces modifications dans leur environnement pour un examen ultérieur, puis reçu des commentaires sur votre petite modification. À ce stade, du temps était perdu entre les différentes équipes en termes de coordination des environnements ou d'ajout de bogues au backlog des nouvelles modifications.

Grâce à la combinaison d'une demande de fusion et d'environnements de révision, vous pouvez rapidement créer un environnement de test basé sur les modifications de votre branche de fonctionnalités. Cela signifie que l'équipe QA ou UX peut suggérer des améliorations ou des modifications pendant le processus d'examen du code, sans perdre de cycles.

L'introduction de l'ApplicationSet a offert une plus grande flexibilité aux flux de travail d'Argo CD, notamment :

- Permettre aux utilisateurs du cluster non privilégiés de déployer des applications (sans accès aux espaces de noms)
- Déployer des applications sur plusieurs clusters en une seule fois
- Déployer de nombreuses applications à partir d'un seul monorepo
- **Et déclencher des environnements de révision basés sur une demande de fusion**

### Examinons l'ApplicationSet et le générateur de demandes de fusion GitLab

Le [générateur de demandes de fusion](https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Generators-Pull-Request) utilisera l'API GitLab pour découvrir automatiquement de nouvelles demandes de fusion dans un dépôt. Selon la correspondance des filtres de la MR, un environnement de révision sera alors généré.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: review-the-application
  namespace: argocd
spec:
  generators:
  - pullRequest:
      gitlab:
        project: <ID-du-projet>
        api: https://gitlab.com/
        tokenRef:
          secretName: <jeton-gitlab>
          key: token
        pullRequestState: opened
      requeueAfterSeconds: 60
  template:
    metadata:
      name: 'review-the-application-{{number}}'
    spec:
      source:
        repoURL: <répertoire-avec-des-fichiers-de-manifeste>
        path: chart/
        targetRevision: 'HEAD'
        helm:
          parameters:
          - name: "image.repository"
            value: "registry.gitlab.com/<chemin-du-groupe-et-du-projet>/{{branch}}"
          - name: "image.tag"
            value: "{{head_sha}}"
          - name: "service.url"
            value: "the-application-{{number}}.<ip>.nip.io"
      project: default
      destination:
        server: https://kubernetes.default.svc
        namespace: dynamic-environments-with-argo-cd
```

#### Champs

- `project`: L'ID du projet GitLab
- `api`: URL de l'instance GitLab
- `tokenRef`: Le secret pour surveiller les modifications de la demande de fusion
- `labels`: Provision d'environnements de révision en fonction d'une étiquette GitLab
- `pullRequestState`: Provision d'environnements de révision en fonction des [états des MR](https://docs.gitlab.com/ee/api/merge_requests.html)

Les options de filtrage comprennent les étiquettes GitLab, l'état de la demande de fusion (ouverte, fermée, fusionnée) et la correspondance de la branche. Les options de création de modèles incluent l'ID de la demande de fusion, le nom de la branche, le slug de la branche, le SHA de la tête et le SHA court de la tête.

Consultez la [dernière documentation de l'ApplicationSet](https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Generators-Pull-Request/#gitlab) pour plus de détails.

Pour cet article de blog, nous explorons l'utilisation de l'Argo CD ApplicationSet pour provisionner un environnement "ReviewOps" basé sur les modifications de la demande de fusion.

### Prérequis

Les outils suivants sont nécessaires pour exécuter ce tutoriel. Veuillez les installer et/ou les configurer avant de commencer.

- **Outils**
  - GitLab v15.0+
  - Cluster Kubernetes v1.21+
  - Argo CD 2.5.0+
- **CLI**
  - kubectl v1.21+

### Explorez le code source

Tout d'abord, explorons le [code source](https://gitlab.com/madou-stories/dynamic-environments-with-argo-cd) du tutoriel.

Ce groupe GitLab est composé des 2 projets suivants :

- `The Application` : contient le code source d'une application conteneurisée et son pipeline CI/CD
- `The Application Configuration` : contient la configuration de l'application (manifestes Kubernetes) gérée par Helm

### Configuration de GitLab

1. Créez votre groupe GitLab et bifurquez les projets [The Application](https://gitlab.com/madou-stories/dynamic-environments-with-argo-cd/the-application) et [The Application Configuration](https://gitlab.com/madou-stories/dynamic-environments-with-argo-cd/the-application-configuration) dans ce groupe.

2. Dans le projet `The Application Configuration`, modifiez le fichier `manifests/applicationset.yml` comme suit :

- `.spec.generators.pullRequest.gitlab.project` : L'ID du projet `The Application`
- `.spec.template.spec.source.repoURL` : URL Git de `The Application Configuration`
- `.spec.template.spec.source.helm

.parameters."image.repository"` : Pointez vers le référentiel d'images, par exemple `registry.gitlab.com/<Votre_Groupe_GitLab>/the-application/{{branch}}`

Note : laissez la chaîne `{{branch}}` telle quelle et remplacez

- `.spec.template.spec.source.helm.parameters."service.url"` : Modélisé avec `the-application-{{number}}.<Votre_Domaine_D'Ingress_Kube_Base>`

Note : laissez la chaîne `{{number}}` telle quelle et remplacez

1. Définissez les variables CI/CD suivantes au niveau du groupe :

   - `ARGOCD_SERVER_URL`, l'adresse du serveur Argo CD
   - `ARGOCD_USERNAME`, le nom d'utilisateur de votre compte Argo CD
   - `ARGOCD_PASSWORD`, le mot de passe de votre compte Argo CD
   - `KUBE_INGRESS_BASE_DOMAIN`, le domaine de base de votre cluster Kubernetes

2. Générez un jeton d'accès de groupe pour accorder l'accès `read_api` et `read_registry` à ce groupe et à ses sous-projets.

   Sauvegardez le jeton d'accès du groupe dans un endroit sûr. Nous l'utiliserons ultérieurement.

### Configuration de Kubernetes

1. Créez un espace de noms appelé `dynamic-environments-with-argo-cd`.

```bash
kubectl create namespace dynamic-environments-with-argo-cd
```

2. Créez un secret Kubernetes appelé `gitlab-token-dewac` pour permettre à Argo CD d'utiliser l'API GitLab.

```yaml
kubectl create secret generic gitlab-token-dewac -n argocd --from-literal=token=<Votre_Jeton_D'Accès>
```

3. Créez un autre secret Kubernetes appelé `gitlab-token-dewac` pour permettre à Kubernetes de télécharger des images depuis le Registre de Conteneurs GitLab.

```bash
kubectl create secret generic gitlab-token-dewac -n dynamic-environments-with-argo-cd --from-literal=token=<Votre_Jeton_D'Accès>
```

### Configuration d'Argo CD

1. Créez l'ApplicationSet Argo CD pour générer une Application Argo CD associée à une demande de fusion.

```bash
kubectl apply -f https://gitlab.com/<Votre_Groupe_GitLab>/the-application-configuration/-/raw/main/manifests/applicationset.yaml
```

### Mettez à jour le code source

1. Dans le projet `The Application`, créez une issue GitLab, puis une branche associée et une demande de fusion.

2. Dans Argo CD, une nouvelle application est provisionnée, appelée `review-the-application`, en fonction du nouvel événement de demande de fusion.

3. Dans le projet `The Application`, modifiez le fichier `index.pug` et remplacez `p Welcome to #{title}` par `p Bienvenue à #{title}`.

4. Effectuez un commit dans votre branche récente qui va déclencher l'exécution d'un pipeline.

5. Dans CI/CD > Pipelines, vous trouverez le pipeline suivant s'exécutant sur votre demande de fusion :

   où,

   - `docker-build` : construit l'image de conteneur
   - `reviewops` : configure et déploie le conteneur dans l'environnement de révision en utilisant Argo CD
   - `stop-reviewops` : supprime l'environnement de révision

6. Une fois terminé, l'application `review-the-application` dans Argo CD est maintenant synchronisée.

7. À partir de la demande de fusion, cliquez sur le bouton `View app` pour accéder à votre application.

8. Vous avez réussi à provisionner un environnement de révision dynamique basé sur votre demande de fusion ! Une fois la demande de fusion fermée, l'environnement sera automatiquement nettoyé.

## Pour résumer

Nous espérons que ce tutoriel vous a été utile et a inspiré vos flux de travail GitLab + Argo CD avec des environnements de révision.

Nous serions ravis d'entendre dans les commentaires comment cela fonctionne pour vous, ainsi que vos idées sur la façon dont nous pouvons faire de GitLab un meilleur endroit pour les flux de travail GitOps.