//@istest
public class Veda {
   // @istest
    public static void A(){
    ware_House__c h=new  ware_House__c();
    h.Name ='kadapa';
    h.Stock_Availability__c=true;
   h.Manager_email__c='sai321@gmail.com';
        insert h;
        system.debug(h);
    }
  
}