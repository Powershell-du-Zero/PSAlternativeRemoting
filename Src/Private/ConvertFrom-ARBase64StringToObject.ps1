function ConvertFrom-ARBase64ToObject {
    [CmdletBinding()]
    param
    (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('string')]
        [System.String]$inputString
    )
    $data = [System.convert]::FromBase64String($inputString)
    $memoryStream = [System.Io.MemoryStream]::new()
    $memoryStream.write($data, 0, $data.length)
    $memoryStream.seek(0, 0) | Out-Null
    $streamReader = [System.IO.StreamReader]::new([System.IO.Compression.GZipStream]::new($memoryStream, [System.IO.Compression.CompressionMode]::Decompress))
    $decompressedData = ConvertFrom-ARCliXml ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($($streamReader.readtoend()))))
    return $decompressedData
}