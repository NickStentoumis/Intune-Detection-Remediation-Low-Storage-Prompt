function DisplayToastNotification() 
{
    #Load Classes
    $Load = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    $Load = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
   
    # Load the notification into the required format
    $ToastXML = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
    $ToastXML.LoadXml($Toast.OuterXml)

    # Display the toast notification
    try 
    {
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Company Name").Show($ToastXML)
        
        [String]$Errormsg = $_.Exception
    }
    catch 
    { 
        Write-Output -Message 'Something went wrong when displaying the toast notification' -Level Warn
        Write-Output -Message 'Make sure the script is running as the logged on user' -Level Warn 

        $ErrorMsg = $_.Exception.Message
        Write-Error $ErrorMsg 
    }
}

#Key And Value To Search For In Regisrty
$KeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$ValueName = "AppsUseLightTheme"

try 
{
    Write-Host "$(Get-Date) Checking If Light Or Dark Theme Is Used Is Enabled"
    $ValueData = (Get-ItemProperty -Path $KeyPath -Name $valueName -ErrorAction Stop).$ValueName

    If($ValueData -eq 0)
    {
        Write-Host "$(Get-Date) Dark is The Default Theme"
        Write-Host "$(Get-Date) Downloading Logo"

        # Setting image variables
        $TempLogoImage = "$env:TEMP\ToastLogoImage.png"
        $LogoImage = "https://yourstorageaccount.blob.core.windows.net/container/DarkThemeLogo.png"
        Invoke-WebRequest -Uri $LogoImage -OutFile $TempLogoImage
    }
    else 
    {
        Write-Host "$(Get-Date) Light is The Default Theme"
        Write-Host "$(Get-Date) Downloading Logo"
        
        # Setting image variables
        $TempLogoImage = "$env:TEMP\ToastLogoImage.png"
        $LogoImage = "https://yourstorageaccount.blob.core.windows.net/container/LightThemeLogo.png"

        Invoke-WebRequest -Uri $LogoImage -OutFile $TempLogoImage
    }
}
catch [System.Management.Automation.PSArgumentException]
{
    Write-Host "$(Get-Date) $Valuename Does Not Exist, Going To Use Image For Light Theme"
    Write-Host "$(Get-Date) Downloading Logo"
        
    # Setting image variables
    $TempLogoImage = "$env:TEMP\ToastLogoImage.png"
    $LogoImage = "https://yourstorageaccount.blob.core.windows.net/container/LightThemeLogo.png"

    Invoke-WebRequest -Uri $LogoImage -OutFile $TempLogoImage

}
catch [System.Management.Automation.ItemNotFoundException]
{
    Write-Host "$(Get-Date) Regisrty Key Does Not Exist, Going To Use Image For Light Theme"
    Write-Host "$(Get-Date) Downloading Logo"
        
    # Setting image variables
    $TempLogoImage = "$env:TEMP\ToastLogoImage.png"
    $LogoImage = "https://yourstorageaccount.blob.core.windows.net/container/LightThemeLogo.png"
    Invoke-WebRequest -Uri $LogoImage -OutFile $TempLogoImage
}
catch
{
    Write-Host "$(Get-Date) An Error Occured While Attempting To Get Regisrty Value. Going To Use Image For Light Theme"
    Write-Host "$(Get-Date) Downloading Logo"
        
    # Setting image variables
    $TempLogoImage = "$env:TEMP\ToastLogoImage.png"
    $LogoImage = "https://yourstorageaccount.blob.core.windows.net/container/LightThemeLogo.png"
    Invoke-WebRequest -Uri $LogoImage -OutFile $TempLogoImage
}

#ToastNotification Settings
$Scenario = 'reminder' # <!-- Possible values are: reminder | short | long -->
        

#Get free space on disk
try
{
    $disk = get-volume -ErrorAction Stop | where {$_.DriveLetter -eq "C"} #get the disk we want
    $FreeSpace = [math]::Round($disk.SizeRemaining / 1GB, 2) #convert the size to GB
}
catch
{
        Write-Host "Error On Get-Volume"
        $ErrorMsg = $_.Exception.Message
        Write-Error $ErrorMsg
        $current_date = Get-Date
}
# Load Toast Notification text
$BodyText1 = "Ο τοπικός δίσκος C είναι σχεδόν γεμάτος. Θα χρειαστεί να διαγράψετε αρχεία που δε χρησιμοποιείτε."
$BodyText2 = "Προτεινόμενος ελεύθερος χώρος 20GB"
$BodyText3 = "Ελεύθερος χώρος συσκευής: $FreeSpace GB"

# Formatting the toast notification XML
[xml]$Toast = @"
<toast scenario="$Scenario">
    <visual>
    <binding template="ToastImageAndText01">
        <image id="1" placement="appLogoOverride"  src="$TempLogoImage"/>
        <text id="1">$BodyText1</text>
        <text id="1">$BodyText2 </text>
        <text placement="attribution">$BodyText3</text>
    </binding>
    </visual>
    <actions>
        <action activationType="system" arguments="dismiss" content="$DismissButtonContent"/>
    </actions>
</toast>
"@

#Send the notification
DisplayToastNotification
Exit 0