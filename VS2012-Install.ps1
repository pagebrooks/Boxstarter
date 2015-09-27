  $vs2012IsoPath = '\\vmware-host\Shared Folders\DEV\SW_DVD5_Visual_Studio_Pro_2012_English_Core_MLF_X18-35900.ISO'
  $vs2012AdminDeploymentFile = "https://raw.github.com/pagebrooks/Boxstarter/master/VS2012-AdminDeployment.xml"
  
  function Mount-DiskImageReturnDriveLetter($imagePath) { 
    Write-Host "mounting iso at: $imagePath"
     $vcdmount = "$($Boxstarter.programFiles86)\Elaborate Bytes\VirtualCloneDrive\vcdmount.exe"
     $args = "/l=E `"$imagePath`""
     Start-ChocolateyProcessAsAdmin -statements $args -exeToRun `"$vcdmount`"
     write-host "waiting 10 seconds"
     start-sleep -s 10
     return "E"
  }

  function Dismount-DiskImage($imagePath) {
      try { 
          Write-Host "dismounting iso: $imagePath"
          $vcdmount = "$($Boxstarter.programFiles86)\Elaborate Bytes\VirtualCloneDrive\vcdmount.exe"
          $args = "/u"
          Start-ChocolateyProcessAsAdmin -statements $args -exeToRun $vcdmount
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

function Install-VisualStudio2012() { 
  
    $devenvPath = "$($Boxstarter.programFiles86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"
    if((Test-Path $devenvPath) -eq $false) {   
      
      $drive = Mount-DiskImageReturnDriveLetter $vs2012IsoPath
      Write-Host "Downloading VS2012-AdminDeployment.xml"
      $vsAdminFile = "$env:temp\VS2012-AdminDeployment.xml"
      $client = New-Object System.Net.WebClient;
      $client.DownloadFile($vs2012AdminDeploymentFile, $vsAdminFile);
      

      Write-Host "Installing VS2012 as it is not already on path $devenvPath"
      $vsInstaller = "${drive}:\vs_professional.exe"
      $vsargs = "/Passive /NoRestart /AdminFile $vsadminFile /Log $env:temp\vs.log"
      Start-ChocolateyProcessAsAdmin -statements $vsargs -exeToRun $vsInstaller
      Dismount-DiskImage $vsIsoPath -ErrorAction SilentlyContinue
      
      Reboot-IfRequired
    }
    else { 
      Write-Host "VS2012 already installed as devenv.exe found on path $devenvPath"
    }

    if((Get-Item "$($Boxstarter.programFiles86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe").VersionInfo.ProductVersion -lt "11.0.60115.1") {
      $vsUpdate4Path = 'http://download.microsoft.com/download/D/4/8/D48D1AC2-A297-4C9E-A9D0-A218E6609F06/VSU4/VS2012.4.exe'
      Install-ChocolateyPackage 'VS2012 Update 4' 'exe' '/passive /norestart' $vsUpdate4Path
      Reboot-IfRequired
    }
}

Disable-MicrosoftUpdate
Disable-UAC
Disable-InternetExplorerESC
Enable-RemoteDesktop

choco install VirtualCloneDrive -y

Install-VisualStudio2012



