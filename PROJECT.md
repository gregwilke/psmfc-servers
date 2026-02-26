# PSMFC Servers Project

## Overview

This project contains documentation, scripts, and configuration backups for managing PSMFC Linux servers, specifically the Ubuntu 24.04 servers that replaced older Ubuntu 16.04/18.04 systems.

## Servers Managed

- **battra.psmfc.org** (10.2.13.180) - Development applications
- **manda.psmfc.org** (10.2.13.182) - Production applications
- **phish.psmfc.org** - Old server (reference only, being retired)

## Project Structure

```
psmfc-servers/
├── README.md                          # Main index and quick reference
├── PROJECT.md                         # This file - project overview
├── ssh-access-configuration.md        # SSH keys and access setup
├── dns-switchover-checklist.md        # DNS migration guide
├── manda-auto-mount-configuration.md  # Auto-mount setup for CWT agencies
├── .gitignore                         # Protect sensitive files
├── docs/                              # Detailed documentation
├── scripts/                           # Helper scripts
└── configs/                           # Configuration backups
```

## Primary Documentation Files

### [README.md](README.md)
Main index with:
- Links to all documentation
- Server overview and status
- Quick start for Claude sessions
- Common tasks
- Troubleshooting

### [ssh-access-configuration.md](ssh-access-configuration.md) 🔐
**⚠️ SENSITIVE - Contains private SSH key**
- SSH key pair for Claude Code access
- Server access details
- Setup instructions
- Verification commands

### [dns-switchover-checklist.md](dns-switchover-checklist.md)
- Complete DNS migration checklist
- Pre/post-switchover verification
- Rollback procedures
- Troubleshooting guide

### [manda-auto-mount-configuration.md](manda-auto-mount-configuration.md)
- NFS auto-mount setup
- CWT agency file storage
- lscwtdirs script and cron
- How files go to Horus

## Git Usage

This project can be tracked with git for version control:

```bash
# Initialize (if not already done)
cd psmfc-servers
git init

# Add all files (note: .gitignore protects SSH keys)
git add .

# Initial commit
git commit -m "Initial commit: PSMFC servers documentation"

# Create remote (if desired)
# git remote add origin <your-repo-url>
# git push -u origin main
```

**⚠️ IMPORTANT:** Never commit `ssh-access-configuration.md` to a public repository. It is included in `.gitignore` for protection.

## For Claude Code Sessions

At the start of any session working with PSMFC servers:

1. Read [README.md](README.md) for context
2. Follow setup in [ssh-access-configuration.md](ssh-access-configuration.md)
3. Verify server access
4. Reference other docs as needed

## Workflow

### Adding Documentation
1. Create markdown file in appropriate location
2. Add entry to README.md index
3. Commit changes with descriptive message

### Adding Scripts
1. Create script in `scripts/` folder
2. Document purpose and usage in script header
3. Make executable: `chmod +x script-name.sh`
4. Update `scripts/README.md` if needed
5. Test before using in production

### Backing Up Configurations
1. Copy config files to `configs/` with appropriate folder structure
2. Include date or use git commits for versioning
3. Document why backup was created
4. Never commit sensitive data (passwords, keys)

## Security Considerations

### Sensitive Files
- `ssh-access-configuration.md` - Contains private SSH key
- Any files with passwords or credentials
- SSL private keys (don't store here)

### Protection Measures
- `.gitignore` prevents accidental commits
- Keep this repository private if using git
- Review files before committing
- Don't share SSH keys publicly

## Maintenance

### Regular Tasks
- Update documentation as servers change
- Back up configs after significant changes
- Review and update scripts
- Clean up outdated information

### Version Control
- Use git commits for tracking changes
- Write descriptive commit messages
- Tag important milestones (e.g., "v1.0-dns-switchover-complete")

## Related Systems

### File Storage
- **Horus** (horus.psmfc.org) - NFS file storage for CWT agencies
- Auto-mounted via `/home` on manda

### Databases
- **saira.psmfc.org** - PostgreSQL for RMIS
- **SQL2016\Streamnet** - SQL Server for other applications

### Other Servers
- Multiple agency-specific servers on PSMFC network

## Contact

- **Greg** - Application Administrator
- **Dan** - PSMFC Systems Administrator

## Project Status

- **Created:** 2026-02-26
- **Current Phase:** Pre-DNS switchover
- **Next Milestone:** DNS migration to new servers

## Future Enhancements

Potential additions:
- Automated health check scripts
- Deployment automation
- Monitoring integration
- Backup automation
- SSL certificate renewal reminders

---

**Last Updated:** 2026-02-26
