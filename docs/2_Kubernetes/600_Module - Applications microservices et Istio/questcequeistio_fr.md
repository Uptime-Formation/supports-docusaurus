

### Qu'est-ce qu'Istio ?

Istio est un **service mesh** open source qui peut se superposer de manière transparente aux applications distribuées existantes.

Il offrent un moyen uniforme et efficace de sécuriser, connecter et surveiller les services. Il ajoute au cluster, avec peu ou pas de modifications du code des services.

- des fonctionnalités plus flexibles et puissantes que le coeur de Kubernetes pour le LoadBalancing entre les services. Notamment un loadbalancing L7 (la couche réseau application) du trafic HTTP, gRPC, WebSocket et TCP

- une authentification entre les services

- une autorisation fine des communications basée sur cette authentification

- une communication chiffrée avec TLS mutuel

- la surveillance du trafic dans le mesh en temps réel

- Un contrôle granulaire du trafic avec des règles de routage riches, des retry automatiques pour les requêtes, des failovers en cas de panne d'un service et un mechanisme de **fault injection**.

- Une couche de politique de sécurité modulaire. l'API de configuration permet d'exprimer des contrôles d'accès, des ratelimits et des quotas pour le traffic

- Istio expose aussi des métriques, des journaux et des traces (chaine d'appels reseau) pour tout le trafic au sein d'un cluster, y compris concernant le traffic entrant et sortant (ingress et egress) du cluster.

- Istio est conçu pour être extensible et gère une grande variété de besoins de déploiement.