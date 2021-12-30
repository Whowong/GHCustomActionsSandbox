$name = $Env:INPUT_WHO_TO_GREET
$message = "Hello $name"
Write-Output "$message, this is a standard output"

Write-Output "::set-output name=GREETING::$message"
