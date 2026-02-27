# PSMFC Server Migration & Configuration Documentation

**Last Updated:** 2026-02-26
**Purpose:** Index and overview of PSMFC server migration documentation

---

## 📚 Documentation Index

### 1. [SSH Access Configuration](ssh-access-configuration.md)
**Purpose:** SSH keys and access setup for Claude Code sessions

**Contains:**
- SSH public/private key pair
- Server access details (battra, manda, phish)
- Setup instructions for future Claude sessions
- Troubleshooting guide

**⚠️ SECURITY:** Contains private SSH key - keep secure

**When to use:** At the start of any new Claude session that needs server access

---

### 2. [DNS Switchover Checklist](dns-switchover-checklist.md)
**Purpose:** Complete checklist for DNS migration from old to new servers

**Contains:**
- Pre-switchover verification steps for battra and manda
- DNS update procedure with phased approach
- Post-switchover verification steps
- Rollback procedure if issues occur
- Troubleshooting common problems

**When to use:** When ready to switch DNS from old servers to new servers

---

### 3. [Manda Auto-Mount Configuration](manda-auto-mount-configuration.md)
**Purpose:** NFS auto-mount configuration for CWT agency file storage

**Contains:**
- Auto-mount setup for /home directories
- lscwtdirs script configuration
- Cron job setup
- Verification procedures
- How files are stored on Horus

**When to use:** Understanding file storage, troubleshooting upload issues, or setting up similar configuration on other servers

---

## 🖥️ Server Overview

### Production Servers (New - Ubuntu 24.04)

#### Battra (battra.psmfc.org)
- **IP:** 10.2.13.180
- **Purpose:** Development applications
- **Applications:** 3 Next.js apps
  - fishregs-dev.psmfc.org
  - hcaxdev.psmfc.org
  - sddtdev.psmfc.org
- **Access:** `ssh nodejs@battra.psmfc.org`
- **Passwordless Sudo:** Yes
- **Status:** ✅ Ready for DNS switchover

#### Gabara (gabara.psmfc.org)
- **IP:** 10.2.13.181
- **Purpose:** Production applications
- **Applications:** 2 Node.js apps
  - fishregs-data.psmfc.org
  - sddt.psmfc.org
- **Access:** `ssh nodejs@gabara.psmfc.org`
- **Passwordless Sudo:** Yes
- **Status:** ✅ Active

#### Manda (manda.psmfc.org)
- **IP:** 10.2.13.182
- **Purpose:** Production applications
- **Applications:** 6 active Node.js apps
  - phish.streamnet.org
  - data.kbfishc.org
  - dev.kbfishc.org
  - phish.rmis.org
  - kbfish-api.psmfc.org
  - test.kbfishc.org
- **Access:** `ssh nodejs@manda.psmfc.org`
- **Passwordless Sudo:** Yes
- **Special:** Auto-mounted /home directories to Horus for file storage (including nodejs home)
- **Status:** ✅ Ready for DNS switchover

### Old Servers (Being Retired)

#### Phish (phish.psmfc.org)
- **OS:** Ubuntu 18.04
- **Status:** Partially decommissioned
- **Access:** `ssh nodejs@phish.psmfc.org` (has passwordless sudo)

**Disabled Apps (switched to Manda):**
- library (phish.streamnet.org)
- kbfish-api (kbfish-api.psmfc.org)
- rmis (phish.rmis.org)

**Still Running (pending switchover):**
- kbfish (data.kbfishc.org)
- kbfish-dev (dev.kbfishc.org)
- kbfish-api-dev (test.kbfishc.org)
- streamnet

---

## 🚀 Quick Start for New Claude Sessions

### Step 1: Restore SSH Access
```bash
# Check if SSH keys already exist
ls -la ~/.ssh/id_ed25519

# If not, restore from ssh-access-configuration.md
# Follow "Initial Setup" section in that document
```

