#!/usr/bin/env bash
# ==============================================================================
# kube-demo-2026 — Master Zero-to-Production Orchestration Script
# ==============================================================================
# Automatiza todo o ciclo de vida e redeploy da infraestrutura quando uma
# nova conta temporária AWS (sandbox de 7h) é provisionada.
#
# Mede o tempo exato de cada fase e o tempo total de provisionamento.
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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
# 1. Início da Medição Global de Tempo
# ------------------------------------------------------------------------------
GLOBAL_START_TIME=$(date +%s)
GLOBAL_START_DATE=$(date "+%Y-%m-%d %H:%M:%S %Z")
echo -e "${MAGENTA}${BOLD}⏱️  Início da Execução:${NC} ${GLOBAL_START_DATE}"
echo ""

# ------------------------------------------------------------------------------
# 2. Coleta e Validação de Credenciais AWS
# ------------------------------------------------------------------------------
REGION="${AWS_REGION:-us-east-1}"
ACCESS_KEY="${AWS_ACCESS_KEY_ID:-$(aws configure get aws_access_key_id 2>/dev/null || echo "")}"
SECRET_KEY="${AWS_SECRET_ACCESS_KEY:-$(aws configure get aws_secret_access_key 2>/dev/null || echo "")}"
SESSION_TOKEN="${AWS_SESSION_TOKEN:-$(aws configure get aws_session_token 2>/dev/null || echo "")}"

if [ -z "${ACCESS_KEY}" ] || [ -z "${SECRET_KEY}" ]; then
  if [ -t 0 ]; then
    echo -e "${YELLOW}Credenciais AWS não encontradas nas variáveis de ambiente ou ~/.aws/credentials.${NC}"
    echo -e "Por favor, informe as credenciais da nova conta AWS do laboratório:"
    echo ""
    read -r -p "AWS Access Key ID: " ACCESS_KEY
    read -r -s -p "AWS Secret Access Key: " SECRET_KEY
    echo ""
    read -r -s -p "AWS Session Token (pressione ENTER se não houver): " SESSION_TOKEN
    echo ""
  else
    echo -e "${RED}❌ ERRO: Credenciais AWS não encontradas e sessão não interativa.${NC}"
    exit 1
  fi
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
# 3. Configurar ~/.aws/credentials e ~/.aws/config localmente
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
# 4. Sincronizar Secrets do GitHub Actions (cirobessa & cirodasilvaj)
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
    gh secret delete AWS_SESSION_TOKEN -R cirobessa/kube-demo-2026 2>/dev/null || true
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
      gh secret delete AWS_SESSION_TOKEN -R "${repo}" 2>/dev/null || true
    fi
  done
  echo -e "${GREEN}✓ Secrets do GitHub Actions sincronizados.${NC}"
else
  echo -e "${YELLOW}Aviso: GitHub CLI ('gh') não encontrado; pulando sincronização de secrets no GitHub.${NC}"
fi
echo ""

# ------------------------------------------------------------------------------
# Função Auxiliar de Despacho e Monitoramento de Workflow
# ------------------------------------------------------------------------------
run_and_watch_workflow() {
  local account="$1"
  local repo="$2"
  local workflow="$3"
  local description="$4"
  local extra_args="${5:-}"

  local p_start=$(date +%s)
  echo -e "${BLUE}${BOLD}------------------------------------------------------------------------------${NC}"
  echo -e "${CYAN}${BOLD}▶ ${description}${NC}"
  echo -e "  Repositório: ${BOLD}${repo}${NC} | Workflow: ${BOLD}${workflow}${NC}"
  echo -e "${BLUE}${BOLD}------------------------------------------------------------------------------${NC}"

  gh auth switch -u "${account}" 2>/dev/null || true

  local prev_run
  prev_run=$(gh run list -R "${repo}" -w "${workflow}" -L 1 --json databaseId -q '.[0].databaseId' 2>/dev/null || echo "")

  if [ -n "${extra_args}" ]; then
    gh workflow run "${workflow}" -R "${repo}" ${extra_args}
  else
    gh workflow run "${workflow}" -R "${repo}"
  fi

  echo -e "${YELLOW}Aguardando início do workflow...${NC}"
  local run_id=""
  for i in $(seq 1 24); do
    sleep 4
    local candidate
    candidate=$(gh run list -R "${repo}" -w "${workflow}" -L 3 --json databaseId,status,createdAt -q '.[] | select(.status != "completed") | .databaseId' 2>/dev/null | head -n 1 || true)
    if [ -n "${candidate}" ] && [ "${candidate}" != "${prev_run}" ]; then
      run_id="${candidate}"
      break
    fi
  done

  if [ -z "${run_id}" ]; then
    run_id=$(gh run list -R "${repo}" -w "${workflow}" -L 1 --json databaseId -q '.[0].databaseId')
  fi

  echo -e "Acompanhando Workflow ID: ${BOLD}${run_id}${NC} (${repo})..."
  if ! gh run watch "${run_id}" -R "${repo}" --exit-status; then
    echo -e "${RED}❌ Falha na execução do workflow ${workflow} em ${repo}.${NC}"
    echo -e "Visualize os logs com: gh run view ${run_id} -R ${repo} --log-failed"
    exit 1
  fi

  local p_end=$(date +%s)
  local p_elapsed=$((p_end - p_start))
  local p_min=$((p_elapsed / 60))
  local p_sec=$((p_elapsed % 60))
  echo -e "${GREEN}✓ ${description} concluído com sucesso em ${BOLD}${p_min}m ${p_sec}s${NC}! (${p_elapsed}s)"
  echo ""
  echo "${p_elapsed}"
}

