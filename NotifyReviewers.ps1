# This script is designed to run off a PR, it will mention the reviewers with a templated message.

#PR ID
$PRID = ${{ github.event.number }}
$ownerRepo = ${{ github.repository }}


# Used for local testing
# $PRID = 1
# $ownerRepo = "Whowong/GHCustomActionsSandbox"

$URI = "https://api.github.com/repos/$ownerRepo/pulls/$PRID/requested_reviewers"

$headers = @{
    'Accept'         = "application/vnd.github.v3+json"
    'Authorization'  = "token ${{ secrets.GITHUB_TOKEN }}"
}

# Getting the reviewers in the PR
try {
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
Invoke-RestMethod -Method Post -Headers $headers -Uri https://api.github.com/repos/$ownerRepo/issues/$PRID/comments -Body $body