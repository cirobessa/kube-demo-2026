---
name: playwright-inspector
description: >-
  Use this skill to inspect, browse, debug, and take screenshots of web applications, Backstage portals, Grafana dashboards, and internal HTTP endpoints using headless Playwright.
---

# Playwright Web Inspector

This skill provides headless browser inspection capabilities using Playwright to view, navigate, interact with, and capture screenshots of web interfaces (such as Backstage Developer Portal, Grafana, SonarQube, and ArgoCD).

## Features
- Handles HTTP Basic Authentication proxy (`admin` / `Backstage@2026`).
- Automatically handles Backstage Guest Sign-in flow.
- Captures full-page screenshots saved to the conversation artifacts directory.
- Dumps DOM structure, Material-UI alert cards, console logs, and errors.

## Running the Inspector
```bash
node /home/ciro/playwright-tool/inspect-backstage.js "http://backstage.<domain>/catalog/default/component/<name>"
```
