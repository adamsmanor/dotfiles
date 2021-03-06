#!/usr/bin/env bash

source ./bin/utils.sh

toInstall=()
toInstallCask=()

function initXCode() {
    if [[ -d "$('xcode-select' -print-path 2>/dev/null)" ]]; then
        e_bold "Initializing XCode Command Line Tools"
        xcode-select --install 2>/dev/null
        # wait until XCode Command Line Tools are installed
        until xcode-select --print-path &> /dev/null; do
            sleep 5
        done
    fi
}

function promptToInstall() {
    test_result=$?
    name=$1; url=$2; useCask=$3
    shift 3
    app=("$@")
    [[ $test_result -eq 0 ]] && e_success "$name is already installed" || {
        e_warning "$name is not installed"
        install="h"
        while [ "$install" == "h" ]; do
            read -p "Do you want to install ${C_FORE_BLUE}$name${C_RESET}? [y/${C_BOLD}n${C_RESET}/h]: " install
            if [ "$install" == "y" ]; then
                if [ "$useCask" == "1" ]; then
                    toInstallCask+=( ${app[@]} )
                else
                    toinstall+=( ${app[@]} )
                fi
            elif [ "$install" == "h" ]; then
                open "$url"
            fi
        done
    }
}

function checkInstall() {
    app=$1; name=$2; url=$3
    type -P $app &> /dev/null
    promptToInstall "$name" "$url" "0" "$app"
}

function checkSubCommand() {
    app=$1; subcommand=$2; name=$3; url=$4
    command -v $subcommand &> /dev/null
    promptToInstall "$name" "$url" "0" "$app"
}

function checkCask() {
    cask=$1; name=$2; app=$3; url=$4
    test -d "/Applications/$app"
    promptToInstall "$name" "$url" "1" "$cask"
}

function checkLibraryCask() {
    cask=$1; name=$2; app=$3; url=$4
    test -d "${HOME}/Library/$app"
    promptToInstall "$name" "$url" "1" "$cask"
}

function checkJava() {
    name=$1; version=$2; url=$3
    cask=("oracle-jdk" "oracle-jdk-javadoc")
    /usr/libexec/java_home -v $version &> /dev/null
    promptToInstall "$name" "$url" "1" "${cask[@]}"
}

function checkNvm() {
    app=$1; name=$2; url=$3
    test -d "$HOME/.nvm"
    promptToInstall "$name" "$url" "0" "$app"
}

function checkFile() {
    app=$1; file=$2; name=$3; url=$4
	test -f "$file"
	promptToInstall "$name" "$url" "0" "$app"
}

function installFonts() {
    e_bold "Installing Fonts"
    mkdir -p "${HOME}/Library/Fonts"
    find ./fonts -iname "*.ttf" -exec bash -c '
        source ./bin/utils.sh
        file=`basename {}`
        test -f ${HOME}/Library/Fonts/$file || {
            cp -av {} ${HOME}/Library/Fonts && e_success "Installed $file" || e_error "Unable to install $file"
        } ' \;
}

e_header "Mac Application Installer"

if [[ $xcode -eq 1 ]]; then
    initXCode
fi
if [[ $fonts -eq 1 ]]; then
    installFonts
fi

if [[ $packages -eq 1 ]]; then

e_bold "Installing Programs"

# Command Line Tools
checkInstall brew "Homebrew" "https://brew.sh/"
checkInstall rvm "Ruby Version Manager (rvm)" "https://rvm.io/"

# Homebrew Bottles
checkSubCommand coreutils gecho "Core Utilities" "https://www.gnu.org/software/coreutils"
checkSubCommand moreutils sponge "MoreUtils" "https://joeyh.name/code/moreutils/"
checkSubCommand findutils gfind "FindUtils" "https://www.gnu.org/software/findutils/"
checkSubCommand gnu-sed gsed "GNU sed" "https://www.gnu.org/software/sed/"
checkSubCommand grep ggrep "grep" "https://www.gnu.org/software/grep/"
checkSubCommand openssh scp "OpenSSH" "https://www.openssh.com/"
checkSubCommand gnupg gpg "GNU Pretty Good Privacy" "https://gnupg.org/"
checkSubCommand imagemagick magick "ImageMagick" "https://www.imagemagick.org/"
checkNvm nvm "nvm" "https://github.com/nvm-sh/nvm"
checkInstall automake "AutoMake" "https://www.gnu.org/software/automake/"
checkInstall autoconf "AutoConf" "https://www.gnu.org/software/autoconf"
checkInstall git "Git" "https://git-scm.com/"
checkInstall wget "Wget" "https://www.gnu.org/software/wget/"
checkInstall node "Node.js" "https://nodejs.org/en/"
checkInstall mysql "MySQL" "https://www.mysql.com/"
checkInstall sqlite3 "SQLite" "https://www.sqlite.org/"
checkInstall magick "ImageMagick" "https://imagemagick.org/"
checkInstall cowsay "CowSay" "https://github.com/tnalpgge/rank-amateur-cowsay"
checkInstall tree "Tree" "http://mama.indstate.edu/users/ice/tree/"
checkInstall rsync "rsync" "https://rsync.samba.org/"
checkInstall kotlin "kotlin" "https://kotlinlang.org/"
checkInstall python3 "python3" "https://www.python.org/"
checkInstall jupyter "jupyter" "https://jupyter.org/"
checkFile bash-completion "/usr/local/etc/profile.d/bash_completion.sh" "Bash Completion" "https://salsa.debian.org/debian/bash-completion"

