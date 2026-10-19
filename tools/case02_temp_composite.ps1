[CmdletBinding()]
param(
    [string]$Root = (Get-Location).Path,
    [string]$OutDir = ""
)

# TEMP / REPLACEABLE Case 02 (SC-01) frames for the playtest slice only.
# Composites the user-supplied SC-01 master image onto the user-supplied M5-A standard room.
# Not evidence and not a final design: replace the PNGs when authored images exist.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $Root).Path
if (-not $OutDir) { $OutDir = Join-Path $root 'assets\temp\case02\generated' }
$masterPath = Join-Path $root 'assets\temp\case02\sc01_master_reference.png'
$roomPath = Join-Path $root 'assets\temp\m5_a\environment\temp_environment_reference.png'
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$OutDir = (Resolve-Path -LiteralPath $OutDir).Path

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class T04Composite
{
    static byte[] Read(Bitmap bmp)
    {
        var data = bmp.LockBits(new Rectangle(0, 0, bmp.Width, bmp.Height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
        var bytes = new byte[data.Stride * bmp.Height];
        Marshal.Copy(data.Scan0, bytes, 0, bytes.Length);
        bmp.UnlockBits(data);
        return bytes;
    }

    static Bitmap Write(byte[] bytes, int w, int h)
    {
        var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb);
        var data = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
        Marshal.Copy(bytes, 0, data.Scan0, bytes.Length);
        bmp.UnlockBits(data);
        return bmp;
    }

    // Removes only the studio backdrop connected to the image border, so pale faces stay opaque.
    public static Bitmap Cutout(string path, int tolerance)
    {
        Bitmap src;
        using (var raw = new Bitmap(path)) src = raw.Clone(new Rectangle(0, 0, raw.Width, raw.Height), PixelFormat.Format32bppArgb);
        int w = src.Width, h = src.Height;
        var px = Read(src);
        src.Dispose();
        double bg = 0; int n = 0;
        for (int x = 0; x < w; x++) { bg += Lum(px, (x) * 4); bg += Lum(px, ((h - 1) * w + x) * 4); n += 2; }
        bg /= n;
        var isBg = new bool[w * h];
        var queue = new Queue<int>();
        Func<int, bool> backdrop = i => Lum(px, i * 4) > 70 && Lum(px, i * 4) < 215 && Sat(px, i * 4) < 22;
        for (int x = 0; x < w; x++) { Seed(x, isBg, queue, backdrop); Seed((h - 1) * w + x, isBg, queue, backdrop); }
        for (int y = 0; y < h; y++) { Seed(y * w, isBg, queue, backdrop); Seed(y * w + w - 1, isBg, queue, backdrop); }
        while (queue.Count > 0)
        {
            int i = queue.Dequeue(), x = i % w, y = i / w;
            if (x > 0 && Math.Abs(Lum(px, (i - 1) * 4) - Lum(px, i * 4)) < tolerance) Seed(i - 1, isBg, queue, backdrop);
            if (x < w - 1 && Math.Abs(Lum(px, (i + 1) * 4) - Lum(px, i * 4)) < tolerance) Seed(i + 1, isBg, queue, backdrop);
            if (y > 0 && Math.Abs(Lum(px, (i - w) * 4) - Lum(px, i * 4)) < tolerance) Seed(i - w, isBg, queue, backdrop);
            if (y < h - 1 && Math.Abs(Lum(px, (i + w) * 4) - Lum(px, i * 4)) < tolerance) Seed(i + w, isBg, queue, backdrop);
        }
        // Enclosed pockets (between crossed arms / necks) are neutral grey like the backdrop;
        // the pale faces are warmer and brighter, so they are kept.
        var seen = new bool[w * h];
        for (int s = 0; s < w * h; s++)
        {
            if (isBg[s] || seen[s] || !backdrop(s)) continue;
            var comp = new List<int>();
            seen[s] = true; queue.Enqueue(s);
            double lumSum = 0, satSum = 0;
            while (queue.Count > 0)
            {
                int i = queue.Dequeue(), x = i % w, y = i / w;
                comp.Add(i); lumSum += Lum(px, i * 4); satSum += Sat(px, i * 4);
                int[] next = { x > 0 ? i - 1 : -1, x < w - 1 ? i + 1 : -1, y > 0 ? i - w : -1, y < h - 1 ? i + w : -1 };
                foreach (int j in next)
                    if (j >= 0 && !seen[j] && !isBg[j] && backdrop(j)) { seen[j] = true; queue.Enqueue(j); }
            }
            if (comp.Count > 200 && satSum / comp.Count < 5 && lumSum / comp.Count < 218)
                foreach (int i in comp) isBg[i] = true;
        }
        // Erode 2px to drop the light fringe, then soften the edge.
        var alpha = new float[w * h];
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++)
            {
                bool keep = !isBg[y * w + x];
                for (int dy = -2; dy <= 2 && keep; dy++)
                    for (int dx = -2; dx <= 2 && keep; dx++)
                    {
                        int xx = x + dx, yy = y + dy;
                        if (xx >= 0 && yy >= 0 && xx < w && yy < h && isBg[yy * w + xx]) keep = false;
                    }
                alpha[y * w + x] = keep ? 1f : 0f;
            }
        var soft = new float[w * h];
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++)
            {
                float sum = 0; int c = 0;
                for (int dy = -1; dy <= 1; dy++)
                    for (int dx = -1; dx <= 1; dx++)
                    {
                        int xx = x + dx, yy = y + dy;
                        if (xx >= 0 && yy >= 0 && xx < w && yy < h) { sum += alpha[yy * w + xx]; c++; }
                    }
                soft[y * w + x] = sum / c;
            }
        for (int i = 0; i < w * h; i++) px[i * 4 + 3] = (byte)(255 * soft[i]);
        return Write(px, w, h);
    }

    static void Seed(int i, bool[] isBg, Queue<int> q, Func<int, bool> backdrop)
    {
        if (!isBg[i] && backdrop(i)) { isBg[i] = true; q.Enqueue(i); }
    }

    static double Lum(byte[] p, int o) { return 0.114 * p[o] + 0.587 * p[o + 1] + 0.299 * p[o + 2]; }
    static int Sat(byte[] p, int o) { return Math.Max(p[o], Math.Max(p[o + 1], p[o + 2])) - Math.Min(p[o], Math.Min(p[o + 1], p[o + 2])); }

    // Monochrome CCTV grade: brightness, optional moving-light spot and flicker bands, noise, scanlines, vignette.
    public static void Grade(Bitmap bmp, double gain, double spotX, double spotY, double spotR, double spotGain, bool bands, int seed)
    {
        int w = bmp.Width, h = bmp.Height;
        var px = Read(bmp);
        var rng = new Random(seed);
        for (int y = 0; y < h; y++)
        {
            double band = bands ? 1.0 + 0.18 * Math.Sin(y / 23.0) : 1.0;
            double scan = (y % 3 == 0) ? 0.88 : 1.0;
            for (int x = 0; x < w; x++)
            {
                int o = (y * w + x) * 4;
                double l = Lum(px, o) * gain * band;
                if (spotR > 0)
                {
                    double d = Math.Sqrt((x - spotX) * (x - spotX) + (y - spotY) * (y - spotY)) / spotR;
                    if (d < 1) l += spotGain * (1 - d) * (1 - d);
                }
                double nx = (x - w / 2.0) / (w / 2.0), ny = (y - h / 2.0) / (h / 2.0);
                double vig = 1.0 - 0.28 * (nx * nx + ny * ny);
                l = l * vig * scan + (rng.NextDouble() - 0.5) * 14;
                l = Math.Max(0, Math.Min(255, l));
                px[o] = (byte)Math.Min(255, l * 1.02);
                px[o + 1] = (byte)l;
                px[o + 2] = (byte)(l * 0.96);
                px[o + 3] = 255;
            }
        }
        var data = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
        Marshal.Copy(px, 0, data.Scan0, px.Length);
        bmp.UnlockBits(data);
    }
}
'@

