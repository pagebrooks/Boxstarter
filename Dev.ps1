$vsIsoPath = 'c:\iso\en_visual_studio_professional_2012_x86_dvd_2262334.iso'


  function Mount-DiskImageReturnDriveLetter($imagePath) { 
    Write-Host "mounting iso at: $imagePath"
     $vcdmount = "$($Boxstarter.programFiles86)\Elaborate Bytes\VirtualCloneDrive\vcdmount.exe"
     Start-ChocolateyProcessAsAdmin -statements `"$imagePath`" -exeToRun `"$vcdmount`"
     write-host "waiting 10 seconds"
     start-sleep -s 10
     return "d"
  }

  function Dismount-DiskImage($imagePath) {
      try { 
          $vcdmount = "$($Boxstarter.programFiles86)\Elaborate Bytes\VirtualCloneDrive\vcdmount.exe"
	      Start-ChocolateyProcessAsAdmin -statements /u -exeToRun $vcdmount
          write-host "waiting 10 seconds"
          start-sleep -s 10
      }
      catch {
        write-host "unmount of $imagepath failed. continuing."
      }
  }
  
 function Reboot-IfRequired() { 
  if(Test-PendingReboot){ 
    Write-Host "Test-PendingReboot shows a reboot is required. Rebooting now"
    Invoke-Reboot
  }
  else {
    Write-Host "No reboot is required. installation continuing"
  }
}


function Install-VisualStudio2012([string]$vsinstaller) { 
    $vsadminFile = "$env:temp\admindeployment.xml"
    $client = New-Object System.Net.WebClient;
    $client.DownloadFile("https://raw.github.com/pagebrooks/Boxstarter/master/VS2012-AdminDeployment.xml", $vsadminFile);
    
    $devenvPath = "$($Boxstarter.programFiles86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"
    if((Test-Path $devenvPath) -eq $false) {
      Write-Host "Installing Visual Studio 2012 as it is not already on path $devenvPath"
      
      $vsargs = "/Passive /NoRestart /AdminFile $vsadminFile /Log $env:temp\vs.log"
      Start-ChocolateyProcessAsAdmin -statements $vsargs -exeToRun $vsinstaller
      Reboot-IfRequired
    }
    else { 
      Write-Host "VS2012 already installed as devenv.exe found on path $devenvPath"
    }

    if((Get-Item "$($Boxstarter.programFiles86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe").VersionInfo.ProductVersion -lt "11.0.60115.1") {
      Install-ChocolateyPackage 'vs update 4' 'exe' '/passive /norestart' 'http://download.microsoft.com/download/D/4/8/D48D1AC2-A297-4C9E-A9D0-A218E6609F06/VSU4/VS2012.4.exe'
      Reboot-IfRequired
    }
}

try {
    
# Windows Configuration
Update-ExecutionPolicy RemoteSigned
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions -EnableShowFullPathInTitleBar
Disable-MicrosoftUpdate
Disable-UAC
Disable-InternetExplorerESC
Enable-RemoteDesktop

if(!(Test-Path -Path "$env:SystemDrive\Projects")){
    md C:\Projects
}

#choco install TelnetClient -source windowsFeatures -y
#choco install IIS-WebServerRole -source windowsfeatures -y
#choco install IIS-HttpCompressionDynamic -source windowsfeatures -y
#choco install IIS-ManagementScriptingTools -source windowsfeatures -y
#choco install IIS-WindowsAuthentication -source windowsfeatures -y

choco install VirtualCloneDrive -y

# Visual Studio Install

try {
      $drive = Mount-DiskImageReturnDriveLetter $vsIsoPath
      Install-VisualStudio2012 "${drive}:\vs_professional.exe"
}
finally {
    Dismount-DiskImage $iso -ErrorAction SilentlyContinue
}

#choco install imdisk -y
#choco install psget -y
#choco install hipchat -y
#choco install 7Zip -y
#choco install NugetPackageExplorer -y
#choco install conemu -y
#choco install greenshot -y
#choco install fiddler4 -y
#choco install curl -y
choco install notepadplusplus.install -y
#choco install gow -y
#choco install regexpixie -y
#choco install linqpad -y
#choco install dotpeek -y
#choco install winmerge -y
#choco install windirstat -y
#choco install filezilla -y
#choco install paint.net -y
#choco install adobereader -y

#choco install git.install -y
#choco install poshgit -y
#choco install git-credential-winstore -Version 1.2.0.0 -y

#choco install VisualStudio2012Professional -InstallArguments "WebTools" -y
#choco install webpi -y
#choco install resharper -y

#choco install javaruntime -y
#choco install golang -y

# Fix SSH-Agent error by adding the bin directory to the `Path` environment variable
#$env:PSModulePath = $env:PSModulePath + ";${Env:ProgramFiles(x86)}\Git\bin"


#Install-ChocolateyPinnedTaskBarItem "$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe"  
#Install-ChocolateyPinnedTaskBarItem "${Env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
#Install-ChocolateyFileAssociation ".build" "${Env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
#Install-ChocolateyFileAssociation ".config" "${Env:ProgramFiles(x86)}\Notepad++\notepad++.exe"

#REG ADD "HKCU\Software\Microsoft\Internet Explorer\Main" /V "Start Page" /D "http://www.google.com/" /F

#choco install Firefox -y
#choco install GoogleChrome -y
#install-module -ModuleUrl https://github.com/pagebrooks/BoxStarter/raw/master/mount.iso.psm1

#Enable-MicrosoftUpdate
#Install-WindowsUpdate -AcceptEula

} catch {
  Write-ChocolateyFailure 'Dev-Boxstarter' $($_.Exception.Message)
  throw
}
