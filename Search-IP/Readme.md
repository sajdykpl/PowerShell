# SYNOPSIS
Function is looking for IP addresses in transffered data (by default from Clipboard, but this can be override with parameter "IPAddress" or by using pipeline), deduplicate and finally sort them. Results can be passed by pipeline to another cmd-lets like ConvertTo-HTML or Export-CSV.

# DESCRIPTION
Search for IP addresses, deduplicate and sort them. 

# PARAMETER IPAddress
Scipt can read data from named parameter "IPAddress", but this is not default behaviour. 
By default function read data from Clipboard. Parameter "IPAddress" should be used if you want to override reading content from Clipboard.

# INPUTS
By default function reads data from Clipboard.
This can be overridden by using parameter "-IPAddress":
    
pass IP address as array:

```
    Search-IP -IPAddresses @("192.168.0.1", "192.168.1.1", "10.0.0.1") 
```
    
pass part of log - can be multiline:
```
    Search-IP -IPAddresses "2023.12.01 20.47 192.168.1.1 172.24.1.2:443 200"
```

or by piping data from external cmdlet like below:
``` 
    Get-Content -Path "some_log_file.log" | Search-IP
```

# OUTPUTS
Results are printed to console but they can saved to file by using below examples:
```
    Search-IP | ConvertTo-HTML | Out-File -FilePath "$($env:USERPROFILE)\Desktop\IP-Sorted.html"
```
or 
```
    Search-IP | Export-CSV -Path "$($env:USERPROFILE)\Desktop\IP-Sorted.csv"
```
