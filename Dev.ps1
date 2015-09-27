$vs2012IsoPath = '\\vmware-host\Shared Folders\DEV\SW_DVD5_Visual_Studio_Pro_2012_English_Core_MLF_X18-35900.ISO'
$vs2012AdminDeploymentFile = "https://raw.github.com/pagebrooks/Boxstarter/master/VS2012-AdminDeployment.xml"
$office2013IsoPath = '\\vmware-host\Shared Folders\DEV\SW_DVD5_Office_Professional_Plus_2013_W32_English_MLF_X18-55138.ISO'
$office2013ConfigFile = "https://raw.github.com/pagebrooks/Boxstarter/master/Office2013-Config.xml"
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

function Install-Sql2014() { 
	$sqlPath = "${Env:ProgramFiles}\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Binn\sqlservr.exe"
	if((Test-Path $sqlPath) -eq $false) {   

		$drive = Mount-DiskImageReturnDriveLetter $sql2014IsoPath
		Write-Host "Downloading Sql2014-Config.ini"
		$sql2014AdminFile = "$env:temp\Sql2014-Config.ini"
		$client = New-Object System.Net.WebClient;
		$client.DownloadFile($sql2014ConfigFile, $sql2014AdminFile);
		Write-Host "Installing SQL Server 2014 as it is not already on path $sqlPath"
		$installer = "${drive}:\setup.exe"
		$user = "${Boxstarter.BoxstarterUser}\${Boxstarter.BoxstarterUserDomain}"
		$vsargs = "/ConfigurationFile=$sql2014AdminFile /SQLSYSADMINACCOUNTS=`"${user}`""
		Write-Host "Args: $vsargs"
		Start-ChocolateyProcessAsAdmin -statements $vsargs -exeToRun $installer
		Dismount-DiskImage $sql2014IsoPath -ErrorAction SilentlyContinue
		Reboot-IfRequired
	} else { 
		Write-Host "SQL Server 2014 already installed as sqlservr.exe found on path $sqlPath"
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
	} else { 
		Write-Host "VS2012 already installed as devenv.exe found on path $devenvPath"
	}

	if((Get-Item "$($Boxstarter.programFiles86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe").VersionInfo.ProductVersion -lt "11.0.60115.1") {
		$vsUpdate4Path = 'http://download.microsoft.com/download/D/4/8/D48D1AC2-A297-4C9E-A9D0-A218E6609F06/VSU4/VS2012.4.exe'
		Install-ChocolateyPackage 'VS2012 Update 4' 'exe' '/passive /norestart' $vsUpdate4Path
		Reboot-IfRequired
	} else {
		Write-Host "VS2012 Update 4 already installed, skipping"
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

try {
	
	$Boxstarter.BoxstarterUser = $env:UserName
	$Boxstarter.BoxstarterUserDomain = $env:UserDomain
	Write-Host $env:UserName
	Write-Host "User: ${Boxstarter.BoxstarterUser}\${Boxstarter.BoxstarterUserDomain}"

	# Windows Configuration
	Update-ExecutionPolicy RemoteSigned
	Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions -EnableShowFullPathInTitleBar
	Disable-MicrosoftUpdate
	Disable-UAC
	Disable-InternetExplorerESC
	Enable-RemoteDesktop

	choco install VirtualCloneDrive -y
	Install-Sql2014
	Install-Office2013
	Install-VisualStudio2012

	choco install psget -y
	choco install hipchat -y
	choco install 7Zip -y
	choco install conemu -y
	choco install greenshot -y
	choco install fiddler4 -y
	choco install curl -y
	choco install notepadplusplus.install -y
	choco install regexpixie -y
	choco install linqpad -y
	choco install dotpeek -y
	choco install winmerge -y
	choco install windirstat -y
	choco install filezilla -y
	choco install paint.net -y
	choco install adobereader -y

	choco install git.install -y
	choco install poshgit -y
	choco install git-credential-winstore -Version 1.2.0.0 -y

	choco install javaruntime -y
	choco install golang -y

	# Fix SSH-Agent error by adding the bin directory to the `Path` environment variable
	$env:PSModulePath = $env:PSModulePath + ";${Env:ProgramFiles(x86)}\Git\bin"

	Install-ChocolateyPinnedTaskBarItem "$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe"  
	Install-ChocolateyPinnedTaskBarItem "${Env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
	Install-ChocolateyFileAssociation ".build" "${Env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
	Install-ChocolateyFileAssociation ".config" "${Env:ProgramFiles(x86)}\Notepad++\notepad++.exe"

	choco install Firefox -y
	choco install GoogleChrome -y
	Reboot-IfRequired

	choco install TelnetClient -source windowsFeatures -y
	choco install IIS-WebServerRole -source windowsfeatures -y
	choco install IIS-HttpCompressionDynamic -source windowsfeatures -y
	choco install IIS-ManagementScriptingTools -source windowsfeatures -y
	choco install IIS-WindowsAuthentication -source windowsfeatures -y

	#Enable-MicrosoftUpdate
	#Install-WindowsUpdate -AcceptEula

} catch {
	Write-ChocolateyFailure 'Dev-Boxstarter' $($_.Exception.Message)
	throw
}
