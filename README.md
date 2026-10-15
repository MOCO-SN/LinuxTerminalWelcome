LinuxTerminalWelcome
=========

<img src="https://raw.githubusercontent.com/sagarshah1729/LinuxTerminalWelcome/master/BeautifulLogin.png">

Features 
--------
 * Minimal and Clean UI
 * All important parameters like OS Info, Processor Info, Memory Usage & Weather Info present
 * Unified installation and uninstallation toggle script
 * **Fixed Duplicate Startup Bug:** The banner will now only execute once per terminal session, even if your configuration file is loaded multiple times.
 * Automatic detection of OS and Shell for installation
 * For manual installation, check the Banner.sh file and manually import in your distros.

Getting Started 
--------------- 
To get started with the Setup, you'll need to get 
familiar with [Git and Repo](https://source.android.com/setup/develop.html).

Initialize the Repository 
-------------------------

    git clone https://github.com/sagarshah1729/LinuxTerminalWelcome
    cd LinuxTerminalWelcome

This will clone the repository in your system!

Configuration & Customization
-----------------------------
Before injecting the banner, you can personalize the configuration inside the `Banner.sh` file:

1. **Weather Location:** Change the `city` variable to your current location (Default is set to `Bengaluru`).
2. **Custom Greeting Text:** Search for `$(whoami)` near the bottom of the script and replace it with **"YOUR NAME"** to personalize your greeting message.

Managing the Welcome Banner 
---------------------------

### To Install:
Run the unified installation script by sourcing it. This automatically detects your OS and interactive shell profile to append the configuration safely:

     source installWelcome.sh

### To Uninstall:
If you want to remove the welcome banner and restore your default shell environment, execute the same script with the `--uninstall` toggle flag (no sourcing required):

     chmod +x installWelcome.sh
     ./installWelcome.sh --uninstall

Contact Info
------------
Find me in [Telegram](https://t.me/sagarshah1729) or Email me at sagarshah2326@gmail.com.

