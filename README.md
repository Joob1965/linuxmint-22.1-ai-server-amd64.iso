# Linux Mint 22.1 AI Server ISO

Custom Linux Mint 22.1 installer image for an AI server.

- Default user: `joachim`
- Default password: `admin`
- Autologin: enabled

The ISO is distributed as a GitHub release asset because of its size.

## Download and reassemble

Download all three release assets:

- `linuxmint-22.1-ai-server-amd64.iso.part00`
- `linuxmint-22.1-ai-server-amd64.iso.part01`
- `linuxmint-22.1-ai-server-amd64.iso.part02`

Place all downloaded files in the same directory as `reassemble.ps1`, then run:

```powershell
.\reassemble.ps1
```
