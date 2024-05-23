# Adding necessary assembly for using Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# Initialize a queue to store file paths
$global:detectedFilesQueue = New-Object System.Collections.Generic.Queue[string]

# Define the path to the folder to monitor
$folderToWatch = "C:\Users\baciu\Desktop\World Of Conquer\All_Screenshots"
$filter = '*.*'  # Watch for all file types

# Create a FileSystemWatcher object to monitor the folder
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folderToWatch
$watcher.Filter = $filter
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true


# Initialize a list to keep track of files being processed
$global:currentlyProcessing = @{}

# Initialize a hashtable to store timestamps of last processed files
$global:lastProcessed = @{}

# Define a debounce interval in seconds
$debounceInterval = 2


# Define target directories based on file name prefix
$targetDirectories = @{
    'N' = "C:\Users\baciu\Desktop\Neo Training\Neo's Photos Diary"
    'CQ' = "C:\Users\baciu\Desktop\World Of Conquer\CQ Media Diary - Starting Mar-2024"
    'DQ' = "C:\Users\baciu\Desktop\Media\Dhamma Quotes"
    'P' = "C:\Users\baciu\Desktop\Media\Photos"
    'M' = "C:\Users\baciu\Desktop\Media"
}


# Function to display a GUI dialog for renaming the detected file
function Get-FileNameThroughDialog($message) {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Enter New Name"
    $form.AutoSize = $true
    $form.AutoSizeMode = 'GrowAndShrink'
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true  # Make the form stay on top


    $label = New-Object Windows.Forms.Label
    $label.Text = $message
    $label.Location = New-Object Drawing.Point 10,20
    $label.Size = New-Object Drawing.Size(380,60)
    $label.AutoSize = $true
    $form.Controls.Add($label)

    $textBox = New-Object Windows.Forms.TextBox
    $textBox.Location = New-Object Drawing.Point 10,80
    $textBox.Size = New-Object Drawing.Size(380,20)
    $form.Controls.Add($textBox)

    $okButton = New-Object Windows.Forms.Button
    $okButton.Location = New-Object Drawing.Point(315,110)
    $okButton.Size = New-Object Drawing.Size(75,23)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($okButton)
    $form.AcceptButton = $okButton

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $textBox.Text
    } else {
        return $null
    }
}


# Placeholder for a function to check if a file is stable
function Is-FileStable($filePath) {
    $initialSize = (Get-Item $filePath).Length
    Start-Sleep -Seconds 2
    $finalSize = (Get-Item $filePath).Length

    return $initialSize -eq $finalSize
}


# Define the action to take when a file is created
$action = {
    Param($source, $event)
    $currentTime = Get-Date
    $lastTime = $global:lastProcessed[$event.FullPath]

    # Debounce check
    if ($lastTime -eq $null -or $currentTime.Subtract($lastTime).TotalSeconds -ge $debounceInterval) {
        if (-not $global:currentlyProcessing.ContainsKey($event.FullPath)) {
            Write-Host "Event triggered for file: $($event.FullPath)"
            if (Is-FileStable $event.FullPath) {
                $global:detectedFilesQueue.Enqueue($event.FullPath)
                $global:currentlyProcessing[$event.FullPath] = $true
                Write-Host "Stable file added to Queue: $($event.FullPath)"
            } else {
                Write-Host "File not stable yet, ignoring: $($event.FullPath)"
            }
            $global:lastProcessed[$event.FullPath] = $currentTime
        }
    } else {
        Write-Host "Duplicate event ignored for file: $($event.FullPath)"
    }
}

# Register the event
$eventSubscriber = Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action

Write-Host "Monitoring $folderToWatch for new files. Press CTRL+C to exit..."

# Main loop to process files from the queue
do {
    Start-Sleep -Milliseconds 500
    while ($detectedFilesQueue.Count -gt 0) {
        $filePath = $detectedFilesQueue.Dequeue()
        $fileName = [System.IO.Path]::GetFileName($filePath)

        $newName = Get-FileNameThroughDialog "A new file has been detected ($fileName). Please enter a new name for it (without extension):"
        
        if (-not [string]::IsNullOrWhiteSpace($newName)) {
            $newPath = Join-Path -Path $folderToWatch -ChildPath ($newName + [System.IO.Path]::GetExtension($filePath))
            try {
                Rename-Item -Path $filePath -NewName $newPath -ErrorAction Stop
                Write-Host "File successfully renamed to $newPath"

                # Use regex to match newName with the convention prefix
                if ($newName -match "^(N|n|CQ|cq|DQ|dq|P|p|M|m)_") {
                    $prefix = $matches[1].ToUpper()  # Captures and standardizes the prefix
                    $cleanName = $newName -replace "^${prefix}_", ''  # Remove the prefix for the final filename

                    # Determine the target directory based on prefix
                    $targetDirectory = $targetDirectories[$prefix]
                    if ($targetDirectory) {
                        $finalName = $cleanName + [System.IO.Path]::GetExtension($newPath)
                        $finalPath = Join-Path -Path $targetDirectory -ChildPath $finalName
                        
                        Move-Item -Path $newPath -Destination $finalPath -ErrorAction Stop
                        Write-Host "File `$finalName` moved to $finalPath"
                    } else {
                        Write-Host "No target directory defined for prefix: $prefix. File will remain in its current location."
                    }
                }

            } catch {
                Write-Host "Error processing file: $($_.Exception.Message)"
            }
            $global:currentlyProcessing.Remove($filePath)
        } else {
            Write-Host "No new name provided. Skipping rename for $fileName"
            $global:currentlyProcessing.Remove($filePath)
        }
    }
} while ($true)
