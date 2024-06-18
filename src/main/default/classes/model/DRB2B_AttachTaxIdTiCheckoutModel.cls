public with sharing class DRB2B_AttachTaxIdTiCheckoutModel {
    public DRB2B_AttachTaxIdTiCheckoutModel() {
    }
    public List<TaxIdentifiers> taxIdentifiers { get; set; }
    public String sourceId { get; set; }
    public class TaxIdentifiers {
        public String id;
    }
}
