function Mount-Iso([string] $isoPath)
{
	if ( -not (Test-Path $isoPath)) { throw "$isoPath does not exist" }
	
	if ($(Test-Windows8orGreater)) {
		Write-Host "Mounting $isoPath using powershell"
		Mount-DiskImage -ImagePath $isoPath
		$driveLetter = (Get-DiskImage $isoPath | Get-Volume).DriveLetter
		return ($driveLetter + ":\")
	}
	else {
		$driveLetter = ls function:[i-z]: -n | ?{ !(test-path $_) } | random
		Write-Host "Mounting $isoPath using ImDisk"
		(& "imdisk" -a -f $isoPath -m $driveLetter) | out-null
		return ($driveLetter + "\")
	}
}

function Dismount-Iso([string] $driveLetter)
{
	start-sleep -s 5

	if ($(Test-Windows8orGreater)) {
		Write-Host "Unmounting $driveLetter using powershell"
		Get-Volume ($driveLetter.Replace(":\","")) | Get-DiskImage | Dismount-DiskImage
	}
	else {
		Write-Host "Unmounting $driveLetter using ImDisk"
		(& "imdisk" -D -m ($driveLetter.Replace("\",""))) | out-null
	}
}

function Invoke-IsoExe([string] $isoFile, [string] $exeFile, [string] $exeArgs)
{
	if ( -not (Test-Path $isoFile)) { throw "$isoFile does not exist" }
	
	$mountPath = Mount-Iso $isoFile  
	$exePath = ($mountPath + $exeFile)

	Wait-ForPath $exePath
	
	if (Test-Path $exePath)
	{
		Write-Host "Executing $exePath"
		if ([string]::IsNullOrEmpty($exeArgs))
		{
			Start-Process -FilePath "$exePath" -Wait
		}
		else
		{
			Start-Process -FilePath "$exePath" -ArgumentList $exeArgs -Wait
		}
	}
	else
	{
		Write-Host "Couldn't locate $exePath" -fore Red
	}
	Dismount-Iso $mountPath
}

function Wait-ForPath([string] $filePath)
{
	$timeoutCount=0
	While ($timeoutCount -lt 15) 
	{
		if (Test-Path $filePath) { break }
		Write-Host "Waiting for $filePath"
		$timeoutCount += 1
		Start-Sleep -s 1		
	}
}

function Test-Windows8orGreater
{
	$osVersion = [Environment]::OSVersion.Version
	return $osVersion -ge (new-object 'Version' 6,2)
}

function Test-ImDisk
{
	if ( -not (Get-Command ImDisk)) { throw "ImDisk does not exist" }
}

if (-not $(Test-Windows8orGreater)) {
	Write-Host "Checking imdisk installed"
	cinst imdisk
	Test-ImDisk
}

Export-ModuleMember Mount-Iso, Dismount-Iso, Invoke-IsoExe
