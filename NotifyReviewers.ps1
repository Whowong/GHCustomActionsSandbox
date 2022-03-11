# This script is designed to run off a PR, it will mention the reviewers with a templated message.

#PR ID
$PRID = $Env:GITHUB_EVENT_NUMBER
$ownerRepo = $Env:GITHUB_REPOSITORY


# Used for local testing
# $PRID = 1
# $ownerRepo = "Whowong/GHCustomActionsSandbox"

$URI = "https://api.github.com/repos/$ownerRepo/pulls/$PRID/requested_reviewers"

$headers = @{
    'Accept'         = "application/vnd.github.v3+json"
    'Authorization'  = "token $Env:SECRETS_GITHUB_TOKEN }}"
}

# Getting the reviewers in the PR
try {
    Write-Output "Checking $uri to get list of reviewers"
    $users = (Invoke-WebRequest -Uri $URI).content | ConvertFrom-Json
}
catch {
    Write-Error "Failed to find reviewers, this could be cause if you do not have reviewers on this PR" -ErrorAction Stop
}


$reviewers = foreach($user in $users.users)
{
    "@$($user.login)"
}

$body = @{
    'body' = "$reviewers - check it!"
}

#Adding the comment to the PR
$body = $body | ConvertTo-Json
$commentURI = "https://api.github.com/repos/$ownerRepo/issues/$PRID/comments"

Write-Output "Posting to $commentURI"

Invoke-RestMethod -Method Post -Headers $headers -Uri $commentURI -Body $body