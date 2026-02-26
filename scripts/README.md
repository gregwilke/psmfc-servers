# Scripts

This folder contains helper scripts for server management and automation.

## Purpose

Scripts to automate common tasks:
- Server health checks
- Deployment helpers
- Backup scripts
- Verification scripts
- Monitoring tools

## Current Contents

(Empty - scripts will be added as needed)

## Usage Guidelines

1. **Test scripts** on development servers first
2. **Document script purpose** at the top of each file
3. **Include usage examples** in comments
4. **Make scripts executable:** `chmod +x script-name.sh`
5. **Use version control** for tracking changes

## Example Script Structure

```bash
#!/bin/bash
#
# Script Name: check-applications.sh
# Purpose: Verify all applications are running on battra and manda
# Usage: ./check-applications.sh
# Author: Greg/Claude
# Date: 2026-02-26
#

# Script content here...
```

## Naming Convention

Use descriptive names with action verbs:
- `check-application-status.sh`
- `backup-nginx-configs.sh`
- `verify-ssl-certificates.sh`
- `restart-all-services.sh`
