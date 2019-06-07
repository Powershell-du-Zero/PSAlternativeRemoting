class ARCimSession {

    [System.String]$Computername
    [pscredential]$Credential
    [CimSession]$CimSession

    [System.Void]Create([System.String]$ComputerName, [System.Management.Automation.PSCredential]$Credential) {
        
        $this.ComputerName = $ComputerName
        $this.Credential = $Credential
        
        $WSMan = Test-WSMan -ComputerName $this.ComputerName -ErrorAction SilentlyContinue
        If (($WSMan -ne $null) -and ($WSMan.ProductVersion -match 'Stack: ([3-9]|[1-9][0-9]+)\.[0-9]+')) {
            $splats = @{
                Credential    = $Credential
                ComputerName  = $ComputerName
                SessionOption = (New-CimSessionOption -Protocol Wsman)
            }
        }
        else {
            $splats = @{
                Credential    = $this.Credential
                ComputerName  = $this.ComputerName
                SessionOption = (New-CimSessionOption -Protocol Dcom)
            }
        }
        $this.CimSession = New-CimSession @splats
    }

    [System.Boolean] Test() {
        if ($this.CimSession) {
            if (Get-CimSession -Id $this.CimSession.Id -ErrorAction SilentlyContinue) {
                return $true
            }
            else {
                return $false
            }
        }
        else {
            return $false
        }
    }

    [System.Void] Remove() {
        if ($this.CimSession) {
            Remove-CimSession -Id $this.CimSession.Id
        }
    }

    [System.Void] Execute([System.String]$encodedScriptBlock) {
        if ($this.Test() -eq $true) {
            $splats = @{
                CimSession = $this.CimSession
                ClassName  = "Win32_Process"
                MethodName = "Create"
                Arguments  = @{ CommandLine = "powershell.exe (invoke-command ([scriptblock]::Create([system.text.encoding]::UTF8.GetString([System.convert]::FromBase64string('$($encodedScriptBlock)')))))" }
            }
            Invoke-CimMethod @splats
        }
        {
            throw 'Please create a CIM session before running a command'
        }
    }
}