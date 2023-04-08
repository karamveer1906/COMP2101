# Welcome Function to display welcome message
#--------------------------------------------
function welcome {
    $name = $env:USERNAME
    $date = Get-Date -Format "dddd, MMMM d"
    Write-Host "Welcome, $name! Today is $date."
}
# Cpu Info Function
#----------------------------------------
function get-cpuinfo {
    $processors = Get-CimInstance CIM_Processor
    $processors | Select-Object Manufacturer, Model, CurrentClockSpeed, MaxClockSpeed, NumberOfCores
}
# Disk Info Function
#-----------------------------------------
function get-mydisks {
    $disks = Get-CimInstance CIM_DiskDrive
    $disks | Select-Object Manufacturer, Model, SerialNumber, FirmwareRevision, @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}} | Format-Table
}
# 'ip-report' function to print ip details.
# -----------------------------------------
function ip-report {
	write-output " "
	write-output "----------| IP Information |----------"
	$Description= @{ e='Description'; width =15}
    	$Index= @{ e='Index'; width =5}
    	$IPAddress= @{ e='IPAddress'; width=20}
    	$IPSubnet = @{ e='IPSubnet'; width=20}
    	$DNSDomain= @{ e='DNSDomain'; width=12}
    	$DNSServer= @{ e='DNSServerSearchOrder'; width=20}
    
    	get-ciminstance win32_networkadapterconfiguration | 
        Where-Object {$_.IPEnabled -eq $true} |
        Format-Table -Property $Description,$Index,$IPAddress,$IPSubnet,$DNSDomain,$DNSServer -Wrap
	write-output " "
}


# 'hardware_description' function to print hardware description.
# -------------------------------------------------------------
function hardware_description {
	write-output " "
	write-output "----------| Hardware Description |----------"
    	gwmi win32_computersystem | select Name, Manufacturer, Model, TotalPhysicalMemory, Description | format-list
	write-output " "
}


# 'os_information' function to print os information.
# --------------------------------------------------
function os_information {
	write-output " "
	write-output "----------| OS Information |----------"
    	gwmi win32_operatingsystem | select Name, Version | format-list
	write-output " "
}


# 'processor_information' function to print processor information.
# ---------------------------------------------------------------
function processor_information {
	write-output " "
	write-output "----------| Processor Information |----------"
    	gwmi win32_processor | select Name, NumberOfCores, CurrectClockSpeed, MaxClockSpeed,
    	@{
        	n = "L1CacheSize";
        	e = {
            	switch ($_.L1CacheSize) {
                	$null { $data = "data unavailable" }
                	Default { $data = $_.L1CacheSize }
            	};
            	$data
        	}
    	},
    	@{
        	n = "L2CacheSize";
        	e = {
            	switch ($_.L2CacheSize) {
                	$null { $data = "data unavailable" }
                	Default { $data = $_.L2CacheSize }
            	};
            	$data
        	}
    	},
    	@{
        	n = "L3CacheSize";
        	e = {
            	switch ($_.L3CacheSize) {
                	$null { $data = "data unavailable" }
                	Default { $data = $_.L3CacheSize }
            	};
            	$data
        	}
    	} | format-list
	write-output " "
}


# 'ram_information' function to print ram information.
# ----------------------------------------------------
function ram_information {
	write-output " "
	write-output "----------| RAM Information |----------"
    	$phymem = get-CimInstance win32_PhysicalMemory | select Description, manufacturer, banklabel,     devicelocator, capacity
    	$phymem | format-table

    	$total = 0
	foreach ($pm in $phymem) {$total = $total + $pm.capacity}
		$total = $total / 1GB
    	write-output "RAM : $total GB"
    	write-output " "
}


# 'physical_disk_information' function to print physical disk information.
# -----------------------------------------------------------------------
function physical_disk_information {
	write-output " "
	write-output "----------| Physical Disk Information |----------"
    	$diskdrives = Get-CIMInstance CIM_diskdrive | where DeviceID -ne $null

    	foreach ($disk in $diskdrives) {
           $partitions = $disk | get-cimassociatedinstance -resultclassname CIM_diskpartition
           foreach ($partition in $partitions) {
            	$logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
            	foreach ($logicaldisk in $logicaldisks) {
                    new-object -typename psobject -property @{
                         Model          = $disk.Model
                         Manufacturer   = $disk.Manufacturer
                         Location       = $partition.deviceid
                         Drive          = $logicaldisk.deviceid
                         "Size(GB)"     = [string]($logicaldisk.size / 1gb -as [int]) + "gb"
                         FreeSpace      = [string]($logicaldisk.FreeSpace / 1gb -as [int]) + "gb"
                         "FreeSpace(%)" = [string]((($logicaldisk.FreeSpace / $logicaldisk.size) * 100) -as [int]) + "%"
                    } | format-table -AutoSize
                }
           }
    	}
	write-output " "
}


# 'network_adapter_information' function to print network adapter information.
# ----------------------------------------------------------------------------
function network_adapter_information {
	write-output " "
	write-output "----------| Network Adapter Information |----------"
    	get-ciminstance win32_networkadapterconfiguration | where { $_.IPEnabled -eq $True } | 
    	format-table Description, Index, IPAddress, IPSubnet, DNSDomain, DNSServerSearchOrder -AutoSize
	write-output " "
}


# 'video_information' function to print video information.
# --------------------------------------------------------
function video_information {
	write-output " "
	write-output "----------| Video Controller Information |----------"
    	get-CimInstance win32_videocontroller | select description, caption, currenthorizontalresolution,     currentverticalresolution

    	$h = $obj.currenthorizontalresolution
    	$v = $obj.currentverticalresolution
    	$resolution = "$h x $v"
    	$resolution
	write-output " "
}