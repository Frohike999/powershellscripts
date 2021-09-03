$appointmentSubjects = "Staff Meeting", "Client Appointment", "Interview", "Presentation", "Doctors Appointment", "Department Meeting"
$recAppointmentSubjects = "Lunch", "Weekly Meeting", "Daily Meeting"
$startTime = "8:00 AM"
$endTime = "5:00 PM"
$incrementTime = 30
$appointmentDuration = 30, 60, 90, 120
[DateTime]$startDate = "1/1/2010"
[DateTime]$endDate = "12/31/2021"

# $appointmentSubjects[(Get-Random -Maximum $appointmentSubjects.Length)]
# $recAppointmentSubjects[(Get-Random -Maximum $recAppointmentSubjects.Length)]
$outlook = new-object -com Outlook.Application

$calendar = $outlook.Session.folders.Item(1).Folders.Item("Calendar")

for ($i=1; $i -le 10000; $i++)
{
    $randomAppointment = New-Object random
    $randomTicks = [Convert]::ToInt64(($endDate.ticks * 1.0 - $startDate.ticks * 1.0) * $randomAppointment.NextDouble() + ($startDate.Ticks * 1.0))

    [DateTime]$randomStartDate = new-object DateTime($RandomTicks)
    $randomStartDate = $randomStartDate.AddMinutes(- $randomStartDate.Minute % 30).ToString("yyyy-MM-dd HH:mm")
    $randomDuration = $appointmentDuration[(Get-Random -Maximum $appointmentDuration.Length)]
    [DateTime]$randomEndDate = $randomStartDate.AddMinutes($randomDuration)
    
    $appt = $calendar.Items.Add(1) #== olAppointmentItem
    $appt.Start = [DateTime]$randomStartDate
    $appt.End = [DateTime]$randomEndDate
    $appt.Subject = $appointmentSubjects[(Get-Random -Maximum $appointmentSubjects.Length)]
    $appt.Body = "IMS Testing"
    $appt.Save()
}