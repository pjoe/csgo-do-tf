Param
(
    [parameter(Mandatory = $true)]
    [ValidateNotNull()]
    $path
)

function Exec {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$cmd
    )
    $global:lastexitcode = 0
    $result = & $cmd
    if ($global:lastexitcode -ne 0) {
        throw "Exec: $errorMessage"
    }
    return $result
}

Write-Host "path: $path"
Exec {
    &gopass show $path | ForEach-Object {
        if ($_ -match '(\w+):\s+(.+)$') {
            Write-Host "Setting $($Matches[1])"
            [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2])
        }
    }
}
Write-Host "Done"