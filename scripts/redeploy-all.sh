#!/usr/bin/env bash
# ==============================================================================
# kube-demo-2026 — Master Zero-to-Production Orchestration Script
# ==============================================================================
# Automatiza todo o ciclo de vida e redeploy da infraestrutura quando uma
# nova conta temporária AWS (sandbox de 7h) é provisionada.
#
# Uso:
#   ./scripts/redeploy-all.sh
#   Ou passando credenciais:
#   AWS_ACCESS_KEY_ID="AKIA..." AWS_SECRET_ACCESS_KEY="..." ./scripts/redeploy-all.sh
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BACKSTAGE_DIR="$(cd "${WORKSPACE_ROOT}/../backstate-infra" 2>/dev/null || echo "${WORKSPACE_ROOT}/../backstage-infra")"
SAMBA_DIR="$(cd "${WORKSPACE_ROOT}/../samba-ad-keycloak" 2>/dev/null || echo "")"
APPS_DIR="$(cd "${WORKSPACE_ROOT}/../apps-demo-2026" 2>/dev/null || echo "")"

echo -e "${BLUE}${BOLD}==============================================================================${NC}"
echo -e "${BLUE}${BOLD}🚀 KUBE-DEMO-2026: MASTER ZERO-TO-PRODUCTION REDEPLOY ORCHESTRATOR${NC}"
echo -e "${BLUE}${BOLD}==============================================================================${NC}"
echo ""

# ------------------------------------------------------------------------------
# 1. Coleta e Validação de Credenciais AWS
# ------------------------------------------------------------------------------
REGION="${AWS_REGION:-us-east-1}"
ACCESS_KEY="${AWS_ACCESS_KEY_ID:-}"
SECRET_KEY="${AWS_SECRET_ACCESS_KEY:-}"
SESSION_TOKEN="${AWS_SESSION_TOKEN:-}"

if [ -z "${ACCESS_KEY}" ] || [ -z "${SECRET_KEY}" ]; then
  echo -e "${YELLOW}Credenciais AWS não encontradas nas variáveis de ambiente.${NC}"
  echo -e "Por favor, informe as credenciais da nova conta AWS do laboratório:"
  echo ""
  read -r -p "AWS Access Key ID: " ACCESS_KEY
  read -r -s -p "AWS Secret Access Key: " SECRET_KEY
  echo ""
  read -r -s -p "AWS Session Token (pressione ENTER se não houver): " SESSION_TOKEN
  echo ""
fi

export AWS_ACCESS_KEY_ID="${ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${SECRET_KEY}"
export AWS_REGION="${REGION}"
if [ -n "${SESSION_TOKEN}" ]; then
  export AWS_SESSION_TOKEN="${SESSION_TOKEN}"
fi

echo -e "${CYAN}Validando credenciais com AWS STS...${NC}"
if ! CALLER_IDENTITY=$(aws sts get-caller-identity --output json 2>/dev/null); then
  echo -e "${RED}❌ ERRO: Credenciais AWS inválidas ou expiradas.${NC}"
  exit 1
fi

ACCOUNT_ID=$(echo "${CALLER_IDENTITY}" | jq -r '.Account')
CALLER_ARN=$(echo "${CALLER_IDENTITY}" | jq -r '.Arn')
echo -e "${GREEN}✓ Conectado com sucesso!${NC}"
echo -e "  Conta AWS : ${BOLD}${ACCOUNT_ID}${NC}"
echo -e "  Caller ARN: ${BOLD}${CALLER_ARN}${NC}"
echo -e "  Região    : ${BOLD}${REGION}${NC}"
echo ""

# ------------------------------------------------------------------------------
# 2. Configurar ~/.aws/credentials e ~/.aws/config localmente
# ------------------------------------------------------------------------------
echo -e "${CYAN}Atualizando ~/.aws/credentials local...${NC}"
mkdir -p "${HOME}/.aws"

cat <<EOF > "${HOME}/.aws/credentials"
[default]
aws_access_key_id = ${ACCESS_KEY}
aws_secret_access_key = ${SECRET_KEY}
$([ -n "${SESSION_TOKEN}" ] && echo "aws_session_token = ${SESSION_TOKEN}")

[kube-demo]
aws_access_key_id = ${ACCESS_KEY}
aws_secret_access_key = ${SECRET_KEY}
$([ -n "${SESSION_TOKEN}" ] && echo "aws_session_token = ${SESSION_TOKEN}")
EOF

cat <<EOF > "${HOME}/.aws/config"
[default]
region = ${REGION}
output = json

[profile kube-demo]
region = ${REGION}
output = json
EOF

echo -e "${GREEN}✓ Arquivos ~/.aws/credentials e ~/.aws/config atualizados.${NC}"
echo ""

# ------------------------------------------------------------------------------
# 3. Sincronizar Secrets do GitHub Actions (cirobessa & cirodasilvaj)
# ------------------------------------------------------------------------------
echo -e "${CYAN}Sincronizando secrets do GitHub Actions...${NC}"

