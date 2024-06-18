// Configure Shipping methods Integration Service
RegisteredExternalService shippingServiceRegistration = [
        SELECT Id
        FROM RegisteredExternalService
        WHERE ExternalServiceProviderType = 'Shipment'
        LIMIT 1
];

ApexClass shippingCalculationService = [
        SELECT Id
        FROM ApexClass
        WHERE Name = 'DRB2B_ShippingSample'
        LIMIT 1
];

// Update Shipping Integration Service class
shippingServiceRegistration.ExternalServiceProviderId = shippingCalculationService.Id;
update shippingServiceRegistration;
