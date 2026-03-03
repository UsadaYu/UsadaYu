# CMD's Proxy

# 1 Preface

Proxy tools like `Hiddify` and `Clash` typically use only the system proxy by default.

This mode only modifies proxy settings at the system level.

In this case, the browser can generally successfully bypass the firewall, but `CMD` remains in a direct connection state.

The system proxy mode does not generate virtual network cards, so you will not see the corresponding interface when running `ipconfig` in `CMD`.

If you want to access the network through a proxy in `CMD` as well, you need to make some modifications.

# 2 Solution

## 2.1 Set To VPN Mode

On Windows, open the proxy tool in administrator mode and set it to VPN (TUN) mode.

At this point, running `ipconfig` in `CMD` will show the virtual adapter for the corresponding proxy tool.

## 2.2 Manually Set Up The Proxy

Find the mixed port of the proxy tool, such as `Hiddify`, which is usually `20810` or `12334`.

Enter the following command in the `CMD` window:

```powershell
set http_proxy=http://127.0.0.1:12334
set https_proxy=http://127.0.0.1:12334
```

Enter the following command to verify if the settings are working:

```powershell
curl -L google.com
```

If the source code of the web page is returned, the setup was successful.