### Step 2: Verify Server Access
```bash
# Test all servers
ssh nodejs@battra.psmfc.org "hostname"
ssh nodejs@manda.psmfc.org "hostname"
ssh nodejs@phish.psmfc.org "hostname"
```

### Step 3: Check Application Status
```bash
# Battra applications
ssh nodejs@battra.psmfc.org "pm2 list"

# Manda applications
ssh nodejs@manda.psmfc.org "ps aux | grep 'node /var' | grep -v grep"
```

---

## 🌐 Network Architecture

### Routing Methods

There are two ways traffic reaches our servers:

1. **Direct DNS** (newer approach)
   - DNS points directly to server IP (e.g., 10.2.13.182 for Manda)
   - Example: kbfish-api.psmfc.org → manda.psmfc.org (10.2.13.182)

2. **IIS Reverse Proxy** (legacy approach)
   - DNS points to psmfc-web.psmfc.org (10.2.13.10)
   - IIS reverse proxy forwards requests to backend server
   - Example: phish.rmis.org → psmfc-web (10.2.13.10) → manda (10.2.13.182)

**Goal:** Standardize on direct DNS when time permits.

---

## 📋 Current Status (as of 2026-02-26)

### Migration Status

| Server | Applications | Configuration | SSL | Auto-Mount | Status |
|--------|-------------|---------------|-----|------------|--------|
| Battra | 3/3 running | ✅ Complete | ✅ Valid | N/A | ✅ Ready |
| Manda | 6/6 running | ✅ Complete | ✅ Valid | ✅ Configured | ✅ Ready |

### DNS Switchover Status

#### ✅ Switched to Manda (3 domains)

| Domain | Routing | Verified | Phish Disabled |
|--------|---------|----------|----------------|
| kbfish-api.psmfc.org | Direct DNS → 10.2.13.182 | ✅ 2026-02-26 | ✅ 2026-02-26 |
| phish.rmis.org | Via psmfc-web proxy | ✅ 2026-02-26 | ✅ 2026-02-26 |
| phish.streamnet.org | Via psmfc-web proxy | ✅ 2026-02-26 | ✅ 2026-02-26 |

#### ⏳ Pending - Manda (3 domains)

| Domain | Current | Target |
|--------|---------|--------|
| data.kbfishc.org | phish | manda |
| dev.kbfishc.org | phish | manda |
| test.kbfishc.org | phish | manda |

#### ⏳ Pending - Battra (3 domains)

| Domain | Target |
|--------|--------|
| fishregs-dev.psmfc.org | battra (10.2.13.180) |
| hcaxdev.psmfc.org | battra (10.2.13.180) |
| sddtdev.psmfc.org | battra (10.2.13.180) |

**Manda (2 inactive - ready if needed):**
- api2.streamnet.org (streamnet-api not running)
- internal.streamnet.org (streamnet-api not running)

---

## 🔧 Common Tasks

### Check Application Status
```bash
# Battra
ssh nodejs@battra.psmfc.org "pm2 list"

# Manda
ssh nodejs@manda.psmfc.org "ps aux | grep 'node /var' | grep -v grep"
ssh nodejs@manda.psmfc.org "sudo systemctl status pm2-nodejs"
```

### Restart Applications
```bash
# Battra - restart specific app
ssh nodejs@battra.psmfc.org "pm2 restart <app-name>"

# Battra - restart all apps
ssh nodejs@battra.psmfc.org "pm2 restart all"
```

### Check Nginx
```bash
# Test configuration
ssh nodejs@battra.psmfc.org "sudo nginx -t"
ssh nodejs@manda.psmfc.org "sudo nginx -t"

# Reload Nginx
ssh nodejs@battra.psmfc.org "sudo systemctl reload nginx"
ssh nodejs@manda.psmfc.org "sudo systemctl reload nginx"

# Check status
ssh nodejs@battra.psmfc.org "sudo systemctl status nginx"
ssh nodejs@manda.psmfc.org "sudo systemctl status nginx"
```

