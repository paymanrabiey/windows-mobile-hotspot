# Windows Mobile Hotspot

**Start Windows Mobile Hotspot using PowerShell and WinRT — with built-in compatibility diagnostics.**

This project provides a PowerShell script to start Windows Mobile Hotspot using the Windows Runtime (WinRT) API, along with diagnostic scripts to inspect system compatibility and networking components.

The goal is to help users test modern Windows Mobile Hotspot functionality without relying on the legacy Hosted Network feature.

## Features

- Attempts to start Windows Mobile Hotspot through the WinRT API.
- Reports the tethering operation result and final state.
- Checks Windows version and build information.
- Detects Wi-Fi adapters and displays driver details.
- Checks legacy Hosted Network support separately.
- Inspects Wi-Fi Direct virtual adapters.
- Checks relevant Windows services.
- Provides diagnostic results and compatibility warnings.
- Does not intentionally modify network configuration in the diagnostic scripts.

## Repository Files

| File | Description |
|---|---|
| `enable-wifi.ps1` | Attempts to start Windows Mobile Hotspot. |
| `Test-MobileHotspotSupport-full.ps1` | Full diagnostic script with a colored summary and additional compatibility checks. |
| `Test-MobileHotspotSupport.ps1` | Standard diagnostic script. |

**Recommended:** Run `Test-MobileHotspotSupport-full.ps1` first, review the results, and then run `enable-wifi.ps1` if appropriate.

## Requirements

- Windows 10 or Windows 11.
- Windows PowerShell 5.1 is recommended.
- A compatible Wi-Fi adapter and driver.
- An available network connection profile.
- Appropriate permission to execute PowerShell scripts.

Compatibility depends on the Windows version, adapter, driver, and network configuration.

## Getting Started

### 1. Download the project

Open the repository:

https://github.com/paymanrabiey/windows-mobile-hotspot

Select **Code → Download ZIP**, then extract the archive to a folder.

Alternatively, download the required `.ps1` files individually.

### 2. Open PowerShell in the extracted folder

Open the folder in File Explorer, click the address bar, type `powershell`, and press Enter.

Alternatively, open PowerShell and navigate to the extracted directory:

```powershell
Set-Location "C:\Path\To\windows-mobile-hotspot"
```

Replace the example path with the actual location of the extracted files.

### 3. Run the full diagnostic script

Run this command first:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Test-MobileHotspotSupport-full.ps1"
```

Review the output for Wi-Fi adapter information, driver details, Windows services, WinRT availability, and compatibility warnings.

If you prefer the standard diagnostic script, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Test-MobileHotspotSupport.ps1"
```

### 4. Start Mobile Hotspot

