##Import Customer APP list
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'textfile (*.txt)|*.txt'
    Title = 'Select files to open'
}
    $null = $FileBrowser.ShowDialog()

$Customer_Apps = Get-Content $FileBrowser.FileName


##Import App Catalog
$App_Catalogue = Import-Csv 'C:\Users\GTackett\OneDrive - Quest\Desktop\Project\list of app by protocol.csv'

#Establish empty array
$AppOutput = ForEach ($App in $Customer_Apps)
    {
        $AppMatch = $App_Catalogue | where {$_.APP -match $App}
##If application is found in catalog it grabs the app and it's protocols   
   
        If($AppMatch)
        { $Appy = (@($App) | Out-String).Trim()
        $Protocol = (@($AppMatch.Protocol) | Out-String).Trim()
        $Catalog = (@($AppMatch.APP) | Out-String).Trim()
##Adds APP and protocols to Array        
        New-Object PsObject -Property @{APP =$Appy;Protocol =$Protocol;Catalogue =$Catalog} 
        }
        else
##If no match, it adds App and N/A to Array
        {
        New-Object PsObject -Property @{APP =$App;Protocol ="N/A";Catalogue ="N/A"}
        }
   
    }

##Exports Array to CSV

$AppOutput | Export-Csv -Path 'C:\Users\GTackett\OneDrive - Quest\Desktop\Project\Results.csv' -NoTypeInformation
