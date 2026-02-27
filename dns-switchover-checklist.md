# DNS Switchover Checklist - Battra & Manda Servers

**Date Prepared:** 2026-02-26
**Purpose:** Complete readiness verification and switchover checklist for migrating domains from old Ubuntu servers to new servers

---

## Table of Contents

1. [Overview](#overview)
2. [Battra Server Checklist](#battra-server-checklist)
3. [Manda Server Checklist](#manda-server-checklist)
4. [DNS Update Procedure](#dns-update-procedure)
5. [Post-Switchover Verification](#post-switchover-verification)
6. [Rollback Procedure](#rollback-procedure)

---

## Overview

### Migration Summary

**Old Servers → New Servers:**
- Old: Ubuntu 16.04/18.04 servers (past EOL)
- New: Ubuntu 24.04 LTS servers
- Applications: Node.js applications with PM2, Nginx reverse proxy
- Migration approach: Clone applications, configure Nginx, set up SSL, verify readiness

### Servers Involved

| New Server | Old Server | IP Address | Applications |
|------------|------------|------------|--------------|
| battra.psmfc.org | (various) | 10.2.13.180 | 3 Next.js apps |
| manda.psmfc.org | phish.psmfc.org | 10.2.13.182 | 6 Node.js apps |

---

## Battra Server Checklist

### Server Information
- **Hostname:** battra.psmfc.org
- **IP Address:** 10.2.13.180
- **OS:** Ubuntu 24.04 LTS
- **Applications:** 3 Node.js applications (PM2)

### DNS Records to Update

| Domain | Current Server | New Server | Port | SSL |
|--------|---------------|------------|------|-----|
| fishregs-dev.psmfc.org | (old) | battra | 3000 | Yes |
| hcaxdev.psmfc.org | (old) | battra | 3002 | Yes |
| sddtdev.psmfc.org | (old) | battra | 3001 | Yes |

### Pre-Switchover Verification

#### 1. Check PM2 Applications
```bash
ssh nodejs@battra.psmfc.org "pm2 list"
```

**Expected Output:**
```
┌────┬──────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┐
│ id │ name         │ version │ mode    │ pid      │ uptime │ ↺    │ status    │
├────┼──────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┤
│ 0  │ fishregs-dev │ 0.40.3  │ fork    │ running  │ XXd    │ X    │ online    │
│ 1  │ hcaxdev      │ 0.40.3  │ fork    │ running  │ XXd    │ X    │ online    │
│ 2  │ sddtdev      │ 0.40.3  │ fork    │ running  │ XXd    │ X    │ online    │
└────┴──────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┘
```

✅ All 3 applications should show status: **online**

#### 2. Check Listening Ports
```bash
ssh nodejs@battra.psmfc.org "netstat -tlnp | grep -E ':(80|443|3000|3001|3002)' | grep LISTEN"
```

**Expected:**
- Port 80 (HTTP) - Nginx
- Port 443 (HTTPS) - Nginx
- Port 3000 - fishregs-dev
- Port 3001 - sddtdev
- Port 3002 - hcaxdev

#### 3. Verify Nginx Configuration
```bash
ssh nodejs@battra.psmfc.org "sudo sudo nginx -t"
```

**Expected:** `nginx: configuration file /etc/nginx/nginx.conf test is successful`

#### 4. Check Nginx Sites
```bash
ssh nodejs@battra.psmfc.org "ls -la /etc/nginx/sites-enabled/"
```

**Expected files:**
- fishregs.psmfc.org.conf
- hcax.psmfc.org.conf
- sddt.psmfc.org.conf

#### 5. Verify SSL Certificates
```bash
ssh nodejs@battra.psmfc.org "ls -la /etc/ssl/certs/psmfc.org.crt /etc/ssl/private/psmfc.org.key"
```

**Expected:** Both files should exist with proper permissions

#### 6. Test Application Responses
```bash
# Test each application locally
ssh nodejs@battra.psmfc.org "curl -s -o /dev/null -w '%{http_code}' http://localhost:3000"  # fishregs-dev
ssh nodejs@battra.psmfc.org "curl -s -o /dev/null -w '%{http_code}' http://localhost:3001"  # sddtdev
ssh nodejs@battra.psmfc.org "curl -s -o /dev/null -w '%{http_code}' http://localhost:3002"  # hcaxdev
```

**Expected:** All should return `200`

#### 7. Test Nginx Reverse Proxy
```bash
ssh nodejs@battra.psmfc.org "curl -k -s -o /dev/null -w '%{http_code}' -H 'Host: fishregs-dev.psmfc.org' https://localhost"
ssh nodejs@battra.psmfc.org "curl -k -s -o /dev/null -w '%{http_code}' -H 'Host: sddtdev.psmfc.org' https://localhost"
ssh nodejs@battra.psmfc.org "curl -k -s -o /dev/null -w '%{http_code}' -H 'Host: hcaxdev.psmfc.org' https://localhost"
```

**Expected:** All should return `200`

#### 8. Verify PM2 Persistence
```bash
ssh nodejs@battra.psmfc.org "pm2 startup"
```

**Expected:** Should indicate PM2 will start on boot

### Configuration Details

#### Application Locations
- **fishregs-dev:** `/var/www/html/SN-Regulations`
- **hcaxdev:** `/var/www/html/streamnet-hcax-query-tool`
- **sddtdev:** `/var/www/html/SN-SDDT`

#### Nginx Configuration Summary
```nginx
# All three use the same pattern:
server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name <domain>;

  ssl_certificate     /etc/ssl/certs/psmfc.org.crt;
  ssl_certificate_key /etc/ssl/private/psmfc.org.key;

  location / {
    proxy_pass http://localhost:<port>;
    # proxy headers...
  }
}

server {
  listen 80;
  listen [::]:80;
  server_name <domain>;
  return 301 https://$server_name$request_uri;
}
```

---

## Manda Server Checklist

### Server Information
- **Hostname:** manda.psmfc.org
- **IP Address:** 10.2.13.182
- **OS:** Ubuntu 24.04 LTS
- **Old Server:** phish.psmfc.org
- **Applications:** 6 active Node.js applications (PM2)

### DNS Records Status

#### ✅ Completed Switchovers

| Domain | New Server | Port | SSL | Backend App | Routing | Switched |
|--------|------------|------|-----|-------------|---------|----------|
| kbfish-api.psmfc.org | manda (10.2.13.182) | 5005 | Yes | kbfish-api | Direct DNS | 2026-02-26 |
| phish.rmis.org | manda (10.2.13.182) | 5001 | Yes | rmis-api | Via psmfc-web proxy | 2026-02-26 |
| phish.streamnet.org | manda (10.2.13.182) | 3000 | No | library | Via psmfc-web proxy | 2026-02-26 |

> **Note:** Some domains route through the IIS reverse proxy at psmfc-web.psmfc.org (10.2.13.10) rather than using direct DNS. This is a legacy configuration; goal is to standardize on direct DNS when time permits.

#### ⏳ Pending Switchovers

| Domain | Current Server | New Server | Port | SSL | Backend App |
|--------|---------------|------------|------|-----|-------------|
| data.kbfishc.org | phish | manda | 3001 | Yes | kbfish |
| dev.kbfishc.org | phish | manda | 3002 | Yes | kbfish-dev |
| test.kbfishc.org | phish | manda | 5006 | Yes | kbfish-api-dev |

### Inactive/Future Use

| Domain | Port | Status | Notes |
|--------|------|--------|-------|
| api2.streamnet.org | 5003 | Not running | Application transferred but not in use |
| internal.streamnet.org | 5003 | Not running | Application transferred but not in use |

### Pre-Switchover Verification

#### 1. Check PM2 Applications
```bash
ssh nodejs@manda.psmfc.org "ps aux | grep 'node /var' | grep -v grep"
```

**Expected:** 6 running node processes
- library (port 3000)
- kbfish (port 3001)
- kbfish-dev (port 3002)
- rmis-api (port 5001)
- kbfish-api (port 5005)
- kbfish-api-dev (port 5006)

#### 2. Check Listening Ports
```bash
ssh nodejs@manda.psmfc.org "netstat -tlnp | grep -E ':(80|443|3000|3001|3002|5001|5005|5006)' | grep LISTEN"
```

**Expected:**
- Port 80 (HTTP) - Nginx
- Port 443 (HTTPS) - Nginx
- Port 3000 - library
- Port 3001 - kbfish (0.0.0.0)
- Port 3002 - kbfish-dev (0.0.0.0)
- Port 5001 - rmis-api (127.0.0.1)
- Port 5005 - kbfish-api (127.0.0.1)
- Port 5006 - kbfish-api-dev (127.0.0.1)

#### 3. Verify Nginx Configuration
```bash
ssh nodejs@manda.psmfc.org "sudo nginx -t"
```

**Expected:** `nginx: configuration file /etc/nginx/nginx.conf test is successful`

#### 4. Check Nginx Sites Enabled
```bash
ssh nodejs@manda.psmfc.org "ls -1 /etc/nginx/sites-enabled/*.conf | xargs -n1 basename"
```

**Expected files:**
- api2.streamnet.org.conf
- data.kbfishc.org.conf
- dev.kbfishc.org.conf
- internal.streamnet.org.conf
- kbfish-api.psmfc.org.conf
- phish.rmis.org.conf
- phish.streamnet.org.conf
- test.kbfishc.org.conf

#### 5. Verify SSL Certificates
```bash
ssh nodejs@manda.psmfc.org "ls -la /etc/ssl/certs/ | grep -E 'kbfishc|psmfc|rmpc'"
```

**Expected certificates:**
- kbfishc.org.crt
- kbfish-api.fullchain.crt
- test.kbfishc.org.fullchain.crt
- www.psmfc.org.crt
- www.rmpc.org.crt

```bash
ssh nodejs@manda.psmfc.org "ls -la /etc/ssl/private/ | grep -E 'kbfishc|psmfc|rmpc'"
```

**Expected keys:**
- kbfishc.org.key
- www.psmfc.org.key
- www.rmpc.org.key

#### 6. Test Application Responses
```bash
ssh nodejs@manda.psmfc.org "curl -s -o /dev/null -w '%{http_code}' http://localhost:3000"  # library
ssh nodejs@manda.psmfc.org "curl -s -o /dev/null -w '%{http_code}' http://localhost:3001"  # kbfish
ssh nodejs@manda.psmfc.org "curl -s -o /dev/null -w '%{http_code}' http://localhost:3002"  # kbfish-dev
ssh nodejs@manda.psmfc.org "curl -s -o /dev/null -w '%{http_code}' http://localhost:5001"  # rmis-api
ssh nodejs@manda.psmfc.org "curl -s -o /dev/null -w '%{http_code}' http://localhost:5005"  # kbfish-api
ssh nodejs@manda.psmfc.org "curl -s -o /dev/null -w '%{http_code}' http://localhost:5006"  # kbfish-api-dev
```

**Expected:** All should return `200` or `302`

#### 7. Verify Auto-Mount Configuration
```bash
ssh nodejs@manda.psmfc.org "sudo systemctl status autofs"
```

**Expected:** `Active: active (running)`

```bash
ssh nodejs@manda.psmfc.org "ls /home/*data | wc -l"
```

**Expected:** Should show 20+ agency directories

```bash
ssh nodejs@manda.psmfc.org "sudo crontab -l | grep lscwtdirs"
```

**Expected:** `0 * * * * /usr/local/sbin/lscwtdirs > /dev/null 2>&1`

#### 8. Verify PM2 Service
```bash
ssh nodejs@manda.psmfc.org "sudo systemctl status pm2-nodejs"
```

**Expected:** `Active: active (running)`

### Application Details

#### Application Locations

| Application | Location | Port | User |
|-------------|----------|------|------|
| library | /var/www/html/library | 3000 | nodejs |
| kbfish | /var/www/html/kbfish | 3001 | nodejs |
| kbfish-dev | /var/www/html/kbfish-dev | 3002 | nodejs |
| rmis-api | /var/nodejs/rmis-api | 5001 | nodejs |
| kbfish-api | /var/nodejs/kbfish-api | 5005 | nodejs |
| kbfish-api-dev | /var/nodejs/kbfish-api-dev | 5006 | nodejs |
| streamnet-api | /var/nodejs/streamnet-api | 5003 | nodejs (not running) |

#### Environment Files

Applications with `.env` files:
- ✅ library - `/var/www/html/library/.env`
- ❌ kbfish - No .env (configuration in code)
- ❌ kbfish-dev - No .env (configuration in code)
- ❌ rmis-api - No .env (uses config.js)
- ✅ kbfish-api - `/var/nodejs/kbfish-api/.env`
- ✅ kbfish-api-dev - `/var/nodejs/kbfish-api-dev/.env`
- ❌ streamnet-api - No .env (uses config.js)

#### Critical: Auto-Mounted Home Directories

**Purpose:** Uploaded files from RMIS API are stored on Horus via NFS auto-mount

**Configuration Files:**
- `/etc/auto.master` - Defines `/home` as auto-mount point
- `/etc/auto.home` - Maps agency users to `horus:/usr/home/<user>`
- `/usr/local/sbin/lscwtdirs` - Script to keep directories mounted
- Cron: `0 * * * * /usr/local/sbin/lscwtdirs` - Runs hourly

**Agency Directories (24 total):**
adfgdata, cctdata, cdfodata, cdfw01data, cdfw02data, cdfwktdata, critfcdata, ctuirdata, idfgdata, nezpdata, nmfsdata, nmfsnwrdata, nwifcdata, odfwdata, qdnrdata, quildata, rmis, rmpcdata, stildata, tran, usfwsdata, wdfwdata, yakadata, rmisdata

**Verification:**
```bash
ssh nodejs@manda.psmfc.org "ls /home/*data/up/ | head -3"
```
Should list files in agency upload directories.

---

## DNS Update Procedure

### Preparation

1. **Notify stakeholders** of planned DNS change
2. **Note current DNS TTL values** for rollback timing
3. **Have console access** to both old and new servers
4. **Verify all applications** are running on new servers

### DNS Update Steps

#### For each domain:

1. **Log into DNS management system** (likely your registrar or internal DNS)

2. **Note current values:**
   ```
   Domain: <domain>
   Current IP: <old-server-ip>
   New IP: <new-server-ip>
   Current TTL: <value>
   ```

3. **Update A record:**
   - Change IP from old server to new server
   - Consider lowering TTL temporarily (e.g., 300 seconds)

4. **Verify DNS propagation:**
   ```bash
   # From your workstation
   nslookup <domain>

   # Or use dig
   dig <domain> +short
   ```

5. **Wait for TTL to expire** before testing (old TTL value in seconds)

### Update Order Recommendation

**✅ Completed (2026-02-26):**
- kbfish-api.psmfc.org (production)
- phish.rmis.org (production)
- phish.streamnet.org (production)

**Remaining - Manda Server:**
- dev.kbfishc.org (development)
- test.kbfishc.org (test)
- data.kbfishc.org (production)

**Remaining - Battra Server:**
- fishregs-dev.psmfc.org (development)
- hcaxdev.psmfc.org (development)
- sddtdev.psmfc.org (development)

### Batch Update Template

#### Manda Server (from phish.psmfc.org)

| Domain | New IP | New Server | Updated? | Verified? |
|--------|--------|------------|----------|-----------|
| kbfish-api.psmfc.org | 10.2.13.182 | manda | ✅ 2026-02-26 | ✅ |
| phish.rmis.org | 10.2.13.182 | manda | ✅ 2026-02-26 | ✅ |
| phish.streamnet.org | 10.2.13.182 | manda | ✅ 2026-02-26 | ✅ |
| data.kbfishc.org | 10.2.13.182 | manda | ☐ | ☐ |
| dev.kbfishc.org | 10.2.13.182 | manda | ☐ | ☐ |
| test.kbfishc.org | 10.2.13.182 | manda | ☐ | ☐ |

#### Battra Server

| Domain | New IP | New Server | Updated? | Verified? |
|--------|--------|------------|----------|-----------|
| fishregs-dev.psmfc.org | 10.2.13.180 | battra | ☐ | ☐ |
| hcaxdev.psmfc.org | 10.2.13.180 | battra | ☐ | ☐ |
| sddtdev.psmfc.org | 10.2.13.180 | battra | ☐ | ☐ |

---

## Post-Switchover Verification

### Immediate Verification (within 5 minutes)

For each domain after DNS update:

#### 1. DNS Resolution Check
```bash
# From your workstation
nslookup <domain>
```
**Expected:** Should resolve to new server IP

#### 2. HTTP/HTTPS Response
```bash
# From your workstation
curl -I https://<domain>
```
**Expected:** HTTP 200 or 301/302 redirect

#### 3. SSL Certificate Validity
```bash
# From your workstation
openssl s_client -connect <domain>:443 -servername <domain> < /dev/null 2>/dev/null | openssl x509 -noout -dates
```
**Expected:** Valid certificate with correct dates

#### 4. Application Functionality
Open in browser and test:
- Page loads correctly
- Login works (if applicable)
- Key features function
- No console errors

### Extended Monitoring (24-48 hours)

#### Monitor Server Logs
```bash
# Nginx access logs
ssh nodejs@manda.psmfc.org "tail -f /var/log/nginx/access.log"

# Nginx error logs
ssh nodejs@manda.psmfc.org "tail -f /var/log/nginx/error.log"

# PM2 logs
ssh nodejs@manda.psmfc.org "pm2 logs --lines 50"
```

#### Monitor Application Performance
```bash
# Check PM2 status
ssh nodejs@manda.psmfc.org "pm2 list"

# Check for application restarts
ssh nodejs@manda.psmfc.org "pm2 list" | grep -E "↺"
```

#### Monitor Resource Usage
```bash
# CPU and Memory
ssh nodejs@manda.psmfc.org "top -b -n 1 | head -20"

# Disk usage
ssh nodejs@manda.psmfc.org "df -h"
```

### Verification Checklist Template

```
Domain: _______________
Date: _______________
Time: _______________

☐ DNS resolves to new IP
☐ HTTP/HTTPS responds
☐ SSL certificate valid
☐ Homepage loads
☐ Login works (if applicable)
☐ Key features tested
☐ No errors in browser console
☐ No errors in server logs
☐ Application showing in PM2 list
☐ No excessive restarts in PM2

Notes:
_______________________________________
_______________________________________
```

---

## Rollback Procedure

If issues are discovered after DNS switchover:

### Immediate Rollback

1. **Access DNS management**
2. **Revert A record to old server IP**
3. **Wait for DNS propagation** (based on TTL)
4. **Verify old server is functioning**

### Rollback Checklist

```
☐ Old servers still running and accessible
☐ Old applications still running
☐ DNS reverted to old IP
☐ Verify DNS resolution shows old IP
☐ Test domain functionality on old server
☐ Notify stakeholders of rollback
☐ Document issues encountered
```

### Common Issues and Solutions

#### Issue: Application not responding
**Check:**
- PM2 status: `pm2 list`
- Application logs: `pm2 logs <app-name>`
- Port listening: `netstat -tlnp | grep <port>`

**Fix:**
- Restart app: `pm2 restart <app-name>`
- Check .env file exists and is correct
- Verify database connectivity

#### Issue: SSL certificate errors
**Check:**
- Certificate files exist: `ls /etc/ssl/certs/<cert>.crt`
- Nginx configuration: `sudo nginx -t`
- Certificate matches domain

**Fix:**
- Verify SSL certificate paths in Nginx config
- Reload Nginx: `sudo systemctl reload nginx`

#### Issue: 502 Bad Gateway
**Check:**
- Backend application running: `pm2 list`
- Port matches Nginx proxy_pass
- Application responding on localhost

**Fix:**
- Restart application: `pm2 restart <app-name>`
- Check application logs: `pm2 logs <app-name>`
- Verify Nginx proxy_pass port number

#### Issue: Files not uploading (RMIS)
**Check:**
- Auto-mount directories visible: `ls /home/*data`
- lscwtdirs cron running: `crontab -l`
- autofs service: `sudo systemctl status autofs`

**Fix:**
- Run lscwtdirs manually: `/usr/local/sbin/lscwtdirs`
- Restart autofs: `sudo systemctl restart autofs`
- Check network connectivity to Horus

---

## Quick Reference

### Server IPs
- **battra.psmfc.org:** 10.2.13.180
- **manda.psmfc.org:** 10.2.13.182
- **phish.psmfc.org:** (old server)

### SSH Access
```bash
# Battra
ssh nodejs@battra.psmfc.org

# Manda
ssh nodejs@manda.psmfc.org
```

### Key Commands

```bash
# Check all applications
pm2 list

# Restart an application
pm2 restart <app-name>

# Check Nginx
sudo sudo nginx -t
sudo systemctl status nginx
sudo sudo systemctl reload nginx

# Check ports
netstat -tlnp | grep LISTEN

# View logs
pm2 logs
tail -f /var/log/nginx/error.log

# Check auto-mount
ls /home/*data
sudo systemctl status autofs
```

### Emergency Contacts

- **Greg:** Application Administrator
- **Dan:** PSMFC Systems Administrator
- **Claude (Previous session logs):** Migration assistance documentation

---

## Document History

| Date | Change | Author |
|------|--------|--------|
| 2026-02-26 | Initial creation | Claude/Greg |
| 2026-02-26 | Marked 3 domains as switched: kbfish-api.psmfc.org, phish.rmis.org, phish.streamnet.org | Claude/Greg |

---

**End of DNS Switchover Checklist**