After reviewing the diagnostic results, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\enable-wifi.ps1"
```

Check the operation status, any additional error message, and the final tethering state.

**Important:** A successful start operation does not necessarily mean that connected devices will receive an IP address or have Internet access.

## PowerShell Execution Policy

The commands above use `-ExecutionPolicy Bypass` for the PowerShell process launched by that command. This does not permanently change the system-wide execution policy.

If your organization enforces PowerShell execution policies through Group Policy or other security controls, those restrictions may still apply.

Only run scripts that you trust and have reviewed.

## Modern Mobile Hotspot vs. Legacy Hosted Network

Windows Mobile Hotspot and the older Hosted Network feature are different technologies.

For example, this output:

```text
Hosted network supported: No
```

does **not**, by itself, prove that modern Windows Mobile Hotspot is unsupported.

The modern Mobile Hotspot API uses Windows Runtime (WinRT). Actual functionality may still depend on the Wi-Fi adapter, driver, Windows version, Internet Connection Sharing (ICS), DHCP, and other network settings.

## Troubleshooting

### A device connects but receives a `169.254.x.x` IP address

An IPv4 address in the `169.254.0.0/16` range often indicates that the device did not receive an address from DHCP.

Check:

- The final tethering state reported by the activation script.
- The status of the relevant Windows networking services.
- Internet Connection Sharing (ICS) configuration.
- Wi-Fi adapter and driver status.
- IP configuration on the connected device.

Do not change network settings blindly, particularly on computers using VPNs, static routes, or enterprise network configurations.

### The script reports success, but Internet access does not work

The hotspot starting successfully is only one part of the process. Client addressing, DHCP, routing, and Internet sharing must also work correctly.

Use the diagnostic output to narrow down the issue before changing system configuration.

## Limitations

- The diagnostic scripts provide compatibility information; they cannot guarantee that the hotspot will start successfully.
- The activation script does not guarantee DHCP functionality or Internet access for connected devices.
- Behavior may vary across Windows versions, Wi-Fi adapters, drivers, and network configurations.
- This project does not replace Windows networking configuration or troubleshooting tools.

## Contributing

Bug reports, suggestions, and test results from different Windows versions and Wi-Fi adapters are welcome.

When reporting an issue, include the Windows version, Wi-Fi adapter model, driver version, and relevant diagnostic output. Remove any sensitive information before sharing logs.

## Disclaimer

This project is provided **as-is**, without warranty. Use it at your own risk. Review the scripts before running them, especially on enterprise systems or computers with specialized network configurations.

---

# هات‌اسپات مدرن ویندوز با PowerShell

این پروژه شامل اسکریپت‌هایی برای بررسی سازگاری سیستم و تلاش برای فعال‌کردن قابلیت **Mobile Hotspot** ویندوز با استفاده از Windows Runtime (WinRT) است.

## امکانات

- تلاش برای روشن‌کردن هات‌اسپات مدرن ویندوز.
- نمایش نتیجه عملیات و وضعیت نهایی.
- نمایش نسخه و Build ویندوز.
- شناسایی کارت‌های Wi-Fi و نمایش مشخصات درایور.
- بررسی جداگانه پشتیبانی از Hosted Network قدیمی.
- بررسی آداپتورهای مجازی Wi-Fi Direct.
- بررسی سرویس‌های مرتبط با شبکه.
- ارائه خلاصه تشخیصی و هشدارهای سازگاری.

اسکریپت‌های تشخیصی عمداً تنظیمات شبکه را تغییر نمی‌دهند.

## فایل‌های پروژه

| نام فایل | کاربرد |
|---|---|
| `enable-wifi.ps1` | تلاش برای فعال‌کردن Mobile Hotspot |
| `Test-MobileHotspotSupport-full.ps1` | نسخه کامل تشخیصی با خلاصه رنگی و بررسی‌های تکمیلی |
| `Test-MobileHotspotSupport.ps1` | نسخه تشخیصی استاندارد |

**پیشنهاد:** ابتدا نسخه کامل تشخیصی را اجرا کنید، نتایج را بررسی کنید و سپس در صورت نیاز سراغ اسکریپت فعال‌سازی بروید.

## پیش‌نیازها

- ویندوز ۱۰ یا ۱۱.
- ترجیحاً Windows PowerShell 5.1.
- کارت Wi-Fi و درایور سازگار.
- وجود یک پروفایل اتصال شبکه.
- مجوز اجرای اسکریپت‌های PowerShell.

## روش اجرا

### ۱. دریافت پروژه

به آدرس زیر بروید:

https://github.com/paymanrabiey/windows-mobile-hotspot

از منوی **Code → Download ZIP** پروژه را دانلود و از حالت فشرده خارج کنید.

### ۲. بازکردن PowerShell

وارد پوشه استخراج‌شده شوید. در نوار آدرس File Explorer عبارت `powershell` را وارد کنید و Enter بزنید.

یا در PowerShell مسیر پوشه را وارد کنید:

```powershell
Set-Location "C:\Path\To\windows-mobile-hotspot"
```

مسیر نمونه را با مسیر واقعی فایل‌ها جایگزین کنید.

### ۳. اجرای نسخه کامل تشخیصی

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Test-MobileHotspotSupport-full.ps1"
```

نتایج بررسی کارت Wi-Fi، درایور، سرویس‌ها، APIهای مرتبط و هشدارهای سازگاری را مطالعه کنید.

