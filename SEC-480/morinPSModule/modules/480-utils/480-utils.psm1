function 480Banner() {

    Write-Host "Hello"

}

function 480Connect([string] $server) {

    $conn = $Global:DefaultVIServer

    if ($conn) {

        $msg = "Already connected to {0}" -f $conn
        Write-Host -ForegroundColor Green $msg

    } else {

        $conn = Connect-VIServer -Server $server
        Write-Host "Connected sucessfully to {0}" -f $server

    }

}

function Get-480Config([string] $configpath) {

    Write-Host "Reading " $configpath
    $conf = $null
    
    if(Test-Path $configpath) {
        $conf = (Get-Content -Raw -Path $configpath | ConvertFrom-Json)
        $msg = "Using configuration at {0}." -f $configpath

        Write-Host -ForegroundColor Green $msg


    } else {
        
        Write-Host -ForegroundColor Red "No configuration file found."

    }
    return $conf
}

function index_picker($array){

    $selection = $null
    $index = 1

    foreach ($x in $array) {

        Write-Host [$index] $x.name
        $index+=1
    }
    
    $pick_index = Read-Host "Which index number [x] would you like to pick?"
    $selection = $array[$pick_index-1]
    Write-Host "You picked" $selection.name

    return $selection
}

function Select-VM([string] $folder) {

    $selected_vm = $null
    try {
        
        $vms = Get-VM -Location $folder
        
        $index = 1
        foreach ($vm in $vms) {

            Write-Host [$index] $vm.name
            $index+=1

        }

        $pick_index = Read-Host "Which index number [x] would you like to pick?"
        $selected_vm = $vms[$pick_index-1]
        Write-Host "You picked" $selected_vm.name
        #Write-Host $selected_vm.GetType().name
        return $selected_vm
    }

    catch {

        Write-Host "Invalid folder: $folder" -ForegroundColor Red

    }
    

}

function Write-LinkedClone() {

      # Write-Host (Get-Folder -type VM | Select-Object Name)
      $folders = Get-Folder -type VM
      $folder = index_picker -array $folders
      if (!$folder) {
         Write-Host "Invalid folder selection. Aborting..." -f Red
         return $null
      }
     
     $vm = Select-VM -folder $folder
     if (!$vm) {
         Write-Host "Invalid VM selection. Aborting..." -f Red
         return $null
     }
     
      $VMHosts = Get-VMHost
      $vmhost = index_picker -array $VMHosts
      if (!$vmhost) {
         Write-Host "Invalid ESXI host selection. Aborting..." -f Red
         return $null
      }
  
      $datastores = Get-Datastore
      $ds = index_picker -array $datastores
      if (!$ds) {
         Write-Host "Invalid datastore selection. Aborting..." -f Red
         return $null
      }
  
      $linkedCloneName = Read-Host "Enter a new name for the linked clone"
      if (!$linkedCloneName) {
         Write-Host "Invalid name input. Aborting..." -f Red
         return $null
      }
 
      $snapshots = Get-Snapshot -VM $vm 
      $snapshot = index_picker -array $snapshots
      if (!$snapshot) {
         Write-Host "Invalid snapshot selection. Aborting..." -f Red
         return $null
      }

    $linkedVM = New-VM -LinkedClone -Name $linkedCloneName -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds

    Write-Host "VM Linked Clone created successfully." -f Green 


}

function Write-FullClone() {

    # Write-Host (Get-Folder -type VM | Select-Object Name)
     $folders = Get-Folder -type VM
     $folder = index_picker -array $folders
     if (!$folder) {
        Write-Host "Invalid folder selection. Aborting..." -f Red
        return $null
     }
    
    $vm = Select-VM -folder $folder
    if (!$vm) {
        Write-Host "Invalid VM selection. Aborting..." -f Red
        return $null
    }
    
     $VMHosts = Get-VMHost
     $vmhost = index_picker -array $VMHosts
     if (!$vmhost) {
        Write-Host "Invalid ESXI host selection. Aborting..." -f Red
        return $null
     }
 
     $datastores = Get-Datastore
     $ds = index_picker -array $datastores
     if (!$ds) {
        Write-Host "Invalid datastore selection. Aborting..." -f Red
        return $null
     }
 
     $fullCloneName = Read-Host "Enter a new name for the full clone"
     $linkedCloneName = "{0}.temp" -f $vm.name
     if (!$fullCloneName) {
        Write-Host "Invalid name input. Aborting..." -f Red
        return $null
     }

     $snapshots = Get-Snapshot -VM $vm 
     $snapshot = index_picker -array $snapshots
     if (!$snapshot) {
        Write-Host "Invalid snapshot selection. Aborting..." -f Red
        return $null
     }
 
     $linkedVM = New-VM -LinkedClone -Name $linkedCloneName -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
 
     #Write-Host "VM Linked Clone created successfully." -f Green
    
    $newvm = New-VM -Name $fullCloneName -vm $linkedVM -VMHost $vmhost -Datastore $ds

    $linkedVM | Remove-VM

    Write-Host "VM Full Clone created successfully." -f Green
 
 }