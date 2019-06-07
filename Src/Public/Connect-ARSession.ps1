function Connect-ARSession {
    [CmdletBinding()]
    [OutputType('System.Void')]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]$ComputerName,

        [Parameter(
            Position = 1,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential
    )

    begin {
        $functionName = $MyInvocation.MyCommand.Name
        Write-Verbose "[${functionName}] Function started"
    }

    process {
        $classObject = Get-ARClass -Name "ARCimSession"
        $classObject.Create($ComputerName, $Credential)
    }

    end {
        Write-Verbose "[${functionName}] Complete"
    }
}