$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

# Windows Configuration
Update-ExecutionPolicy RemoteSigned
Set-WindowsExplorerOptions -EnableShowFileExtensions -EnableShowFullPathInTitleBar
Disable-UAC
Disable-InternetExplorerESC
Enable-RemoteDesktop

md C:\Projects

choco install powershell4

choco install IIS-WebServerRole -source windowsfeatures
choco install TelnetClient -source windowsFeatures
choco install IIS-HttpCompressionDynamic -source windowsfeatures
choco install IIS-ManagementScriptingTools -source windowsfeatures
choco install IIS-WindowsAuthentication -source windowsfeatures

choco install javaruntime
choco install golang

choco install GoogleChrome
choco install Firefox

choco install hipchat
choco install 7Zip
choco install NugetPackageExplorer
choco install console-devel
choco install greenshot
choco install fiddler4
choco install curl
choco install notepadplusplus.install
choco install gow
choco install regexpixie
choco install linqpad
choco install dotpeek
choco install winmerge
choco install windirstat
choco install filezilla
choco install visualstudiocode
choco install stylecop
    
# Without Git, we might as well go home.
choco install git.install
choco install poshgit
choco install git-credential-winstore -Version 1.2.0.0

choco install VisualStudio2013Professional -InstallArguments "WebTools"
choco install webpi
choco install resharper

# Fix SSH-Agent error by adding the bin directory to the `Path` environment variable
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Git\bin"


Install-ChocolateyPinnedTaskBarItem "$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe"
Install-ChocolateyPinnedTaskBarItem "$env:programfiles\console\console.exe"
Install-ChocolateyPinnedTaskBarItem "$env:programfiles\Notepad++\notepad++.exe"

Install-ChocolateyFileAssociation ".build" "$env:programfiles\Notepad++\notepad++.exe"
Install-ChocolateyFileAssociation ".config" "$env:programfiles\Notepad++\notepad++.exe"

Install-WindowsUpdate -AcceptEula