برای اجرای نسخه استاندارد:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Test-MobileHotspotSupport.ps1"
```

### ۴. فعال‌کردن هات‌اسپات

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\enable-wifi.ps1"
```

نتیجه عملیات، پیام خطای احتمالی و وضعیت نهایی هات‌اسپات را بررسی کنید.

**توجه:** موفقیت عملیات به معنی تضمین دریافت IP یا دسترسی به اینترنت برای دستگاه‌های متصل نیست.

## سیاست اجرای PowerShell

گزینه `-ExecutionPolicy Bypass` در دستورهای بالا برای فرایند PowerShell اجراشده اعمال می‌شود و سیاست اجرایی سیستم را به‌صورت دائمی تغییر نمی‌دهد.

اگر سیاست‌های امنیتی سازمان از طریق Group Policy یا روش‌های دیگر اعمال شده باشند، ممکن است همچنان مانع اجرای اسکریپت شوند.

فقط اسکریپت‌هایی را اجرا کنید که به آن‌ها اعتماد دارید و محتوایشان را بررسی کرده‌اید.

## تفاوت Mobile Hotspot مدرن و Hosted Network قدیمی

این دو قابلیت یکسان نیستند. بنابراین نمایش عبارت زیر:

```text
Hosted network supported: No
```

به‌تنهایی ثابت نمی‌کند که Mobile Hotspot مدرن ویندوز پشتیبانی نمی‌شود.

قابلیت مدرن از APIهای WinRT استفاده می‌کند، اما عملکرد نهایی به نسخه ویندوز، سخت‌افزار، درایور و تنظیمات اشتراک‌گذاری اینترنت و DHCP بستگی دارد.

## عیب‌یابی

### دستگاه متصل می‌شود اما IP آن با `169.254.x.x` شروع می‌شود

این وضعیت معمولاً نشان می‌دهد که دستگاه نتوانسته از DHCP یک آدرس IPv4 دریافت کند.

موارد زیر را بررسی کنید:

- وضعیت نهایی هات‌اسپات.
- وضعیت سرویس‌های مرتبط با شبکه.
- تنظیمات Internet Connection Sharing (ICS).
- وضعیت کارت Wi-Fi و درایور آن.
- تنظیمات IP دستگاه متصل‌شده.

روی سیستم‌هایی که VPN، مسیرهای ثابت یا تنظیمات شبکه سازمانی دارند، بدون بررسی دقیق تنظیمات شبکه را تغییر ندهید.

### اسکریپت موفقیت را نشان می‌دهد اما اینترنت برقرار نیست

روشن‌شدن هات‌اسپات فقط یکی از مراحل است. تخصیص IP، DHCP، مسیریابی و اشتراک‌گذاری اینترنت نیز باید درست کار کنند.

## محدودیت‌ها

- اسکریپت تشخیصی اطلاعات سازگاری را ارائه می‌دهد، اما موفقیت اجرای هات‌اسپات را تضمین نمی‌کند.
- اسکریپت فعال‌سازی عملکرد صحیح DHCP یا دسترسی به اینترنت را تضمین نمی‌کند.
- رفتار ممکن است در نسخه‌های مختلف ویندوز، کارت‌های Wi-Fi و درایورها متفاوت باشد.

## مشارکت در پروژه

گزارش خطاها، پیشنهادها و نتایج آزمایش روی نسخه‌های مختلف ویندوز و کارت‌های Wi-Fi مورد استقبال است.

هنگام گزارش مشکل، نسخه ویندوز، مدل کارت Wi-Fi، نسخه درایور و خروجی مرتبط اسکریپت تشخیصی را ارائه کنید. پیش از انتشار خروجی، اطلاعات حساس را حذف کنید.

## سلب مسئولیت

این پروژه بدون ضمانت ارائه می‌شود و استفاده از آن بر عهده کاربر است. پیش از اجرا، کد را بررسی کنید؛ به‌ویژه اگر سیستم دارای تنظیمات شبکه سازمانی یا مسیرهای خاص است.
