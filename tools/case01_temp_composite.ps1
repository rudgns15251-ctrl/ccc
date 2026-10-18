[CmdletBinding()]
param(
    [string]$Root = (Get-Location).Path,
    [string]$OutDir = ""
)

# TEMP / REPLACEABLE Case 01 frames for the playtest slice only.
# No creature image exists yet: a flat, clearly artificial silhouette is drawn into the user-supplied
# M5-A standard room. Not evidence and not a creature design; replace the PNGs when authored art exists.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $Root).Path
if (-not $OutDir) { $OutDir = Join-Path $root 'assets\temp\case01\generated' }
$roomPath = Join-Path $root 'assets\temp\m5_a\environment\temp_environment_reference.png'
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$OutDir = (Resolve-Path -LiteralPath $OutDir).Path
Add-Type -AssemblyName System.Drawing

function New-Frame([double]$brightness, [double]$contrast, [double[]]$tint) {
    $src = [System.Drawing.Bitmap]::FromFile($roomPath)
    $bmp = [System.Drawing.Bitmap]::new($src.Width, $src.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $t = (1.0 - $contrast) / 2.0 + $brightness
    $m = [System.Drawing.Imaging.ColorMatrix]::new()
    $m.Matrix00 = [single]($contrast * $tint[0]); $m.Matrix11 = [single]($contrast * $tint[1]); $m.Matrix22 = [single]($contrast * $tint[2]); $m.Matrix33 = 1.0; $m.Matrix44 = 1.0
    $m.Matrix40 = [single]$t; $m.Matrix41 = [single]$t; $m.Matrix42 = [single]$t
    $attr = [System.Drawing.Imaging.ImageAttributes]::new()
    $attr.SetColorMatrix($m)
    $g.DrawImage($src, [System.Drawing.Rectangle]::new(0, 0, $src.Width, $src.Height), 0, 0, $src.Width, $src.Height, [System.Drawing.GraphicsUnit]::Pixel, $attr)
    $src.Dispose(); $attr.Dispose()
    return @{ Bitmap = $bmp; Graphics = $g }
}

# No creature art exists, so the subject's position is only marked with a tracking reticle.
# The observed reaction is carried by the authored observation text, never by a drawn figure.
function Add-Silhouette($g, [string]$pose) {
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    $x = 262; $y = 548; $w = 190; $h = 190; $c = 34
    $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(230, 232, 236, 228), 3)
    # corner brackets
    foreach ($corner in @(@($x, $y, 1, 1), @(($x + $w), $y, -1, 1), @($x, ($y + $h), 1, -1), @(($x + $w), ($y + $h), -1, -1))) {
        $g.DrawLine($pen, $corner[0], $corner[1], $corner[0] + $corner[2] * $c, $corner[1])
        $g.DrawLine($pen, $corner[0], $corner[1], $corner[0], $corner[1] + $corner[3] * $c)
    }
    $pen.Dispose()
    $font = [System.Drawing.Font]::new('Consolas', 15, [System.Drawing.FontStyle]::Bold)
    $bk = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
    $fg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 232, 236, 228))
    $g.FillRectangle($bk, $x, $y + $h + 8, 250, 24)
    $g.DrawString('SUBJECT 01 / NO IMAGE', $font, $fg, $x + 4, $y + $h + 10)
}

function Add-Finish($bmp, $g, [string]$osd, [int]$seed) {
    $rng = [System.Random]::new($seed)
    $line = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(26, 0, 0, 0))
    for ($y = 0; $y -lt $bmp.Height; $y += 3) { $g.FillRectangle($line, 0, $y, $bmp.Width, 1) }
    $noise = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(22, 255, 255, 255))
    for ($i = 0; $i -lt 2600; $i++) { $g.FillRectangle($noise, $rng.Next($bmp.Width), $rng.Next($bmp.Height), 2, 1) }
    $vig = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $vig.AddEllipse(-$bmp.Width * 0.2, -$bmp.Height * 0.2, $bmp.Width * 1.4, $bmp.Height * 1.4)
    $pgb = [System.Drawing.Drawing2D.PathGradientBrush]::new($vig)
    $pgb.CenterColor = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)
    $pgb.SurroundColors = @([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
    $g.FillRectangle($pgb, 0, 0, $bmp.Width, $bmp.Height)
    $font = [System.Drawing.Font]::new('Consolas', 24, [System.Drawing.FontStyle]::Bold)
    $bk = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
    $fg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 232, 236, 228))
    $g.FillRectangle($bk, 24, 20, 520, 38)
    $g.DrawString($osd, $font, $fg, 30, 22)
    $small = [System.Drawing.Font]::new('Consolas', 16, [System.Drawing.FontStyle]::Regular)
    $g.FillRectangle($bk, $bmp.Width - 470, $bmp.Height - 44, 446, 28)
    $g.DrawString('TEMP PLACEHOLDER / NOT EVIDENCE', $small, $fg, $bmp.Width - 466, $bmp.Height - 42)
}

function Save-Frame($frame, [string]$name) {
    $path = Join-Path $OutDir $name
    $frame.Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $frame.Graphics.Dispose(); $frame.Bitmap.Dispose()
    Write-Output $path
}

# 1) CCTV anchor: dim room, the subject crouches in the far shadow, away from the ceiling lamps.
$f = New-Frame -0.08 0.92 @(0.96, 1.0, 0.98)
Add-Silhouette $f.Graphics 'crouch'; Add-Finish $f.Bitmap $f.Graphics 'CAM 01-01  00:00' 11
Save-Frame $f 'case01_cctv_anchor_temp.png'

# 2) Light: the room is flooded; the subject folds up and covers the face with both arms.
$f = New-Frame 0.22 1.18 @(1.0, 1.0, 0.97)
Add-Silhouette $f.Graphics 'cover'; Add-Finish $f.Bitmap $f.Graphics 'CAM 01-01  EXP LIGHT' 21
Save-Frame $f 'case01_exp_light_temp.png'

# 3) Sound: the room is unchanged; the subject lifts its head toward the speaker only.
$f = New-Frame -0.06 0.94 @(0.96, 1.0, 0.98)
Add-Silhouette $f.Graphics 'crouch'; Add-Finish $f.Bitmap $f.Graphics 'CAM 01-01  EXP SOUND' 31
Save-Frame $f 'case01_exp_sound_temp.png'

# 4) Temperature: cold tint; no posture change is drawn beyond the crouch.
$f = New-Frame -0.04 0.96 @(0.82, 0.98, 1.12)
Add-Silhouette $f.Graphics 'crouch'; Add-Finish $f.Bitmap $f.Graphics 'CAM 01-01  EXP TEMP' 41
Save-Frame $f 'case01_exp_temp_temp.png'