if command -v gh >/dev/null 2>&1; then
  # Repositório cirobessa/kube-demo-2026
  echo -e "Atualizando secrets em ${BOLD}cirobessa/kube-demo-2026${NC}..."
  gh auth switch -u cirobessa 2>/dev/null || true
  gh secret set AWS_ACCESS_KEY_ID -b "${ACCESS_KEY}" -R cirobessa/kube-demo-2026
  gh secret set AWS_SECRET_ACCESS_KEY -b "${SECRET_KEY}" -R cirobessa/kube-demo-2026
  gh secret set AWS_REGION -b "${REGION}" -R cirobessa/kube-demo-2026
  if [ -n "${SESSION_TOKEN}" ]; then
    gh secret set AWS_SESSION_TOKEN -b "${SESSION_TOKEN}" -R cirobessa/kube-demo-2026
  else
    gh secret set AWS_SESSION_TOKEN -b "" -R cirobessa/kube-demo-2026 2>/dev/null || true
  fi

  # Repositórios cirodasilvaj/*
  echo -e "Atualizando secrets em repositórios da conta ${BOLD}cirodasilvaj${NC}..."
  gh auth switch -u cirodasilvaj 2>/dev/null || true
  for repo in cirodasilvaj/backstage-infra cirodasilvaj/samba-ad-keycloak cirodasilvaj/apps-demo-2026; do
    echo -e "  -> ${repo}..."
    gh secret set AWS_ACCESS_KEY_ID -b "${ACCESS_KEY}" -R "${repo}"
    gh secret set AWS_SECRET_ACCESS_KEY -b "${SECRET_KEY}" -R "${repo}"
    gh secret set AWS_REGION -b "${REGION}" -R "${repo}"
    if [ -n "${SESSION_TOKEN}" ]; then
      gh secret set AWS_SESSION_TOKEN -b "${SESSION_TOKEN}" -R "${repo}"
    else
      gh secret set AWS_SESSION_TOKEN -b "" -R "${repo}" 2>/dev/null || true
    fi
  done
  echo -e "${GREEN}✓ Secrets do GitHub Actions sincronizados.${NC}"
else
  echo -e "${YELLOW}Aviso: GitHub CLI ('gh') não encontrado; pulando sincronização de secrets no GitHub.${NC}"
fi
echo ""

# ------------------------------------------------------------------------------
# 4. Modo de Execução: CI (GitHub Actions) ou Local
# ------------------------------------------------------------------------------
EXEC_MODE="${1:-ci}"
echo -e "${BOLD}Modo de Execução Selecionado:${NC} ${CYAN}${EXEC_MODE}${NC}"

if [ "${EXEC_MODE}" = "ci" ]; then
  echo ""
  echo -e "${BLUE}${BOLD}=== DISPARANDO PIPELINES VIA GITHUB ACTIONS ===${NC}"

  # 1. Disparar EKS
  echo -e "${CYAN}1/3. Disparando deploy do EKS (cirobessa/kube-demo-2026)...${NC}"
  gh auth switch -u cirobessa 2>/dev/null || true
  gh workflow run eks.yml -R cirobessa/kube-demo-2026 -f action=apply

  echo -e "${YELLOW}Aguardando início do novo workflow do EKS...${NC}"
  RUN_ID=""
  for i in $(seq 1 12); do
    sleep 5
    RUN_ID=$(gh run list -R cirobessa/kube-demo-2026 -W eks.yml -L 1 --json databaseId,status -q '.[] | select(.status != "completed") | .databaseId' 2>/dev/null || true)
    if [ -n "${RUN_ID}" ]; then
      break
    fi
  done
  if [ -z "${RUN_ID}" ]; then
    RUN_ID=$(gh run list -R cirobessa/kube-demo-2026 -W eks.yml -L 1 --json databaseId -q '.[0].databaseId')
  fi
  echo -e "Acompanhando Workflow ID: ${BOLD}${RUN_ID}${NC}"
  gh run watch "${RUN_ID}" -R cirobessa/kube-demo-2026 --exit-status

  # 2. Configurar kubectl local
  echo -e "${CYAN}Configurando kubectl local...${NC}"
  aws eks update-kubeconfig --name kube-demo-eks --region "${REGION}"
  kubectl get nodes

  # 3. Disparar Backstage Infra Platform
  echo -e "${CYAN}2/3. Disparando deploy da Plataforma DevEx & Backstage (cirodasilvaj/backstage-infra)...${NC}"
  gh auth switch -u cirodasilvaj 2>/dev/null || true
  gh workflow run terraform.yml -R cirodasilvaj/backstage-infra -f action=apply

  echo -e "${YELLOW}Aguardando início do novo workflow do Backstage...${NC}"
  RUN_ID=""
  for i in $(seq 1 12); do
    sleep 5
    RUN_ID=$(gh run list -R cirodasilvaj/backstage-infra -W terraform.yml -L 1 --json databaseId,status -q '.[] | select(.status != "completed") | .databaseId' 2>/dev/null || true)
    if [ -n "${RUN_ID}" ]; then
      break
    fi
  done
  if [ -z "${RUN_ID}" ]; then
    RUN_ID=$(gh run list -R cirodasilvaj/backstage-infra -W terraform.yml -L 1 --json databaseId -q '.[0].databaseId')
  fi
  echo -e "Acompanhando Workflow ID: ${BOLD}${RUN_ID}${NC}"
  gh run watch "${RUN_ID}" -R cirodasilvaj/backstage-infra --exit-status

  # 4. Disparar Apps Demo
  echo -e "${CYAN}3/3. Disparando build e deploy das Apps Demo (cirodasilvaj/apps-demo-2026)...${NC}"
  gh workflow run build.yml -R cirodasilvaj/apps-demo-2026 2>/dev/null || true

