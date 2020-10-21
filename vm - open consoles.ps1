# RK - 10-18-2019

# Desc:
# Open up consoles via PowerCLI

# Two options
# 1) Open using the external VMRC - works great on windows with a simple PowerCLI Commandlet - limted to 20 at a time per the commandlet itself (but if you run separate lines at once, it works fine).
# 2) Open using your browser - Using William Lam's script to pull the Flash Client URL and then open it. (The HTML5 console is fine, but I haven't used it yet as we are still on 6.5U1. Just have to figure out how to do it if you want to do it that way.)

# Needed for CCRB-45536
# I was asked to check each console for FSCK issues (Corey said sometimes it needs manual help).
# As I was originally limted to pulling 20 consoles at a time, I needed to figure out how to separate out the consoles, so I used folders.
# I ended up discovering they were kind of silly in their use.

# References:
# https://virtuallythatguy.co.uk/how-to-open-vm-virtual-machine-console-using-powercli/
# https://www.virtuallyghetto.com/2013/09/how-to-generate-pre-authenticated-html5.html


# You need to be logged into the vCenters in the BROWSER for these to work:
Connect-VIServer vc01-dal.dal.sync.lan


# FOLDERS:
# https://www.reddit.com/r/vmware/comments/56u5iw/list_vms_inside_a_specific_folder_path_with/
# Get-Folder "First Folder" | Get-Folder "Second Folder" | Get-VM | Sort

# Get sub folders for future use:
Get-Folder "Beryl (Passive)" -Type VM | Get-Folder | Sort
Get-Folder "Lapis (Passive)" -Type VM | Get-Folder | Sort
Get-Folder "Windstream (Passive)" -Type VM | Get-Folder | Sort


# OPEN VMRC CONSOLES:
#Get-VM ldap01-a.beryl.dal.sync.lan | Open-VMConsoleWindow -FullScreen #Works!

#Get-VM -Location (Get-Folder -Name "Beryl (Passive)" -Type VM) | Open-VMConsoleWindow -FullScreen
#Get-VM -Location (Get-Folder -Name "Lapis (Passive)" -Type VM) | Open-VMConsoleWindow -FullScreen
#Get-VM -Location (Get-Folder -Name "Windstream (Passive)" -Type VM) | Open-VMConsoleWindow -FullScreen


# Breaking them up into folders so I can control what is appearing:
Get-VM -Location (Get-Folder "Lapis (Passive)" -Type VM | Get-Folder "ECMGR") | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Lapis (Passive)" -Type VM | Get-Folder "LDAP") | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Lapis (Passive)" -Type VM | Get-Folder "MD") | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Lapis (Passive)" -Type VM | Get-Folder "MX") | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Lapis (Passive)" -Type VM | Get-Folder "POP") | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Lapis (Passive)" -Type VM | Get-Folder "SMTP") | Sort | Open-VMConsoleWindow -FullScreen


# Breaking them up into folders so I can control what is appearing, including separating out the mail drops into groups of 9 to bypass the 20 instance limit:
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "ECMGR") | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "LDAP") | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "MD") | where {$_.Name -match "md0"} | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "MD") | where {$_.Name -match "md1"} | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "MD") | where {$_.Name -match "md2"} | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "MD") | where {$_.Name -match "md3"} | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "MD") | where {$_.Name -match "md4"} | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "MD") | where {$_.Name -match "md5"} | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "MX") | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "POP") | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "SMTP") | Sort | Open-VMConsoleWindow -FullScreen
Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "TEST") | Sort | Open-VMConsoleWindow -FullScreen


# OPEN WEB CONSOLES (Firefox):

# Grabs the host VMRC URL itself, and I'm not sure what to do with it.
#Open-VMConsoleWindow -VM "ldap01-a.beryl.dal.sync.lan" -UrlOnly
#start-process -FilePath '"C:\Program Files\Mozilla Firefox\firefox.exe"' -ArgumentList 'vmrc://esxbc02b04.dal.sync.lan:902/?mksticket=5239aaf4-fcc6-805e-681f-ea8e63d5db6c&thumbprint=62:3F:E8:81:AC:C7:F4:0C:7C:0E:F0:F9:1D:D0:F2:15:F8:24:69:25&path=/vmfs/volumes/597a304b-de0f6ec6-db87-1402ec956bb0/ldap01-a.beryl.dal.sync.lan/ldap01-a.beryl.dal.sync.lan.vmx'


