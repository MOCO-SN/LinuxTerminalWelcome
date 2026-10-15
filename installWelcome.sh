#!/bin/bash

# Define Colors
red='\e[0;31m'
green='\e[0;32m'
cyan='\e[0;36m'
lightgray='\e[0;37m'
purple='\e[1;35m'

# Function to safely inject the banner block
function injectBanner(){
cat <<EOT >> "${1}"

# Customised banner display by @sagarshah1729
if [ -f ~/.Banner.sh ] && [ -z "\$MY_MOTD_HAS_RUN" ]; then
    export MY_MOTD_HAS_RUN=1
    source ~/.Banner.sh
fi
EOT
}

# Function to remove the banner block from .rc files
function removeBanner(){
    local rcpath="${1}"
    if [ -f "$rcpath" ]; then
        if grep -q "Customised banner display by @sagarshah1729" "$rcpath"; then
            echo -e "${cyan}[i] Cleaning banner injection from $rcpath...${lightgray}"
            if [[ "$OS" == "mac" ]]; then
                sed -i '' '/# Customised banner display by @sagarshah1729/,/fi/d' "$rcpath"
            else
                sed -i '/# Customised banner display by @sagarshah1729/,/fi/d' "$rcpath"
            fi
            echo -e "${green}[✓] Removed injection from $rcpath.${lightgray}"
        fi
    fi
}

# Function to install dependencies
function run_install() {
    if [[ "${OS}" == "linux" ]]; then
       sudo apt-get install -y "${1}"
    elif [[ "${OS}" == "mac" ]]; then
       brew install "${1}"
    fi
}

# Detect the platform
case $(uname | tr '[:upper:]' '[:lower:]') in
  linux*)   OS=linux ;;
  darwin*)  OS=mac ;;
  *)        OS=unknown ;;
esac

# ==========================================
# UNINSTALL MODE
# ==========================================
if [[ "${1}" == "--uninstall" ]]; then
    echo -e "${purple}--- Welcome Banner Uninstaller ---\n${lightgray}"
    
    # 1. Delete the script payload from home directory
    if [ -f ~/.Banner.sh ]; then
        rm ~/.Banner.sh
        echo -e "${green}[✓] Removed ~/.Banner.sh script.${lightgray}"
    else
        echo -e "${cyan}[i] ~/.Banner.sh was not found.${lightgray}"
    fi

    # 2. Clean both potential shell profiles
    removeBanner "${HOME}/.bashrc"
    removeBanner "${HOME}/.zshrc"

    # 3. Prompt to clear dependencies
    echo ""
    read -p "Do you want to completely uninstall dependencies (curl, figlet, lolcat)? [y/N]: " choice
    choice=${choice:-n}

    if [[ "$choice" =~ ^[Yy]$ ]]; then
        if [[ "${OS}" == "linux" ]]; then
            echo -e "${cyan}Removing packages via apt...${lightgray}"
            sudo apt-get remove --purge -y curl figlet lolcat
            sudo apt-get autoremove -y
        elif [[ "${OS}" == "mac" ]]; then
            echo -e "${cyan}Removing packages via brew...${lightgray}"
            brew uninstall curl figlet lolcat
        else
            echo -e "${red}Unknown OS. Skipping package removal.${lightgray}"
        fi
        echo -e "${green}[✓] Dependency uninstallation complete.${lightgray}"
    else
        echo -e "${cyan}[i] Dependencies kept intact.${lightgray}"
    fi

    echo -e "\n${green}Uninstall complete! Please restart your terminal session.${lightgray}"
    exit 0
fi

# ==========================================
# INSTALL MODE (Default Behavior)
# ==========================================

# We check if sourced ONLY for the install block since it evaluates the shell interactively
if [ -z "$PS1" ] ; then
    echo -e "${red}This script must be sourced for installation. Use \"source installWelcome.sh\" instead."
    echo -e "To uninstall, run it directly: \"./installWelcome.sh --uninstall\"${lightgray}"
    exit 1
fi

# Check if Banner.sh exists in current working directory before starting
if [ ! -f "Banner.sh" ]; then
    echo -e "${red}FATAL ERROR: Source file 'Banner.sh' not found in this directory!${lightgray}"
    return 1 2>/dev/null || exit 1
fi

# Check required libraries
package_check=false
packages=("curl" "figlet" "lolcat")
for pkg in "${packages[@]}"; do
    if [[ "${OS}" == "linux" ]]; then
        is_pkg_installed=$(dpkg-query -W --showformat='${Status}\n' "${pkg}" 2>/dev/null | grep "install ok installed")
    else
        is_pkg_installed=$(brew list "${pkg}" &>/dev/null && echo "install ok installed" || echo "no")
    fi

    if [ "${is_pkg_installed}" != "install ok installed" ]; then
        echo -e "${red}\nDependency missing: ${pkg} not found. Attempting installation...${lightgray}"
        run_install "${pkg}"
    fi
    package_check=true
done

# Detect active interactive shell setup
rcpath=""
if [[ "${package_check}" == "true" ]]; then
   echo -e "\nAll required Packages are validated/installed!"
   
   if [ -n "$ZSH_VERSION" ]; then
      echo -e "\nDetermined default shell environment as ZSH."
      rcpath="${HOME}/.zshrc"
   elif [ -n "$BASH_VERSION" ]; then
      echo -e "\nDetermined default shell environment as Bash."
      rcpath="${HOME}/.bashrc"
   else
      read -p "Unable to determine the shell automatically, default to Bash configuration? [Y/N]: " answer
      answer=${answer:-Y}
      if [[ "$answer" =~ ^[Yy]$ ]]; then
          rcpath="${HOME}/.bashrc"
      fi
   fi

   # FIX: Replaced invalid '-not -z' operator syntax with the valid standard '! -z'
   if [ ! -z "${rcpath}" ]; then
      # Fix for your original double-execution issue: clean any old versions out first
      if grep -q "Customised banner display by @sagarshah1729" "$rcpath"; then
          if [[ "$OS" == "mac" ]]; then
              sed -i '' '/# Customised banner display by @sagarshah1729/,/fi/d' "$rcpath"
          else
              sed -i '/# Customised banner display by @sagarshah1729/,/fi/d' "$rcpath"
          fi
      fi

      echo -e "\nInjecting the Welcome Banner inside ${rcpath}...."
      cp Banner.sh ~/.Banner.sh
      injectBanner "${rcpath}"
      echo -e "${green}[✓] Installation complete! Re-open your terminal to see the changes.${lightgray}"
   fi
fi
