param(
    [Parameter(Mandatory = $true)] [string]$ReferencePath,
    [Parameter(Mandatory = $true)] [string]$SpecPath,
    [Parameter(Mandatory = $true)] [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Get-PixelHash {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [int]$X = 0,
        [int]$Y = 0,
        [int]$Width = 0,
        [int]$Height = 0
    )
    if ($Width -le 0) { $Width = $Bitmap.Width }
    if ($Height -le 0) { $Height = $Bitmap.Height }
    $rect = New-Object System.Drawing.Rectangle($X, $Y, $Width, $Height)
    $data = $Bitmap.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $rowBytes = $Width * 4
        $length = $rowBytes * $Height
        $bytes = New-Object byte[] $length
        for ($row = 0; $row -lt $Height; $row++) {
            $sourceRow = if ($data.Stride -ge 0) { $row } else { $Height - 1 - $row }
            $sourcePtr = [IntPtr]::Add($data.Scan0, $sourceRow * [Math]::Abs($data.Stride))
            [System.Runtime.InteropServices.Marshal]::Copy($sourcePtr, $bytes, $row * $rowBytes, $rowBytes)
        }
        $sha = [System.Security.Cryptography.SHA256]::Create()
        try { return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant() }
        finally { $sha.Dispose() }
    } finally { $Bitmap.UnlockBits($data) }
}

