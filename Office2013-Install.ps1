  $office2013IsoPath = '\\vmware-host\Shared Folders\DEV\SW_DVD5_Office_Professional_Plus_2013_W32_English_MLF_X18-55138.ISO'
  $office2013ConfigFile = "https://raw.github.com/pagebrooks/Boxstarter/master/Office2013-Config.xml"
  
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

function Install-Office2013() { 
    $officePath = "$($Boxstarter.programFiles86)\Microsoft Office\Office15\WINWORD.exe"
    if((Test-Path $officePath) -eq $false) {   
      
      $drive = Mount-DiskImageReturnDriveLetter $office2013IsoPath
      Write-Host "Downloading Office2013-Config.xml"
      $officeAdminFile = "$env:temp\Office2013-Config.xml"
      $client = New-Object System.Net.WebClient;
      $client.DownloadFile($office2013ConfigFile, $officeAdminFile);
      
      Write-Host "Installing Office 2013 as it is not already on path $officePath"
      $vsInstaller = "${drive}:\setup.exe"
      $vsargs = "/Config $officeAdminFile"
      Start-ChocolateyProcessAsAdmin -statements $vsargs -exeToRun $vsInstaller
      Dismount-DiskImage $vsIsoPath -ErrorAction SilentlyContinue
      Reboot-IfRequired
    } else { 
      Write-Host "Office 2013 already installed as WINWORD.exe found on path $officePath"
    }
}

Disable-MicrosoftUpdate
Disable-UAC
Disable-InternetExplorerESC
Enable-RemoteDesktop

choco install VirtualCloneDrive -y

Install-Office2013
