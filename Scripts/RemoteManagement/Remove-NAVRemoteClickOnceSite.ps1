﻿Function Remove-NAVRemoteClickOnceSite {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
        )
    PROCESS
    {
        # Prepare and Clean Up        
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                Param([PSObject]$SelectedTenant)
                $wwwRootPath = (Get-Item "HKLM:\SOFTWARE\Microsoft\InetStp").GetValue("PathWWWRoot")
                $wwwRootPath = [System.Environment]::ExpandEnvironmentVariables($wwwRootPath)

                if (!(Test-Path (Join-Path $wwwRootPath "ClickOnce"))) {
                    New-Item -Path (Join-Path $wwwRootPath "ClickOnce") -ItemType Directory | Out-Null
                }
                $ExistingWebSite = Get-Website -Name "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)"
                if ($ExistingWebSite) {
                    Write-Host "Removing old ClickOnce Site..."
                    Get-ChildItem "IIS:\SslBindings" | Where-Object -Property Sites -eq "$($SelectedTenant.ServerInstance)-$($SelectedTenant.Id)" | Remove-Item -Force
                    $ExistingWebSite | Remove-Website 
                    Remove-Item -Path $ExistingWebSite.PhysicalPath -Recurse -Force  -ErrorAction SilentlyContinue                          
                }                           
            } -ArgumentList $SelectedTenant -ErrorAction Stop
        Return $Result
    }
}
