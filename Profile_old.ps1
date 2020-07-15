if (!$profile.Contains("NuGet_profile")) {
	cls
	#Write-Host "PowerShell FTW!"
	#Write-Host

	$devLocation = "D:\Dev"
	$shareLocation = "D:\Share"
	$shareArchiveLocation = "D:\Share\Archive"
	$downloadsLocation = "C:\Users\award5\Downloads"

	function software-solutions {
		Write-Host "  ____         __ _                            ____        _       _   _                 "
		Write-Host " / ___|  ___  / _| |___      ____ _ _ __ ___  / ___|  ___ | |_   _| |_(_) ___  _ __  ___ "
		Write-Host " \___ \ / _ \| |_| __\ \ /\ / / _`` | '__/ _ \ \___ \ / _ \| | | | | __| |/ _ \| '_ \/ __|"
		Write-Host "  ___) | (_) |  _| |_ \ V  V / (_| | | |  __/  ___) | (_) | | |_| | |_| | (_) | | | \__ \"
		Write-Host " |____/ \___/|_|  \__| \_/\_/ \__,_|_|  \___| |____/ \___/|_|\__,_|\__|_|\___/|_| |_|___/"
		Write-Host "                                                                                         "
	}

	software-solutions

	# Commands load on start up
	cd $devLocation

	$vs2008 = "C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\devenv.exe"
	$vs2010 = "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
	$vs2012 = "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"
	$vs2013 = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"
	$vs2014 = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"
	$vs2015 = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe"

	$Global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
	$principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
	$Global:UserType = "User"

	if ($principal.IsInRole("Administrators")) {
		$Global:UserType = "Administrator"
	}

	function reset {
		cd $devLocation
		cls
		#dir
	}

	function prompt {
		$host.UI.RawUI.WindowTitle = "Windows PowerShell - " + $currentuser.Name + " (" + $global:usertype + ") - " + (Get-Location)

		if (Test-HgRepo) {
			#$hg_default = (((hg paths default) -replace("http://awtsdev002/FogBugz/kiln/Repo/", "")) -replace("Group/", "")) -replace("/", ">>")
			$hg_branch =(hg branch)
			$hg_status = Get-HgStatus
			Write-Host("HG ") -ForegroundColor Green -NoNewLine
			Write-Host(Get-Location) -NoNewLine
			Write-Host(" [") -ForegroundColor Green -NoNewLine
			Write-Host($hg_branch) -ForegroundColor Yellow -NoNewLine
			if (($hg_status["added"] -gt 0) -or ($hg_status["modified"] -gt 0) -or ($hg_status["deleted"] -gt 0) -or ($hg_status["missing"] -gt 0) -or ($hg_status["untracked"] -gt 0)) {
				Write-Host(" ") -NoNewLine
				if ($hg_status["modified"] -gt 0) {
					Write-Host($hg_status["modified"]) -NoNewLine -ForegroundColor DarkGreen
				}
				if ($hg_status["added"] -gt 0) {
					Write-Host($hg_status["added"]) -NoNewLine -ForegroundColor Green
				}
				if ($hg_status["deleted"] -gt 0) {
					Write-Host($hg_status["deleted"]) -NoNewLine -ForegroundColor DarkRed
				}
				if ($hg_status["missing"] -gt 0) {
					Write-Host($hg_status["missing"]) -NoNewLine -ForegroundColor Cyan
				}
				if ($hg_status["untracked"] -gt 0) {
					Write-Host($hg_status["untracked"]) -NoNewLine -ForegroundColor Magenta
				}
			}

			Write-Host "]" -ForegroundColor Green -NoNewLine

			#Write-Host ($hg_default + " ") -ForegroundColor DarkGreen -NoNewLine
			#Write-Host ((Get-Location).ToString().Replace((Split-Path (hg root) -parent) + "\", "")) -NoNewLine
			#Write-Host " [$hg_branch]"
		} else {
			Write-Host ("PS ") -NoNewLine
			Write-Host (Get-Location) -NoNewLine
		}
		Write-Host (">") -NoNewLine
		return " "
	}

	function Test-HgRepo {
		$current = get-location
		while ($current -ne "") {
			if (test-path "$current\.hg") {
				return $true
			}
			$current = (split-path $current -parent)
		}
		return $false
	}

	function Get-HgStatus {
		$untracked = 0
		$added = 0
		$modified = 0
		$deleted = 0
		$missing = 0

		$output = hg status

		#$branchbits = $output[0].Split(' ')
		#$branch = $branchbits[$branchbits.length - 1]

	   # Write-Host($output)
		$output | foreach {
			if ($_ -match "^R") {
				$deleted += 1
			}
			elseif ($_ -match "^M") {
				$modified += 1
			}
			elseif ($_ -match "^A") {
				$added += 1
			}
			elseif ($_ -match "^\!") {
				$missing += 1
			}
			elseif ($_ -match "^\?") {
				$untracked += 1
			}
		}

		return @{"untracked" = $untracked;
				 "added" = $added;
				 "modified" = $modified;
				 "deleted" = $deleted;
				 "missing" = $missing}
	}
	
	function test {
		$blah = hg status
		Write-Host $blah
	}

	
	
	
	
	
	# Functions to make life that little bit easier
	function clear-profile {
		cls
		software-solutions
	}
	set-alias clr clear-profile

	function edit-global-profile {
		& $env:windir\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe $profile.CurrentUserAllHosts
	}
	set-alias egp edit-global-profile

	function edit-profile {
		& $env:windir\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe $SCRIPTS\profile.ps1
	}
	set-alias ep edit-profile

	function explorer-here {
		explorer .
	}
	set-alias eh explorer-here

	function hg_pull {
		hg pull
		hg update
	}
	set-alias hgpl hg_pull

	function hg_pull_with_rebase {
		hg pull --rebase
		hg update
	}
	set-alias hgpr hg_pull_with_rebase

	function hg_push {
		hg push
	}
	set-alias hgps hg_push

	function hg_revert_all_no_backup {
		hg revert --all --no-backup
	}
	set-alias hgrev hg_revert_all_no_backup

	function hg_commit_with_add ($msg) {
		hg ci -Am '' $msg ''
		Write-Host "Changes have been " -nonewline
		Write-Host "committed " -nonewline -foreground "green";
		Write-Host "with a comment of '$msg'"
	}
	set-alias hgci hg_commit_with_add

	function hg_status {
		hg status
	}
	set-alias hgst hg_status

	function u { cd .. }
	function u2 { cd ..\.. }
	function u3 { cd ..\..\.. }
	function u4 { cd ..\..\..\.. }
	function u5 { cd ..\..\..\..\.. }
	set-alias uu u2
	set-alias uuu u3
	set-alias uuuu u4
	set-alias uuuuu u5

	function downloads {
		cd $downloadsLocation
	}

	function dev {
		cd $devLocation
	}

	function clear_page {
		cls
	}
	set-alias x clear_page

	function share([string] $file) {
		if ($file -eq "") {
			cd $shareLocation
			return
		}
		copy-item $file $shareLocation -recurse
		"Shared " + $file + ". FTW!"
	}

	function archive-share() {
		 dir $shareLocation -exclude "Archive" |? {$_.LastWriteTime -lt (get-date).adddays(-28)} | move-item -destination $shareArchiveLocation -force
	}

	function rdp([string]$item) {
		$rdpitem = $rdplocation + "$item.rdp"
		if(test-path $rdpitem)
		{
			& mstsc $rdpitem
		}
		else
		{
			& mstsc /v:$item -f
		}
	}

	function sln() {
		$sourceExists = test-path Source
		$slnfiles
		if ($sourceExists) {
			$slnfiles = @(Get-ChildItem Source *.sln -Recurse)
		}
		else {
			# Put in for WMS...
			$mainExists = test-path Main
			if ($mainExists){
				$slnfiles = @(Get-ChildItem Main *.sln -Recurse)
			}
			else {
				$slnfiles = @(Get-ChildItem . *.sln -Recurse)
			}
		}
		
		if ($slnfiles.Count -gt 1) {
			$slnfiles |% {$i=0} {"($i) " + $_.Name; $i++} | echo
			$ix = (Read-Host "Choose solution index to load, or leave blank for all")
			if($ix -ne "") {
				$sln = $slnfiles[$ix]
				open-solution($sln.FullName)
			} else {
				$slnfiles |% { "$_" ; open-solution($_.FullName) }
			}
		} elseif ($slnfiles.Count -eq 1) {
			open-solution($slnfiles[0].FullName)
		} else {
			Write-Host "Cannot run sln from here"
		}
	}

	function open-solution([string]$sln) {
		if ($sln -eq $null) { return }
		$slnVersion = (Get-Content $sln)[2]	
		if ($slnVersion -eq "# Visual Studio 2008") {
			& $vs2008 $sln
		} elseif ($slnVersion -eq "# Visual Studio 2010") {
			& $vs2010 $sln
		} elseif ($slnVersion -eq "# Visual Studio 2012") {
			if (Test-Path $vs2012){
				& $vs2012 $sln
			} else {
				& $vs2014 $sln
			}		
		} elseif ($slnVersion -eq "# Visual Studio 2013") {
			if (Test-Path $vs2012){
				& $vs2013 $sln
			} else {
				& $vs2014 $sln
			}
		} elseif ($slnVersion -eq "# Visual Studio 14"){
			& $vs2014 $sln
		} elseif ($slnVersion -eq "# Visual Studio 15"){
			& $vs2015 $sln
		}
		else {
			Write-Host "Error - Solution Version: " $slnVersion
		}
	}

	function run-as-admin([string]$exec, [string]$arguments) {
	  $psi = new-object System.Diagnostics.ProcessStartInfo $exec
	  $psi.Arguments = $arguments
	  $psi.Verb = "runas"
	  [System.Diagnostics.Process]::Start($psi)
	}

	function remove-all([string]$match) {
		get-childitem . $match -recurse | ?{!$_.PSIsContainer} | remove-item -force
	}

	function edit-mercurialini {
		& notepad $HOME\Mercurial.ini
	}

	function mm {
		. "C:\Program Files (x86)\FreeMind\Freemind.exe"
		<#if (test-path "D:\Documents\My Dropbox\MindMaps") {
			$files = @(Get-ChildItem "D:\Documents\My Dropbox\MindMaps" *.mm -Recurse)

		}#>
	}

	function re {
		. "C:\Program Files\TortoiseHg\thgw.exe" log
	}

	function sha-hash ($file) {
	  $content = [Byte[]][System.IO.File]::ReadAllBytes($file)
	  $hasher = [System.Security.Cryptography.SHA1]::Create()
	  [string]::Join("",$($hasher.ComputeHash($content) | %{"{0:x2}" -f $_}))
	}

}