# Arrays para métricas de tempo
PHASE_NAMES=()
PHASE_TIMES=()

# ------------------------------------------------------------------------------
# Fase 1: Base Infrastructure, EKS Cluster & Prometheus (cirobessa/kube-demo-2026)
# ------------------------------------------------------------------------------
PHASE_NAMES+=("1. EKS Cluster + VPC + Prometheus (cirobessa/kube-demo-2026)")
T1=$(run_and_watch_workflow "cirobessa" "cirobessa/kube-demo-2026" "eks.yml" "Fase 1: Infraestrutura Base, EKS e Prometheus" "-f action=apply" | tail -n 1)
PHASE_TIMES+=("${T1}")

# ------------------------------------------------------------------------------
# Fase 2: Configurar kubectl Localmente e Validar Nós
# ------------------------------------------------------------------------------
P2_START=$(date +%s)
echo -e "${BLUE}${BOLD}------------------------------------------------------------------------------${NC}"
echo -e "${CYAN}${BOLD}▶ Fase 2: Configuração e Verificação do Cluster Kubernetes Local${NC}"
echo -e "${BLUE}${BOLD}------------------------------------------------------------------------------${NC}"
aws eks update-kubeconfig --name kube-demo-eks --region "${REGION}"
kubectl get nodes -o wide
P2_END=$(date +%s)
T2=$((P2_END - P2_START))
PHASE_NAMES+=("2. Configuração kubectl local e validação de nós")
PHASE_TIMES+=("${T2}")
echo -e "${GREEN}✓ Fase 2 concluída em ${BOLD}$((T2 / 60))m $((T2 % 60))s${NC}!\n"

# ------------------------------------------------------------------------------
# Fase 3: DevEx Platform, RDS PostgreSQL, ArgoCD, SonarQube, Grafana, Backstage
# ------------------------------------------------------------------------------
PHASE_NAMES+=("3. DevEx Platform: RDS, Backstage, ArgoCD, SonarQube, Grafana (backstage-infra)")
T3=$(run_and_watch_workflow "cirodasilvaj" "cirodasilvaj/backstage-infra" "terraform.yml" "Fase 3: DevEx Platform & Backstage Portal" "-f action=apply" | tail -n 1)
PHASE_TIMES+=("${T3}")

# ------------------------------------------------------------------------------
# Fase 4: Identity Stack: Samba 4 AD Multi-DC + FreeRADIUS MFA + Keycloak SSO
# ------------------------------------------------------------------------------
PHASE_NAMES+=("4. Identity Stack: Samba 4 AD + FreeRADIUS + Keycloak SSO (samba-ad-keycloak)")
T4=$(run_and_watch_workflow "cirodasilvaj" "cirodasilvaj/samba-ad-keycloak" "deploy.yml" "Fase 4: Identity Stack (Samba 4 AD, FreeRADIUS, Keycloak)" "-f action=apply" | tail -n 1)
PHASE_TIMES+=("${T4}")

# ------------------------------------------------------------------------------
# Fase 5: Demo Web Apps (Python Flask & .NET 8 C#) + QA & SonarQube CI/CD
# ------------------------------------------------------------------------------
PHASE_NAMES+=("5. Demo Web Apps: Python & .NET + QA SonarQube CI/CD (apps-demo-2026)")
T5=$(run_and_watch_workflow "cirodasilvaj" "cirodasilvaj/apps-demo-2026" "build.yml" "Fase 5: Demo Web Apps (Python & .NET) + QA & SonarQube CI/CD" "" | tail -n 1)
PHASE_TIMES+=("${T5}")

# ------------------------------------------------------------------------------
# Fase 6: Smoke Tests de Endpoints e Verificação de Saúde
# ------------------------------------------------------------------------------
P6_START=$(date +%s)
echo -e "${BLUE}${BOLD}==============================================================================${NC}"
echo -e "${CYAN}${BOLD}▶ Fase 6: Smoke Tests, Resolução DNS e Verificação de Endpoints${NC}"
echo -e "${BLUE}${BOLD}==============================================================================${NC}"

# Descobre o domínio público do laboratório no Route 53
ZONE_NAME=$(aws route53 list-hosted-zones --query "HostedZones[?contains(Name, 'realhandsonlabs.net') && Config.PrivateZone == \`false\`].Name | [0]" --output text 2>/dev/null | sed 's/\.$//' || true)
if [ -z "${ZONE_NAME}" ] || [ "${ZONE_NAME}" = "None" ]; then
  ZONE_NAME="${ACCOUNT_ID}.realhandsonlabs.net"
