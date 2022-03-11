# This script is designed to run off a PR, it will mention the reviewers with a templated message.

# Debug Purposes Only.  Displaying All envionrment variables
dir $env
#PR ID
$PRID = $Env:GITHUB_EVENT_NUMBER
$ownerRepo = $Env:GITHUB_REPOSITORY


# Used for local testing
# $PRID = 1
# $ownerRepo = "Whowong/GHCustomActionsSandbox"

$URI = "https://api.github.com/repos/$ownerRepo/pulls/$PRID/requested_reviewers"

$headers = @{
    'content-type' = 'application/json'
    'authorization'  = "Bearer $Env:SECRETS_GITHUB_TOKEN }}"
}

Write-Output "Here are the headers: $headers"

# Local Dev Parameters
# $headers = @{
    
#     'Accept'         = "application/vnd.github.v3+json"
#     'Authorization'  = "token "
# }

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

$body = @{
    'body' = "$reviewers - check it!"
}

#Adding the comment to the PR
$body = $body | ConvertTo-Json
$commentURI = "https://api.github.com/repos/$ownerRepo/issues/$PRID/comments"

Write-Output "Posting to $commentURI"

Invoke-RestMethod -Method Post -Headers $headers -Uri $commentURI -Body $body