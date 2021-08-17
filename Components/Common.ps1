function Get-FileFromUrl {
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Url,
        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        [Alias('Folder')]
        $FolderPath,
        [Parameter(Mandatory = $false)]
        [string]
        $FileName
    )
    process {
        try {
            $result = Invoke-WebRequest -Method GET -Uri $Url -UseBasicParsing

            if (-Not $FileName) {
                $contentDisposition = $result.Headers.'Content-Disposition'
                if (-Not $contentDisposition) {
                    $FileName = $contentDisposition.Split("=")[1].Replace("`"", "")
                }
                else {
                    $FileName = Split-Path -path "$Url" -leaf
                }
            }

            if (-Not $FolderPath) {
                $DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
                $FolderPath = $DownloadsFolder
            }

            $path = Join-Path $FolderPath $FileName

            $file = [System.IO.FileStream]::new($path, [System.IO.FileMode]::Create)
            $file.write($result.Content, 0, $result.RawContentLength)
            $file.close()

            Write-Host -ForegroundColor DarkGreen "Downloaded '$Url' to '$path'"
            $path
        }
        catch {
            Write-Host -ForegroundColor DarkRed $_.Exception.Message
        }
    }
}
