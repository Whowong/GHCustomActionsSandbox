# This script is designed to run off a PR, it will mention the reviewers with a templated message.

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    $GitHubToken
)


#PR ID
$PRID = $Env:GITHUB_EVENT_NUMBER
$ownerRepo = $Env:GITHUB_REPOSITORY

$headers = @{
    'content-type' = 'application/json'
    'authorization'  = "Bearer $GitHubToken"
}

$URI = "https://api.github.com/repos/$ownerRepo/pulls/$PRID/requested_reviewers"

# Getting the reviewers in the PR
try {
    Write-Output "Checking $uri to get list of reviewers"
    $users = (Invoke-WebRequest -Uri $URI -Headers $headers).content | ConvertFrom-Json
}
catch {
    Write-Error "Failed to find reviewers, this could be cause if you do not have reviewers on this PR" -ErrorAction Stop
}


$reviewers = foreach($user in $users.users)
{
    "@$($user.login)"
}

Write-Output "Here are the reviewers we will be notifying $reviewers"


#Adding the comment to the PR
$body = @{
    'body' = "$reviewers - check it!"
}

$body = $body | ConvertTo-Json
$commentURI = "https://api.github.com/repos/$ownerRepo/issues/$PRID/comments"

Write-Output "Posting to $commentURI"

Invoke-RestMethod -Method Post -Headers $headers -Uri $commentURI -Body $body