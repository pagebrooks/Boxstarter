$sql2014IsoPath = '\\vmware-host\Shared Folders\DEV\SW_DVD9_SQL_Svr_Developer_Edtn_2014_64Bit_English_MLF_X19-34421.ISO'
$sql2014configFile = "https://raw.github.com/pagebrooks/Boxstarter/master/SQL2014-Config.ini"

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
		write-host "unmount of $imagePath failed. continuing."
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

function Install-Sql2014() { 
	$sqlPath = "$($Boxstarter.programFiles)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Binn\sqlservr.exe"
	if((Test-Path $sqlPath) -eq $false) {   

		$drive = Mount-DiskImageReturnDriveLetter $sql2014IsoPath
		Write-Host "Downloading Sql2014-Config.ini"
		$sqlAdminFile = "$env:temp\Sql2014-Config.ini"
		$client = New-Object System.Net.WebClient;
		$client.DownloadFile($sql2014ConfigFile, $sql2014AdminFile);
		Write-Host "Installing SQL Server 2014 as it is not already on path $sqlPath"
		$installer = "${drive}:\setup.exe"
		$vsargs = "/ConfigurationFile=$sqlAdminFile" 
		Start-ChocolateyProcessAsAdmin -statements $vsargs -exeToRun $installer
		Dismount-DiskImage $sql2014IsoPath -ErrorAction SilentlyContinue
		Reboot-IfRequired
	} else { 
		Write-Host "SQL Server 2014 already installed as sqlservr.exe found on path $sqlPath"
	}
}

Disable-MicrosoftUpdate
Disable-UAC
Disable-InternetExplorerESC
Enable-RemoteDesktop

choco install VirtualCloneDrive -y

Install-Sql2014
