function Get-ARClass {
    [CmdletBinding()]
    [OutputType('System.Object')]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ARClass]
        $Name,

        [Parameter(
            Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [System.Boolean]
        $Cache = $true
    )

    begin {
        $functionName = $MyInvocation.MyCommand.Name
        Write-Verbose "[${functionName}] Function started"
    }

    process {
        if ($Cache -eq $true) {
            $classObject = Get-Variable -Name $Name -Scope 'Script' -ValueOnly -ErrorAction SilentlyContinue
            if ($null -eq $classObject) {
                $classObject = New-ARClass -Name $Name
                Set-Variable -Name $Name -Value $classObject -Scope 'Script'
            }
            return $classObject
        }
        else {
            $classObject = New-ARClass -Name $Name
            return $classObject
        }
    }

    end {
        Write-Verbose "[${functionName}] Complete"
    }
}