function Copy-PixelsExact {
    param(
        [System.Drawing.Bitmap]$Source,
        [System.Drawing.Bitmap]$Destination,
        [int]$DestinationX,
        [int]$DestinationY
    )
    $sourceRect = New-Object System.Drawing.Rectangle(0, 0, $Source.Width, $Source.Height)
    $destinationRect = New-Object System.Drawing.Rectangle($DestinationX, $DestinationY, $Source.Width, $Source.Height)
    $sourceData = $Source.LockBits($sourceRect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $destinationData = $Destination.LockBits($destinationRect, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $rowBytes = $Source.Width * 4
        $rowBuffer = New-Object byte[] $rowBytes
        for ($row = 0; $row -lt $Source.Height; $row++) {
            $sourceRow = if ($sourceData.Stride -ge 0) { $row } else { $Source.Height - 1 - $row }
            $destinationRow = if ($destinationData.Stride -ge 0) { $row } else { $Source.Height - 1 - $row }
            $sourcePtr = [IntPtr]::Add($sourceData.Scan0, $sourceRow * [Math]::Abs($sourceData.Stride))
            $destinationPtr = [IntPtr]::Add($destinationData.Scan0, $destinationRow * [Math]::Abs($destinationData.Stride))
            [System.Runtime.InteropServices.Marshal]::Copy($sourcePtr, $rowBuffer, 0, $rowBytes)
            [System.Runtime.InteropServices.Marshal]::Copy($rowBuffer, 0, $destinationPtr, $rowBytes)
        }
    } finally {
        $Destination.UnlockBits($destinationData)
        $Source.UnlockBits($sourceData)
    }
}

function Draw-TextBlock {
    param(
        [System.Drawing.Graphics]$Graphics,
        [string]$Text,
        [System.Drawing.Font]$Font,
        [System.Drawing.Brush]$Brush,
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$MaxHeight = 1000
    )
    if ([string]::IsNullOrWhiteSpace($Text)) { return 0 }
    $format = New-Object System.Drawing.StringFormat
    try {
        $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
        $rect = New-Object System.Drawing.RectangleF($X, $Y, $Width, $MaxHeight)
        $size = $Graphics.MeasureString($Text, $Font, [int]$Width, $format)
        $Graphics.DrawString($Text, $Font, $Brush, $rect, $format)
        return [Math]::Ceiling($size.Height)
    } finally { $format.Dispose() }
}

$referenceFull = [System.IO.Path]::GetFullPath($ReferencePath)
$specFull = [System.IO.Path]::GetFullPath($SpecPath)
$outputFull = [System.IO.Path]::GetFullPath($OutputPath)

if (-not (Test-Path -LiteralPath $referenceFull -PathType Leaf)) { throw "Reference image not found: $referenceFull" }
if (-not (Test-Path -LiteralPath $specFull -PathType Leaf)) { throw "Deconstruction spec not found: $specFull" }
if ([System.IO.Path]::GetExtension($outputFull).ToLowerInvariant() -ne '.png') { throw 'OutputPath must end with .png' }
if ($referenceFull -eq $outputFull) { throw 'OutputPath must not overwrite the reference image.' }

$outputDirectory = Split-Path -Parent $outputFull
if (-not (Test-Path -LiteralPath $outputDirectory)) { New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null }

$spec = Get-Content -LiteralPath $specFull -Raw -Encoding UTF8 | ConvertFrom-Json
$sourceBitmap = $null
$board = $null
$graphics = $null

try {
    $sourceBitmap = New-Object System.Drawing.Bitmap($referenceFull)
    $sourceHash = Get-PixelHash -Bitmap $sourceBitmap

    $margin = 40
    $headerHeight = 92
    $panelGap = 36
    $panelWidth = [Math]::Max(620, [Math]::Min(900, [int]($sourceBitmap.Width * 0.62)))
    $boardWidth = $margin + $sourceBitmap.Width + $panelGap + $panelWidth + $margin
    $boardHeight = [Math]::Max($sourceBitmap.Height + $headerHeight + ($margin * 2), 1180)
    $sourceX = $margin
    $sourceY = $headerHeight + $margin
    $panelX = $sourceX + $sourceBitmap.Width + $panelGap
    $panelY = $sourceY

    $board = New-Object System.Drawing.Bitmap($boardWidth, $boardHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($board)
    $graphics.Clear([System.Drawing.Color]::FromArgb(255, 22, 19, 17))
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $cream = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 246, 226, 190))
    $muted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 196, 174, 143))
    $accent = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 170, 60))
    $panelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 43, 34, 29))
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 121, 86, 56), 2)
    $accentPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 170, 60), 3)
    $titleFont = New-Object System.Drawing.Font('Microsoft YaHei UI', 26, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $sectionFont = New-Object System.Drawing.Font('Microsoft YaHei UI', 21, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $bodyFont = New-Object System.Drawing.Font('Microsoft YaHei UI', 17, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $smallFont = New-Object System.Drawing.Font('Microsoft YaHei UI', 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

    try {
        $title = if ($spec.title) { [string]$spec.title } else { '视觉拆解图' }
        $graphics.DrawString($title, $titleFont, $cream, $margin, 30)
        $graphics.DrawString('SOURCE IMAGE — UNCHANGED 1:1', $smallFont, $muted, $margin, $sourceY - 26)
        $graphics.FillRectangle($panelBrush, $panelX - 18, $panelY - 18, $panelWidth + 36, $boardHeight - $panelY - $margin + 18)
        $graphics.DrawRectangle($borderPen, $sourceX - 1, $sourceY - 1, $sourceBitmap.Width + 1, $sourceBitmap.Height + 1)

        $y = [float]$panelY
        $graphics.DrawString('视觉公式', $sectionFont, $accent, $panelX, $y)
        $y += 34
        $height = Draw-TextBlock -Graphics $graphics -Text ([string]$spec.style_summary) -Font $bodyFont -Brush $cream -X $panelX -Y $y -Width $panelWidth
        $y += $height + 30

        if ($spec.zones -and $spec.zones.Count -gt 0) {
            $graphics.DrawString('结构区域', $sectionFont, $accent, $panelX, $y)
            $y += 38
            $index = 1
            foreach ($zone in $spec.zones | Select-Object -First 5) {
                $circleRect = New-Object System.Drawing.RectangleF($panelX, $y, 30, 30)
                $graphics.FillEllipse($accent, $circleRect)
                $numberFormat = New-Object System.Drawing.StringFormat
                try {
                    $numberFormat.Alignment = [System.Drawing.StringAlignment]::Center
                    $numberFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
                    $graphics.DrawString(('{0:d2}' -f $index), $smallFont, [System.Drawing.Brushes]::Black, $circleRect, $numberFormat)
                } finally { $numberFormat.Dispose() }
                $zoneText = "{0}`n{1}" -f [string]$zone.label, [string]$zone.description
                $zoneHeight = Draw-TextBlock -Graphics $graphics -Text $zoneText -Font $bodyFont -Brush $cream -X ($panelX + 42) -Y $y -Width ($panelWidth - 42) -MaxHeight 130
                $y += [Math]::Max(44, $zoneHeight + 14)
                $index++
            }
            $y += 16
        }

        if ($spec.eye_path) {
            $graphics.DrawString('视觉动线', $sectionFont, $accent, $panelX, $y)
            $y += 34
            $height = Draw-TextBlock -Graphics $graphics -Text ([string]$spec.eye_path) -Font $bodyFont -Brush $cream -X $panelX -Y $y -Width $panelWidth
            $y += $height + 26
        }

        if ($spec.colour_roles -and $spec.colour_roles.Count -gt 0) {
            $graphics.DrawString('色彩角色', $sectionFont, $accent, $panelX, $y)
            $y += 36
            foreach ($role in $spec.colour_roles | Select-Object -First 5) {
                $swatchBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml([string]$role.hex))
                try { $graphics.FillEllipse($swatchBrush, $panelX, $y + 2, 26, 26) }
                finally { $swatchBrush.Dispose() }
                $graphics.DrawString(([string]$role.label), $bodyFont, $cream, $panelX + 38, $y)
                $y += 36
            }
            $y += 18
        }

        if ($spec.transferable_formula) {
            $graphics.DrawString('可迁移公式', $sectionFont, $accent, $panelX, $y)
            $y += 36
            Draw-TextBlock -Graphics $graphics -Text ([string]$spec.transferable_formula) -Font $bodyFont -Brush $cream -X $panelX -Y $y -Width $panelWidth | Out-Null
        }

        $graphics.DrawLine($accentPen, $panelX, $boardHeight - $margin - 28, $panelX + 130, $boardHeight - $margin - 28)
        $graphics.DrawString('结构指南，不是风格替代图', $smallFont, $muted, $panelX + 145, $boardHeight - $margin - 42)
    } finally {
        $cream.Dispose(); $muted.Dispose(); $accent.Dispose(); $panelBrush.Dispose()
        $borderPen.Dispose(); $accentPen.Dispose()
        $titleFont.Dispose(); $sectionFont.Dispose(); $bodyFont.Dispose(); $smallFont.Dispose()
    }

    $graphics.Dispose()
    $graphics = $null
    Copy-PixelsExact -Source $sourceBitmap -Destination $board -DestinationX $sourceX -DestinationY $sourceY
    $board.Save($outputFull, [System.Drawing.Imaging.ImageFormat]::Png)

    $savedBoard = New-Object System.Drawing.Bitmap($outputFull)
    try {
        $embeddedHash = Get-PixelHash -Bitmap $savedBoard -X $sourceX -Y $sourceY -Width $sourceBitmap.Width -Height $sourceBitmap.Height
    } finally { $savedBoard.Dispose() }

    $integrityPath = [System.IO.Path]::ChangeExtension($outputFull, '.integrity.json')
    $report = [ordered]@{
        schema_version = '1.0'
        composition_method = 'side-by-side-canvas'
        reference_path = $referenceFull
        output_path = $outputFull
        source_width = $sourceBitmap.Width
        source_height = $sourceBitmap.Height
        source_rectangle = [ordered]@{ x = $sourceX; y = $sourceY; width = $sourceBitmap.Width; height = $sourceBitmap.Height }
        source_pixel_sha256 = $sourceHash
        embedded_pixel_sha256 = $embeddedHash
        pixel_integrity_exact = ($sourceHash -eq $embeddedHash)
        original_crop_preserved = $true
        annotations_overlap_source = $false
    }
    $report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $integrityPath -Encoding UTF8
    if (-not $report.pixel_integrity_exact) { throw "Pixel integrity verification failed. See $integrityPath" }

    Write-Output "Board: $outputFull"
    Write-Output "Integrity: $integrityPath"
    Write-Output "Pixel SHA-256: $sourceHash"
} finally {
    if ($graphics) { $graphics.Dispose() }
    if ($board) { $board.Dispose() }
    if ($sourceBitmap) { $sourceBitmap.Dispose() }
}
