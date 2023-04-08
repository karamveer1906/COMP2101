[CmdletBinding()]
param (
    [switch]$System,
    [switch]$Disks,
    [switch]$Network
)

function Get-SystemInformation {
    # Get system hardware description
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $computerManufacturer = $computerSystem.Manufacturer
    $computerModel = $computerSystem.Model
    $computerName = $computerSystem.Name
    $computerDescription = "$computerManufacturer $computerModel ($computerName)"
}

    # Get operating system name and version number
    $operatingSystem = Get-WmiObject -Class Win32_OperatingSystem
    $osName = $operatingSystem.Caption
    $osVersion = $operatingSystem.Version

    # Get processor description with speed, number of cores, and sizes of the L1, L2, and L3 caches if they are present
    $processor = Get-WmiObject -Class Win32_Processor
    $processorDescription = $processor.Name
    $processorSpeed = "{0:N2} GHz" -f ($processor.MaxClockSpeed / 1e3)
    $processorCores = $processor.NumberOfCores
    $processorL1CacheSize = "$($processor.L2CacheSize / 1KB) KB"
    $processorL2CacheSize = "$($processor.L2CacheSize / 1KB) KB"
    $processorL3CacheSize = "$($processor.L3CacheSize / 1KB) KB"

    # Get summary of the RAM installed
    $physicalMemory = Get-WmiObject -Class Win32_PhysicalMemory
    $ram = $physicalMemory | ForEach-Object {
        [PSCustomObject]@{
            Vendor = $_.Manufacturer
            Description = $_.PartNumber
            Size = "{0:N2} GB" -f ($_.Capacity / 1GB)
            Bank = "Bank $_.BankLabel"
            Slot = "Slot $_.DeviceLocator"
        }
    }
    $totalRam = "{0:N2} GB" -f (($physicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB)

    # Get summary of the physical disk drives
    $diskDrives = Get-WmiObject -Class Win32_DiskDrive
    $disks = $diskDrives | ForEach-Object {
        $partitions = $_ | Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition
        $partitionSize = ($partitions | Measure-Object -Property Size -Sum).Sum
        [PSCustomObject]@{
            Vendor = $_.Manufacturer
            Model = $_.Model
            Size = "{0:N2} GB" -f ($_.Size / 1GB)
            SpaceUsed = "{0:N2} GB" -f ($partitionSize / 1GB)
            FreeSpace = "{0:N2} GB" -f ($_.Size / 1GB - $partitionSize / 1GB)
            PercentFree = "{0:P2}" -f (($_.Size - $partitionSize) / $_.Size)
        }
    }

    # Get network adapter configuration report
    $networkAdapters = Get-NetAdapter
    $network = $networkAdapters | ForEach-Object {
        $ipAddress = $_ | Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            Name = $_.Name
            Description = $_.InterfaceDescription
            MACAddress = $_.MacAddress
}
}