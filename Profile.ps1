# Check not running via a NuGet prompt
if (!$profile.Contains("NuGet_profile")) {
	# Set local variables
	$devLocation = "D:\Dev"
	$shareLocation = "D:\Share"
	$shareArchiveLocation = "D:\Share\Archive"
	$downloadsLocation = "C:\Users\award5\Downloads"

	# Set Visual Studio locations
	$vs2008 = "C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\devenv.exe"
	$vs2010 = "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
	$vs2012 = "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"
	$vs2013 = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"
	$vs2014 = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"
	$vs2015 = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe"

	# Global variables
	$Global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
	$principal = new-object System.Security.Principal.WindowsPrincipal($CurrentUser)
	$Global:UserType = "User"

	#  Colours
	$BracketColour = "Green"
	$BranchColour = "Yellow"
	$ModifiedColour = "DarkGreen"
	$AddedColour = "Green"
	$DeletedColour = "DarkRed"
	$MissingColour = "Cyan"
	$UntrackedColour = "Magenta"

	# Import PowerShell functions
	Import-module $PSScriptRoot\Commands\Mercurial.psm1
	Import-module $PSScriptRoot\Commands\Git.psm1
	
	# Set user type
	if ($principal.IsInRole("Administrators")) {
		$Global:UserType = "Administrator"
	}
	
	function logo {
		Write-Host "Some fancy logo.."
	}
	
	# Clear the prompt
	cls
	
	# Change to dev directory
	cd $devLocation

	# Load the logo
	logo

	# Update the prompt
	function prompt {
		# Variables
		$location = Get-Location
						
		# Update the window title of the command window
		$host.UI.RawUI.WindowTitle = "Windows PowerShell - " + $currentuser.Name + " (" + $global:usertype + ") - " + ($location)

		# Test for a mercurial repo
		$hgRepo = Test-HgRepo
		if ($hgRepo) {
			$details = Get-HgStatus
			UpdatePrompt $details
			return " "
		}
		
		# Test for a git repo
		$gitRepo = Test-GitRepo
		if ($gitRepo) {
			$details = Get-GitStatus
			UpdatePrompt $details
			return " "
		}
		
		Write-Host ("PS ") -NoNewLine
		Write-Host (Get-Location) -NoNewLine
		Write-Host (">") -NoNewLine
		
		return " "
	}
	
	function UpdatePrompt($repo_status) {
		# Variables
		$repo_branch = $repo_status["branch"]
		
		# Construct the prompt command line
		Write-Host($repo_status["repo"]) -ForegroundColor Green -NoNewLine
		Write-Host($location) -NoNewLine
		Write-Host(" [") -ForegroundColor $BracketColour -NoNewLine
		Write-Host($repo_branch) -ForegroundColor $BranchColour -NoNewLine
		
		if (($repo_status["added"] -gt 0) -or ($repo_status["modified"] -gt 0) -or ($repo_status["deleted"] -gt 0) -or ($repo_status["missing"] -gt 0) -or ($repo_status["untracked"] -gt 0)) {
			Write-Host(" ") -NoNewLine
			if ($repo_status["modified"] -gt 0) {
				Write-Host($repo_status["modified"]) -NoNewLine -ForegroundColor $ModifiedColour
			}
			if ($repo_status["added"] -gt 0) {
				Write-Host($repo_status["added"]) -NoNewLine -ForegroundColor $AddedColour
			}
			if ($repo_status["deleted"] -gt 0) {
				Write-Host($repo_status["deleted"]) -NoNewLine -ForegroundColor $DeletedColour
			}
			if ($repo_status["missing"] -gt 0) {
				Write-Host($repo_status["missing"]) -NoNewLine -ForegroundColor $MissingColour
			}
			if ($repo_status["untracked"] -gt 0) {
				Write-Host($repo_status["untracked"]) -NoNewLine -ForegroundColor $UntrackedColour
			}
		}

		Write-Host "]" -ForegroundColor $BracketColour -NoNewLine
		Write-Host (">") -NoNewLine
	}
	
	# Open Visual Studio
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

	# Open solution
	function open-solution([string]$sln) {
		# Just open in latest version of Visual Studio
		& $vs2019 $sln
		
		#if ($sln -eq $null) { return }
		#$slnVersion = (Get-Content $sln)[2]	
		#if ($slnVersion -eq "# Visual Studio 2008") {
		#	& $vs2008 $sln
		#} elseif ($slnVersion -eq "# Visual Studio 2010") {
		#	& $vs2010 $sln
		#} elseif ($slnVersion -eq "# Visual Studio 2012") {
		#	if (Test-Path $vs2012){
		#		& $vs2012 $sln
		#	} else {
		#		& $vs2014 $sln
		#	}		
		#} elseif ($slnVersion -eq "# Visual Studio 2013") {
		#	if (Test-Path $vs2012){
		#		& $vs2013 $sln
		#	} else {
		#		& $vs2014 $sln
		#	}
		#} elseif ($slnVersion -eq "# Visual Studio 14"){
		#	& $vs2014 $sln
		#} elseif ($slnVersion -eq "# Visual Studio 15"){
		#	& $vs2015 $sln
		#}
		#else {
		#	Write-Host "Error - Solution Version: " $slnVersion
		#}
	}
	
	
	# Functions to make life that little bit easier #
	# Clean inline if function
	function iif($If, $Right, $Wrong) {
		If ($If) {$Right} Else {$Wrong}
	}
	
	# Reset
	function clear-profile {
		cls
		logo
	}
	set-alias clr clear-profile
	
	# Edit global profile
	function edit-global-profile {
		& $env:windir\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe $profile.CurrentUserAllHosts
	}
	set-alias egp edit-global-profile

	function explorer-here {
		explorer .
	}
	set-alias eh explorer-here

	function downloads {
		cd $downloadsLocation
	}
	set-alias dl downloads

	function dev {
		cd $devLocation
	}
	
	function u { cd .. }
	function u2 { cd ..\.. }
	function u3 { cd ..\..\.. }
	function u4 { cd ..\..\..\.. }
	function u5 { cd ..\..\..\..\.. }
	set-alias uu u2
	set-alias uuu u3
	set-alias uuuu u4
	set-alias uuuuu u5
}