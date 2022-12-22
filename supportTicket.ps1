



$supportServices = Get-AzSupportService


$serviceNames = [PSCustomObject]@{}
$supportProblems = [PSCustomObject]@{}

foreach ($service in $supportServices) {
    Write-Output "service Name: $($service.displayName)"
    foreach ($problems in $service) {
        $problems = Get-AzSupportProblemClassification -ServiceId $service.Name
        foreach ($issue in $problems) {
            Write-Output "issue displayName: $($issue.DisplayName)"
        }  
    } Write-Output "------------"
}
$supportProblems | Add-Member -MemberType NoteProperty -Name $issue.DisplayName -Value $issue.id
$serviceNames | Add-Member -MemberType NoteProperty -Name $service.DisplayName -Value $supportProblems 


$a = $serviceNames | ConvertTo-Json -Depth 5| clip






$serviceNames = [PSCustomObject]@{}
$supportProblems = [PSCustomObject]@{}

$problems = Get-AzSupportProblemClassification -ServiceId $supportServices[0].Name
$serviceNames | Add-Member -MemberType NoteProperty -Name $supportServices[0].DisplayName -Value $supportProblems
foreach ($issue in $problems) {
    $supportProblems | Add-Member -MemberType NoteProperty -Name $issue.DisplayName -Value $issue.id
} 
 


