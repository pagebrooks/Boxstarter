
# Windows Configuration
Update-ExecutionPolicy RemoteSigned
Set-WindowsExplorerOptions -EnableShowFileExtensions -EnableShowFullPathInTitleBar
Disable-UAC
Disable-InternetExplorerESC
Enable-RemoteDesktop

md C:\Projects

choco install IIS-WebServerRole -source windowsfeatures -y
choco install TelnetClient -source windowsFeatures -y
choco install IIS-HttpCompressionDynamic -source windowsfeatures -y
choco install IIS-ManagementScriptingTools -source windowsfeatures -y
choco install IIS-WindowsAuthentication -source windowsfeatures -y

choco install javaruntime -y
choco install golang -y

choco install GoogleChrome -y
choco install Firefox -y

choco install hipchat -y
choco install 7Zip -y
choco install NugetPackageExplorer -y
choco install console-devel -y
choco install greenshot -y
choco install fiddler4 -y
choco install curl -y
choco install notepadplusplus.install -y
choco install gow -y
choco install regexpixie -y
choco install linqpad -y
choco install dotpeek -y
choco install winmerge -y
choco install windirstat -y
choco install filezilla -y
choco install visualstudiocode -y
choco install stylecop -y
    
# Without Git, we might as well go home.
choco install git.install -y
choco install poshgit -y
choco install git-credential-winstore -Version 1.2.0.0 -y

choco install VisualStudio2013Professional -InstallArguments "WebTools" -y
choco install webpi -y
choco install resharper -y

# Fix SSH-Agent error by adding the bin directory to the `Path` environment variable
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Git\bin"


Install-ChocolateyPinnedTaskBarItem "$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe"
Install-ChocolateyPinnedTaskBarItem "$env:programfiles\console\console.exe"
Install-ChocolateyPinnedTaskBarItem "$env:programfiles\Notepad++\notepad++.exe"

Install-ChocolateyFileAssociation ".build" "$env:programfiles\Notepad++\notepad++.exe"
Install-ChocolateyFileAssociation ".config" "$env:programfiles\Notepad++\notepad++.exe"

Install-WindowsUpdate -AcceptEula
