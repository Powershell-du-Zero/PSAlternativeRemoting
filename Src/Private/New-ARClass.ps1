function New-ARClass {
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
        $Name
    )

    begin {
        $functionName = $MyInvocation.MyCommand.Name
        Write-Verbose "[${functionName}] Function started"
    }

    process {
        $classObject = New-Object -TypeName $Name
        return $classObject
    }

    end {
        Write-Verbose "[${functionName}] Complete"
    }
}