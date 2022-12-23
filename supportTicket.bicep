targetScope = 'subscription'

param ticketTitle string 
param ticketDescription string
@allowed(['critical', 'highestcriticalimpact', 'minimal', 'moderate'])
param severity string = 'minimal'
param serviceName string
param problemClassificationName string
param resourceId string 
param utc string = utcNow()


var serviceId = '/providers/Microsoft.Support/services/${serviceName}'
var problemClassificationId = '/providers/Microsoft.Support/services/${serviceName}/problemClassifications/${problemClassificationName}'

var abc = resourceId


param contactDetails object = {
  country: 'DNK'
  firstName: 'Mantas'
  lastName: ''
  preferredContactMethod: 'email'
  preferredSupportLanguage: 'en-US'
  preferredTimeZone: 'Central Europe Standard Time'
  primaryEmailAddress: ''
  phoneNumber: 
}

resource supportTicket 'Microsoft.Support/supportTickets@2020-04-01' = {
  #disable-next-line use-stable-resource-identifiers
  name: guid(subscription().id, utc)
    properties:{
    contactDetails: contactDetails
    description: ticketDescription
    #disable-next-line use-resource-id-functions
    problemClassificationId: problemClassificationId
    #disable-next-line use-resource-id-functions
    serviceId: serviceId
    severity: severity
    title: ticketTitle
    technicalTicketDetails: {
      resourceId: resourceId
    }
  }
}


output supportTicketName string = supportTicket.name
output supportTciketId string = supportTicket.id
output supportTicketProperties object = supportTicket.properties
