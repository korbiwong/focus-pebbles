param([string]$OutDir)
Add-Type -AssemblyName System.Drawing

function RoundRect([float]$x,[float]$y,[float]$w,[float]$h,[float]$r){
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r*2
  $p.AddArc($x,$y,$d,$d,180,90); $p.AddArc($x+$w-$d,$y,$d,$d,270,90)
  $p.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90); $p.AddArc($x,$y+$h-$d,$d,$d,90,90)
  $p.CloseFigure(); return $p
}

function Make([int]$size,[string]$name,[bool]$rounded,[float]$inner){
  $bmp = New-Object System.Drawing.Bitmap $size,$size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.Clear([System.Drawing.Color]::Transparent)
  $k = $size/512.0
  $navy = [System.Drawing.ColorTranslator]::FromHtml('#1d3557')
  $bg = New-Object System.Drawing.SolidBrush $navy
  if($rounded){ $g.FillPath($bg,(RoundRect 0 0 $size $size (96*$k))) } else { $g.FillRectangle($bg,0,0,$size,$size) }
  $grid = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml('#2e4a72')),(4*$k)
  for($i=64;$i -lt 512;$i+=64){ $g.DrawLine($grid,$i*$k,0,$i*$k,$size); $g.DrawLine($grid,0,$i*$k,$size,$i*$k) }
  # content scaled around the centre (smaller for maskable so it survives the mask)
  $s = $inner; $c = 256
  function T([float]$v){ return (($v-256)*$s+256)*$k }
  $box = RoundRect (T 136) (T 136) (240*$s*$k) (240*$s*$k) (18*$s*$k)
  $g.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#2e7d4f'))),$box)
  $gold = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml('#e0b45a')),(16*$s*$k)
  $g.DrawPath($gold,$box)
  $tick = New-Object System.Drawing.Pen ([System.Drawing.Color]::White),(34*$s*$k)
  $tick.StartCap='Round'; $tick.EndCap='Round'; $tick.LineJoin='Round'
  $pts = [System.Drawing.PointF[]]@((New-Object System.Drawing.PointF (T 190),(T 262)),(New-Object System.Drawing.PointF (T 236),(T 308)),(New-Object System.Drawing.PointF (T 328),(T 204)))
  $g.DrawLines($tick,$pts)
  $bmp.Save((Join-Path $OutDir $name),[System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}

Make 192 'icon-192.png' $true 1.0
Make 512 'icon-512.png' $true 1.0
Make 512 'icon-maskable-512.png' $false 0.8
Make 180 'icon-180.png' $false 1.0
Get-ChildItem $OutDir | Select-Object Name,Length
