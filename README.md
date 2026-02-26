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
- **Status:** ✅ Ready for DNS switchover

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
- **Access:** `ssh root@manda.psmfc.org`
- **Special:** Auto-mounted /home directories to Horus for file storage
- **Status:** ✅ Ready for DNS switchover

### Old Servers (Being Retired)

#### Phish (phish.psmfc.org)
- **OS:** Ubuntu 18.04
- **Status:** Production (being replaced by manda)
- **Access:** `ssh nodejs@phish.psmfc.org`
- **Action:** Do not modify - reference only

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
ssh root@manda.psmfc.org "hostname"
ssh nodejs@phish.psmfc.org "hostname"
```

### Step 3: Check Application Status
```bash
# Battra applications
ssh nodejs@battra.psmfc.org "pm2 list"

# Manda applications
ssh root@manda.psmfc.org "ps aux | grep 'node /var' | grep -v grep"
```

---

## 📋 Current Status (as of 2026-02-26)

### Migration Status

| Server | Applications | Configuration | SSL | Auto-Mount | Status |
|--------|-------------|---------------|-----|------------|--------|
| Battra | 3/3 running | ✅ Complete | ✅ Valid | N/A | ✅ Ready |
| Manda | 6/6 running | ✅ Complete | ✅ Valid | ✅ Configured | ✅ Ready |

### DNS Switchover
- **Status:** NOT YET PERFORMED
- **Planned:** When Greg is ready
- **Preparation:** All verification complete
- **Checklist:** Use dns-switchover-checklist.md

### Domains Ready to Switch

**Battra (3 domains):**
- fishregs-dev.psmfc.org
- hcaxdev.psmfc.org
- sddtdev.psmfc.org

**Manda (6 active domains):**
- phish.streamnet.org
- data.kbfishc.org
- dev.kbfishc.org
- phish.rmis.org
- kbfish-api.psmfc.org
- test.kbfishc.org

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
ssh root@manda.psmfc.org "ps aux | grep 'node /var' | grep -v grep"
ssh root@manda.psmfc.org "systemctl status pm2-nodejs"
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
ssh root@manda.psmfc.org "nginx -t"

# Reload Nginx
ssh nodejs@battra.psmfc.org "sudo systemctl reload nginx"
ssh root@manda.psmfc.org "systemctl reload nginx"

# Check status
ssh nodejs@battra.psmfc.org "sudo systemctl status nginx"
ssh root@manda.psmfc.org "systemctl status nginx"
```

### View Logs
```bash
# Battra - PM2 logs
ssh nodejs@battra.psmfc.org "pm2 logs --lines 50"

# Manda - Nginx logs
ssh root@manda.psmfc.org "tail -f /var/log/nginx/error.log"

# Manda - Application logs (if PM2 accessible)
ssh root@manda.psmfc.org "sudo -u nodejs bash -c 'cd /var/nodejs && pm2 logs --lines 50'"
```

### Check Auto-Mount (Manda only)
```bash
# Verify autofs service
ssh root@manda.psmfc.org "systemctl status autofs"

# List mounted directories
ssh root@manda.psmfc.org "ls /home/*data"

# Test directory access
ssh root@manda.psmfc.org "ls /home/*data/up/ | head -5"

# Check cron job
ssh root@manda.psmfc.org "crontab -l | grep lscwtdirs"
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