$cutout = [T04Composite]::Cutout($masterPath, 5)
$room = [System.Drawing.Bitmap]::new($roomPath)
$W = $room.Width; $H = $room.Height

# Placement: room centre floor, height slightly above the door frame; Master proportions unchanged.
$figH = 500; $figW = [int]($figH * $cutout.Width / $cutout.Height)
$feetY = 842; $figX = 690 - [int]($figW / 2); $figY = $feetY - $figH

function New-Frame([string]$name, [string]$tag, [double]$gain, [double]$spotX, [double]$spotY, [double]$spotR, [double]$spotGain, [bool]$bands, [int]$seed, [scriptblock]$annotate) {
    $frame = [System.Drawing.Bitmap]::new($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($frame)
    $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'AntiAlias'
    $g.DrawImage($room, 0, 0, $W, $H)
    $shadow = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $shadow.AddEllipse($figX + 10, $feetY - 62, $figW - 20, 44)
    $brush = [System.Drawing.Drawing2D.PathGradientBrush]::new($shadow)
    $brush.CenterColor = [System.Drawing.Color]::FromArgb(150, 0, 0, 0)
    $brush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
    $g.FillPath($brush, $shadow)
    $attr = [System.Drawing.Imaging.ImageAttributes]::new()
    $cm = [System.Drawing.Imaging.ColorMatrix]::new()
    $cm.Matrix00 = 0.82; $cm.Matrix11 = 0.82; $cm.Matrix22 = 0.82
    $attr.SetColorMatrix($cm)
    $g.DrawImage($cutout, [System.Drawing.Rectangle]::new($figX, $figY, $figW, $figH), 0, 0, $cutout.Width, $cutout.Height, 'Pixel', $attr)
    $g.Dispose()
    [T04Composite]::Grade($frame, $gain, $spotX, $spotY, $spotR, $spotGain, $bands, $seed)
    $g = [System.Drawing.Graphics]::FromImage($frame)
    $g.TextRenderingHint = 'AntiAliasGridFit'; $g.SmoothingMode = 'AntiAlias'
    if ($annotate) { & $annotate $g }
    $font = [System.Drawing.Font]::new('Consolas', 26, [System.Drawing.FontStyle]::Bold)
    $small = [System.Drawing.Font]::new('Consolas', 20)
    $ink = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(225, 235, 235, 225))
    $back = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
    $g.FillRectangle($back, 24, 22, 430, 46); $g.DrawString("SC-01  $tag", $font, $ink, 34, 28)
    $g.FillRectangle($back, $W - 470, $H - 66, 446, 42); $g.DrawString('TEMP COMPOSITE / NOT EVIDENCE', $small, $ink, $W - 458, $H - 58)
    $g.Dispose()
    $path = Join-Path $OutDir $name
    $frame.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $frame.Dispose()
    Write-Output $path
}

