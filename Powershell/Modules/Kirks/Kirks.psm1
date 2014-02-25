function Get-Uptime {
	param (
		[Parameter(Mandatory=$false)]  [String[]] $computerNames = $Env:COMPUTERNAME
	)

	$os = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computerNames)

	if ($os -ne $null) {
		$os | ForEach-Object {
			$uptime = (Get-Date) – [Management.ManagementDateTimeconverter]::ToDateTime($_.LastBootUpTime)
			Write-Host ("{0,-15} -> {1,4} Day(s), {2:d2} Hour(s), {3:d2} Min(s), {4:d2} Sec(s)" -f $_.csname, $uptime.days, $uptime.hours, $uptime.minutes, $uptime.seconds)
		}
	}
}

function Get-SysInfo {
	param (
		[Parameter(Mandatory=$false)]  [String[]] $computerNames = $Env:COMPUTERNAME
	)

	(Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computerNames) | ForEach-Object {
		$uptime = (Get-Date) – [Management.ManagementDateTimeconverter]::ToDateTime($_.LastBootUpTime)

		Write-Host (
			[String]::Format(
"{0,-15} ->
`tUser:       {1}\{2}
`tOS:         {3}
`tVersion:    {4}
`tArch:       {5}
`tBuild:      {6}
`tSvc Pack:   {7}
`tPurpose:    {8}
`tInstalled:  {9}
`tStatus      {10}
`tWinDir:     {11}
`tUptime:     {12:d2} Day(s), {13:d2} Hour(s), {13:d2} Min(s), {14:d2} Sec(s)
`tTimeZone:   {15} Hours GMT",
				$_.CSName,
				$Env:USERDOMAIN, $Env:USERNAME,
				$_.Caption,
				$_.Version,
				$_.OSArchitecture,
				$_.BuildNumber,
				$_.CSDVersion,
				$_.ProductType,
				[Management.ManagementDateTimeconverter]::ToDateTime($_.InstallDate),
				$_.Status,
				$_.WindowsDirectory,
				$uptime.days, $uptime.hours, $uptime.minutes, $uptime.seconds,
				$_.CurrentTimeZone / 60
			)
		)
	}
}

function Get-Drives {
    Get-WmiObject Win32_LogicalDisk | Format-Table                                                               `
			@{Expression={$_.DeviceID + "\"};Label="Dev";width=4},                                               `
			@{Expression={$_.VolumeName};Label="Name        ";width=12},                                         `
			@{Expression={"{0,-15}" -F([System.IO.DriveType] $_.DriveType) };Label="Type           ";width=15},  `
			@{Expression={$_.ProviderName};Label="Provider                                          ";width=50}, `
			@{Expression={"{0,10:N1} GB" -f($_.FreeSpace/1gb)};Label="         Free";width=13},                  `
			@{Expression={"{0,10:N1} GB" -f($_.Size/1gb)};Label="         Size";width=13}
}

function isint ( $str ) {
    if ( $str ) {
        try {
            0 + $str | Out-Null
            [Int32]::Parse($str)
            $true
        } catch {
            $false
        }
    }
}

function pause ([int] $seconds = -1) {
    function Write-Delay-Msg ($left, $top, $secs) {
        Write-Host -NoNewLine ("Press any key to continue ({0}) . . .   " -f $secs)
        [Console]::SetCursorPosition($left, $top)    
    }

    if ($seconds -le 0) {
        Write-Host -NoNewLine "Press any key to continue . . ."
        $k = [Console]::ReadKey($true)
    } else {
        [Console]::TreatControlCAsInput = $true
        $milliSecs = ($seconds * 1000)
        $left = [Console]::CursorLeft
        $top = [Console]::CursorTop

        for (; $milliSecs -gt 0; $milliSecs -= 250) {
            if (($milliSecs % 1000) -eq 0) {
                Write-Delay-Msg $left $top ($milliSecs / 1000)
            }

            if ([Console]::KeyAvailable) { 
                break
            } else {
                Start-Sleep -m 250
            }
        }
        Write-Delay-Msg $left $top 0
    }

    Write-Host ""
}


