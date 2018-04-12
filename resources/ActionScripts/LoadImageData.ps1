$Install = Read-Host -Prompt 'Would you like to play a game?'

If($Install -eq "Yes" -or $Install -eq "Y")
{
$setupLog = "c:\tmp\ConfigureImageSimilarity.txt"
Start-Transcript -Path $setupLog 

##Paramaters to pass to ConfigureSQL.ps1
$StartTime = Get-Date
 $Query = "SELECT SERVERPROPERTY('ServerName')"
    $ServerName  = invoke-sqlcmd -Query $Query
    $ServerName = $ServerName.Item(0)
Write-Host ("ServerName set to $ServerName")
$dbName = "ImageSimilarity_Py" 
$src = "C:\Solutions\ImageSimilarity\Data"
$dst = "\\$ServerName\MSSQLSERVER\FileTableData\ImageStore\"

$Query =    "INSERT INTO [ImageSimilarity_Py].[dbo].[query_images] VALUES (0,'C:\Solutions\ImageSimilarity\data\dotted\81.jpg')"
            # INSERT INTO [ImageSimilarity_Py].[dbo].[query_images] VALUES (0,'C:\Solutions\ImageSimilarity\data\fashionTexture\floral\2562.jpg')
            # INSERT INTO [ImageSimilarity_Py].[dbo].[query_images] VALUES (0,'C:\Solutions\ImageSimilarity\data\fashionTexture\leopard\3093.jpg')"

Invoke-Sqlcmd -ServerInstance $ServerName -Database $dbName -Query $query 


Write-Host "Copy Image Files into FileStream Table"
    Set-Location "C:\Solutions\ImageSimilarity\Data"
    Invoke-Expression ".\import_data.bat"
    $src = ".\dotted"         
    copy-item -Force -Recurse -Verbose -PassThru $src $dst -ErrorAction SilentlyContinue
    copy-item -Force -Recurse $src $dst -ErrorAction SilentlyContinue
    $src = ".\leopard"         
    copy-item -Force -Recurse -Verbose -PassThru $src $dst -ErrorAction SilentlyContinue
    copy-item -Force -Recurse $src $dst -ErrorAction SilentlyContinue
    $src = ".\striped"         
    copy-item -Force -Recurse -Verbose -PassThru $src $dst -ErrorAction SilentlyContinue
    copy-item -Force -Recurse $src $dst -ErrorAction SilentlyContinue

Write-Host " Image Files Copied to FileStream Table" 

Write-Host (" Training Model and Scoring Data...")

Set-Location "C:\Solutions\ImageSimilarity\Python"
Invoke-Expression ".\run_image_similarity.bat"

$Pyend = Get-Date

$Duration = New-TimeSpan -Start $PyStart -End $Pyend 
Write-Host ("Py Server Configured in $Duration")
Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\LoadImageData.ps1"
}
ELSE
{"Why Not?"}