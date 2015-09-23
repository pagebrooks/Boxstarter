$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

Install-WindowsUpdate -AcceptEula
Update-ExecutionPolicy RemoteSigned
Set-WindowsExplorerOptions -EnableShowFileExtensions -EnableShowFullPathInTitleBar
Disable-InternetExplorerESC
Enable-RemoteDesktop

choco install powershell4

cinst IIS-WebServerRole -y -source windowsfeatures
cinst TelnetClient -y -source windowsFeatures
cinst IIS-HttpCompressionDynamic -y -source windowsfeatures
cinst IIS-ManagementScriptingTools -y -source windowsfeatures
cinst IIS-WindowsAuthentication -y -source windowsfeatures

choco install javaruntime
choco install golang

cinst GoogleChrome -y
cinst Firefox -y

cinst hipchat -y
cinst 7Zip -y
cinst NugetPackageExplorer -y
cinst console-devel -y
cinst greenshot -y
choco install paint.net
cinst fiddler4 -y
choco install curl
cinst notepadplusplus.install -y
choco install gow
cinst regexpixie -y
cinst linqpad -y
cinst dotpeek -y
cinst winmerge -y
cinst windirstat -y
cinst filezilla -y
choco install visualstudiocode
    
# Without Git, we might as well go home.
choco install git.install
cinst poshgit -y
cinst git-credential-winstore -y -Version 1.2.0.0

choco install VisualStudio2013Professional -InstallArguments "WebTools"
choco install webpi
cinst resharper -y

# Fix SSH-Agent error by adding the bin directory to the `Path` environment variable
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Git\bin"


Install-ChocolateyPinnedTaskBarItem "$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe"
Install-ChocolateyPinnedTaskBarItem "$env:programfiles\console\console.exe"
Install-ChocolateyPinnedTaskBarItem "$env:programfiles\Notepad++\notepad++.exe"
