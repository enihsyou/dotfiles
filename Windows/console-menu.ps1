# 本脚本用于在 PowerShell 控制台中创建一个可交互的菜单界面，允许用户选择和执行脚本。
# 加载 console-menu 目录下的所有脚本，并以树形结构展示。

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope = 'Function')]
param()

$ErrorActionPreference = "Stop"

function New-MenuItem {
    param (
        [string]$Title,
        [string]$Script,
        [hashtable]$Parent = $null
    )

    $route = @()
    if ($Parent -ne $null) {
        $route += $Parent.Route + $Title
    } else {
        $route += $Title
    }

    return @{
        Title    = $Title
        Script   = $Script
        Parent   = $Parent
        Children = New-Object System.Collections.ArrayList
        Route    = $route # 从根到当前项的路径
        Checked  = $false # 是否选中
        Expanded = $false # 有多个子项时是否展开
    }
}

function Import-MenuItems {
    param (
        [string]$BasePath,
        [System.Collections.ArrayList]$MenuItems,
        [hashtable]$Parent = $null
    )

    $dirEntries = Get-ChildItem -Path $BasePath -Directory
    foreach ($entry in $dirEntries) {
        $dirMenuItem = New-MenuItem -Title $entry.Name -Parent $Parent
        
        Import-MenuItems -BasePath $entry.FullName -MenuItems $dirMenuItem.Children -Parent $dirMenuItem
        foreach ($child in $dirMenuItem.Children) {
            $child.Parent = $dirMenuItem
            $child.Route = $dirMenuItem.Route + $child.Title
        }
        [void]$MenuItems.Add($dirMenuItem)
    }
    $ps1Entries = Get-ChildItem -Path $BasePath -Filter "*.ps1"
    foreach ($entry in $ps1Entries) {
        $menuItem = New-MenuItem -Title $entry.BaseName -Script $entry.FullName -Parent $Parent
        [void]$MenuItems.Add($menuItem)
    }
}

function Set-FlatMenu {
    param (
        [System.Collections.ArrayList]$Items,
        [System.Collections.ArrayList]$Flats
    )
    
    foreach ($item in $Items) {
        [void]$Flats.Add($item)
        if ($item.Expanded -and $item.Children.Count -gt 0) {
            Set-FlatMenu -Items $item.Children -Flats $Flats
        }
    }
}

function Run-FlatMenu {
    param (
        [System.Collections.ArrayList]$Items
    )
    
    foreach ($item in $Items) {
        if ($item.Checked -and $item.Script -ne "") {
            Write-Host "执行: $($item.Route -join " / ")" -ForegroundColor Yellow
            try {
                & $item.Script
            } catch {
                Write-Host "错误: $_" -ForegroundColor Red
            }
        }
        Run-FlatMenu -Items $item.Children
    }
}

# 处理目录选择
function Update-DirectorySelection {
    param (
        [hashtable]$Item,
        [bool]$CheckState
    )
    
    # 更新目录下所有子项的选中状态
    foreach ($child in $Item.Children) {
        $child.Checked = $CheckState
        Update-DirectorySelection -Item $child -CheckState $CheckState
    }
}

# 处理单项选择
function Update-DirectorySelectionStatus {
    param (
        [hashtable]$Parent
    )
    
    $allChecked = $true
    foreach ($child in $Parent.Children) {
        if (-not $child.Checked) {
            $allChecked = $false
            break
        }
    }
    if ($allChecked -and $Parent.Children.Count -gt 0) {
        $Parent.Checked = $true
    } else {
        $Parent.Checked = $false
    }

    if ($Parent.Parent -ne $null) {
        Update-DirectorySelectionStatus -Parent $Parent.Parent
    }
}

