
# Windows Configuration
Update-ExecutionPolicy RemoteSigned
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions -EnableShowFullPathInTitleBar
Disable-UAC
Disable-InternetExplorerESC
Enable-RemoteDesktop

if(!(Test-Path -Path "$env:SystemDrive\Projects")){
    md C:\Projects
}

choco install TelnetClient -source windowsFeatures -y
choco install IIS-WebServerRole -source windowsfeatures -y
choco install IIS-HttpCompressionDynamic -source windowsfeatures -y
choco install IIS-ManagementScriptingTools -source windowsfeatures -y
choco install IIS-WindowsAuthentication -source windowsfeatures -y

choco install imdisk -y
choco install psget -y
choco install hipchat -y
choco install 7Zip -y
choco install NugetPackageExplorer -y
choco install conemu -y
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
choco install paint.net -y

choco install git.install -y
choco install poshgit -y
choco install git-credential-winstore -Version 1.2.0.0 -y

#choco install VisualStudio2012Professional -InstallArguments "WebTools" -y
#choco install webpi -y
#choco install resharper -y

choco install javaruntime -y
choco install golang -y

choco install GoogleChrome -y
choco install Firefox -y

# Fix SSH-Agent error by adding the bin directory to the `Path` environment variable
$env:PSModulePath = $env:PSModulePath + ";$env:ProgramFiles(x86)\Git\bin"


Install-ChocolateyPinnedTaskBarItem "$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe"
Install-ChocolateyPinnedTaskBarItem "$env:ProgramFiles\console\console.exe"
Install-ChocolateyPinnedTaskBarItem "$env:ProgramFiles(x86)\Notepad++\notepad++.exe"
C:\Program Files (x86)\Notepad++
Install-ChocolateyFileAssociation ".build" "$env:ProgramFiles(x86)\Notepad++\notepad++.exe"
Install-ChocolateyFileAssociation ".config" "$env:ProgramFiles(x86)\Notepad++\notepad++.exe"

Install-WindowsUpdate -AcceptEula


#install-module -ModuleUrl https://github.com/pagebrooks/BoxStarter/raw/master/mount.iso.psm1