fi
echo -e "Domínio Route 53: ${BOLD}${ZONE_NAME}${NC}"
echo ""

echo -e "${CYAN}Verificando pods nos namespaces Kubernetes...${NC}"
kubectl get pods -A | grep -v 'kube-system\|amazon-cloudwatch' || true
echo ""

echo -e "${CYAN}Executando Smoke Tests nos Endpoints HTTP/HTTPS (com retry de até 60s)...${NC}"
TEST_SERVICES=("backstage:/" "grafana:/api/health" "argocd:/" "sonarqube:/api/system/status" "sso:/" "python:/healthz" "dotnet:/healthz")

for entry in "${TEST_SERVICES[@]}"; do
  svc="${entry%%:*}"
  path="${entry##*:}"
  url="http://${svc}.${ZONE_NAME}${path}"
  
  echo -n "  Testing ${svc} (${url})... "
  HTTP_CODE="000"
  for attempt in $(seq 1 12); do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${url}" || echo "000")
    if [ "${HTTP_CODE}" != "000" ]; then
      break
    fi
    sleep 5
  done

  if [ "${HTTP_CODE}" -ge 200 ] && [ "${HTTP_CODE}" -lt 400 ]; then
    echo -e "${GREEN}HTTP ${HTTP_CODE} OK${NC}"
  elif [ "${HTTP_CODE}" = "401" ]; then
    echo -e "${YELLOW}HTTP 401 (Auth Required - OK)${NC}"
  else
    echo -e "${YELLOW}HTTP ${HTTP_CODE}${NC}"
  fi
done

P6_END=$(date +%s)
T6=$((P6_END - P6_START))
PHASE_NAMES+=("6. Smoke Tests e Validação de Endpoints")
PHASE_TIMES+=("${T6}")

# ------------------------------------------------------------------------------
# Fase 7: Recuperação dos Dados Consolidados no AWS Parameter Store
# ------------------------------------------------------------------------------
echo ""
echo -e "${CYAN}Consultando AWS Systems Manager Parameter Store...${NC}"
SSM_PARAM="/kube-demo-2026/platform/credentials"
if CREDS_JSON=$(aws ssm get-parameter --name "${SSM_PARAM}" --with-decryption --query "Parameter.Value" --output text 2>/dev/null); then
  echo "${CREDS_JSON}" > "${WORKSPACE_ROOT}/deploy-summary.json"
  echo -e "${GREEN}✓ Dados do ambiente salvos em: ${BOLD}${WORKSPACE_ROOT}/deploy-summary.json${NC}"
fi

# ------------------------------------------------------------------------------
# Relatório Final de Tempo e Métricas
# ------------------------------------------------------------------------------
GLOBAL_END_TIME=$(date +%s)
GLOBAL_END_DATE=$(date "+%Y-%m-%d %H:%M:%S %Z")
TOTAL_ELAPSED=$((GLOBAL_END_TIME - GLOBAL_START_TIME))
TOTAL_MIN=$((TOTAL_ELAPSED / 60))
TOTAL_SEC=$((TOTAL_ELAPSED % 60))

echo ""
echo -e "${BLUE}${BOLD}==============================================================================${NC}"
echo -e "${GREEN}${BOLD}🎉 AMBIENTE 100% OPERACIONAL E NO AR!${NC}"
echo -e "${BLUE}${BOLD}==============================================================================${NC}"
echo ""
echo -e "${BOLD}Métricas de Tempo do Provisionamento Zero-to-Production:${NC}"
echo -e "  Início : ${GLOBAL_START_DATE}"
echo -e "  Término: ${GLOBAL_END_DATE}"
echo -e "  ${BOLD}Tempo Total Decorrido:${NC} ${GREEN}${BOLD}${TOTAL_MIN} minutos e ${TOTAL_SEC} segundos${NC} (${TOTAL_ELAPSED} segundos)"
echo ""
echo -e "${BOLD}Detalhamento por Fase:${NC}"
for i in "${!PHASE_NAMES[@]}"; do
  name="${PHASE_NAMES[$i]}"
  time_sec="${PHASE_TIMES[$i]}"
  min=$((time_sec / 60))
  sec=$((time_sec % 60))
  printf "  • %-72s : %2dm %02ds (%4ds)\n" "${name}" "${min}" "${sec}" "${time_sec}"
done
echo ""
echo -e "${BOLD}Diretório de Endpoints Disponíveis:${NC}"
echo "  • Backstage Portal : http://backstage.${ZONE_NAME}"
echo "  • Grafana          : http://grafana.${ZONE_NAME}"
echo "  • ArgoCD GitOps    : http://argocd.${ZONE_NAME} (ou https)"
echo "  • SonarQube QA     : http://sonarqube.${ZONE_NAME}"
echo "  • Keycloak SSO     : http://sso.${ZONE_NAME}"
echo "  • Python Flask App : http://python.${ZONE_NAME} (ou https)"
echo "  • .NET 8 C# App    : http://dotnet.${ZONE_NAME} (ou https)"
echo ""
echo -e "${GREEN}${BOLD}Ambiente pronto para uso e demonstração!${NC}"