# Homebrew Casks
checkCask android-studio "Android Studio" "Android Studio.app" "https://developer.android.com/studio"
checkCask atom "Atom" "Atom.app" "https://atom.io/"
checkCask balenaetcher "balena Etcher" "balenaEtcher.app" "https://www.balena.io/etcher/"
checkCask coteditor "CotEditor" "CotEditor.app" "https://coteditor.com/"
checkCask cpuinfo "CPU Info" "cpuinfo.app" "https://github.com/yusukeshibata/cpuinfo/"
checkCask db-browser-for-sqlite "DB Browser for SQLite" "DB Browser for SQLite.app" "https://sqlitebrowser.org/"
checkCask diffmerge "DiffMerge" "DiffMerge.app" "https://sourcegear.com/diffmerge/"
checkCask docker "Docker" "Docker.app" "https://www.docker.com/products/docker-desktop"
checkCask dropbox "Dropbox" "Dropbox.app" "https://www.dropbox.com/"
checkCask firefox "Firefox" "Firefox.app" "https://www.mozilla.org/en-US/exp/firefox/"
checkCask gimp "Gimp" "GIMP-2.10.app" "https://www.gimp.org/"
checkCask google-chrome "Google Chrome" "Google Chrome.app" "https://www.google.com/chrome/"
checkCask fork "Git-Fork" "Fork.app" "https://git-fork.com/"
checkCask inkscape "Inkscape" "Inkscape.app" "https://inkscape.org/"
checkCask iterm2 "iTerm2" "iTerm.app" "https://www.iterm2.com/"
checkCask macdown "MacDown" "MacDown.app" "https://macdown.uranusjr.com/"
checkCask macvim "MacVim" "MacVim.app" "https://github.com/macvim-dev/macvim"
checkCask openinterminal-lite "OpenInTerminal Lite" "OpenInTerminal-Lite.app" "https://github.com/Ji4n1ng/OpenInTerminal"
checkCask openineditor-lite "OpenInEditor Lite" "OpenInEditor-Lite.app" "https://github.com/Ji4n1ng/OpenInTerminal"
checkCask postman "Postman" "Postman.app" "https://www.postman.com/"
checkCask powershell "PowerShell Core" "PowerShell.app" "https://microsoft.com/PowerShell"
checkCask projectlibre "Project Libre" "ProjectLibre.app" "https://www.projectlibre.com/"
checkCask pycharm-ce "PyCharm Community Edition" "PyCharm CE.app" "https://www.jetbrains.com/pycharm/"
checkCask scribus "Scribus" "Scribus.app" "https://www.scribus.net/"
checkCask the-unarchiver "The Unarchiver" "The Unarchiver.app" "https://theunarchiver.com/"
checkCask thunderbird "Mozilla Thunderbird" "Thunderbird.app" "https://www.thunderbird.net/en-US/"
checkCask visual-studio-code "Visual Studio Code" "Visual Studio Code.app" "https://code.visualstudio.com/"
checkCask vlc "VLC Media Player" "VLC.app" "https://www.videolan.org/vlc/"
checkCask zoomus "Zoom.us" "zoom.us.app" "https://www.zoom.us/"
checkLibraryCask qlcolorcode "QuickLook CodeFormatter plugin" "QuickLook/QLColorCode.qlgenerator" "https://github.com/anthonygelibert/QLColorCode"
checkLibraryCask qlmarkdown "QuickLook Markdown plugin" "QuickLook/QLMarkdown.qlgenerator" "https://github.com/toland/qlmarkdown"
checkLibraryCask qlprettypatch "QuickLook PrettyPatch plugin" "QuickLook/QLPrettyPatch.qlgenerator" "https://github.com/anthonygelibert/QLColorCode"
checkLibraryCask qlstephen "QuickLook Extensionless plugin" "QuickLook/QLStephen.qlgenerator" "https://github.com/whomwah/qlstephen"
checkLibraryCask quicklook-csv "QuickLook CSV plugin" "QuickLook/QuickLookCSV.qlgenerator" "https://github.com/p2/quicklook-csv"
checkLibraryCask quicklook-json "QuickLook JSON plugin" "QuickLook/QuickLookJSON.qlgenerator" "http://www.sagtau.com/quicklookjson.html"
checkLibraryCask webpquicklook "QuickLook WebP plugin" "QuickLook/WebpQuickLook.qlgenerator" "https://github.com/emin/WebPQuickLook"