# WORKS!!!!
# Use this function to obtain the proper "https://<VC_FQDN>:9443/vsphere-client/webconsole.html?afdkjdkadljfha"
# Then use the additional code to open multiple tabs.
Function Get-VMConsoleURL {
<#
    .NOTES
    ===========================================================================
     Created by:    William Lam
     Organization:  VMware
     Blog:          www.virtuallyghetto.com
     Twitter:       @lamw
        ===========================================================================
    .DESCRIPTION
        This function generates the HTML5 VM Console URL (default) as seen when using the
        vSphere Web Client connected to a vCenter Server 6.5 environment. You must
        already be logged in for the URL to be valid or else you will be prompted
        to login before being re-directed to VM Console. You have option of also generating
        either the Standalone VMRC or WebMKS URL using additional parameters
        https://github.com/lamw/vghetto-scripts/blob/master/powershell/GenerateVMConsoleURL.ps1
    .PARAMETER VMName
        The name of the VM
    .PARAMETER webmksUrl
        Set to true to generate the WebMKS URL instead (e.g. wss://<host>/ticket/<ticket>)
    .PARAMETER vmrcUrl
        Set to true to generate the VMRC URL instead (e.g. vmrc://...)
    .EXAMPLE
        Get-VMConsoleURL -VMName "Embedded-VCSA1"
    .EXAMPLE
        Get-VMConsoleURL -VMName "Embedded-VCSA1" -vmrcUrl $true
    .EXAMPLE
        Get-VMConsoleURL -VMName "Embedded-VCSA1" -webmksUrl $true
        #>
    param(
        [Parameter(Mandatory=$true)][String]$VMName,
        [Parameter(Mandatory=$false)][Boolean]$vmrcUrl,
        [Parameter(Mandatory=$false)][Boolean]$webmksUrl
    )

    Function Get-SSLThumbprint {
        param(
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('FullName')]
        [String]$URL
        )

        add-type @"
            using System.Net;
            using System.Security.Cryptography.X509Certificates;

                public class IDontCarePolicy : ICertificatePolicy {
                public IDontCarePolicy() {}
                public bool CheckValidationResult(
                    ServicePoint sPoint, X509Certificate cert,
                    WebRequest wRequest, int certProb) {
                    return true;
                }
                }
"@
        [System.Net.ServicePointManager]::CertificatePolicy = new-object IDontCarePolicy

        # Need to connect using simple GET operation for this to work
        Invoke-RestMethod -Uri $URL -Method Get | Out-Null

        $ENDPOINT_REQUEST = [System.Net.Webrequest]::Create("$URL")
        $SSL_THUMBPRINT = $ENDPOINT_REQUEST.ServicePoint.Certificate.GetCertHashString()

        return $SSL_THUMBPRINT -replace '(..(?!$))','$1:'
    }

    $VM = Get-VM -Name $VMName
    $VMMoref = $VM.ExtensionData.MoRef.Value

    if($webmksUrl) {
        $WebMKSTicket = $VM.ExtensionData.AcquireTicket("webmks")
        $VMHostName = $WebMKSTicket.host
        $Ticket = $WebMKSTicket.Ticket
        $URL = "wss://$VMHostName`:443/ticket/$Ticket"
    } elseif($vmrcUrl) {
        $VCName = $global:DefaultVIServer.Name
        $SessionMgr = Get-View $DefaultViserver.ExtensionData.Content.SessionManager
        $Ticket = $SessionMgr.AcquireCloneTicket()
        $URL = "vmrc://clone`:$Ticket@$VCName`:443/?moid=$VMMoref"
    } else {
        $VCInstasnceUUID = $global:DefaultVIServer.InstanceUuid
        $VCName = $global:DefaultVIServer.Name
        $SessionMgr = Get-View $DefaultViserver.ExtensionData.Content.SessionManager
        $Ticket = $SessionMgr.AcquireCloneTicket()
        $VCSSLThumbprint = Get-SSLThumbprint "https://$VCname"
        $URL = "https://$VCName`:9443/vsphere-client/webconsole.html?vmId=$VMMoref&vmName=$VMname&serverGuid=$VCInstasnceUUID&locale=en_US&host=$VCName`:443&sessionTicket=$Ticket&thumbprint=$VCSSLThumbprint”
    }
    $URL
}

# I was just playing around here
<#
#Get-VMConsoleURL -VMName "ldap01-a.beryl.dal.sync.lan"
#Get-VMConsoleURL -VMName "ldap01-b.beryl.dal.sync.lan"

#$TestVM1 = Get-VMConsoleURL -VMName "ldap01-a.beryl.dal.sync.lan"
#$TestVM2 = Get-VMConsoleURL -VMName "ldap01-b.beryl.dal.sync.lan"

#$TestVM1
#$TestVM2
#>

# Clear an array variable
$ArrayList = ""
$ArrayList = @()

# Grab the VMs you want to have a browser console opened for
$VMs = Get-VM -Location (Get-Folder "Windstream (Passive)" -Type VM | Get-Folder "MD") | Select Name -ExpandProperty Name | Sort Name

# Simply use a foreach loop to make an array of the VM names
foreach ($VM in $VMs){
    #$VM #was used to see the VM name
    $SingleVM = Get-VMConsoleURL -VMName "$VM"
    #$SingleVM #was used to see the URL of the single vm name
    $ArrayList += $SingleVM #make an array of VM names
}

# Print out the array list to make sure all the variables are in there, and correct
$ArrayList

# This Powershell will open Firefox and then open URLs via the ArgumentList argument, which happens to take an array as an input.
start-process -FilePath '"C:\Program Files\Mozilla Firefox\firefox.exe"' -ArgumentList "$ArrayList"