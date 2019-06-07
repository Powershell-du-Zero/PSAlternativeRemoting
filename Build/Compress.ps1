$ProjectPath = (Get-Item $($MyInvocation.MyCommand.Path)).Directory.Parent.FullName

#region copy source
New-Item -Path (Join-Path -Path $ProjectPath -ChildPath 'Build\Artifact\') -ItemType Directory -ErrorAction SilentlyContinue
Remove-Item -Path (Join-Path -Path $ProjectPath -ChildPath 'Build\Artifact\') -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path (Join-Path -Path $ProjectPath -ChildPath 'Src\') -Destination (Join-Path -Path $ProjectPath -ChildPath 'Build\Artifact') -Recurse -Force
#endregion

#region Write all Powershell classes/functions in the script root file
Write-Output '- Write all Powershell classes/functions in the script root file'
$sources = [System.Collections.Generic.Dictionary[string, string]]::new()
$sources.Add("Library - Enum", [System.IO.Path]::Combine($ProjectPath, "Src\Lib\Enum\*.ps1"))
$sources.Add("Library - Class", [System.IO.Path]::Combine($ProjectPath, "Src\Lib\Class\*.ps1"))
$sources.Add("Function - Private", [System.IO.Path]::Combine($ProjectPath, "Src\Private\*.ps1"))
$sources.Add("Function - Public", [System.IO.Path]::Combine($ProjectPath, "Src\Public\*.ps1"))

$stream = [System.IO.StreamWriter]::new([System.IO.Path]::Combine($ProjectPath, "Build\Artifact\PSAlternativeRemoting.psm1"))
foreach ($source in $sources.GetEnumerator()) {
    # Add a type delimiter
    $stream.WriteLine("# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
    $stream.WriteLine("# + $($source.Key)")
    $stream.WriteLine("# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")

    # Write script root file
    $Files = @( Get-ChildItem -Path $source.Value -Recurse -ErrorAction Stop )
    foreach ($file in $files) {
        Write-Output "`t- $($file.FullName)"
        $stream.WriteLine([System.IO.File]::ReadAllText($file.FullName))
    }
}
$stream.close()
#endregion

#region Remove all unnecessary files/folders
Write-Output '- Remove all unnecessary files/folders'
Remove-Item -Path ([System.IO.Path]::Combine($ProjectPath, "Build\Artifact\Lib\")) -Recurse -Confirm:$false -Force
Remove-Item -Path ([System.IO.Path]::Combine($ProjectPath, "Build\Artifact\Private\")) -Recurse -Confirm:$false -Force
Remove-Item -Path ([System.IO.Path]::Combine($ProjectPath, "Build\Artifact\Public\")) -Recurse -Confirm:$false -Force
