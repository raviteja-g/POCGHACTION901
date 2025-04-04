using { cuid, managed } from '@sap/cds/common';
namespace sap.capire.incidents; 

/**
* Incidents created by Customers.
*/
entity Incidents : cuid, managed {  
    customer     : Association to Customers;
    title        : String  @title : 'Title';
}

entity Customers : managed { 
    key ID        : String;
    firstName     : String;
    lastName      : String;
}