checkJava "Oracle JDK" "1.8" "https://www.oracle.com/technetwork/java/javase/overview/index.html"

echo "Those software will be installed: ${toinstall[@]} ${toInstallCask[@]}";
read -p "Let's do it now? [y/${C_BOLD}n${C_RESET}]: " install
if [ "$install" != "y" ]; then
    e_bold "Install cancelled."
    exit 1
fi

# Install the Command Line Tools and the Homebrew Bottles
for i in "${toinstall[@]}"
do
    e_bold "Installing ${C_FORE_BLUE}$i"
    if [ "$i" == "brew" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        brew doctor
        brew update
        brew upgrade
    elif [ "$i" == "rvm" ]; then
        curl -sSL https://get.rvm.io | bash -s stable --ruby --rails
        gem install bundler -v '=1.17.3'
        rvm docs generate-ri
    elif [ "$i" == "nvm" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh)"
    else
        brew install $i
    fi
done

# Install the Homebrew Casks
for i in "${toInstallCask[@]}"
do
    e_bold "Installing ${C_FORE_BLUE}$i"
    brew cask install $i
done

# Add NPM Packages
# e_bold "Configuring ${C_FORE_BLUE}npm"
# npm install http-server

# Configure OpenInTerminal and OpenInEditor
if [ -d "/Applications/OpenInEditor-Lite.app" ]; then
    e_bold "Configuring ${C_FORE_BLUE}OpenInEditor Lite"
    if [ -d "/Applications/MacVim.app" ]; then
        defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier MacVim
    elif [ -d "/Applications/Visual Studio Code.app" ]; then
        defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier VSCode
    elif [ -d "/Applications/CotEditor.app" ]; then
        defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier CotEditor
    fi
fi
if [ -d "/Applications/OpenInTerminal-Lite.app" ]; then
    e_bold "Configuring ${C_FORE_BLUE}OpenInTerminal Lite"
    if [ -d "/Applications/iTerm.app" ]; then
        defaults write wang.jianing.app.OpenInTerminal-Lite OIT_TerminalBundleIdentifier iTerm
        defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool false
    else
        defaults write wang.jianing.app.OpenInTerminal-Lite OIT_TerminalBundleIdentifier Terminal
    fi
fi

fi # if [[ $packages ]]

if [[ $macdefaults -eq 1 ]]; then

# Configure Mac Appearance
e_bold "Configuring ${C_FORE_BLUE}Mac Appearance"
osascript -e 'tell application "System Preferences" to quit'
osascript << EOF
tell application "System Preferences"
    reveal anchor "Main" of pane id "com.apple.preference.general"
    activate
end tell
EOF

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable “natural” (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Show the ~/Library folder
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library &> /dev/null

# Finder: use list view in all windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show hidden files in Finder
defaults write com.apple.Finder AppleShowAllFiles -bool true
killall Finder

fi # if [[ $macdefaults ]]

if [[ $packages -eq 1 ]]; then
    if [ -d "/Applications/iTerm.app" ]; then
        e_bold "Configuring ${C_FORE_BLUE}iTerm2"
        /bin/bash -c "$(curl -fsSL https://iterm2.com/shell_integration/install_shell_integration.sh)"
        open one-dark.itermcolors
    fi

    # Open instruction pages for manual post-install work
    if [ -d "/Applications/OpenInTerminal-Lite.app" -o -d "/Applications/OpenInEditor-Lite.app" ]; then
        open "https://github.com/Ji4n1ng/OpenInTerminal/blob/master/Resources/README-Lite.md"
    fi
fi
