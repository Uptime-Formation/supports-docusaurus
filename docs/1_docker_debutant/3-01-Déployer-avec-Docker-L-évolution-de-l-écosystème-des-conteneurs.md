---
title: Déployer avec Docker L'évolution de l'écosystème des conteneurs
pre: "<b>3.01 </b>"
weight: 28
---

## Objectifs pédagogiques
  - comprendre les composants nécessaires pour un système de conteneurs
  - connaître les alternatives à Docker

  But, as of Kubernetes 1.24, the dockershim component was removed completely, and Kubernetes no longer supports Docker as a container runtime. Instead, you need to choose a container runtime that implements CRI.

  * [ ] + les autres solutions de conteneurisations et l'héritage docker
      https://www.tutorialworks.com/assets/images/container-ecosystem.drawio.png?ezimgfmt=rs:704x1183/rscb6/ng:webp/ngcb6

  * [ ] + TP runc build


  Les alternatives

  Docker => Container Runtime Interface

  * containerd
  * CRI-O

  Open Container Initiative
    docker
    runc
    crun
    firecracker-containerd https://github.com/firecracker-microvm/firecracker-containerd
    gvisor
    runhcs (windows OCI compliant)


  Podman, Buildah, and Skopeo

  AWS Fargate
