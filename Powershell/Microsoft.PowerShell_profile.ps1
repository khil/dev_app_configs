Set-Alias rdp mstsc
Set-Alias gvi start-vi
Set-Alias gvim start-vi
Set-Alias vi start-vi
Set-Alias vim start-vi
#Set-Alias ed ($env:HOMEDRIVE + $env:USERPROFILE + "\bin\Ted\TedNPad.exe")
Set-Alias gs Get-Service
Set-Alias l List-Wide
Set-Alias ll Get-ChildItem
Set-Alias psh powershell
Set-Alias vs start-visual-studio-cmd-prompt
Set-Alias tail 'Get-Content $0 -Wait | % { $counter++; write-host "$counter`t| $_" }'
Import-Module Kirks
Set-alias unmount Dismount-Drive
Set-alias umount Dismount-Drive
Set-alias eject Dismount-Drive
Set-Alias untar unpack
Set-Alias activate c:\python\64bit\virt_env\activate_ve.ps1
Set-Alias start-vs start-visual-studio-cmd-prompt

$Env:PYTHONSTARTUP=$Env:UserProfile + "\src\python\startup.py"
$env:Path += $env:UserProfile + "\bin\;" + $env:UserProfile + "\scripts\;" + $env:UserProfile + "\bin\putty\;C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319;C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC"

$host.ui.rawui.WindowTitle = "psh v" + $Host.Version

cd c:\Users\khildreth.nvfel

##
## create an artificial command to go back up a directory tree
## For example:
#     the command: u4  is equal to cd ..\..\..\..\
##  or
##     the command uu is equal to cd ..\..\
##
for ($i = 1; $i -le 6; $i++) {
	$u = "".PadLeft($i, "u")
	$unum = "u$i"
	$d = $u.Replace("u", "..\")
	Invoke-Expression "function $u { push-location $d }"
	Invoke-Expression "function $unum { push-location $d }"
}

function list-wide {
    #Get-ChildItem | Select-Object name | Format-Wide -AutoSize
    Invoke-Expression ("Get-ChildItem $args") | ForEach-Object {
        if ($_.psiscontainer) {
            '[{0}]' -f $_.Name
        } else {
            $_.Name
        }
    } | Format-Wide {$_} -AutoSize -Force	
}

function prompt {

	##Write-Host ($(Get-Location).Path.Replace('\','/') + ">") -NoNewLine -BackgroundColor Gray -ForegroundColor Black
	Write-Host ($(Get-Location).Path.Replace('\','/') + ">") -NoNewLine -ForegroundColor DarkCyan
	return " "
}

function start-visual-studio-cmd-prompt {
	pushd 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC'
	cmd /c ".\vcvarsall.bat&set" | foreach {
		if ($_ -match "=") {
			$v = $_.split("="); set-item -force -path "ENV:\$($v[0])" -value $($v[1])
		}
	}
	popd
	## python wants vs2008 or vs2010 to compile c libraries so fake it
    $ENV:VS090COMNTOOLS = $ENV:VS110COMNTOOLS   # pointer for VS2008
	$ENV:VS100COMNTOOLS = $ENV:VS110COMNTOOLS   # pointer for VS2010
	Write-Host "`nVisual Studio 2012 Command Prompt Variables have been set" -ForegroundColor Yellow
}

function edit-vimrc() {
	start-vi -NewWindow $home\_vimrc
	start-vi -ShowTabs $home\vimfiles\ftplugin\*.vim 
}

function edit-profile() {
	start-vi -NewWindow $profile
}

function start-vi ([Switch] $NewWindow, [Switch] $ShowTabs) {
	$is_running = ((ps gvim -ErrorAction SilentlyContinue) -ne $null)

	if ($NewWindow) {
		& 'C:\Program Files\Vim\vim74\gvim.exe' $args
		return
	}
	
	if ($ShowTabs) {
		if ($is_running -and $args.Length -gt 0) {
			& 'C:\Program Files\Vim\vim74\gvim.exe' --remote-tab-silent $args
			return
		}		
	}

	# default: use the smae vi window with no tabs
	if ($is_running) {
		if ($args.Length -gt 0) {
			& 'C:\Program Files\Vim\vim74\gvim.exe' --remote-silent $args
		}
	}
	else {
		& 'C:\Program Files\Vim\vim74\gvim.exe' $args
	}
}

function unpack($fp) {
	if ($fp.EndsWith("tar.gz")) {
		(7z e $fp) -and (7z x $fp.SubString(0, $fp.Length - 3)) -and (rm $fp.SubString(0, $fp.Length - 3)) | out-null
	}
}

