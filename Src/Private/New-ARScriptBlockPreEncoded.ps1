function New-ARScriptBlockPreEncoded {
    [CmdletBinding()]
    [OutputType('System.String')]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [System.Guid]$pipename,

        [Parameter(
            Position = 1,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.ScriptBlock]$ScriptBlock
    )

    begin {
        $functionName = $MyInvocation.MyCommand.Name
        Write-Verbose "[${functionName}] Function started"
    }

    process {
        $scriptBlockPreEncoded = [scriptblock]{
            #region support functions
            function ConvertTo-ARCliXml {
                param (
                    [Parameter(
                        Position = 0,
                        Mandatory = $true,
                        ValueFromPipeline = $true,
                        ValueFromPipelineByPropertyName = $true
                    )]
                    [ValidateNotNullOrEmpty()]
                    [PSObject[]]$InputObject
                )
                return [management.automation.psserializer]::Serialize($InputObject)
            }
    
            function ConvertTo-ARBase64StringFromObject {
                [CmdletBinding()]
                [OutputType([System.String])]
                param
                (
                    [Parameter(
                        Position = 0,
                        Mandatory = $true,
                        ValueFromPipeline = $true,
                        ValueFromPipelineByPropertyName = $true
                    )]
                    [ValidateNotNullOrEmpty()]
                    [Alias('object', 'data', 'input')]
                    [psobject]$inputObject
                )
                $tempString = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([management.automation.psserializer]::Serialize($inputObject)))
                $memoryStream = [System.IO.MemoryStream]::new()
                $compressionStream = [System.IO.Compression.GZipStream]::new($memoryStream, [System.io.compression.compressionmode]::Compress)
                $streamWriter = [System.IO.streamwriter]::new($compressionStream)
                $streamWriter.write($tempString)
                $streamWriter.close()
                $compressedData = [System.convert]::ToBase64String($memoryStream.ToArray())
                return $compressedData
            }
            #endregion
            
            #region open pipe server to send result
            $namedPipe = [System.IO.Pipes.NamedPipeServerStream]::new("<pipename>", "Out")
            $namedPipe.WaitForConnection()
            $streamWriter = [System.IO.StreamWriter]::new($namedPipe)
            $streamWriter.AutoFlush = $true
            $TempResultPreConversion = Invoke-Command -ScriptBlock { <scriptBlock> } -ErrorAction Stop
            $results = ConvertTo-ARBase64StringFromObject -inputObject $TempResultPreConversion
            $streamWriter.WriteLine("$($results)")
            $streamWriter.dispose()
            $namedPipe.dispose()
            #endregion
        }
        $scriptBlockPreEncoded = $scriptBlockPreEncoded -replace "<pipename>", $PipeName
        $scriptBlockPreEncoded = $scriptBlockPreEncoded -replace "<scriptBlock>", $ScriptBlock
        $byteCommand = [System.Text.encoding]::UTF8.GetBytes($scriptBlockPreEncoded)
        $encodedScriptBlock = [convert]::ToBase64string($byteCommand)
        return $encodedScriptBlock
    }

    end {
        Write-Verbose "[${functionName}] Complete"
    }
}