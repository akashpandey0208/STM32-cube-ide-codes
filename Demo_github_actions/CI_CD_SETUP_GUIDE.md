# Complete CI/CD Setup Guide for STM32 GitHub Actions

This guide walks you through setting up a complete CI/CD pipeline that automatically builds and flashes your STM32F411 board whenever you push code to GitHub.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Set Up Git and GitHub Repository](#step-1-set-up-git-and-github-repository)
3. [Step 2: Install Self-Hosted GitHub Actions Runner](#step-2-install-self-hosted-github-actions-runner)
4. [Step 3: Install Required Tools on Runner Machine](#step-3-install-required-tools-on-runner-machine)
5. [Step 4: Configure ST-Link USB Access](#step-4-configure-st-link-usb-access)
6. [Step 5: Test the Workflow](#step-5-test-the-workflow)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- **STM32F411 Discovery/Nucleo Board** with ST-Link debugger
- **USB Cable** to connect board to your computer
- **Computer** (Windows/Linux/macOS) that will act as the self-hosted runner
- **GitHub Account** and repository access
- **Internet Connection**

---

## Step 1: Set Up Git and GitHub Repository

### 1.1 Initialize Git Repository (if not already done)

Open PowerShell in your project directory:

```powershell
cd D:\STM32CUBEIDE\Demo_github_actions
git init
```

### 1.2 Create `.gitignore` File

Create a `.gitignore` file to exclude build artifacts and IDE metadata:

```powershell
@"
# Build artifacts
Debug/
Release/
*.o
*.elf
*.bin
*.hex
*.map
*.list
*.d
*.su
*.cyclo

# IDE metadata (optional - adjust based on your needs)
.metadata/
.settings/
*.launch

# System files
.DS_Store
Thumbs.db
"@ | Out-File -FilePath .gitignore -Encoding UTF8
```

### 1.3 Create GitHub Repository

1. Go to [GitHub](https://github.com) and log in
2. Click the **+** icon → **New repository**
3. Name it: `STM32-cube-ide-codes` (or your preferred name)
4. Keep it **Public** or **Private** (your choice)
5. Do **NOT** initialize with README (we have files already)
6. Click **Create repository**

### 1.4 Push Your Code to GitHub

```powershell
# Add all files
git add .

# Commit
git commit -m "Initial commit: STM32F411 project with CI/CD workflow"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/akashpandey0208/STM32-cube-ide-codes.git

# Push to main branch
git branch -M main
git push -u origin main
```

---

## Step 2: Install Self-Hosted GitHub Actions Runner

A self-hosted runner is required because GitHub's cloud runners **cannot access your local USB devices** (STM32 board).

### 2.1 Navigate to Runner Settings

1. Go to your GitHub repository
2. Click **Settings** tab
3. In the left sidebar, click **Actions** → **Runners**
4. Click **New self-hosted runner**
5. Select your OS (Windows/Linux/macOS)

### 2.2 Install Runner (Windows)

Follow GitHub's instructions, or use these steps:

#### Create a folder for the runner:

```powershell
# Create runner directory
mkdir C:\actions-runner
cd C:\actions-runner
```

#### Download the runner (check GitHub page for latest version):

```powershell
# Download (version may vary - check GitHub page)
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-win-x64-2.311.0.zip -OutFile actions-runner-win-x64-2.311.0.zip

# Extract
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\actions-runner-win-x64-2.311.0.zip", "$PWD")
```

#### Configure the runner:

```powershell
# Run configuration (GitHub will provide the token)
.\config.cmd --url https://github.com/akashpandey0208/STM32-cube-ide-codes --token YOUR_TOKEN_HERE
```

**Configuration prompts:**
- Runner group: Press Enter (default)
- Runner name: `stm32-runner` (or your choice)
- Work folder: Press Enter (default: `_work`)
- Labels: Press Enter (default: includes `self-hosted`)

#### Start the runner:

```powershell
# Run interactively (for testing)
.\run.cmd

# OR install as Windows Service (recommended for automatic startup)
.\svc.sh install
.\svc.sh start
```

### 2.3 Install Runner (Linux/Ubuntu)

```bash
# Create runner directory
mkdir ~/actions-runner && cd ~/actions-runner

# Download (check GitHub for latest version)
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Extract
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Configure
./config.sh --url https://github.com/akashpandey0208/STM32-cube-ide-codes --token YOUR_TOKEN_HERE

# Start runner
./run.sh

# OR install as service
sudo ./svc.sh install
sudo ./svc.sh start
```

---

## Step 3: Install Required Tools on Runner Machine

### 3.1 Windows Installation

#### Install MSYS2 (provides make and Unix tools):

1. Download from: https://www.msys2.org/
2. Install to default location (`C:\msys64`)
3. Open **MSYS2 MINGW64** terminal
4. Update package database:

```bash
pacman -Syu
```

5. Install make:

```bash
pacman -S make
```

6. Add to Windows PATH:
   - Open **System Properties** → **Environment Variables**
   - Edit **Path** → Add `C:\msys64\usr\bin`

#### Install ARM GCC Toolchain:

1. Download from: https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads
2. Choose: **arm-none-eabi** for Windows (`.exe` installer)
3. Run installer
4. **Important:** Check "Add to PATH" during installation
5. Verify installation:

```powershell
arm-none-eabi-gcc --version
```

#### Install OpenOCD (Windows):

**Option A: Pre-built binaries (Easier)**

1. Download from: https://github.com/xpack-dev-tools/openocd-xpack/releases
2. Extract to `C:\openocd`
3. Add `C:\openocd\bin` to PATH

**Option B: Via MSYS2**

```bash
# In MSYS2 terminal
pacman -S mingw-w64-x86_64-openocd
```

4. Verify:

```powershell
openocd --version
```

#### Install ST-Link Drivers (Windows):

1. Download **ST-Link USB Driver** from: https://www.st.com/en/development-tools/stsw-link009.html
2. Extract and run installer
3. Connect your STM32 board
4. Verify in Device Manager: You should see "STMicroelectronics STLink dongle"

### 3.2 Linux Installation (Ubuntu/Debian)

```bash
# Update package list
sudo apt-get update

# Install build tools
sudo apt-get install -y build-essential make git

# Install ARM GCC toolchain
sudo apt-get install -y gcc-arm-none-eabi binutils-arm-none-eabi

# Install OpenOCD
sudo apt-get install -y openocd

# Verify installations
arm-none-eabi-gcc --version
make --version
openocd --version
```

---

## Step 4: Configure ST-Link USB Access

### 4.1 Linux: Add udev Rules

Create udev rules so OpenOCD can access ST-Link without root:

```bash
# Create udev rules file
sudo nano /etc/udev/rules.d/49-stlinkv2.rules
```

Add these lines:

```
# ST-Link V2
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="0666", GROUP="plugdev"

# ST-Link V2-1
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", GROUP="plugdev"

# ST-Link V3
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="0666", GROUP="plugdev"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="0666", GROUP="plugdev"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="0666", GROUP="plugdev"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="0666", GROUP="plugdev"
```

Reload udev rules:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Add your user to plugdev group:

```bash
sudo usermod -a -G plugdev $USER
# Log out and back in for changes to take effect
```

### 4.2 Test ST-Link Connection

**Linux:**

```bash
# Connect your board and run
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg
```

**Windows:**

```powershell
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg
```

You should see output like:

```
Info : stlink_usb_init_mode: connect under reset
Info : clock speed 2000 kHz
Info : STLINK V2J29S7 (API v2) VID:PID 0483:3748
...
Info : Listening on port 3333 for gdb connections
```

Press `Ctrl+C` to exit.

---

## Step 5: Test the Workflow

### 5.1 Make Sure Runner is Online

1. Go to your GitHub repo → **Settings** → **Actions** → **Runners**
2. Verify your runner shows **Idle** status (green)

### 5.2 Make a Code Change and Push

Edit your `main.c` to change the message:

```powershell
# Edit Core/Src/main.c in your editor
# Change line 103 from:
#   HAL_UART_Transmit(&huart2,(uint8_t*)"HELLO",5,HAL_MAX_DELAY);
# To:
#   HAL_UART_Transmit(&huart2,(uint8_t*)"HELLO WORLD",11,HAL_MAX_DELAY);
```

Commit and push:

```powershell
git add Core/Src/main.c
git commit -m "Update UART message to HELLO WORLD"
git push
```

### 5.3 Monitor the GitHub Actions Run

1. Go to your GitHub repo
2. Click **Actions** tab
3. You should see your workflow running
4. Click on the run to see live logs
5. The **build** job runs on GitHub's cloud (ubuntu-latest)
6. The **flash-self-hosted** job runs on your local runner and flashes the board

### 5.4 Verify on Hardware

1. Connect a USB-to-Serial adapter to your board's UART2 pins:
   - **PA2** (TX) → USB-Serial RX
   - **PA3** (RX) → USB-Serial TX
   - **GND** → GND

2. Open a serial terminal (PuTTY, Tera Term, or use VS Code extension):
   - **Baud:** 115200
   - **Data bits:** 8
   - **Stop bits:** 1
   - **Parity:** None

3. You should see "HELLO WORLD" printing every second!

---

## Troubleshooting

### Issue: Runner not connecting

**Solution:**
- Check firewall settings
- Verify token hasn't expired (regenerate if needed)
- Restart runner service

```powershell
# Windows
cd C:\actions-runner
.\svc.sh stop
.\svc.sh start

# Linux
sudo ./svc.sh restart
```

### Issue: OpenOCD can't find ST-Link

**Windows:**
- Install ST-Link drivers
- Try different USB port
- Check Device Manager for ST-Link device

**Linux:**
- Check udev rules are applied
- Run `lsusb` to verify ST-Link is detected:

```bash
lsusb | grep STMicro
```

- Try with sudo (temporary workaround):

```bash
sudo openocd -f interface/stlink.cfg -f target/stm32f4x.cfg
```

### Issue: Build fails - "arm-none-eabi-gcc not found"

**Solution:**
- Verify ARM toolchain is in PATH:

```powershell
# Windows
$env:Path -split ";" | Select-String arm

# Linux
echo $PATH | grep arm
```

- Restart terminal/runner after installing toolchain

### Issue: OpenOCD can't find config files

**Solution:**
Use full paths in the workflow:

```yaml
sudo openocd -f /usr/share/openocd/scripts/interface/stlink.cfg -f /usr/share/openocd/scripts/target/stm32f4x.cfg -c "program Demo_github_actions.elf verify reset exit"
```

### Issue: Flash job skipped

**Solution:**
The flash job only runs on self-hosted runners. Check:
1. Runner is online and has `self-hosted` label
2. Workflow condition is met: `if: contains(runner.labels, 'self-hosted')`

### Issue: Permission denied on Linux

**Solution:**
- Ensure your user is in `plugdev` group
- Log out and back in
- As temporary fix, run runner with sudo (not recommended for production)

---

## 🎉 Success Checklist

- ✅ GitHub repository created and code pushed
- ✅ Self-hosted runner installed and online
- ✅ ARM toolchain and OpenOCD installed
- ✅ ST-Link detected by OpenOCD
- ✅ GitHub Actions workflow runs successfully
- ✅ Board flashes automatically on push
- ✅ UART output verified on serial terminal

---

## Next Steps

1. **Add unit tests** to the workflow before flashing
2. **Set up notifications** (Slack, email) for build failures
3. **Create releases** automatically with versioned binaries
4. **Add multiple boards** to test on different hardware
5. **Implement staging environments** (dev/prod branches)

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [OpenOCD User Guide](https://openocd.org/doc/html/index.html)
- [STM32CubeIDE User Manual](https://www.st.com/resource/en/user_manual/dm00629856-stm32cubeide-user-guide-stmicroelectronics.pdf)
- [ARM GCC Toolchain](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain)

---

**Questions or issues?** Open an issue on the GitHub repository or check the Actions logs for detailed error messages.
