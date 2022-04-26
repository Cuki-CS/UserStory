public inherited sharing class PriceBookEntrySelector {
    public static Map<Id, PricebookEntry> getOrderableActivePriceBookEntryRecordsOrEmptyList(){
        Map<Id, PricebookEntry> resultList = new Map<Id, PricebookEntry>([
            SELECT Id, Name, UnitPrice, ProductCode
            FROM PricebookEntry 
            WHERE Pricebook2.IsActive = true AND Pricebook2.IsStandard = true AND IsActive = true
            LIMIT 1000
        ]);
        return resultList;
    }
}
