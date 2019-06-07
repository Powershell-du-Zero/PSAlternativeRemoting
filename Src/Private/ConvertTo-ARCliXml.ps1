ConvertTo-ARCliXmlfunction ConvertTo-ARCliXml {
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