public with sharing class AtkWebCartEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity webCartEntity, Integer size) {
        webCartEntity
            .field(WebCart.Name)
            .repeat('Cart')
            .field(WebCart.Status)
            .repeat('Active')
            .field(WebCart.Type)
            .repeat('Cart')
            .field(WebCart.IsRepricingNeeded)
            .repeat(false)
            .field(WebCart.BillingCountry)
            .repeat(getCountry())
            .field(WebCart.BillingState)
            .repeat(getState())
            .field(WebCart.BillingPostalCode)
            .repeat('08540')
            .field(WebCart.BillingCity)
            .repeat('Princeton')
            .field(WebCart.BillingStreet)
            .repeat('123 Main St');
    }
    
    public string getCountry(){
        String country = 'US';
        if(DRB2B_Utility.isCountryStateEnabled() == true){
            country = 'United States';
        }
        return country;
    }
    
    public string getState(){
        String state = 'NJ';
        if(DRB2B_Utility.isCountryStateEnabled() == true){
            state = 'New Jersey';
        }
        return state;
    }
}