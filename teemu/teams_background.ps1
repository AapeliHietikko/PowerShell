$detectionFiles = "$env:appdata\Microsoft\Teams\Backgrounds\Uploads\20200425_151834.jpg","$env:appdata\Microsoft\Teams\Backgrounds\Uploads\20200425_151924.jpg"

foreach ($detectionFile in $detectionFiles)
{
    if (-not (test-path $detectionFile)) {
        
        $filename = $detectionFile.split('\')[-1]
        copy-item "c:\temp\$filename" $detectionFile

    }
}
