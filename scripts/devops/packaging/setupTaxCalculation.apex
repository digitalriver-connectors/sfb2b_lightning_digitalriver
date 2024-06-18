// Configure Tax Calculation Service
RegisteredExternalService taxServiceRegistration = [
        SELECT Id
        FROM RegisteredExternalService
        WHERE ExternalServiceProviderType = 'Tax'
        LIMIT 1
];

ApexClass taxCalculationService = [
        SELECT Id
        FROM ApexClass
        WHERE Name = 'DRB2B_CartTaxCalculations'
        LIMIT 1
];

taxServiceRegistration.ExternalServiceProviderId = taxCalculationService.Id;

update taxServiceRegistration;

