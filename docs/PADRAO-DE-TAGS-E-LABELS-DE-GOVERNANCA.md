# Padrão Corporativo de Tags e Labels de Governança (FinOps & Observabilidade)

Este documento define a **política mandatória de metadados, tags na AWS e labels no Kubernetes** aplicada a todos os recursos provisionados nos 4 repositórios da plataforma. O objetivo é assegurar rastreabilidade total, governança de custos (FinOps), auditoria de segurança, ciclo de vida e alinhamento com as melhores práticas recomendadas pelo mercado (AWS Well-Architected Framework e CNCF/Kubernetes Recommended Labels).

---

## 1. Princípios da Política de Metadados

1. **Zero Untagged Resources (Nenhum Recurso Sem Tag):** Todo e qualquer recurso criado na AWS ou no Kubernetes deve conter metadados que respondam imediatamente a:
   * **Quem** é o dono (`Owner`)?
   * **Qual** é o projeto de origem (`Project` / `SourceProject`)?
   * **Em que** ambiente está operando (`Environment`)?
   * **Qual** ferramenta gerou o recurso (`ManagedBy` / `ResourceGenerator`)?
   * **A qual** centro de custo financeiro a cobrança deve ser imputada (`CostCenter`)?
   * **Qual** é a nuvem de hospedagem (`CloudProvider`)?
   * **Qual** é o repositório de código-fonte de onde o recurso se origina (`Repository`)?
   * **Qual** é o ciclo de vida e tempo de retenção planejado (`Lifecycle`)?
2. **Herança Automática no Provedor (Provider-Level Default Tags):** No Terraform, todas as tags são declaradas no bloco `default_tags` do `provider "aws"`, garantindo que 100% dos recursos criados herdem os metadados automaticamente sem depender de inserção manual em cada bloco `resource`.
3. **Alinhamento CNCF no Kubernetes:** Todos os manifests de Namespaces, Deployments, Pods e Services utilizam a convenção oficial `app.kubernetes.io/*` combinada com chaves de governança corporativa.

---

## 2. Padrão Mandatório de Tags na AWS

### 2.1 Matriz de Tags Mandatórias

| Tag AWS | Descrição / Propósito | Exemplo de Valor | Obrigatória |
|---|---|---|---|
| **`Name`** | Identificador legível do recurso na AWS | `kube-demo-eks-vpc`, `samba-dc1` | **Sim** |
| **`Project`** | Nome do projeto de origem do recurso | `kube-demo-2026`, `backstage-infra` | **Sim** |
| **`SourceProject`** | Repositório Git / Projeto upstream | `kube-demo-2026`, `apps-demo-2026` | **Sim** |
| **`Environment`** | Estágio de deploy / ciclo de vida | `sandbox`, `dev`, `staging`, `prod` | **Sim** |
| **`ManagedBy`** | Ferramenta controladora de estado | `terraform`, `helm`, `kubernetes` | **Sim** |
| **`ResourceGenerator`**| Motor gerador do recurso | `terraform`, `ansible`, `github-actions`| **Sim** |
| **`CostCenter`** | Centro de custo para faturamento e FinOps| `devops-platform-cloud`, `eng-101` | **Sim** |
| **`CloudProvider`** | Nuvem pública onde o recurso reside | `aws` | **Sim** |
| **`Owner`** | Equipe ou pessoa responsável pela manutenção | `platform-team`, `cirobessa` | **Sim** |
| **`Repository`** | URL completa do repositório no GitHub | `https://github.com/cirobessa/...` | **Sim** |
| **`Lifecycle`** | SLA / Política de vida do ambiente | `ephemeral-7h`, `persistent` | **Sim** |
| **`Provisioner`** | Mecanismo de execução de CI/CD | `github-actions` | **Sim** |

### 2.2 Implementação no Terraform (`provider.tf`)

Para garantir aplicação uniforme em 100% dos recursos AWS:

```hcl
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project           = var.project_name
      SourceProject     = var.project_name
      Environment       = var.environment
      ManagedBy         = "terraform"
      ResourceGenerator = "terraform"
      CostCenter        = var.cost_center
      CloudProvider     = "aws"
      Owner             = var.owner
      Repository        = var.repository
      Lifecycle         = "ephemeral-7h"
      Provisioner       = "github-actions"
    }
  }
}
```

---

## 3. Padrão Mandatório de Labels no Kubernetes

### 3.1 Matriz de Labels CNCF e Governança

