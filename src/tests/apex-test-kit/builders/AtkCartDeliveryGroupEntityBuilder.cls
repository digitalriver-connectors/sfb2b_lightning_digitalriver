public with sharing class AtkCartDeliveryGroupEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity cartDeliveryGroupEntity, Integer size) {
        cartDeliveryGroupEntity
            .field(CartDeliveryGroup.Name).index('Default Delivery {0000}')
            .field(CartDeliveryGroup.DeliverToPostalCode).repeat('30705')
            .field(CartDeliveryGroup.DeliverToCountry).repeat(getCountry())
            .field(CartDeliveryGroup.DeliverToState).repeat(getState())
            .field(CartDeliveryGroup.DeliverToCity).index('{0000} Hillcrest Drive')
            .field(CartDeliveryGroup.DeliverToName).repeat('Chatsworth');
    }
    
    public string getCountry(){
        String country = 'US';
        if(DRB2B_Utility.isCountryStateEnabled() == true){
            country = 'United States';
        }
        return country;
    }
    
    public string getState(){
        String state = 'GA';
        if(DRB2B_Utility.isCountryStateEnabled() == true){
            state = 'Georgia';
        }
        return state;
    }
}