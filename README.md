
# Windows Mobile Hotspot

A PowerShell utility to start Windows Mobile Hotspot using the Windows Runtime (WinRT) API.

## Features

- Starts Windows Mobile Hotspot through WinRT.
- Reports the current and final tethering state.
- Displays the operation result and any additional error message.

## Requirements

- Windows with support for the Windows Runtime networking APIs.
- PowerShell with access to `System.Runtime.WindowsRuntime`.
- A compatible Wi-Fi adapter and driver.
- An available network connection profile.

## Usage

Run `enable-wifi.ps1` in PowerShell.

The script reports whether the tethering operation succeeded. A successful result does not guarantee that connected devices will receive an IP address or have internet access.

C:\ .\enable-wifi.ps1

## Compatibility Notes

The legacy `netsh wlan hostednetwork` feature and the modern Windows Mobile Hotspot feature are different. A driver reporting `Hosted network supported: No` does not necessarily mean that Mobile Hotspot is unsupported.

Hardware, driver, Windows configuration, internet connection sharing, and DHCP behavior may affect the result.

## Disclaimer

Provided as-is, without warranty. Test in your own environment before relying on it.

هات‌اسپات ویندوز ۱۱ با PowerShell

این پروژه یک اسکریپت PowerShell برای روشن‌کردن قابلیت Mobile Hotspot ویندوز با استفاده از Windows Runtime (WinRT) است.

هدف پروژه این است که کاربران بتوانند هات‌اسپات مدرن ویندوز را از طریق اسکریپت اجرا کنند و وضعیت گزارش‌شده آن را مشاهده کنند.

امکانات

تلاش برای روشن‌کردن Mobile Hotspot ویندوز از طریق WinRT.

نمایش وضعیت هات‌اسپات قبل و بعد از اجرا.

نمایش نتیجه عملیات و پیام خطای احتمالی.

ارائه توضیحات درباره سازگاری کارت‌های Wi-Fi و درایورها.

پیش‌نیازها

نسخه‌ای از ویندوز که از APIهای موردنیاز پشتیبانی کند.

PowerShell با دسترسی به System.Runtime.WindowsRuntime.

کارت Wi-Fi و درایور سازگار.

وجود یک پروفایل اتصال شبکه.

روش استفاده

۱. فایل enable-wifi.ps1 را دریافت کنید.

۲. PowerShell را باز کنید.

C:\ .\enable-wifi.ps1
۳. اسکریپت را اجرا کنید.

۴. نتیجه عملیات و وضعیت نهایی هات‌اسپات را بررسی کنید.

توجه: موفقیت عملیات به معنی تضمین دریافت IP توسط گوشی یا دسترسی آن به اینترنت نیست. تخصیص IP به دستگاه‌های متصل و اشتراک‌گذاری اینترنت باید جداگانه بررسی شود.

نکات سازگاری

قابلیت قدیمی netsh wlan hostednetwork با قابلیت جدید Mobile Hotspot ویندوز یکسان نیست.

بنابراین، اگر دستور netsh wlan show drivers مقدار Hosted network supported: No را نمایش دهد، نمی‌توان صرفاً بر اساس آن نتیجه گرفت که Mobile Hotspot مدرن ویندوز پشتیبانی نمی‌شود.

عملکرد نهایی به نسخه ویندوز، کارت Wi-Fi، درایور، تنظیمات شبکه، سرویس Internet Connection Sharing (ICS) و عملکرد DHCP بستگی دارد.

سلب مسئولیت

این پروژه بدون ضمانت ارائه می‌شود. پیش از استفاده در محیط عملیاتی، آن را در محیط خود آزمایش کنید.

مشارکت در پروژه

گزارش خطاها، پیشنهادها و تجربه آزمایش روی کارت‌های Wi-Fi و نسخه‌های مختلف ویندوز مورد استقبال است.