| Label Kubernetes | Padrão | Descrição | Exemplo |
|---|---|---|---|
| **`app.kubernetes.io/name`** | CNCF | Nome da aplicação ou componente | `python-app`, `backstage` |
| **`app.kubernetes.io/instance`** | CNCF | Identificador único da instância | `python-app-prod`, `argocd-server` |
| **`app.kubernetes.io/version`** | CNCF | Versão semântica do build | `1.0.0`, `11.3.1`, `24.0.1` |
| **`app.kubernetes.io/component`** | CNCF | Função do componente na arquitetura | `backend-api`, `idp-portal`, `database` |
| **`app.kubernetes.io/part-of`** | CNCF | Projeto/Sistema ao qual pertence | `kube-demo-2026`, `backstage-infra` |
| **`app.kubernetes.io/managed-by`**| CNCF | Ferramenta que gerencia o manifest | `terraform`, `argocd`, `helm` |
| **`app.kubernetes.io/created-by`**| Mercado | Agente de CI que gerou o deploy | `github-actions` |
| **`environment`** | Mercado | Estágio de execução | `sandbox` |
| **`cost-center`** | FinOps | Centro de custo da carga de trabalho | `devops-platform-cloud` |
| **`cloud-provider`** | FinOps | Infraestrutura subjacente | `aws` |
| **`source-project`** | Governança | Repositório Git de origem | `apps-demo-2026` |
| **`owner`** | Governança | Equipe proprietária do serviço | `platform-team` |
| **`backstage.io/kubernetes-id`** | DevEx | Vinculação com o catálogo Backstage | `python-app`, `dotnet-csharp-app` |

### 3.2 Exemplo em Manifest de Deployment Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
  namespace: apps-demo
  labels:
    app.kubernetes.io/name: python-app
    app.kubernetes.io/instance: python-app-prod
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/component: backend-api
    app.kubernetes.io/part-of: apps-demo-2026
    app.kubernetes.io/managed-by: argocd
    app.kubernetes.io/created-by: github-actions
    environment: sandbox
    cost-center: devops-platform-cloud
    cloud-provider: aws
    source-project: apps-demo-2026
    owner: platform-team
    backstage.io/kubernetes-id: python-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: python-app
  template:
    metadata:
      labels:
        app.kubernetes.io/name: python-app
        app.kubernetes.io/instance: python-app-prod
        app.kubernetes.io/version: "1.0.0"
        app.kubernetes.io/component: backend-api
        app.kubernetes.io/part-of: apps-demo-2026
        app.kubernetes.io/managed-by: argocd
        app.kubernetes.io/created-by: github-actions
        environment: sandbox
        cost-center: devops-platform-cloud
        cloud-provider: aws
        source-project: apps-demo-2026
        owner: platform-team
        backstage.io/kubernetes-id: python-app
...
```

---

## 4. Aplicação por Camada de Infraestrutura

### 4.1 Camada 1: `kube-demo-2026`
- **VPC, Subnets, Gateways, Route Tables, EIPs:**
  - `Name`: `${var.cluster_name}-vpc`, `${var.cluster_name}-public-0`, etc.
  - Tags de integração com Kubernetes: `kubernetes.io/role/elb = 1` e `kubernetes.io/role/internal-elb = 1`.
  - Tags de FinOps injetadas via `default_tags`.
- **EKS Cluster e Node Groups:**
  - `Name`: `kube-demo-eks`, `kube-demo-eks-nodes`.
  - Tags de autoscaling: `k8s.io/cluster-autoscaler/enabled = true`.
- **Namespace `monitoring`:**
  - Labels de governança: `app.kubernetes.io/name = monitoring`, `cost-center = devops-platform-cloud`.

### 4.2 Camada 2: `backstage-infra`
- **Amazon RDS PostgreSQL 15:**
  - `Name`: `backstage-rds-postgres`.
  - Tags de backup e retenção FinOps.
- **Backstage, ArgoCD, SonarQube e Grafana:**
  - Namespaces e Services com `environment: sandbox`, `source-project: backstage-infra`, `cost-center: devops-platform-cloud`.

### 4.3 Camada 3: `samba-ad-keycloak`
- **Instâncias EC2 (`samba_dc1`, `samba_dc2`, `keycloak`):**
  - `Name`: `samba-dc1`, `samba-dc2`, `keycloak-sso`.
  - `Role`: `domain-controller-primary`, `domain-controller-replica`, `identity-broker`.
  - Tags de segurança e gerenciamento Ansible: `Project = samba-ad-keycloak`.

### 4.4 Camada 4: `apps-demo-2026`
- **Microserviços Python e .NET:**
  - Labels de instrumentação: `prometheus.io/scrape = true`, `fluentd.io/collect = true`.
  - Metadados completos do Backstage: `backstage.io/kubernetes-id`.

---

## 5. Alinhamento com Práticas de FinOps e Auditoria

1. **Ativação no AWS Cost Allocation Tags:**
   No console do AWS Billing, as tags de usuário (`Project`, `Environment`, `CostCenter`, `Owner`) devem ser ativadas como **Cost Allocation Tags**. Isso permite:
   * Segmentar os custos no AWS Cost Explorer por projeto (`kube-demo-2026` vs `backstage-infra` vs `samba-ad-keycloak` vs `apps-demo-2026`).
   * Ratear despesas por centro de custo (`CostCenter`).
   * Detectar anomalias de gasto ou recursos ociosos antes do término da conta de 7 horas.
2. **Kubectl e Filtros de Consulta:**
   Os engenheiros podem filtrar recursos no cluster de forma rápida e precisa:
   ```bash
   # Listar todos os pods do centro de custo
   kubectl get pods -A -l cost-center=devops-platform-cloud

   # Listar recursos criados pelo ArgoCD
   kubectl get all -A -l app.kubernetes.io/managed-by=argocd

   # Listar aplicações por ambiente
   kubectl get deployments -A -l environment=sandbox
   ```