### View Logs
```bash
# Battra - PM2 logs
ssh nodejs@battra.psmfc.org "pm2 logs --lines 50"

# Manda - Nginx logs
ssh nodejs@manda.psmfc.org "tail -f /var/log/nginx/error.log"

# Manda - Application logs (if PM2 accessible)
ssh nodejs@manda.psmfc.org "sudo -u nodejs bash -c 'cd /var/nodejs && pm2 logs --lines 50'"
```

### Check Auto-Mount (Manda only)
```bash
# Verify autofs service
ssh nodejs@manda.psmfc.org "sudo systemctl status autofs"

# List mounted directories
ssh nodejs@manda.psmfc.org "ls /home/*data"

# Test directory access
ssh nodejs@manda.psmfc.org "ls /home/*data/up/ | head -5"

# Check cron job
ssh nodejs@manda.psmfc.org "sudo crontab -l | grep lscwtdirs"
```

---

## 🔐 Security Notes

### SSH Keys
- Keys are ED25519 type (modern, secure)
- Private key stored in ssh-access-configuration.md
- Keys grant full access (nodejs user with sudo on battra, root on manda)
- Use responsibly under Greg's direction only

### Access Levels
- **Battra:** nodejs user with passwordless sudo
- **Manda:** root user (required due to /home being network-mounted)
- **Phish:** nodejs user (read-only reference, don't modify)

### Best Practices
1. Always verify you're on the correct server before running commands
2. Test in dev environments first when possible
3. Back up configurations before changes
4. Document all changes made
5. Verify services after changes

---

## 🐛 Troubleshooting

### Cannot SSH to Server
**See:** [ssh-access-configuration.md](ssh-access-configuration.md) - Troubleshooting section

### Application Not Running
```bash
# Check PM2 status
pm2 list

# Check logs
pm2 logs <app-name>

# Restart if needed
pm2 restart <app-name>
```

### Nginx Errors
```bash
# Test configuration
nginx -t

# Check error logs
tail -f /var/log/nginx/error.log

# Common fix: reload nginx
systemctl reload nginx
```

### Files Not Uploading (Manda RMIS)
**See:** [manda-auto-mount-configuration.md](manda-auto-mount-configuration.md) - Troubleshooting section

```bash
# Quick checks
systemctl status autofs
ls /home/*data
/usr/local/sbin/lscwtdirs
```

---

## 📞 Contacts

- **Greg:** Application Administrator
- **Dan (PSMFC):** Systems Administrator - created auto-mount setup

---

## 📝 Document History

| Date | Event | Details |
|------|-------|---------|
| 2026-02-26 | Migration preparation complete | All servers ready for DNS switchover |
| 2026-02-26 | Documentation created | SSH access, DNS checklist, auto-mount config |
| 2026-02-26 | 3 domains switched to Manda | kbfish-api.psmfc.org (direct), phish.rmis.org (proxy), phish.streamnet.org (proxy) |
| 2026-02-26 | Disabled switched apps on Phish | Stopped PM2 apps and disabled Nginx configs for library, kbfish-api, rmis |
| 2026-02-26 | Standardized Manda SSH access | Changed from root to nodejs user, added passwordless sudo, nodejs home on Horus |
| 2026-02-26 | Added Gabara server | gabara.psmfc.org (10.2.13.181) with fishregs-data and sddt apps |

---

## 🎯 Next Steps

1. **When ready for DNS switchover:**
   - Review [dns-switchover-checklist.md](dns-switchover-checklist.md)
   - Perform pre-switchover verification steps
   - Update DNS records in phases (dev domains first)
   - Perform post-switchover verification
   - Monitor for 24-48 hours

2. **After successful switchover:**
   - Monitor applications for issues
   - Document any problems and solutions
   - Plan decommissioning of old servers (phish, etc.)

3. **Ongoing maintenance:**
   - Regular application updates
   - Monitor auto-mount functionality (manda)
   - SSL certificate renewals
   - Security updates

---

**End of Index**

For detailed information on any topic, refer to the specific documentation file listed above.
