



$supportServices = Get-AzSupportService


$serviceNames = New-Object PSCustomObject
$serviceNamesList = @()
$ServiceNames | Add-Member -MemberType NoteProperty -Name $service.DisplayName $serviceNamesList
foreach ($service in $supportServices) {
    $ServiceList = New-Object PSCustomObject
    $serviceListArray = @()
    $ServiceList | Add-Member -MemberType NoteProperty -Name $service.DisplayName $serviceListArray
    # foreach ($problems in $service) {
    #     $123 = New-Object PSCustomObject
    #     $enListe = @()
    #     $123 | Add-Member -MemberType NoteProperty -Name $issue.DisplayName -Value $enListe
    #     $problems = Get-AzSupportProblemClassification -ServiceId $service.Name
    #     foreach ($issue in $problems) {
    #         $abc = New-Object PSCustomObject
    #         $abc | Add-Member -MemberType NoteProperty -Name $issue.DisplayName -Value $issue.id
    #         $enListe += $abc
    #     } 
    #     $emptyList += $123
    # } 
    $serviceNamesList += $ServiceList
}
$serviceNames



$a = $supportProblems | ConvertTo-Json -Depth 5| clip






$serviceNames = [PSCustomObject]@{}
$supportProblems = [PSCustomObject]@{}

$problems = Get-AzSupportProblemClassification -ServiceId $supportServices[0].Name
$serviceNames | Add-Member -MemberType NoteProperty -Name $supportServices[0].DisplayName -Value $supportProblems
foreach ($issue in $problems) {
    $supportProblems | Add-Member -MemberType NoteProperty -Name $issue.DisplayName -Value $issue.id
} 
 


