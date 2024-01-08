
function Search-IP {
    <#
.SYNOPSIS
    Function is looking for IP addresses in transffered data (by default from Clipboard, but this can be override with parameter "IPAddress" or by using pipeline), deduplicate and finally sort them. Results can be passed by pipeline to another cmd-lets like ConvertTo-HTML or Export-CSV.
    

.DESCRIPTION
  Search for IP addresses, deduplicate and sort them. 

.PARAMETER IPAddress
    Scipt can read data from named parameter "IPAddress", but this is not default behaviour. 
    By default function read data from Clipboard. Parameter "IPAddress" should be used if you want to override reading content from Clipboard.

.INPUTS
    By default function reads data from Clipboard.
    This can be overridden by using parameter "-IPAddress":
        Search-IP -IPAddresses @("192.168.0.1", "192.168.1.1", "10.0.0.1") #pass IP address as array
        Search-IP -IPAddresses "2023.12.01 20.47 192.168.1.1 172.24.1.2:443 200" #pass part of log - can be multiline
    or by piping data from external cmdlet like below:
        Get-Content -Path "some_log_file.log" | Search-IP

.OUTPUTS
  Results are printed to console but they can be saved to file using below examples:
    Search-IP | ConvertTo-HTML | Out-File -FilePath "$($env:USERPROFILE)\Desktop\IPs.html"
    Search-IP | Export-CSV -Path "$($env:USERPROFILE)\Desktop\IPs.csv"

.NOTES
  Version:        1.1
  Author:         Daniel Sajdyk
  Creation Date:  01.01.2024
  Purpose/Change: Cleaning unnecessary comments


.EXAMPLE
        Search-IP
        By simply typing "Search-IP" you will run function that will read Clipboard content, look for IP addresses, deduplicate and sort them. Final results will be displayed on console.
  
.EXAMPLE
        Get-Content -path log.txt | Search-IP | Out-Host -Paging
        This example read log file and pass its content to function, which will deduplicate, and sort found IP addresses. Finally results are passed to Out-Host cmd-let wioth "-Paging" parameter which can help with reading results.

.EXAMPLE
    Search-IP -IPAddresses  

    Search-IP -IPAddresses @("192.168.0.1", "192.168.1.1", "10.0.0.1") | ConvertTo-Html | Out-File "$($env:USERPROFILE)\Desktop\IPs.html"
    This example search for IP addresses passed by parameter IPAddresses, convert them to HTML and save as html file in current user desktop.
      

#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]$IPAddresses
    ) 

    BEGIN {
        $arrayListIPAddressess = New-Object -TypeName 'System.Collections.ArrayList';
        #regex below catches IP addresses including also those with dots in brackets
        $regexPattern = '(?<ip>\d{1,3}.?\..?\d{1,3}.?\..?\d{1,3}.?\..?\d{1,3})' #ten regex wyłapuje wszystkie adresy które wokół kropek rozdzielających okrekty mają dowolne znaki (np. nawias okrągły, lub kwardratowy)
        $removeCharacters = @('\[', 
                                '\]',
                                '\(',
                                '\)'
                                )
    }
    
    PROCESS {
        # Block PROCESS is like loop, which takes values one by one from the pipeline and store them to variable $IPAddresses
        if ($TRUE -eq ($PSBoundParameters.ContainsKey('IPAddresses'))) {
            #write-host "Getting IP addresses from pipeline"    

            if ($TRUE -eq ($matched = [regex]::Matches($IPAddresses, "$regexPattern")).Value){
                
                ForEach ($match in $matched){
                    #section below removes unnecessary characters like brackets from IP Addresses
                    ForEach ($replaceCharacter in $removeCharacters){
                        $match = $match -replace ("$replaceCharacter","")
                    }

                    #IP address with removed unnecessary characters is added to $arrayListIPAddressess
                    $NULL = $arrayListIPAddressess.Add($match)
                }
            }
        }
    }

    END {
        if ($arrayListIPAddressess.Count -eq 0) {

            if ($TRUE -eq ($matched = [regex]::Matches((Get-Clipboard), "$regexPattern")).Value){
                
                ForEach ($match in $matched){
                    #section below removes unnecessary characters like brackets from IP Addresses
                    ForEach ($replaceCharacter in $removeCharacters){
                        $match = $match -replace ("$replaceCharacter","")
                    }

                    #IP address with removed unnecessary characters is added to $arrayListIPAddressess
                    $NULL = $arrayListIPAddressess.Add($match)
                }
            }
        }


        #Checking if any data are in arraylist (no matter from pipeline or from clipboard)
        if (($arrayListIPAddressess).Count -ne 0){
            
            $arrayListIPHex = New-Object -TypeName 'System.Collections.ArrayList';

            ForEach ($IP in $arrayListIPAddressess){
                $NULL = $arrayListIPHex.Add("0x" + (($IP -split '\.' | ForEach-Object {"{0:x2}" -f [int]$_}) -join ''))
            } 
            
            [array]$arrayIPHexDeduplicated = $arrayListIPHex | Sort-Object -Unique
            
            ForEach ($IPHex in $arrayIPHexDeduplicated){
                ([ipaddress]$IPHex) | select-object -property @{Name='IPs';Expression={$_.IPAddressToString}}
            }
            
            Remove-Variable arrayListIPAddressess
            Remove-Variable arrayIPHexDeduplicated
        }
        else {
            Write-Warning -Message "No data passed from Clipboard, parameter or pipeline. Below are 3 lines of data stored in Clipboard."
            $i = 1;
            Get-Clipboard | Select-Object -First 3 | ForEach-Object {
                write-host "$i. $_"
                $i ++
            }
        }
    }
} 