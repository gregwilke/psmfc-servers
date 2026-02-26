# Configuration Backups

This folder contains backups of important server configuration files.

## Purpose

Store copies of critical configuration files for:
- Reference during troubleshooting
- Comparison between servers
- Quick restoration if needed
- Documentation of working configurations
- Version tracking

## Current Contents

(Empty - configurations will be backed up as needed)

## Organization

Organize by server and service:

```
configs/
  battra/
    nginx/
      fishregs.psmfc.org.conf
      hcax.psmfc.org.conf
      sddt.psmfc.org.conf
    pm2/
      ecosystem.config.js
  manda/
    nginx/
      data.kbfishc.org.conf
      dev.kbfishc.org.conf
      kbfish-api.psmfc.org.conf
      phish.rmis.org.conf
      phish.streamnet.org.conf
      test.kbfishc.org.conf
    autofs/
      auto.home
      auto.master
```

## Backup Commands

### Nginx Configurations
```bash
# Battra
scp nodejs@battra.psmfc.org:/etc/nginx/sites-available/*.conf configs/battra/nginx/

# Manda
scp root@manda.psmfc.org:/etc/nginx/sites-available/*.conf configs/manda/nginx/
```

### Auto-Mount Configurations (Manda)
```bash
scp root@manda.psmfc.org:/etc/auto.master configs/manda/autofs/
scp root@manda.psmfc.org:/etc/auto.home configs/manda/autofs/
```

### PM2 Configurations
```bash
# If ecosystem.config.js exists
scp nodejs@battra.psmfc.org:/var/www/html/*/ecosystem.config.js configs/battra/pm2/
```

## Best Practices

1. **Include timestamps** in filenames or commit messages
2. **Don't store sensitive data** (passwords, private keys)
3. **Document why** configuration was saved (e.g., "Working config before migration")
4. **Compare configs** between servers to ensure consistency
5. **Update backups** after significant changes

## Naming Convention

Include date for reference:
- `nginx-site.conf.2026-02-26`
- Or use git commits for versioning