elif [ "${EXEC_MODE}" = "local" ]; then
  echo ""
  echo -e "${BLUE}${BOLD}=== EXECUTANDO DEPLOY LOCALMENTE VIA TERRAFORM ===${NC}"

  # 1. Bucket S3 de Estado
  STATE_BUCKET="kube-demo-2026-tfstate-${ACCOUNT_ID}"
  echo -e "${CYAN}Garantindo bucket de estado: ${STATE_BUCKET}...${NC}"
  if ! aws s3api head-bucket --bucket "${STATE_BUCKET}" 2>/dev/null; then
    aws s3api create-bucket --bucket "${STATE_BUCKET}" $([ "${REGION}" != "us-east-1" ] && echo "--create-bucket-configuration LocationConstraint=${REGION}")
    aws s3api put-bucket-versioning --bucket "${STATE_BUCKET}" --versioning-configuration Status=Enabled
  fi

  # 2. Deploy EKS
  echo -e "${CYAN}Deployando EKS Cluster...${NC}"
  cd "${WORKSPACE_ROOT}/eks"
  terraform init -input=false -reconfigure \
    -backend-config="bucket=${STATE_BUCKET}" \
    -backend-config="key=eks/terraform.tfstate" \
    -backend-config="region=${REGION}"
  terraform apply -input=false -auto-approve

  aws eks update-kubeconfig --name kube-demo-eks --region "${REGION}"

  # 3. Deploy Backstage Platform
  echo -e "${CYAN}Deployando Backstage DevEx Platform...${NC}"
  cd "${BACKSTAGE_DIR}/terraform"
  terraform init -input=false -reconfigure \
    -backend-config="bucket=${STATE_BUCKET}" \
    -backend-config="key=backstage-infra/terraform.tfstate" \
    -backend-config="region=${REGION}"
  terraform apply -input=false -auto-approve

  # Sync Manifests
  kubectl apply -f "${BACKSTAGE_DIR}/k8s-manifests/backstage/"
  kubectl apply -f "${BACKSTAGE_DIR}/k8s-manifests/sonarqube/"
  kubectl apply -f "${BACKSTAGE_DIR}/k8s-manifests/grafana/"

  # 4. Deploy Samba AD Keycloak
  if [ -d "${SAMBA_DIR}/terraform" ]; then
    echo -e "${CYAN}Deployando Samba AD + Keycloak...${NC}"
    cd "${SAMBA_DIR}/terraform"
    terraform init -input=false -reconfigure \
      -backend-config="bucket=${STATE_BUCKET}" \
      -backend-config="key=samba-ad-keycloak/terraform.tfstate" \
      -backend-config="region=${REGION}"
    terraform apply -input=false -auto-approve
  fi
fi

# ------------------------------------------------------------------------------
# 5. Recuperação dos Dados Consolidados no AWS Parameter Store
# ------------------------------------------------------------------------------
echo ""
echo -e "${BLUE}${BOLD}==============================================================================${NC}"
echo -e "${GREEN}${BOLD}🎉 DEPLOY CONCLUÍDO COM SUCESSO!${NC}"
echo -e "${BLUE}${BOLD}==============================================================================${NC}"
echo ""
echo -e "${CYAN}Consultando AWS Systems Manager Parameter Store...${NC}"
SSM_PARAM="/kube-demo-2026/platform/credentials"

if CREDS_JSON=$(aws ssm get-parameter --name "${SSM_PARAM}" --with-decryption --query "Parameter.Value" --output text 2>/dev/null); then
  echo "${CREDS_JSON}" > "${WORKSPACE_ROOT}/deploy-summary.json"
  echo -e "${GREEN}✓ Dados do ambiente salvos em: ${BOLD}${WORKSPACE_ROOT}/deploy-summary.json${NC}"
  echo ""
  echo -e "${BOLD}Diretório de Endpoints e Acessos Provisionados:${NC}"
  echo "${CREDS_JSON}" | jq '.'
else
  echo -e "${YELLOW}Aviso: O parâmetro ${SSM_PARAM} ainda está sendo propagado no SSM.${NC}"
  echo -e "Você pode consultar a qualquer momento com:"
  echo -e "${BOLD}aws ssm get-parameter --name '${SSM_PARAM}' --with-decryption --query 'Parameter.Value' --output text | jq .${NC}"
fi

echo ""
echo -e "${GREEN}${BOLD}Ambiente pronto para demonstração!${NC}"
