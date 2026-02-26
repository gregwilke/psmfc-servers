# Manda Auto-Mount Configuration for CWT Agency Directories

**Date:** 2026-02-26
**Server:** manda.psmfc.org
**Purpose:** Keep NFS auto-mounted agency directories persistently visible

## Background

The `/home` directory on manda.psmfc.org is configured with autofs to auto-mount directories from Horus (horus.psmfc.org). These directories store uploaded files from various agencies through the RMIS API and other applications.

### The Problem

Auto-mounted directories use "lazy loading" - they only appear when first accessed. Without periodic access:
- Directories auto-unmount after a timeout
- `ls /home` only shows recently accessed directories
- Applications may fail to find expected directories

### The Solution

A script that periodically accesses all CWT agency directories to keep them mounted and visible.

## Configuration Files

### 1. Auto-Mount Configuration

**File:** `/etc/auto.master`
```
/home       /etc/auto.home sec=sys
```

**File:** `/etc/auto.home` (relevant excerpt)
```
rmis -rw	horus:/usr/home/&
rmpcdata -rw	horus:/usr/home/&
adfgdata -rw    horus:/usr/home/&
cctdata -rw     horus:/usr/home/&
cdfodata -rw    horus:/usr/home/&
cdfw01data -rw  horus:/usr/home/&
cdfw02data -rw  horus:/usr/home/&
cdfwktdata -rw  horus:/usr/home/&
critfcdata -rw  horus:/usr/home/&
ctuirdata -rw   horus:/usr/home/&
idfgdata -rw    horus:/usr/home/&
nezpdata -rw    horus:/usr/home/&
nmfsdata -rw    horus:/usr/home/&
nmfsnwrdata -rw horus:/usr/home/&
nwifcdata -rw   horus:/usr/home/&
odfwdata -rw    horus:/usr/home/&
qdnrdata -rw    horus:/usr/home/&
quildata -rw    horus:/usr/home/&
rmisdata -rw    horus:/usr/home/&
rmpctest -rw	horus:/usr/home/&
stildata -rw    horus:/usr/home/&
tran -rw	horus:/usr/home/&
usfwsdata -rw   horus:/usr/home/&
wdfwdata -rw    horus:/usr/home/&
yakadata -rw    horus:/usr/home/&
```

All agency directories map to `horus:/usr/home/<username>`, meaning files are actually stored on Horus.

### 2. Directory Persistence Script

**File:** `/usr/local/sbin/lscwtdirs`

```bash
#!/bin/bash

# *****************************************************************************
# Name:          lscwtdirs
# Description:   Keeps auto-mounted CWT agency directories visible by
#                periodically accessing them. Prevents auto-unmounting.
# *****************************************************************************

cd /home
ls -d1 adfgdata;
ls -d1 cctdata;
ls -d1 cdfodata;
ls -d1 cdfw01data;
ls -d1 cdfw02data;
ls -d1 cdfwktdata;
ls -d1 critfcdata;
ls -d1 ctuirdata;
ls -d1 idfgdata;
ls -d1 nezpdata;
ls -d1 nmfsdata;
ls -d1 nmfsnwrdata;
ls -d1 nwifcdata;
ls -d1 odfwdata;
ls -d1 qdnrdata;
ls -d1 quildata;
ls -d1 rmis;
ls -d1 rmpcdata;
ls -d1 stildata;
ls -d1 tran;
ls -d1 usfwsdata;
ls -d1 wdfwdata;
ls -d1 yakadata;
```

**Permissions:**
```bash
chmod +x /usr/local/sbin/lscwtdirs
```

### 3. Cron Job

**Configured in:** root crontab (`sudo crontab -e`)

```cron
0 * * * * /usr/local/sbin/lscwtdirs > /dev/null 2>&1
```

**Schedule:** Runs every hour (at the top of each hour)

**View current crontab:**
```bash
sudo crontab -l
```

## How It Works

1. **autofs service** monitors `/home` directory
2. When a directory like `/home/adfgdata` is accessed, autofs:
   - Mounts `horus:/usr/home/adfgdata` to `/home/adfgdata`
   - Makes the directory visible in `ls /home`
3. **lscwtdirs script** accesses each directory hourly
4. Regular access prevents auto-unmounting
5. Directories stay persistently visible

## Verification

### Check Auto-Mount Service Status
```bash
systemctl status autofs
```

Should show: `Active: active (running)`

### Test the Script Manually
```bash
/usr/local/sbin/lscwtdirs
```

Should list all agency directory names without errors.

### Verify Directories are Visible
```bash
ls /home
```

Should show all 23+ agency directories.

### Verify Access to Upload Directories
```bash
ls /home/*data/up/
```

Should show contents of each agency's upload directory.

### Check Files are on Horus
Compare the same directory on manda vs directly on horus - they should be identical:

```bash
# On manda
ls /home/rmisdata/up/

# On horus (if you have access)
ls /usr/home/rmisdata/up/
```

Same files should appear in both locations.

## Troubleshooting

### Directories Not Appearing
1. Check autofs service: `systemctl status autofs`
2. Restart autofs: `sudo systemctl restart autofs`
3. Run lscwtdirs manually: `/usr/local/sbin/lscwtdirs`

### Cron Not Running
1. Check crontab: `sudo crontab -l`
2. Check cron service: `systemctl status cron`
3. Check cron logs: `grep lscwtdirs /var/log/syslog`

### Files Not Showing Up
1. Verify network connectivity to Horus: `ping horus.psmfc.org`
2. Check NFS mounts: `mount | grep horus`
3. Check auto.home configuration: `cat /etc/auto.home | grep <username>`

## Related Applications

Applications that rely on these auto-mounted directories:

- **RMIS API** (`/var/nodejs/rmis-api`) - Port 5001
  - Uploads files to `/home/<agency>data/up/`
  - Configuration: `HOME_DIR: "/home/"` in config.js

## Same Configuration on Other Servers

This same setup exists on:
- **phish.psmfc.org** - Old server being replaced by manda
- **saira.psmfc.org** - Database server
- **horus.psmfc.org** - File storage server (the actual storage location)

## Migration Notes

Copied from phish.psmfc.org on 2026-02-26 as part of server migration. Configuration must be identical to ensure uploaded files go to the same Horus storage location regardless of which server receives the upload.

## Contact

For issues or questions, contact:
- Dan (PSMFC Systems Administrator)
- Greg (Application Administrator)
