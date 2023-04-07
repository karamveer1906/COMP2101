# Retrieve network adapter configuration objects
$adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled}

# Create an empty array to store adapter details
$adapterDetails = @()

# Loop through each adapter and retrieve its configuration details
foreach ($adapter in $adapters) {
    $details = [ordered]@{
        'Description' = $adapter.Description
        'Index' = $adapter.Index
        'IP Address' = $adapter.IPAddress
        'Subnet Mask' = $adapter.IPSubnet
        'DNS Domain' = $adapter.DNSDomain
        'DNS Server' = $adapter.DNSServerSearchOrder
    }
    # Add adapter details to the array
    $adapterDetails += New-Object -TypeName PSObject -Property $details
}

# Format the adapter details as a table
$adapterDetails | Format-Table -AutoSize