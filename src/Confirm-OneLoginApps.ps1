##Import Customer APP list
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = "$PSScriptRoot\..\example"
    Filter = 'textfile (*.txt)|*.txt'
    Title = 'Select your application list .txt file'
}

$FileBrowser.ShowDialog() | out-null

Try {
    $Customer_Apps = Get-Content $FileBrowser.FileName
} Catch {
    Throw "Could not get content from file $($FileBrowser.FileName)"
}

##Import App Catalog
Try {
    $App_Catalogue = Import-Csv "$PSScriptRoot\OneLogin_Application_List.csv"
} Catch {
    Throw "The OneLogin_Application_List.csv file was not found in the directory - $PSScriptRoot`r`n$_"
}

$AppOutput = ForEach ($App in $Customer_Apps)
    {
        $AppMatch = $App_Catalogue | Where-Object {$_.APP -match $App}
        
        $AppData = [PSCustomObject][Ordered]@{
            App = $App
            Catalogue = "N/A"
            Protocol = "N/A"
        }

        ##If application is found in catalog it grabs the app and it's protocols   
        If ($AppMatch) {

            $AppData = [PSCustomObject][Ordered]@{
                App = (@($App) | Out-String).Trim()
                Catalogue = (@($AppMatch.APP) | Out-String).Trim()
                Protocol = (@($AppMatch.Protocol) | Out-String).Trim()
            }  
        }

        $AppData
        
    }

##Exports Array to CSV
$FileDate = Get-Date -Format "yyyy-MM-ddTHH-mm-ss-ff"
$File = "$PSScriptRoot\..\results\$($FileDate)_Report.csv"
$AppOutput | Export-Csv -Path $File -NoTypeInformation

Invoke-Item -Path $File