$vent = {
    param($g)
    $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(210, 235, 235, 225), 3)
    $g.DrawRectangle($pen, 422, 120, 120, 112)
    $g.DrawString('AIR', [System.Drawing.Font]::new('Consolas', 20, [System.Drawing.FontStyle]::Bold), [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(225, 235, 235, 225)), 424, 236)
}

$cold = {
    param($g)
    $g.FillRectangle([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(46, 70, 120, 190)), 0, 0, $W, $H)
}

New-Frame 'case02_cctv_anchor_temp.png' 'CCTV 00:00' 0.80 0 0 0 0 $false 501 $null
New-Frame 'case02_exp_light_temp.png' 'EXP LIGHT LOW' 0.52 0 0 0 0 $false 502 $null
New-Frame 'case02_exp_air_temp.png' 'EXP AIRFLOW' 0.88 0 0 0 0 $false 503 $vent
New-Frame 'case02_exp_vibro_temp.png' 'EXP VIBRO' 0.86 0 0 0 0 $true 504 $null
New-Frame 'case02_exp_soundproof_temp.png' 'EXP SOUNDPROOF' 0.92 0 0 0 0 $false 505 $null
New-Frame 'case02_exp_temp_temp.png' 'EXP TEMP LOW' 0.70 0 0 0 0 $false 506 $cold

$cutout.Dispose(); $room.Dispose()
