@isTest
private class alcd_ContentDocumentLinkHandlerTest{
    @isTest
    static void itShould(){
        Account acc = new Account(name='test acc');
        insert acc;
        /* Contact con = new Contact(lastname='test cont',accountid=acc.id);
        insert con;
        Opportunity opp = new Opportunity(name='testoppty',AccountId=acc.id,stageName='Qualification',closedate=system.today());
        insert opp;
        Case cas = new Case(AccountId=acc.id,ContactId=con.id,Subject='This is a test',Status='New',Priority='Low',Type='Problem',Origin='Email');
        insert cas; */
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=acc.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'V';
        Test.startTest();
        insert contentlink;
        Test.stopTest();
    }
}