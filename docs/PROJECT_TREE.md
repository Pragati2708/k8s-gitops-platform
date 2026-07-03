# Project Tree

```text
.
├── README.md
├── Makefile
├── .github/
│   └── workflows/
│       └── build-push-gitops.yml
├── apps/
│   ├── frontend/
│   ├── legacy-service/
│   ├── notification-service/
│   └── transaction-service/
├── infrastructure/
│   ├── scripts/
│   │   ├── lib/
│   │   ├── 01_check-environment.sh
│   │   ├── 02_connect-eks.sh
│   │   ├── 03_verify-platform.sh
│   │   ├── 04_check-cost.sh
│   │   ├── 05_stop-development.sh
│   │   ├── 06_start-development.sh
│   │   ├── 07_database-health.sh
│   │   ├── 08_platform-health.sh
│   │   ├── 09_cleanup-report.sh
│   │   └── 10_daily-report.sh
│   └── terraform/
│       ├── terraform-infra/
│       └── terraform-platform/
├── docs/
├── policies/
├── gitops/
│   └── helm/
└── monitoring/
```

The separate `k8s-gitops-config` repository remains outside this monorepo and
continues to own ArgoCD Applications, Helm deployment configuration, and
Kubernetes desired state.

Generated, local, and machine-specific files such as `node_modules/`, `dist/`,
`.terraform/`, local Terraform state copies, logs, and `.DS_Store` should not be
committed.
