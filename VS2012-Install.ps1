  $vsIsoPath = 'z:\dev\SW_DVD5_Visual_Studio_Pro_2012_English_Core_MLF_X18-35900.iso'

  function Mount-DiskImageReturnDriveLetter($imagePath) { 
    Write-Host "mounting iso at: $imagePath"
     $vcdmount = "$($Boxstarter.programFiles86)\Elaborate Bytes\VirtualCloneDrive\vcdmount.exe"
     Start-ChocolateyProcessAsAdmin -statements `"$imagePath`" -exeToRun `"$vcdmount`"
     write-host "waiting 10 seconds"
     start-sleep -s 10
     return "e"
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

Disable-MicrosoftUpdate
Disable-UAC
Disable-InternetExplorerESC
Enable-RemoteDesktop

choco install VirtualCloneDrive -y

try {
      $drive = Mount-DiskImageReturnDriveLetter $vsIsoPath
      Install-VisualStudio2012 "${drive}:\vs_professional.exe"
}
finally {
    Dismount-DiskImage $iso -ErrorAction SilentlyContinue
}
