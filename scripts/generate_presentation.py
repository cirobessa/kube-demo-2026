#!/usr/bin/env python3
"""
Generate a professional widescreen (16:9) PowerPoint presentation
documenting the complete 4-repository AWS EKS architecture.
"""

import sys
import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def build_presentation(output_path: str):
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank_layout = prs.slide_layouts[6]

    # Professional Dark Theme Palette
    C_BG = RGBColor(10, 15, 29)         # Deep Space Navy (#0A0F1D)
    C_CARD = RGBColor(19, 28, 49)       # Card Navy (#131C31)
    C_CARD_BORDER = RGBColor(37, 99, 235) # Border Blue (#2563EB)
    C_TEXT_WHITE = RGBColor(255, 255, 255)
    C_TEXT_MUTED = RGBColor(148, 163, 184) # Slate 400 (#94A3B8)
    C_ACCENT_BLUE = RGBColor(56, 189, 248) # Electric Sky Blue (#38BDF8)
    C_ACCENT_GREEN = RGBColor(52, 211, 153) # Mint Emerald (#34D399)
    C_ACCENT_PURPLE = RGBColor(192, 132, 252) # Soft Purple (#C084FC)
    C_ACCENT_AMBER = RGBColor(251, 191, 36) # Golden Amber (#FBBF24)

    def set_slide_background(slide):
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
        bg.fill.solid()
        bg.fill.fore_color.rgb = C_BG
        bg.line.color.rgb = C_BG

    def add_header(slide, category: str, title: str, subtitle: str = ""):
        # Category Pill
        pill = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(0.5), Inches(3.2), Inches(0.35))
        pill.fill.solid()
        pill.fill.fore_color.rgb = RGBColor(30, 41, 59)
        pill.line.color.rgb = C_ACCENT_BLUE
        pill.line.width = Pt(1)
        tf_pill = pill.text_frame
        tf_pill.word_wrap = True
        p_pill = tf_pill.paragraphs[0]
        p_pill.text = category.upper()
        p_pill.font.size = Pt(10)
        p_pill.font.bold = True
        p_pill.font.color.rgb = C_ACCENT_BLUE
        p_pill.alignment = PP_ALIGN.CENTER

        # Title
        tb_title = slide.shapes.add_textbox(Inches(0.8), Inches(0.9), Inches(11.7), Inches(0.8))
        tf_title = tb_title.text_frame
        tf_title.word_wrap = True
        p_title = tf_title.paragraphs[0]
        p_title.text = title
        p_title.font.size = Pt(24)
        p_title.font.bold = True
        p_title.font.color.rgb = C_TEXT_WHITE

        # Subtitle
        if subtitle:
            p_sub = tf_title.add_paragraph()
            p_sub.text = subtitle
            p_sub.font.size = Pt(13)
            p_sub.font.color.rgb = C_TEXT_MUTED

    def add_card(slide, left, top, width, height, title, items, badge_text="", accent_color=C_ACCENT_BLUE):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
        card.fill.solid()
        card.fill.fore_color.rgb = C_CARD
        card.line.color.rgb = accent_color
        card.line.width = Pt(1.5)

        tb = slide.shapes.add_textbox(left + Inches(0.2), top + Inches(0.2), width - Inches(0.4), height - Inches(0.4))
        tf = tb.text_frame
        tf.word_wrap = True

        p0 = tf.paragraphs[0]
        p0.text = title
        p0.font.size = Pt(16)
        p0.font.bold = True
        p0.font.color.rgb = accent_color

        if badge_text:
            p_b = tf.add_paragraph()
            p_b.text = f"[{badge_text}]"
            p_b.font.size = Pt(10)
            p_b.font.bold = True
            p_b.font.color.rgb = C_TEXT_MUTED

        for item in items:
            p = tf.add_paragraph()
            p.text = f"• {item}"
            p.font.size = Pt(12)
            p.font.color.rgb = C_TEXT_WHITE
            p.space_after = Pt(6)

    # -------------------------------------------------------------------------
    # SLIDE 1: Title Slide
    # -------------------------------------------------------------------------
    slide1 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide1)

    # Decorative glow card
    center_box = slide1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(1.5), Inches(1.2), Inches(10.333), Inches(5.1))
    center_box.fill.solid()
    center_box.fill.fore_color.rgb = C_CARD
    center_box.line.color.rgb = C_ACCENT_BLUE
    center_box.line.width = Pt(2)

    tb1 = slide1.shapes.add_textbox(Inches(2.0), Inches(1.8), Inches(9.333), Inches(3.8))
    tf1 = tb1.text_frame
    tf1.word_wrap = True

    p_badge = tf1.paragraphs[0]
    p_badge.text = "AWS EKS • CLOUD NATIVE • DEVOPS ARCHITECTURE 2026"
    p_badge.font.size = Pt(12)
    p_badge.font.bold = True
    p_badge.font.color.rgb = C_ACCENT_BLUE

    p_t1 = tf1.add_paragraph()
    p_t1.text = "Cloud Native Enterprise Platform"
    p_t1.font.size = Pt(36)
    p_t1.font.bold = True
    p_t1.font.color.rgb = C_TEXT_WHITE
    p_t1.space_after = Pt(10)

    p_sub = tf1.add_paragraph()
    p_sub.text = "Ephemeral Sandbox Automation, Route 53 Dynamic DNS & 4-Tier Multi-Repo Decoupled Architecture"
    p_sub.font.size = Pt(18)
    p_sub.font.color.rgb = C_TEXT_MUTED
    p_sub.space_after = Pt(25)

    p_foot = tf1.add_paragraph()
    p_foot.text = "Repositories: cirobessa/kube-demo-2026 • cirodasilvaj/backstage-infra • cirodasilvaj/samba-ad-keycloak • cirodasilvaj/apps-demo-2026"
    p_foot.font.size = Pt(11)
    p_foot.font.color.rgb = C_ACCENT_GREEN

    # -------------------------------------------------------------------------
    # SLIDE 2: Challenge & Context (Ephemeral Sandbox)
    # -------------------------------------------------------------------------
    slide2 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide2)
    add_header(slide2, "Context & Challenges", "The 7-Hour Ephemeral AWS Sandbox Reality", "Operating enterprise-grade Kubernetes in non-persistent, rapidly rotating cloud lab environments")

    add_card(slide2, Inches(0.8), Inches(2.0), Inches(3.6), Inches(4.8),
             "1. Strict Time Boundary",
             [
                 "AWS accounts expire and are terminated every 7 hours.",
                 "All resources (VPC, EKS, RDS, EC2, IAM) get permanently wiped.",
                 "Requires zero-touch, automated re-provisioning under 20 minutes.",
                 "No manual console clicks or interactive credentials."
             ],
             badge_text="LIFECYCLE", accent_color=C_ACCENT_AMBER)

    add_card(slide2, Inches(4.85), Inches(2.0), Inches(3.6), Inches(4.8),
             "2. Dynamic DNS Rotation",
             [
                 "Each account receives a random Route 53 domain: *.<random-id>.realhandsonlabs.net.",
                 "Hardcoded domains break immediately on the next rotation.",
                 "DNS must be auto-discovered by Terraform & scripts dynamically.",
                 "Service endpoints must be seamlessly mapped via CNAME delegation."
             ],
             badge_text="NETWORKING", accent_color=C_ACCENT_BLUE)

    add_card(slide2, Inches(8.9), Inches(2.0), Inches(3.6), Inches(4.8),
             "3. State & Decoupling",
             [
                 "4 distinct Git repositories managed by two GitHub accounts.",
                 "Strict dependency order: VPC -> EKS -> DevEx -> IAM -> Apps.",
                 "Database state dump/hydrate mechanism for Backstage RDS.",
                 "Native Terraform S3 locking prevents pipeline concurrency conflicts."
             ],
             badge_text="PERSISTENCE", accent_color=C_ACCENT_GREEN)

    # -------------------------------------------------------------------------
    # SLIDE 3: Decoupled Multi-Repo Architecture
    # -------------------------------------------------------------------------
    slide3 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide3)
    add_header(slide3, "Global Architecture", "Decoupled 4-Tier Multi-Repository Orchestration", "Isolated failure domains with clean interfaces, dynamic outputs, and GitOps")

    add_card(slide3, Inches(0.8), Inches(2.0), Inches(2.7), Inches(4.8),
             "Tier 1: Base Infra",
             [
                 "Repo: kube-demo-2026",
                 "Owner: cirobessa",
                 "VPC / Subnets across 3 AZs",
                 "EKS 1.30 Managed Cluster",
                 "Prometheus Helm Stack",
                 "EBS / S3 CSI Drivers IRSA",
                 "Output: vpc_id, subnets, OIDC"
             ],
             badge_text="FOUNDATION", accent_color=C_ACCENT_BLUE)

    add_card(slide3, Inches(3.8), Inches(2.0), Inches(2.7), Inches(4.8),
             "Tier 2: Platform",
             [
                 "Repo: backstage-infra",
                 "Owner: cirodasilvaj",
                 "RDS PostgreSQL 15 Instance",
                 "Backstage Developer Portal",
                 "ArgoCD GitOps Controller",
                 "SonarQube Security Scanner",
                 "Route 53 DNS Auto-Delegate"
             ],
             badge_text="DEVEX", accent_color=C_ACCENT_PURPLE)

    add_card(slide3, Inches(6.8), Inches(2.0), Inches(2.7), Inches(4.8),
             "Tier 3: Enterprise IAM",
             [
                 "Repo: samba-ad-keycloak",
                 "Owner: cirodasilvaj",
                 "Samba 4 AD Multi-DC (EC2)",
                 "Deployed in EKS Private VPC",
                 "FreeRADIUS MFA Gateway",
                 "Keycloak SAML 2.0 & OIDC",
                 "Round-Robin LDAP Endpoints"
             ],
             badge_text="IDENTITY", accent_color=C_ACCENT_AMBER)

    add_card(slide3, Inches(9.8), Inches(2.0), Inches(2.7), Inches(4.8),
             "Tier 4: Microservices",
             [
                 "Repo: apps-demo-2026",
                 "Owner: cirodasilvaj",
                 "Python 3.12 Flask REST API",
                 ".NET 8 C# Enterprise API",
                 "SonarQube CI/CD Quality Gate",
                 "Backstage Catalog Specs",
                 "Dynamic Ingress CNAMEs"
             ],
             badge_text="APPLICATIONS", accent_color=C_ACCENT_GREEN)

    # -------------------------------------------------------------------------
    # SLIDE 4: Tier 1 - Core Infrastructure (EKS & VPC)
    # -------------------------------------------------------------------------
    slide4 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide4)
    add_header(slide4, "Tier 1: Core Infrastructure", "Amazon EKS 1.30 & Cloud Foundation", "Provisioned via Terraform with high-availability networking and native add-ons")

    add_card(slide4, Inches(0.8), Inches(2.0), Inches(5.6), Inches(4.8),
             "Networking & Compute Blueprint",
             [
                 "VPC CIDR: 10.0.0.0/16 with DNS Support & Hostnames enabled.",
                 "Public Subnets: 10.0.0.0/24, 10.0.1.0/24 (Tagged for ELB).",
                 "Private Subnets: 10.0.10.0/24, 10.0.11.0/24 (Tagged for Internal ELB).",
                 "Cost-optimized NAT Gateway with dedicated Elastic IP.",
                 "EKS Cluster: Version 1.30, Public/Private Endpoint.",
                 "Managed Node Group: 2x t3.medium instances in private subnets.",
                 "Auto-scaling configuration: Min 2, Desired 2, Max 2."
             ],
             badge_text="VPC & EKS", accent_color=C_ACCENT_BLUE)

    add_card(slide4, Inches(6.8), Inches(2.0), Inches(5.6), Inches(4.8),
             "Cluster Add-ons & IRSA Roles",
             [
                 "VPC-CNI: AWS-native pod networking with ENI IP allocation.",
                 "CoreDNS & Kube-Proxy: Managed cluster service discovery.",
                 "EKS Pod Identity Agent: Modern AWS credential management.",
                 "Metrics Server: HPA & real-time resource utilization.",
                 "AWS Mountpoint S3 CSI Driver: S3 bucket volume mounts.",
                 "IAM OIDC Provider: Fine-grained IRSA roles for pods.",
                 "Monitoring Namespace: Pre-loaded with Prometheus Community Helm stack."
             ],
             badge_text="ADD-ONS & IAM", accent_color=C_ACCENT_GREEN)

    # -------------------------------------------------------------------------
    # SLIDE 5: Tier 2 - Platform & DevEx (Backstage & ArgoCD)
    # -------------------------------------------------------------------------
    slide5 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide5)
    add_header(slide5, "Tier 2: DevEx Platform", "Internal Developer Portal, GitOps & Quality Gate", "Empowering engineering teams with Backstage, ArgoCD, SonarQube, and RDS")

    add_card(slide5, Inches(0.8), Inches(2.0), Inches(5.6), Inches(4.8),
             "Backstage & Managed PostgreSQL",
             [
                 "Backstage IDP: Centralized software catalog, documentation & APIs.",
                 "RDS PostgreSQL 15: Dedicated instance for relational catalog state.",
                 "Catalog Entity Discovery: Integrates apps-demo-2026 catalog-info.yaml.",
                 "Disaster Recovery: Automated backup endpoint /backstage-rds-dump.sql.",
                 "Pre-configured plugins: Kubernetes, TechDocs, SonarQube, ArgoCD.",
                 "Route 53 CNAME: http://backstage.<lab-id>.realhandsonlabs.net."
             ],
             badge_text="BACKSTAGE IDP", accent_color=C_ACCENT_PURPLE)

    add_card(slide5, Inches(6.8), Inches(2.0), Inches(5.6), Inches(4.8),
             "ArgoCD, SonarQube & Grafana",
             [
                 "ArgoCD GitOps: Declarative continuous delivery from Git repositories.",
                 "SonarQube Scanner: Static code analysis, security & vulnerability gates.",
                 "Grafana Dashboards: Real-time telemetry, cluster & pod health.",
                 "Dynamic DNS Endpoints automatically created:",
                 "  • http://argocd.<lab-id>.realhandsonlabs.net",
                 "  • http://sonarqube.<lab-id>.realhandsonlabs.net",
                 "  • http://grafana.<lab-id>.realhandsonlabs.net"
             ],
             badge_text="GITOPS & QUALITY", accent_color=C_ACCENT_BLUE)

    # -------------------------------------------------------------------------
    # SLIDE 6: Tier 3 - Enterprise IAM (Samba 4 AD & Keycloak)
    # -------------------------------------------------------------------------
    slide6 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide6)
    add_header(slide6, "Tier 3: Enterprise Identity", "Samba 4 Multi-DC Active Directory & Keycloak SSO", "Dual domain controllers in EKS private subnets with FreeRADIUS MFA")

    add_card(slide6, Inches(0.8), Inches(2.0), Inches(5.6), Inches(4.8),
             "Samba 4 Active Directory Multi-DC",
             [
                 "Dual Domain Controllers (DC1 & DC2) on dedicated EC2 instances.",
                 "Attached directly to EKS VPC Private Subnets for low latency.",
                 "Automated DRS replication between domain controllers.",
                 "Samba internal DNS disabled to prevent conflict with Route 53.",
                 "FreeRADIUS Integration: Multi-Factor Authentication (MFA) on port 1812.",
                 "Round-Robin LDAP resolution: ldap://ad.<lab-id>.realhandsonlabs.net:389."
             ],
             badge_text="ACTIVE DIRECTORY", accent_color=C_ACCENT_AMBER)

    add_card(slide6, Inches(6.8), Inches(2.0), Inches(5.6), Inches(4.8),
             "Keycloak Central SSO & Federation",
             [
                 "Keycloak 24 IAM: Enterprise Single Sign-On (SSO) gateway.",
                 "User Federation: Syncs users and groups directly with Samba AD LDAP.",
                 "Modern Protocols: SAML 2.0 & OIDC tokens for Backstage and microservices.",
                 "Automated Ansible provisioner initializes realms, clients, and roles.",
                 "Public SSO CNAME: http://sso.<lab-id>.realhandsonlabs.net.",
                 "Enables seamless SSO login for developers across the entire platform."
             ],
             badge_text="KEYCLOAK SSO", accent_color=C_ACCENT_PURPLE)

    # -------------------------------------------------------------------------
    # SLIDE 7: Tier 4 - Polyglot Microservices
    # -------------------------------------------------------------------------
    slide7 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide7)
    add_header(slide7, "Tier 4: Polyglot Microservices", "Python & .NET 8 Microservices with CI/CD", "Production-ready workloads integrated with SonarQube, Prometheus, and Backstage")

    add_card(slide7, Inches(0.8), Inches(2.0), Inches(5.6), Inches(4.8),
             "Python 3.12 Flask Microservice",
             [
                 "High-performance REST API with modular Flask blueprint routing.",
                 "Prometheus Metrics Exporter: Exposes /metrics for scrape target.",
                 "Structured JSON logging ready for Fluentd and Loki log aggregation.",
                 "catalog-info.yaml registered in Backstage with links to Grafana & SonarQube.",
                 "Automated Docker multi-stage build & EKS Kubernetes deployment.",
                 "Dynamic Route 53 Endpoint: http://python.<lab-id>.realhandsonlabs.net."
             ],
             badge_text="PYTHON APP", accent_color=C_ACCENT_BLUE)

    add_card(slide7, Inches(6.8), Inches(2.0), Inches(5.6), Inches(4.8),
             " .NET 8 C# Enterprise Microservice",
             [
                 "Modern ASP.NET Core 8 Web API with Dependency Injection.",
                 "Built-in Health Checks (/healthz) and OpenTelemetry instrumentation.",
                 "SonarQube Quality Gate enforced in GitHub Actions CI pipeline.",
                 "Dedicated catalog-info.yaml defines component, dependencies, and API specs.",
                 "Zero-downtime rolling deployment managed by Kubernetes Service.",
                 "Dynamic Route 53 Endpoint: http://dotnet.<lab-id>.realhandsonlabs.net."
             ],
             badge_text=".NET 8 C# APP", accent_color=C_ACCENT_GREEN)

    # -------------------------------------------------------------------------
    # SLIDE 8: Dynamic Route 53 DNS Engine
    # -------------------------------------------------------------------------
    slide8 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide8)
    add_header(slide8, "Networking & DNS", "Route 53 Dynamic Discovery & CNAME Delegation", "Solving the random hosted zone dilemma in ephemeral sandbox environments")

    add_card(slide8, Inches(0.8), Inches(2.0), Inches(5.6), Inches(4.8),
             "The Auto-Discovery Mechanism",
             [
                 "Lab accounts automatically create a hosted zone: *realhandsonlabs.net.",
                 "Terraform data source queries: data \"aws_route53_zone\" \"lab\" { }.",
                 "Extracts the random subsegment: <random-id> from the zone name.",
                 "Dynamically synthesizes canonical domain endpoints without hardcoding.",
                 "Generates CNAME records pointing to AWS Load Balancer hostnames.",
                 "Runs sync-cluster-dns.sh post-deployment to ensure ELB readiness."
             ],
             badge_text="TERRAFORM DNS", accent_color=C_ACCENT_BLUE)

    add_card(slide8, Inches(6.8), Inches(2.0), Inches(5.6), Inches(4.8),
             "Complete Service DNS Directory",
             [
                 "Platform: http://backstage.<lab-id>.realhandsonlabs.net",
                 "GitOps:   http://argocd.<lab-id>.realhandsonlabs.net",
                 "QA/Code:  http://sonarqube.<lab-id>.realhandsonlabs.net",
                 "Metrics:  http://grafana.<lab-id>.realhandsonlabs.net",
                 "Identity: http://sso.<lab-id>.realhandsonlabs.net",
                 "Directory: ldap://ad.<lab-id>.realhandsonlabs.net:389",
                 "Microservices: http://python.<lab-id>... & http://dotnet.<lab-id>...",
                 "All URLs cleanly published into GitHub Actions Step Summary."
             ],
             badge_text="DNS REGISTRY", accent_color=C_ACCENT_GREEN)

    # -------------------------------------------------------------------------
    # SLIDE 9: Observability & Telemetry
    # -------------------------------------------------------------------------
    slide9 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide9)
    add_header(slide9, "Observability & Telemetry", "Prometheus Metrics, Fluentd Logging & Grafana", "End-to-end full stack visibility across infrastructure, containers, and applications")

    add_card(slide9, Inches(0.8), Inches(2.0), Inches(3.6), Inches(4.8),
             "1. Prometheus Scraping",
             [
                 "Deployed via Helm 25.27.0 in monitoring namespace.",
                 "Scrapes kubelet, cAdvisor, node-exporter, and cluster pods.",
                 "Scrapes /metrics on Python and .NET microservices.",
                 "In-cluster URL: http://prometheus-server.monitoring.svc.cluster.local."
             ],
             badge_text="METRICS", accent_color=C_ACCENT_BLUE)

    add_card(slide9, Inches(4.85), Inches(2.0), Inches(3.6), Inches(4.8),
             "2. Fluentd & Loki Logs",
             [
                 "Dedicated IRSA IAM role for Fluentd CloudWatch/S3 logging.",
                 "DaemonSet collects stdout/stderr from all worker node containers.",
                 "Loki log aggregation provides indexed log querying.",
                 "Correlates log traces with metrics in Backstage and Grafana."
             ],
             badge_text="LOGGING", accent_color=C_ACCENT_PURPLE)

    add_card(slide9, Inches(8.9), Inches(2.0), Inches(3.6), Inches(4.8),
             "3. Grafana Dashboards",
             [
                 "Pre-provisioned dashboards for EKS cluster, nodes, and pods.",
                 "Application performance monitoring (latency, errors, RPS).",
                 "Accessible via friendly dynamic Route 53 CNAME.",
                 "Deep links embedded directly in Backstage catalog components."
             ],
             badge_text="VISUALIZATION", accent_color=C_ACCENT_GREEN)

    # -------------------------------------------------------------------------
    # SLIDE 10: Zero-to-Production Playbook
    # -------------------------------------------------------------------------
    slide10 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide10)
    add_header(slide10, "Operations & Runbook", "Zero-to-Production Execution Sequence", "Step-by-step pipeline to provision the complete architecture in a new AWS account")

    phases = [
        ("Phase 0", "Credentials & Backup", "Update AWS secrets in GitHub Actions (cirobessa & cirodasilvaj accounts); optional DB dump.", C_ACCENT_AMBER),
        ("Phase 1", "Base Infrastructure", "Run eks.yml on cirobessa/kube-demo-2026. Deploys VPC, Subnets, EKS 1.30, and Prometheus.", C_ACCENT_BLUE),
        ("Phase 2", "Local Kubeconfig", "Execute 'aws eks update-kubeconfig --name kube-demo-eks' to verify node readiness.", C_ACCENT_GREEN),
        ("Phase 3", "DevEx Platform & DB", "Run terraform.yml on backstage-infra. Deploys RDS PostgreSQL, Backstage, ArgoCD, SonarQube.", C_ACCENT_PURPLE),
        ("Phase 4", "Enterprise IAM", "Run deploy.yml on samba-ad-keycloak. Provisions Samba 4 Multi-DC and Keycloak inside EKS VPC.", C_ACCENT_AMBER),
        ("Phase 5", "Microservices & CI", "Run build.yml on apps-demo-2026. Builds and deploys Python and .NET apps with SonarQube scan.", C_ACCENT_BLUE),
    ]

    for idx, (p_title, p_sub, p_desc, col) in enumerate(phases):
        x = Inches(0.8 + (idx % 3) * 4.05)
        y = Inches(2.0 + (idx // 3) * 2.5)
        card = slide10.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, x, y, Inches(3.7), Inches(2.2))
        card.fill.solid()
        card.fill.fore_color.rgb = C_CARD
        card.line.color.rgb = col
        card.line.width = Pt(1.5)

        tb = slide10.shapes.add_textbox(x + Inches(0.15), y + Inches(0.15), Inches(3.4), Inches(1.9))
        tf = tb.text_frame
        tf.word_wrap = True

        p0 = tf.paragraphs[0]
        p0.text = f"{p_title}: {p_sub}"
        p0.font.size = Pt(13)
        p0.font.bold = True
        p0.font.color.rgb = col
        p0.space_after = Pt(4)

        p1 = tf.add_paragraph()
        p1.text = p_desc
        p1.font.size = Pt(11)
        p1.font.color.rgb = C_TEXT_WHITE

    # -------------------------------------------------------------------------
    # SLIDE 11: Disaster Recovery & State Continuity
    # -------------------------------------------------------------------------
    slide11 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide11)
    add_header(slide11, "Disaster Recovery", "Surviving Sandbox Termination & State Hydration", "Ensuring configuration, code, and relational data continuity across ephemeral account resets")

    add_card(slide11, Inches(0.8), Inches(2.0), Inches(5.6), Inches(4.8),
             "State Continuity Architecture",
             [
                 "S3 Remote Backend with DynamoDB / native S3 state locking.",
                 "Separate state keys per repository isolate failure domains:",
                 "  • kube-demo-2026/eks/terraform.tfstate",
                 "  • backstage-infra/terraform.tfstate",
                 "  • samba-ad-keycloak/terraform.tfstate",
                 "All infrastructure is 100% codified — zero manual config.",
                 "Automated tear-down: 'terraform destroy' cleanly removes ELBs to prevent orphaned ENIs before account termination."
             ],
             badge_text="TERRAFORM STATE", accent_color=C_ACCENT_BLUE)

    add_card(slide11, Inches(6.8), Inches(2.0), Inches(5.6), Inches(4.8),
             "Database Rehydration & Secrets",
             [
                 "Backstage Catalog Schema rehydrated automatically on boot.",
                 "db/schema.sql pre-seeds components, templates, and plugins.",
                 "Live SQL backup dump can be fetched before account expiration:",
                 "  curl -u admin:*** http://<ELB>/backstage-rds-dump.sql.",
                 "GitHub Actions Secrets act as the single source of credential truth.",
                 "Recovery Time Objective (RTO): < 20 minutes from blank account to live.",
                 "Recovery Point Objective (RPO): Code is 0s (Git-backed); DB is per-dump."
             ],
             badge_text="RTO & RPO", accent_color=C_ACCENT_GREEN)

    # -------------------------------------------------------------------------
    # SLIDE 12: Architecture Summary & Key Takeaways
    # -------------------------------------------------------------------------
    slide12 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide12)
    add_header(slide12, "Summary & Key Takeaways", "Enterprise Architecture Mastery in AWS Sandboxes", "A production-grade, highly automated, fully resilient cloud foundation")

    # 4 summary boxes
    metrics = [
        ("4 Repositories", "Decoupled GitOps and Infrastructure layers with clean interfaces", C_ACCENT_BLUE),
        ("< 20 Min", "Zero-to-production deployment time in any brand new AWS sandbox", C_ACCENT_GREEN),
        ("100% Codified", "Terraform, Kubernetes manifests, Helm charts, and Ansible playbooks", C_ACCENT_PURPLE),
        ("Dynamic DNS", "Automated Route 53 zone auto-discovery & CNAME delegation", C_ACCENT_AMBER),
    ]

    for idx, (m_title, m_desc, col) in enumerate(metrics):
        x = Inches(0.8 + (idx % 2) * 6.0)
        y = Inches(2.0 + (idx // 2) * 2.5)
        card = slide12.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, x, y, Inches(5.6), Inches(2.2))
        card.fill.solid()
        card.fill.fore_color.rgb = C_CARD
        card.line.color.rgb = col
        card.line.width = Pt(1.5)

        tb = slide12.shapes.add_textbox(x + Inches(0.2), y + Inches(0.2), Inches(5.2), Inches(1.8))
        tf = tb.text_frame
        tf.word_wrap = True

        p0 = tf.paragraphs[0]
        p0.text = m_title
        p0.font.size = Pt(22)
        p0.font.bold = True
        p0.font.color.rgb = col
        p0.space_after = Pt(6)

        p1 = tf.add_paragraph()
        p1.text = m_desc
        p1.font.size = Pt(13)
        p1.font.color.rgb = C_TEXT_WHITE

    # Save presentation
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    prs.save(output_path)
    print(f"Presentation successfully created at: {output_path}")

if __name__ == "__main__":
    out_file = "/home/ciro/kube-demo-2026/docs/kube-demo-2026-architecture.pptx"
    if len(sys.argv) > 1:
        out_file = sys.argv[1]
    build_presentation(out_file)
