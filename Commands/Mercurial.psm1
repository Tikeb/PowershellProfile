# Is the current location a mercurial repo
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

function GetFull-HgStatus {
	$untracked = 0
	$added = 0
	$modified = 0
	$deleted = 0
	$missing = 0

	$output = hg status
	$branch = hg branch

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
	
	return @{"repo" = "HG ";
			"branch" = $branch;
			"untracked" = $untracked;
			"added" = $added;
			"modified" = $modified;
			"deleted" = $deleted;
			"missing" = $missing}
}
set-alias hgfst GetFull-HgStatus

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

function hg_push ($new_branch) {
	if ($new_branch) {
		hg push --new-branch
	} else {
		hg push
	}	
}
set-alias hgps hg_push

function hg_revert_all_no_backup {
	hg revert --all --no-backup
}
set-alias hgrev hg_revert_all_no_backup

function hg_purge {
	hg purge
}
set-alias hgpur hg_purge

function hg_commit_with_add ($msg, $push) {
	hg ci -Am '' $msg ''
	Write-Host "Changes have been " -nonewline
	Write-Host "committed " -nonewline -foreground "green"
	Write-Host "with a comment of :"
	Write-Host $msg -foreground "Cyan"
	
	if ($push) {
		hg_push
	}
}
set-alias hgci hg_commit_with_add

function hg_merge_and_commit ($branch) {
	$repo_status = GetFull-HgStatus
	$repo_branch = $repo_status["branch"]
	hg merge $branch
	
	$merge_commit_msg = "Merged "
	
	if ($repo_branch -eq $branch) {
		$merge_commit_msg = $merge_commit_msg + "branch"
	} else {
		$merge_commit_msg = $merge_commit_msg + $branch + " into branch"
	}
	
	hg_commit_with_add $merge_commit_msg
}
set-alias hgmer hg_merge_and_commit

function hg_update ($branch) {
	hg update $branch
}
set-alias hgup hg_update

function hg_close_branch {
	hg ci -Am 'Closed branch' --close-branch
	Write-Host "Branch closed" -foreground "Cyan"
	hg_push
	Write-Host "Branch closure pushed to host" -foreground "Cyan"
}
set-alias hgcls hg_close_branch

function hg_status {
	hg status
}
set-alias hgst hg_status

function hg_repo_explorer {
	. "C:\Program Files\TortoiseHg\thgw.exe" log
}

function hg_check_for_error ($input){
	Write-Host $input
}

#========================================#
# Start - Conversion of mercurial to git #
#========================================#

#function setupGitRepo (repo_name) {
#	$repoDir = 'git_' + repo_name
#	mkdir $repoDir
#	cd mkdir
#	git init
#}

#function createHgBookmarks () {
#	$branches = hg branches
#	$branchSuffix = _bookmark
#	
#	$branches | foreach {
#		$thisBranch = $_
#		
#		Write-Host "Bookmark created for branch: " + $thisBranch -foreground "Cyan"
#	}
#}


#======================================#
# End - Conversion of mercurial to git #
#======================================#