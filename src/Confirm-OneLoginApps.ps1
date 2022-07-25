##Import Customer APP list
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = "$PSScriptRoot\..\example"
    Filter = 'textfile (*.txt)|*.txt'
    Title = 'Select files to open'
}
    $null = $FileBrowser.ShowDialog()

$Customer_Apps = Get-Content $FileBrowser.FileName


##Import App Catalog
Try {
    $App_Catalogue = Import-Csv "$PSScriptRoot\OneLogin_Application_List.csv"
} Catch {
    Throw "The OneLogin_Application_List.csv file was not found in the directory - $PSScriptRoot`r`n$_"
}


$AppOutput = ForEach ($App in $Customer_Apps)
    {
        $AppMatch = $App_Catalogue | Where-Object {$_.APP -match $App}
        
        ##If application is found in catalog it grabs the app and it's protocols   
        If ($AppMatch) {
            $Appy = (@($App) | Out-String).Trim()
            $Protocol = (@($AppMatch.Protocol) | Out-String).Trim()
            $Catalog = (@($AppMatch.APP) | Out-String).Trim()
               
            New-Object PsObject -Property @{APP =$Appy;Protocol =$Protocol;Catalogue =$Catalog} 
        }
        ##If no match, it adds App and N/A to Array
        Else {
            New-Object PsObject -Property @{APP =$App;Protocol ="N/A";Catalogue ="N/A"}
        }
   
    }

##Exports Array to CSV
$FileDate = Get-Date -Format "yyyy-MM-ddTHH-mm-ss-ff"
$AppOutput | Export-Csv -Path "$PSScriptRoot\..\out\$($FileDate)_Report.csv" -NoTypeInformation