function iif {
    <#
    .SYNOPSIS
    Inline if function
    
    .DESCRIPTION
    Inline if function with optional delayed execution -or- short circuit

    .EXAMPLE
    
    Standard execution:  both true & false statements are executed at function invocation, regardless of the predicate's result.
    
     iif ($a -eq $b) "Hello" "Goodbye"

    An example that shows that both oTrue & oFalse are executed at the function invocation:
    
     [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms");
     iif $true ([Windows.Forms.MessageBox]::Show("Hello")) ([Windows.Forms.MessageBox]::Show("Goodbye"))

    
        
    Delayed execution (short circuit): only the statement matching the predicate's result is executed.  Execution is delayed until after function invocation and the predicate is evaluated.  The oposing predicate will never be executed.

     iif ($a -eq $b) { "Hello" } { "Goodbye" }
       
    -or -
        
    iif ($a -eq $b) ([ScriptBlock]::create("'Hello'")) ([ScriptBlock]::create("'Goodbye'"))

    An example that shows that only the proper scriptblock is executed at the function invocation:
     [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms");
     iif $true { [Windows.Forms.MessageBox]::Show("Hello") } { [Windows.Forms.MessageBox]::Show("Goodbye") }



    Mixing of the oTrue & oFalse parameter types:
        
    iif ($a -eq $b) "Hello" { "Goodbye" }
    
    
    .PARAMETER predicate
    Conditional statement.  The conditional statement should be wrapped in parentheses as it will need to be executed at the function invocation point.

    .PARAMETER oTrue
    The result that is optionally executed and returned if the predicate is true.

    .PARAMETER oFalse
    The result that is optionally executed and returned if the predicate is false.
    
    .INPUTS
    N/A
    
    .OUTPUTS
    N/A

    .NOTES
    Created By:  Kirk Hildreth  |  US EPA  | Ann Arbor, MI  |  May 8, 2013
    #>
    
    param (
    	[Parameter(
            Position = 0,
    		Mandatory = $true,
            ValueFromPipeline = $true)]
    	[Boolean] $predicate = $false,
    	
    	[Parameter(
            Position = 1,
    		Mandatory = $true,
            ValueFromPipeline = $true)]
    	[Object] $oTrue,
        
    	[Parameter(
            Position = 2,
    		Mandatory = $true,
            ValueFromPipeline = $true)]
    	[Object] $oFalse
    )
    
    begin {
        Write-Debug ("Executing iif function with values`n   $predicate => {0} => {1}`n   $oTrue => {2} => {3}`n   $oFalse => {4} => {5}" -f
            $predicate.GetType(), $predicate,
            $oTrue.GetType(), $oTrue,
            $oFalse.GetType(), $oFalse)
    }
    
    process {
        if ( $predicate ) {
            if ($oTrue -is [ScriptBlock]) {
                $oTrue.Invoke()
            } else {
                $oTrue
            }        
        } else { 
            if ($oFalse -is [ScriptBlock]) {
                $oFalse.Invoke()
            } else {
                $oFalse
            }
        }
    }
}

function Dismount-Drive {
    <#
    .SYNOPSIS
    Unmount Removable Drive

    .DESCRIPTION
    Unmount or eject a removable drive

    .EXAMPLE    
    Unmount-Drive 'E'    

    .PARAMETER driveLtr
    Drive letter of the drive to be unmounted

    .INPUTS
    N/A

    .OUTPUTS
    N/A

    .NOTES
    Created By:  Kirk Hildreth  |  US EPA  | Ann Arbor, MI  |  May 30, 2013
    For Windows NT5 requires the deveject.exe utility to be in the path.  The
    utility can be obtained here:  http://www.withopf.com/tools/deveject/
    #>
    
    Param (
        [Parameter(
        Position = 0,
        		Mandatory = $true,
        ValueFromPipeline = $true)]
        [char] $driveLtr
    )

    begin {
        Write-Debug ("Attempting to unmount/eject drive '" + $driveLtr + "'")
    }
    
    process {
        function Is-DriveRemovable([char] $driveLtr) {
        	$drive = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.Name -eq ($driveLtr + ":\") }

        	if ($drive -ne $null) {
        		if ($drive.DriveType -eq [System.IO.DriveType]::Removable) {
                    if ($drive.IsReady -eq $true) {
        			     return $true;
                    } else {
                        Write-Error "Drive '$driveLtr' is busy and cannot be unmounted at this time."
                    }
        		} else {
        			Write-Error ("Drive $driveLtr is of type " + $drive.DriveType + " which cannot be unmounted with this script.")
        		}
        	} else {
        		Write-Error "Drive '$driveLtr' Not Found"
        	}

        	return $false
        }        
    
        if (Is-DriveRemovable $driveLtr) {
            switch ([Environment]::OSVersion.Version.Major) {
                5 { ## (Win 2k, XP, Svr 2003)
                    deveject -EjectDrive:($driveLtr + ":")
                }
                6 { ## (Vista, 7, 8, Svr 2008, Svr 2012)
                	$vol = Get-WmiObject -Class Win32_Volume | where {$_.Name -eq ($driveLtr + ":\") }
                	$vol.DriveLetter = $null
                	$vol.Put()
                	$vol.Dismount($false, $false)            
                }
                default { ## (NT 3.5, 4.0, future releases)
                    Write-Error ("Error:  Unsupported Windows OS.")
                }
            }
        }
    }
}
