function Disconnect-ARSession {
    [CmdletBinding()]
    [OutputType('System.Void')]
    Param()

    begin {
        $functionName = $MyInvocation.MyCommand.Name
        Write-Verbose "[${functionName}] Function started"
    }

    process {
        $classObject = Get-ARClass -Name "ARCimSession" 
        $classObject.Remove()
    }

    end {
        Write-Verbose "[${functionName}] Complete"
    }
}