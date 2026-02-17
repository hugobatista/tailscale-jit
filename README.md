# Tailscale JIT Access 🛡️

**Secure, temporary access to Tailscale resources using GitHub Actions.**

Grant just-in-time access to your Tailscale-protected infrastructure with GitHub's built-in security and approvals. No persistent permissions needed.

## 🚀 Quick Start

1. **Configure Tailscale ACLs** with posture-based access rules ([see example](#example-acl-configuration))
2. **Fork this GitHub repository** or copy the workflow files into your own repository
3. **Configure secrets** for Tailscale API access
4. **Trigger access requests** via GitHub Actions

### Example Grants Configuration

```json
{
  // Define postures that check for custom attributes set by GitHub Actions workflows
  "postures": {
    "posture:jit_ssh_granted": ["custom:ssh_jit_granted == true"],
    "posture:jit_arr_granted": ["custom:arr_jit_granted == true"],
    "posture:jit_monitoring_granted": ["custom:monitoring_jit_granted == true"],
    "posture:jit_admin_granted": ["custom:admin_jit_granted == true"]
  },
  "grants": [
    {
      // example of using posture-based grant for SSH access - can be applied to any service by defining appropriate postures and grants
      "src": ["autogroup:member"],
      "srcPosture": ["posture:jit_ssh_granted"],
      "dst": ["tag:production-server"],
      "ip": ["tcp:22"]
    },
    {
      // example of using the same pattern for access to a web service, like the arr suite - can be applied to any service by defining appropriate postures and grants
      "src": ["autogroup:member"],
      "srcPosture": ["posture:jit_arr_granted"],
      "dst": ["tag:arr-server"],
      "ip": ["tcp:80", "tcp:443", "tcp:6767"]
    },
    {
      // example of using the same pattern for monitoring access - can be applied to any service by defining appropriate postures and grants
      "src": ["autogroup:member"],
      "srcPosture": ["posture:jit_monitoring_granted"],
      "dst": ["tag:monitoring-server"],
      "ip": ["tcp:9090"]
    },
    {
      // example of full access grant - use with caution!
      "src": ["autogroup:member"],
      "srcPosture": ["posture:jit_admin_granted"],
      "dst": ["tag:monitoring-server", "tag:production-server", "tag:arr-server"],
      "ip": ["*"]
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

1. **Posture Definition**: Define Tailscale postures that check for custom attributes (e.g., `custom:ssh_jit_granted`, `custom:arr_jit_granted`, `custom:monitoring_jit_granted`, `custom:admin_jit_granted`)
2. **Grants**: Use `srcPosture` in grants to restrict access to devices with the required attributes
3. **GitHub Actions**: Workflows use Tailscale API to set/remove custom attributes on devices
4. **JIT Access**: When attribute is present, posture condition is met, granting access
5. **Access Types**: Choose from ssh, arr, monitoring, admin, or all access types. Use "all" to revoke all JIT attributes simultaneously.

## 📊 Workflows

| Workflow | File | Description |
|----------|------|-------------|
| JIT Access | [.github/workflows/jit.yml](.github/workflows/jit.yml) | Grants temporary access (ssh, arr, monitoring, or admin) to a specific device by setting the corresponding custom attribute with expiration. |
| Expire JIT Access (Specific Device) | [.github/workflows/jit-expire-device.yml](.github/workflows/jit-expire-device.yml) | Revokes JIT access (ssh, arr, monitoring, admin, or all) from a specific device by removing the corresponding custom attribute(s). Use "all" to revoke all JIT attributes at once. |
| Expire All JIT Access | [.github/workflows/jit-expire-all.yml](.github/workflows/jit-expire-all.yml) | Revokes JIT access (ssh, arr, monitoring, admin, or all) from all devices in the tailnet by removing the corresponding custom attribute(s) where present. Use "all" to revoke all JIT attributes at once.

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
     "posture:jit_ssh_granted": ["custom:ssh_jit_granted == true"],
     "posture:jit_arr_granted": ["custom:arr_jit_granted == true"],
     "posture:jit_monitoring_granted": ["custom:monitoring_jit_granted == true"],
     "posture:jit_admin_granted": ["custom:admin_jit_granted == true"]
   }
   ```

3. **Configure Grants** to use posture-based access:
   ```json
   "grants": [
     {
       "src": ["autogroup:member"],
       "srcPosture": ["posture:jit_ssh_granted"],
       "dst": ["tag:secure-resource"],
       "ip": ["tcp:22"]
     },
     {
       "src": ["autogroup:member"],
       "srcPosture": ["posture:jit_arr_granted"],
       "dst": ["tag:arr-server"],
       "ip": ["tcp:80", "tcp:443", "tcp:6767"]
     },
     {
       "src": ["autogroup:member"],
       "srcPosture": ["posture:jit_monitoring_granted"],
       "dst": ["tag:monitoring-server"],
       "ip": ["tcp:9090"]
     },
     {
       "src": ["autogroup:member"],
       "srcPosture": ["posture:jit_admin_granted"],
       "dst": ["tag:monitoring-server", "tag:production-server", "tag:arr-server"],
       "ip": ["*"]
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
- Go to **Actions** → **JIT Access**
- Enter device hostname, duration, and access type (ssh, arr, monitoring, or admin)
- Click **Run workflow**

### Revoke Access
- **Single Device**: Use "Expire JIT Access (Specific Device)"
  - Specify device hostname and access type (ssh, arr, monitoring, admin, or all)
  - Use "all" to revoke all JIT attributes from the device at once
- **All Devices**: Use "Expire All JIT Access"
  - Specify access type (ssh, arr, monitoring, admin, or all)
  - Use "all" to revoke all JIT attributes from all devices at once

## 🧪 Running Workflows Locally

Test and debug workflows locally using [act](https://nektosact.com/), which simulates the GitHub Actions environment on your machine.

### Through the run-act.sh script (recommended - avoids the need to store secrets in plaintext files)

Run the run-act.sh script, which will:
- install act if not already installed
- store the secrets in the local secret store (using secret-tool)
- run the workflow using act, passing the stored secrets as input

note: don't forget to mark the script as executable using `chmod +x run-act.sh`.

when prompted for the secrets, you can paste the content of the .secrets file, which should be in the following format:
```
TS_OAUTH_CLIENT_ID=your_client_id
TS_OAUTH_CLIENT_SECRET=your_client_secret 
TELEGRAM_BOT_TOKEN=your_token (optional)
TELEGRAM_CHAT_ID=your_chat_id (optional)
```

Example:
```bash
./run-act.sh workflow_dispatch \
  --eventpath event.json \
  -j grant-access \
  -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
```

note: the secrets are stored in the local secret store using the projectname-secrets (or the provided --app <appname>)You can check the stored secrets using the command `secret-tool lookup app <appname>` and delete them using `secret-tool clear app <appname>`


### using act directly

- [Install act](https://nektosact.com/installation/index.html)
- Create a `.secrets` file in your repository root with your secrets:
  ```
  TS_OAUTH_CLIENT_ID=your_client_id
  TS_OAUTH_CLIENT_SECRET=your_client_secret
  TELEGRAM_BOT_TOKEN=your_token (optional)
  TELEGRAM_CHAT_ID=your_chat_id (optional)
  ```

Use the `event.json` file to simulate workflow inputs:

```bash
act workflow_dispatch \
  --eventpath event.json \
  --secret-file .secrets \
  -j grant-access \
  -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
```

**Parameters:**
- `workflow_dispatch`: Trigger type (matches the workflow's `on: workflow_dispatch`)
- `--eventpath event.json`: Path to file containing workflow inputs
- `--secret-file .secrets`: Path to file with repository secrets
- `-j grant-access`: Job ID to run (find in workflow YAML)
- `-P ubuntu-latest=...`: Container image for the runner


### Example .secrets file

```
TS_OAUTH_CLIENT_ID=your_client_id
TS_OAUTH_CLIENT_SECRET=your_client_secret
TELEGRAM_BOT_TOKEN=your_token (optional)
TELEGRAM_CHAT_ID=your_chat_id (optional)
```

### Example event.json

```json
{
  "inputs": {
    "source_hostname": "my-server",
    "duration_minutes": "30",
    "access_type": "ssh"
  }
}
```

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
