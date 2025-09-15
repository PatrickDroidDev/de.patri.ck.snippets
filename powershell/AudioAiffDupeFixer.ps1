
  # Audio Aiff & Dupe Fixer v1.3 | 2025
  # ====================================
  # Dieses Skript liest den eingegeben Ordner rekursiv ein,
  # benennt alle .aiff dateien in .aif um! Sollte die .aif
  # bereits existieren, wird die .aiff gelöscht!
  # Vergleicht alle Dateien, ob gleiche Tracks mit einer
  # anderen Dateiendung existiert. Die übrigen Dateien
  # werden priorisiert "aif > flac > wav > mp3" und
  # jeweils die beste Datei behalten. Die schlechteren
  # werden in den Papierkorb verschoben! Gleiche Dateien
  # in verschiedenen Ordner ist erlaubt!

  $Folder = Read-Host "Bitte den Pfad zum Hauptordner mit den Audiodateien eingeben"
  if(-not(Test-Path $Folder)) {
    Write-Host "Fehler: Der Ordner '$Folder' wurde nicht gefunden!" -ForegroundColor Red
    exit
  }

  $TrashFolder = Join-Path $Folder "Papierkorb"
  if(-not(Test-Path $TrashFolder)) {
    New-Item -ItemType Directory -Path $TrashFolder | Out-Null
  }

  $Priority = @("aif","flac","wav","mp3")

  $AiffFiles = Get-ChildItem -Path $Folder -Recurse -File -Filter *.aiff
  foreach($File in $AiffFiles) {
    $NewName = [System.IO.Path]::ChangeExtension($File.FullName, ".aif")
    if(-not(Test-Path $NewName)) {
      Write-Host "Umbenennen: $($File.FullName) → $NewName" -ForegroundColor Cyan
      Rename-Item -Path $File.FullName -NewName $NewName
    } else {
      Write-Host "Lösche doppelte: $($File.FullName) (weil $NewName existiert)" -ForegroundColor Red
      Remove-Item -Path $File.FullName -Force
    }
  }

  $Files = Get-ChildItem -Path $Folder -File -Recurse | Where-Object { 
    $Priority -contains $_.Extension.TrimStart(".").ToLower() 
  }

  $Groups = $Files | Group-Object { 
    Join-Path $_.DirectoryName ([System.IO.Path]::GetFileNameWithoutExtension($_.Name)) 
  }

  foreach($Group in $Groups) {
    if($Group.Count -gt 1) {
      $Sorted = $Group.Group | Sort-Object { 
        $Priority.IndexOf($_.Extension.TrimStart(".").ToLower()) 
      }
      $Best = $Sorted[0]
      Write-Host "Behalte: $($Best.FullName)" -ForegroundColor Green
      $ToMove = $Sorted | Select-Object -Skip 1
      foreach($File in $ToMove) {
        $RelativePath = $File.FullName.Substring($Folder.Length).TrimStart("\")
        $TargetPath = Join-Path $TrashFolder $RelativePath
        $TargetDir  = Split-Path $TargetPath -Parent
        if(-not(Test-Path $TargetDir)) {
          New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        }
        Write-Host "Verschiebe: $($File.FullName) → $TargetPath" -ForegroundColor Yellow
        Move-Item -Path $File.FullName -Destination $TargetPath -Force
      }
    }
  }
