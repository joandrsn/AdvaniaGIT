﻿function Add-BlankLines
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
        [int]$NoOfLines = 10
    )
    if ($env:TERM_PROGRAM -eq $null -and $env:username -ne "ContainerAdministrator") {
        For ($i=0; $i -le $NoOfLines; $i++) { Write-Host "" }
    }
}