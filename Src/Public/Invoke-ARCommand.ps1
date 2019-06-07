function Invoke-ARCommand {
    [CmdletBinding()]
    [OutputType('System.Void')]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [System.Guid]$PipeName = [System.Guid]::NewGuid(),

        [Parameter(
            Position = 1,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.ScriptBlock]$ScriptBlock,

        [Parameter(
            Position = 4,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateRange(1000, 900000)]
        [System.UInt32]$Timeout = 120000
    )

    begin {
        $functionName = $MyInvocation.MyCommand.Name
        Write-Verbose "[${functionName}] Function started"
    }

    process {
        $classObject = Get-ARClass -Name "ARCimSession"
        $encodedScriptBlock = New-ARScriptBlockPreEncoded -pipename $PipeName -ScriptBlock $ScriptBlock
        $classObject.Execute($encodedScriptBlock)

        $namedPipe = New-Object System.IO.Pipes.NamedPipeClientStream $classObject.Computername, "$($PipeName)", "In"
        $namedPipe.connect($timeout)
        $streamReader = New-Object System.IO.StreamReader $namedPipe
        while ($null -ne ($data = $streamReader.ReadLine()))
        {
            $tempData = $data
        }
        
        $streamReader.dispose()
        $namedPipe.dispose()
        ConvertFrom-ARBase64ToObject -inputString $tempData
    }

    end {
        Write-Verbose "[${functionName}] Complete"
    }
}

