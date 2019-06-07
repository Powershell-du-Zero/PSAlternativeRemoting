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