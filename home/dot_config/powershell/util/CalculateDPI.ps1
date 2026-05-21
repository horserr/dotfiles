# 1. 获取物理显示器的物理宽度和高度（单位：厘米）
$monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams
if (-not $monitors) {
  Write-Error "未能获取到物理显示器信息，请确认是否为直连显示器（虚拟机或远程桌面可能无法获取）。"
  return
}

# 2. 遍历所有检测到的物理显示器并计算 DPI
foreach ($monitor in $monitors) {
  $widthCm = $monitor.MaxHorizontalImageSize
  $heightCm = $monitor.MaxVerticalImageSize

  # 排除无效数据
  if ($widthCm -eq 0 -or $heightCm -eq 0) { continue }

  # 将厘米转换为英寸 (1 英寸 = 2.54 厘米)
  $widthInch = $widthCm / 2.54
  $heightInch = $heightCm / 2.54
  $diagonalInch = [Math]::Round([Math]::Sqrt([Math]::Pow($widthInch, 2) + [Math]::Pow($heightInch, 2)), 1)

  # 3. 获取当前屏幕的真实物理分辨率（忽略 Windows 缩放的影响）
  $videoController = Get-CimInstance Win32_VideoController | Select-Object -First 1
  $hRes = $videoController.CurrentHorizontalResolution
  $vRes = $videoController.CurrentVerticalResolution

  if (-not $hRes -or -not $vRes) {
    Write-Warning "未能获取到当前分辨率，尝试备用方法..."
    # 备用方法
    $b = [Windows.作業系統]::获取分辨率 # 简化，通常用 WmiMonitorPhysicalVideoResolution
    $res = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorPhysicalVideoResolution | Select-Object -First 1
    $hRes = $res.HorizontalResolution
    $vRes = $res.VerticalResolution
  }

  # 4. 计算对角线像素总数
  $diagonalPixels = [Math]::Sqrt([Math]::Pow($hRes, 2) + [Math]::Pow($vRes, 2))

  # 5. 计算物理 DPI / PPI
  $dpi = [Math]::Round($diagonalPixels / $diagonalInch, 0)

  # 6. 输出结果
  Write-Host "======================================" -ForegroundColor Cyan
  Write-Host " 显示器名称/实例: $($monitor.InstanceName.Split('_')[0])"
  Write-Host " 物理尺寸 (宽x高): $widthCm 厘米 x $heightCm 厘米"
  Write-Host " 屏幕对角线尺寸 : $diagonalInch 英寸"
  Write-Host " 当前物理分辨率 : $hRes x $vRes"
  Write-Host "======================================" -ForegroundColor Cyan
  Write-Host " 计算得到的屏幕真实 DPI 为: " -NoNewline
  Write-Host "$dpi" -ForegroundColor Green -BackgroundColor Black
  Write-Host "======================================" -ForegroundColor Cyan
  Write-Host "提示：你可以将 Sumatra PDF 的设置修改为：CustomScreenDPI = $dpi`n"
}
