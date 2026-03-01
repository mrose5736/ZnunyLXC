# Znuny LXC for Proxmox VE

This repository provides a Proxmox VE Helper-Script for deploying [Znuny](https://www.znuny.org/), a fully featured open-source web-based ticketing system (a fork of OTRS).

## 🚀 Installation

To deploy the Znuny LXC container, open your Proxmox VE web GUI, navigate to your node's **Shell**, and run the following command to start the interactive installation:

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/mrose5736/ZnunyLXC/main/ct/znuny.sh)"
```

### Default Settings
- **OS**: Debian 12
- **RAM**: 4096 MB
- **Disk**: 20 GB
- **CPU**: 2 Cores

### 🔑 Access & Credentials

Once the installation is complete, the script will output the IP address of your new container. You can access the Znuny web interface at:

- **URL**: `http://<IP>/znuny/index.pl`
- **Username**: `root@localhost`
- **Password**: `root`

*Note: Please change the default password immediately after your first login.*

## 🛠️ Update Procedure

Znuny requires database migrations and specific steps during updates, so it cannot be safely updated via a one-click GUI script. Please follow the official [Znuny Update Documentation](https://doc.znuny.org/znuny_administrator_manual/installation_and_update/update.html) to perform updates via the command line inside the container.

## 🤝 Contributing

This script follows the structure of the [Proxmox VE Helper-Scripts](https://community-scripts.github.io/ProxmoxVE/). Contributions, issues, and pull requests are welcome!
