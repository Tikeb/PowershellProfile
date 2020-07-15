
function Test-GitRepo {
	$current = get-location
	while ($current -ne "") {
		if (test-path "$current\.git") {
			return $true
		}
		$current = (split-path $current -parent)
	}
	return $false
}

function Get-GitStatus {
	$untracked = 0
	$added = 0
	$modified = 0
	$deleted = 0
	$missing = 0
	$renamed = 0

	$untrackedFiles = New-Object System.Collections.Generic.List[System.Object]
	$addedFiles = New-Object System.Collections.Generic.List[System.Object]
	$modifiedFiles = New-Object System.Collections.Generic.List[System.Object]
	$deletedFiles = New-Object System.Collections.Generic.List[System.Object]
	$missingFiles = New-Object System.Collections.Generic.List[System.Object]
	$renamedFiles = New-Object System.Collections.Generic.List[System.Object]
	
	$other = 0
	$otherFiles = New-Object System.Collections.Generic.List[System.Object]
	
	$output = git status --porcelain
	$branch = (git status).split(' ')[2]
	
	$output | foreach {
		if ($_ -match "^ D") {
			$deleted += 1
			$files = $_.substring(3, $_.length - 3)
			$deletedFiles.Add($files)
		}
		elseif ($_ -match "^ M") {
			$modified += 1
			$files = $_.substring(3, $_.length - 3)
			$modifiedFiles.Add($files)
		}
		elseif ($_ -match "^A") {
			$added += 1
			$files = $_.substring(3, $_.length - 3)
			$addedFiles.Add($files)
		}
		elseif ($_ -match "^??") {
			$untracked += 1
			$files = $_.substring(3, $_.length - 3)
			$untrackedFiles.Add($files)
		}
		else {
			$other += 1
			$files = $_.substring(3, $_.length - 3)
			$otherFiles.Add($files)
		}
	}
	
	return @{"repo" = "GIT ";
		"branch" = $branch;
		"untracked" = $untracked;
		"untrackedFiles" = $untrackedFiles;
		"added" = $added;
		"addedFiles" = $addedFiles;
		"modified" = $modified;
		"modifiedFiles" = $modifiedFiles;
		"deleted" = $deleted;
		"deletedFiles" = $deletedFiles;
		"missing" = $missing;
		"missingFiles" = $missingFiles;
		"other" = $other;
		"otherFiles" = $otherFiles}
}

function Git-Full-Status {

	if (Test-GitRepo) {
		$status = Get-GitStatus
		
		Write-Host "Branch:		" $status["branch"] -ForegroundColor $BranchColour
		
		if (($status["added"] -gt 0) -or ($status["modified"] -gt 0) -or ($status["deleted"] -gt 0) -or ($status["missing"] -gt 0) -or ($status["untracked"] -gt 0)) {
			if ($status["modified"] -gt 0) {
				Write-Host "Modified:	" $status["modified"] -ForegroundColor $ModifiedColour
				Write-Files $status["modifiedFiles"] "* " $ModifiedColour
			}
			if ($status["added"] -gt 0) {
				Write-Host "Added:		" $status["added"] -ForegroundColor $AddedColour
				Write-Files $status["addedFiles"] "+ " $AddedColour
			}
			if ($status["deleted"] -gt 0) {
				Write-Host "Deleted:	" $status["deleted"] -ForegroundColor $DeletedColour
				Write-Files $status["deletedFiles"] "- " $DeletedColour
			}
			if ($status["missing"] -gt 0) {
				Write-Host "Missing:	" $status["missing"]  -ForegroundColor $MissingColour
				Write-Files $status["missingFiles"] "~ " $MissingColour
			}
			if ($status["untracked"] -gt 0) {
				Write-Host "Untracked:	" $status["untracked"] -ForegroundColor $UntrackedColour
				Write-Files $status["untrackedFiles"] "? " $UntrackedColour
			}
			if ($status["other"] -gt 0) {
				Write-Host "Other:	" $status["other"] -ForegroundColor "Black"
				Write-Files $status["otherFiles"] "? " "Black"
			}
		} else {
			Write-Host "No changes found.." -ForegroundColor "Yellow"
		}
	} else {
		FriendlyError "Not a git repo!"
	}
}
set-alias st Git-Full-Status

function Git-Commit-With-Add ($msg) {
	git add -A
	git commit -a -m '' $msg ''
	Write-Host "Changes have been " -nonewline
	Write-Host "committed " -nonewline -foreground "green";
	Write-Host "with a comment of '$msg'"
}
set-alias ci Git-Commit-With-Add

function Git-Push {
	git push
}
set-alias push Git-Push

function Git-Pull {
	git pull
}
set-alias pull Git-Pull

function Git-Merge ($branch) {
	git merge $branch
	# Only commit if no conflicts
	#$msg = "Merged '$branch' into branch"
	#Git-Commit-With-Add $msg
}

function Git-Revert-All-No-Backup {
	if(confirmAction) {
		git reset --hard
	} else {
		FriendlyError "Revert cancelled!"
	}
}
set-alias rev Git-Revert-All-No-Backup

function Git-Stash {
	git stash
}
set-alias stash Git-Stash

function Git-Pop {
	git stash apply
}
set-alias pop Git-Pop

function Git-Repo-Explorer {
	. "C:\Users\AnthonyWard\AppData\Local\SourceTree\SourceTree.exe"
}


# Helpers #

function confirmAction {
	$question = 'Are you sure you want to proceed?'
	$choices  = '&Yes', '&No'

	$decision = $Host.UI.PromptForChoice('', $question, $choices, 1)
	if ($decision -eq 0) {
		return $true
	} else {
		return $false
	}
}

function Write-Files ($files, $token, $colour) {
	$files | foreach {
		Write-Host $token $_ -ForegroundColor $colour
	}
}
