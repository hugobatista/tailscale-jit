# Tailscale JIT Access 🛡️

**Secure, temporary access to Tailscale resources using GitHub Actions.**

Grant just-in-time access to your Tailscale-protected infrastructure with GitHub's built-in security and approvals. No persistent permissions needed.

## 🚀 Quick Start

1. **Configure Tailscale ACLs** with posture-based access rules ([see example](#example-acl-configuration))
2. **Fork this GitHub repository** or copy the workflow files into your own repository
3. **Configure secrets** for Tailscale API access
4. **Trigger access requests** via GitHub Actions

### Example ACL Configuration

```json
{
  "postures": {
    "posture:jit_ssh_granted": ["custom:ssh_jit_granted == true"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["autogroup:member"],
      "srcPosture": ["posture:jit_ssh_granted"],
      "dst": ["tag:production-server"],
      "proto": "tcp",
      "dst": ["tag:production-server:22"]
    }
  ]
}
```

## ✨ Key Features

- **GitHub-Native Security**: Leverage GitHub's authentication, secrets, and approval workflows
- **Temporary Access**: Grant time-limited access with automatic expiration
- **Device-Level Control**: Target specific devices by hostname
- **Bulk Operations**: Expire access across all devices when needed
- **Mobile-Friendly**: Request access from GitHub Mobile app
- **Telegram Notifications**: (Optional) Real-time notifications for access grants and revocations
- **Customizable**: Base framework that can be extended with approvers and custom logic
- **Audit Trail**: Full logging through GitHub Actions and Tailscale API

## 🔄 How It Works

1. **Posture Definition**: Define Tailscale postures that check for custom attributes (e.g., `custom:ssh_jit_granted`)
2. **ACL Rules**: Use `srcPosture` in ACLs to restrict access to devices with the required attributes
3. **GitHub Actions**: Workflows use Tailscale API to set/remove custom attributes on devices
4. **JIT Access**: When attribute is present, posture condition is met, granting access

## 📊 Workflows

| Workflow | File | Description |
|----------|------|-------------|
| JIT SSH Access | [.github/workflows/jit-ssh.yml](.github/workflows/jit-ssh.yml) | Grants temporary SSH access to a specific device by setting the `custom:ssh_jit_granted` attribute with expiration. |
| Expire JIT SSH Access (Specific Device) | [.github/workflows/jit-ssh-expire-device.yml](.github/workflows/jit-ssh-expire-device.yml) | Revokes JIT access from a specific device by removing the `custom:ssh_jit_granted` attribute. |
| Expire All JIT SSH Access | [.github/workflows/jit-ssh-expire-all.yml](.github/workflows/jit-ssh-expire-all.yml) | Revokes JIT access from all devices in the tailnet by removing the `custom:ssh_jit_granted` attribute where present.

## 🛠️ Setup

### Prerequisites
- GitHub repository with Actions enabled
- Tailscale OAuth client configured

### Tailscale Configuration

1. **Create OAuth Client** in Tailscale admin console:
   - Go to Settings → OAuth clients
   - Create client with scopes: `devices:core:read`, `devices:posture_attributes`

2. **Define Postures** in your tailnet policy file:
   ```json
   "postures": {
     "posture:jit_ssh_granted": [
       "custom:ssh_jit_granted == true"
     ]
   }
   ```

3. **Configure ACLs** to use posture-based access:
   ```json
   "acls": [
     {
       "action": "accept",
       "src": ["autogroup:member"],
       "srcPosture": ["posture:jit_ssh_granted"],
       "dst": ["tag:secure-resource"],
       "proto": "tcp",
       "dst": ["tag:secure-resource:22"]
     }
   ]
   ```

### GitHub Configuration

1. **Add Repository Secrets**:
   - `TS_OAUTH_CLIENT_ID`: Your Tailscale OAuth client ID
   - `TS_OAUTH_CLIENT_SECRET`: Your Tailscale OAuth client secret
   - `TELEGRAM_BOT_TOKEN`: (Optional) Telegram bot token for notifications
   - `TELEGRAM_CHAT_ID`: (Optional) Telegram chat ID for notifications

2. **Set up Telegram Notifications** (optional - workflows will work without notifications):
   - Create a Telegram bot via [@BotFather](https://t.me/botfather)
   - Get your bot token from BotFather
   - Create a private Telegram channel or group for notifications
   - Add the bot as an administrator to the channel/group
   - Get the chat ID using methods like sending a message to the channel and checking `https://api.telegram.org/bot<YourBOTToken>/getUpdates`
   - Set `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` as repository secrets
   - If not configured, workflows will show a warning and continue without notifications

3. **Copy Workflows** to `.github/workflows/` in your repository

4. **Customize** workflows as needed (notification channels, approval requirements, etc.)

## 📋 Usage

### Request Access
- Go to **Actions** → **JIT SSH Access**
- Enter device hostname and duration
- Click **Run workflow**

### Revoke Access
- **Single Device**: Use "Expire JIT SSH Access (Specific Device)"
- **All Devices**: Use "Expire All JIT SSH Access"

## 🎨 Customization

- **Add Approvals**: Enable GitHub environment protection rules
- **Custom Attributes**: Extend for VPN, database, or admin access
- **Notifications**: Replace Telegram with Slack, Teams, or webhooks
- **Validation**: Add time restrictions or device health checks

## 🔒 Security

- OAuth with minimal scopes
- Automatic access expiration
- Complete audit trails
- GitHub secrets management

## 📚 Resources

- [Tailscale Device Posture](https://tailscale.com/docs/features/device-posture)
- [Tailscale ACL Syntax](https://tailscale.com/docs/reference/syntax/policy-file)
- [GitHub Actions Security](https://docs.github.com/en/actions/security-guides)

---

**MIT License**
