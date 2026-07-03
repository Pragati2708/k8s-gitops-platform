# k8s-gitops-platform

Application source repository for the banking platform services.

## Contents

- `frontend/`: React/Vite frontend application.
- `legacy-service/`: Legacy Node.js service.
- `notification-service/`: Notification Node.js service.
- `transaction-service/`: Transaction Node.js service.
- `docker-compose.yml`: Local multi-service development entrypoint.
- `.github/workflows/`: Build and publish workflow definitions.

## Operating Notes

This repository owns application code and Docker build inputs. Kubernetes
deployment intent is managed separately in `k8s-gitops-config`.

Do not change service ports, Dockerfiles, workflow names, image names, or API
behavior as part of repository cleanup. Keep generated dependencies and build
outputs out of future commits unless there is an explicit reason to vendor them.