function Show-Menu {
    param (
        [System.Collections.ArrayList]$MenuItems
    )

    # 扁平化菜单项以便于导航
    $flatMenu = New-Object System.Collections.ArrayList

    $selectedIndex = 0
    $running = $true

    [Console]::CursorVisible = $false
    while ($running) {
        Clear-Host

        # 显示标题
        $sepLine = "─────────────────────────────────────────────────────────────"
        Write-Host "使用↑↓键导航，←→键展开/折叠，空格键勾选/取消，Enter键确认运行" -ForegroundColor Cyan
        Write-Host $sepLine -ForegroundColor DarkGray
        
        # 重新扁平化菜单以反映展开/折叠状态
        $flatMenu.Clear()
        Set-FlatMenu -Items $MenuItems -Flats $flatMenu
        $runButtonIndex = $flatMenu.Count
        
        # 显示菜单项
        for ($i = 0; $i -lt $flatMenu.Count; $i++) {
            $item = $flatMenu[$i]
            $indent = "  " * $item.Route.Count
            $expandChar = ""
            
            # 为有子项的菜单项添加展开/折叠符号
            if ($item.Children.Count -gt 0) {
                $expandChar = if ($item.Expanded) { "- " } else { "+ " }
            } else {
                $expandChar = "  "
            }
            
            # 显示勾选状态
            $checkbox = if ($item.Checked) { "[◼] " } else { "[ ] " }
            
            # 高亮当前选中项
            if ($i -eq $selectedIndex) {
                Write-Host "$indent" -NoNewline
                Write-Host "$expandChar" -NoNewline -ForegroundColor DarkCyan
                Write-Host "$checkbox" -NoNewline -ForegroundColor Yellow
                Write-Host "$($item.Route  -join "/")" -ForegroundColor White -BackgroundColor DarkBlue
            } else {
                $color = if ($item.Checked) { "Green" } else { "Gray" }
                Write-Host "$indent$expandChar$checkbox$($item.Route -join "/")" -ForegroundColor $color
            }
        }
        
        # 显示运行按钮
        Write-Host $sepLine -ForegroundColor DarkGray
        if ($selectedIndex -eq $flatMenu.Count) {
            Write-Host "[ 运行 ]" -ForegroundColor White -BackgroundColor DarkGreen
        } else {
            Write-Host "[ 运行 ]" -ForegroundColor Green
        }
        
        # 处理键盘输入
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
        switch ($key.VirtualKeyCode) {
            0x1B { # VK_ESCAPE
                $running = $false
            }
            0x26 { # VK_UP
                $selectedIndex = [Math]::Max(0, $selectedIndex - 1)
            }
            0x28 { # VK_DOWN
                $selectedIndex = [Math]::Min($runButtonIndex, $selectedIndex + 1)
            }
            0x25 { # VK_LEFT
                if ($selectedIndex -lt $runButtonIndex -and $flatMenu[$selectedIndex].Children.Count -gt 0) {
                    $flatMenu[$selectedIndex].Expanded = $false
                }
            }
            0x27 { # VK_RIGHT
                if ($selectedIndex -lt $runButtonIndex -and $flatMenu[$selectedIndex].Children.Count -gt 0) {
                    $flatMenu[$selectedIndex].Expanded = $true
                }
            }
            0x20 { # VK_SPACE
                if ($selectedIndex -lt $runButtonIndex) {
                    $item = $flatMenu[$selectedIndex]
                    $item.Checked = !$item.Checked
                    
                    # 如果是目录，更新所有子项
                    if ($item.Children.Count -gt 0) {
                        Update-DirectorySelection -Item $item -CheckState $item.Checked
                    }

                    # 如果是子项，在父项做更新
                    if ($item.Parent -ne $null) {
                        Update-DirectorySelectionStatus -Parent $item.Parent
                    }
                }
            }
            0x0D { # VK_RETURN
                if ($selectedIndex -eq $runButtonIndex) {
                    # 执行选中的操作
                    Clear-Host
                    Write-Host "执行选中的操作..." -ForegroundColor Cyan
                    Write-Host $sepLine -ForegroundColor DarkGray
                
                    Run-FlatMenu -Items $MenuItems
                   
                    Write-Host "按任意键结束..." -ForegroundColor Green
                    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    $running = $false
                } else {
                    # 跳转到运行按钮
                    $selectedIndex = $runButtonIndex
                }
            }
        }
    }
}

# 加载菜单项
$menuItems = New-Object System.Collections.ArrayList
Import-MenuItems -BasePath (Join-Path $PSScriptRoot "console-menu") -MenuItems $menuItems

# 运行菜单
Show-Menu -MenuItems $menuItems
