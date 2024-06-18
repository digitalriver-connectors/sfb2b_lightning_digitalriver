public inherited sharing class DRB2B_CountryPicklist {
    private Picklist picklist;

    public DRB2B_CountryPicklist() {
        this.picklist = new Picklist(Product2.DR_Product_Country_Origin__c);
    }

    /**
     * @return API Names of all active countries values.
     */
    public List<String> getValues() {
        return this.getValues();
    }

    /**
     * @return Labels of all active countries values.
     */
    public List<String> getLabels() {
        return this.picklist.getLabels();
    }

    /**
     * @param value Country option's API name / value
     *
     * @return Label corresponding to the given picklist value.
     */
    public String getLabel(String value) {
        return this.picklist.getLabel(value);
    }

    /**
     * @return AuraEnabled collection of active countries entries
     */
    public List<Picklist.Entry> getEntries() {
        return this.picklist.getEntries();
    }

    /**
     * @return Map Values to Labels
     */
    public Map<String, String> getEntriesMap() {
        return this.picklist.getEntriesMap();
    }

    /**
     * @return Map of Labels to Values
     */
    public Map<String, String> getLabelToValueMap() {
        return this.picklist.getLabelToValueMap();
    }

    public Picklist.Entry getEntry(String valueOrLabel) {
        String label = getLabelByValue(valueOrLabel);
        Picklist.Entry entry;
        if (String.isEmpty(label)) {
            String value = getValueByLabel(valueOrLabel);

            if (String.isEmpty(value)) {
                throw new CountryPicklistException(
                    'The system does not provide such a country picklist entry:' + valueOrLabel
                );
            } else {
                entry = this.picklist.getEntriesByValues().get(value);
            }
        } else {
            entry = this.picklist.getEntriesByValues().get(valueOrLabel);
        }

        return entry;
    }

    public String getValueByLabel(String label) {
        return this.getLabelToValueMap().get(label);
    }

    public String getLabelByValue(String value) {
        return this.getEntriesMap().get(value);
    }

    public class CountryPicklistException extends Exception {
    }
}
