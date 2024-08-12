@isTest
private class RouteCasesBasedOnSkillsTest {

    @testSetup
    static void setupTestData() {
          // Ensure ServiceChannel exists
          List<ServiceChannel> serviceChannels = [SELECT Id, DeveloperName FROM ServiceChannel WHERE DeveloperName = 'caseChannel'];
          if (serviceChannels.isEmpty()) {
              System.assert(false, 'ServiceChannel with DeveloperName "caseChannel" does not exist. Ensure it exists before running tests.');
          }
  
          // Ensure Skills exist
          List<String> skillNames = new List<String>{'Otras', 'Benestar', 'Asesoría Jurídica', 'Contratación', 'Cultura y Deportes', 'Infraestructuras (Vías y Obras)', 
                                                      'Intervención', 'Medio Ambiente', 'RRHH', 'Recaudación', 'Tramitación electrónica', 'Transparencia', 'Turismo'};
          List<Skill> skills = [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel IN :skillNames];
          Set<String> existingSkillNames = new Set<String>();
          for (Skill skill : skills) {
              existingSkillNames.add(skill.MasterLabel);
          }
  
          if (existingSkillNames.size() != skillNames.size()) {
              System.assert(false, 'Not all required Skills exist. Ensure all required Skills are created before running tests.');
          }
  

        // Create Users
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser1 = new User(Alias = 'tuser1', Email = 'testuser1@example.com', EmailEncodingKey = 'UTF-8', LastName = 'User1', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = standardUserProfile.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testuser1ouvac@example.com');
        User testUser2 = new User(Alias = 'tuser2', Email = 'testuser2@example.com', EmailEncodingKey = 'UTF-8', LastName = 'User2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = standardUserProfile.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testuser2ouvac@example.com');
        insert new List<User>{testUser1, testUser2};

        // Create Service Resources and Service Resource Skills
        ServiceResource sr1 = new ServiceResource(RelatedRecordId = testUser1.Id, ResourceType = 'A', Name = 'TestResource1', IsActive = true);
        ServiceResource sr2 = new ServiceResource(RelatedRecordId = testUser2.Id, ResourceType = 'A', Name = 'TestResource2', IsActive = true);
        insert new List<ServiceResource>{sr1, sr2};

        Skill benestarSkill = [SELECT Id FROM Skill WHERE MasterLabel = 'Benestar' LIMIT 1];
        Skill recaudacionSkill = [SELECT Id FROM Skill WHERE MasterLabel = 'Recaudación' LIMIT 1];
        ServiceResourceSkill srs1 = new ServiceResourceSkill(ServiceResourceId = sr1.Id, SkillId = benestarSkill.Id, effectiveStartDate = Date.today());
        ServiceResourceSkill srs2 = new ServiceResourceSkill(ServiceResourceId = sr2.Id, SkillId = recaudacionSkill.Id, effectiveStartDate = Date.today());
        insert new List<ServiceResourceSkill>{srs1, srs2};

        // Create Groups for Queues
        Group benestarQueue = new Group(Name = 'Benestar', DeveloperName = 'Benestar1', Type = 'Queue');
        Group generalQueue = new Group(Name = 'General', DeveloperName = 'General1', Type = 'Queue');
        Group recaudacionQueue = new Group(Name = 'Recaudacion', DeveloperName = 'Recaudacion1', Type = 'Queue');
        insert new List<Group>{benestarQueue, generalQueue, recaudacionQueue};
    }

    @isTest
    static void testRouteCasesBasedOnSkills() {
        // Create Case records
        List<Case> cases = new List<Case>{
            new Case(Subject = 'Case 1', ambitos__c = 'Benestar'),
            new Case(Subject = 'Case 2', ambitos__c = 'Contratación'),
            new Case(Subject = 'Case 3', ambitos__c = 'Otras'),
            new Case(Subject = 'Case 4', ambitos__c = 'Asesoría Jurídica (legal)'),
            new Case(Subject = 'Case 5', ambitos__c = 'Cultura y Deportes'),
            new Case(Subject = 'Case 6', ambitos__c = 'Infraestructuras (Vías y Obras)'),
            new Case(Subject = 'Case 7', ambitos__c = 'Intervención'),
            new Case(Subject = 'Case 8', ambitos__c = 'Medio Ambiente'),
            new Case(Subject = 'Case 9', ambitos__c = 'RRHH (Ofertas de empleo)'),
            new Case(Subject = 'Case 10', ambitos__c = 'Recaudación'),
            new Case(Subject = 'Case 11', ambitos__c = 'Tramitación electrónica'),
            new Case(Subject = 'Case 12', ambitos__c = 'Transparencia'),
            new Case(Subject = 'Case 13', ambitos__c = 'Turismo'),
            new Case(Subject = 'Case 14', ambitos__c = ' ')
        };
        insert cases;

        // Ensure no existing PendingServiceRouting
        List<PendingServiceRouting> existingPSRs = [SELECT Id FROM PendingServiceRouting WHERE WorkItemId IN :cases];
        delete existingPSRs;

        // Call the method to be tested
        Test.startTest();
        RouteCasesBasedOnSkills.RouteCasesBasedOnSkills(cases);
        Test.stopTest();

        // Verify PendingServiceRouting and SkillRequirement records
        List<PendingServiceRouting> psrs = [SELECT Id, WorkItemId, IsReadyForRouting FROM PendingServiceRouting WHERE WorkItemId IN :cases];
        System.assertEquals(14, psrs.size(), 'There should be 14 PendingServiceRouting records.');

        List<SkillRequirement> skillRequirements = [SELECT Id, SkillId, RelatedRecordId FROM SkillRequirement WHERE RelatedRecordId IN :psrs];
        System.assertEquals(14, skillRequirements.size(), 'There should be 14 SkillRequirement records.');

        // Verify that PendingServiceRouting records are ready for routing
        for (PendingServiceRouting psr : psrs) {
            System.assertEquals(true, psr.IsReadyForRouting, 'PendingServiceRouting should be ready for routing.');
        }
    }
    
    @isTest
    static void testHandleAmbitosChangeNoChangeInOwner() {
        // Get the test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'tuser1' LIMIT 1];
        Skill benestarSkill = [SELECT Id FROM Skill WHERE MasterLabel = 'Benestar' LIMIT 1];

        // Create Case records
        List<Case> cases = new List<Case>{
            new Case(Subject = 'Case 1', ambitos__c = 'Benestar', OwnerId = testUser.Id)
        };
        insert cases;

        // Simulate ambitos__c change
        Case caseToUpdate = cases[0];
        caseToUpdate.ambitos__c = 'Benestar';

        // Call the method to be tested
        Test.startTest();
        RouteCasesBasedOnSkills.handleAmbitosChange(
            new Map<Id, Case>{cases[0].Id => cases[0]},
            new Map<Id, Case>{cases[0].Id => caseToUpdate}
        );
        Test.stopTest();

        // Verify OwnerId does not change
        Case updatedCase = [SELECT Id, OwnerId FROM Case WHERE Id = :cases[0].Id];
        System.assertEquals(testUser.Id, updatedCase.OwnerId, 'Owner should not change if they have the required skill.');
    } 
    // Test method to verify handling of ambitos__c changes
    @isTest
    static void testHandleAmbitosChange_AssignToCorrectQueue() {
        // Fetch the test data created in the @testSetup method
        User testUser = [SELECT Id FROM User WHERE Alias = 'tuser1' LIMIT 1];
        Group benestarQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Benestar' LIMIT 1];
        Group recaudacionQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Recaudacion' LIMIT 1];

        // Create Case records
        Case case1 = new Case(Subject = 'Case 1', ambitos__c = 'Benestar', OwnerId = testUser.Id);
        insert case1;

        // Simulate ambitos__c change
        Case caseToUpdate = [SELECT Id, ambitos__c FROM Case WHERE Id = :case1.Id LIMIT 1];
        caseToUpdate.ambitos__c = 'Recaudación';

        // Call the method to be tested
        Test.startTest();
        RouteCasesBasedOnSkills.handleAmbitosChange(
            new Map<Id, Case>{case1.Id => case1},
            new Map<Id, Case>{case1.Id => caseToUpdate}
        );
        Test.stopTest();

        // Verify that the OwnerId is updated correctly based on ambitos__c
        Case updatedCase = [SELECT Id, OwnerId FROM Case WHERE Id = :case1.Id];
        System.assertEquals(recaudacionQueue.Id, updatedCase.OwnerId, 'Owner should be reassigned to Recaudacion queue.');
    }

    @isTest
    static void testHandleAmbitosNotChange() {
        // Fetch the test data created in the @testSetup method
        User testUser = [SELECT Id FROM User WHERE Alias = 'tuser1' LIMIT 1];
        Group benestarQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Benestar' LIMIT 1];
        Group recaudacionQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Recaudacion' LIMIT 1];

        // Create Case records
        Case case1 = new Case(Subject = 'Case 1', ambitos__c = 'Benestar', OwnerId = testUser.Id);
        Case case2 = new Case(Subject = 'Case 2', ambitos__c = 'Recaudación', OwnerId = testUser.Id);
        insert new List<Case>{case1, case2};

        // Call the method to be tested
        Test.startTest();
        RouteCasesBasedOnSkills.handleAmbitosNotChange(new List<Case>{case1, case2});
        Test.stopTest();

        // Verify that the cases have been assigned to the correct owners/queues
        Case updatedCase1 = [SELECT Id, OwnerId FROM Case WHERE Id = :case1.Id];
        Case updatedCase2 = [SELECT Id, OwnerId FROM Case WHERE Id = :case2.Id];
    
        // Case 1: Should remain with the original owner (testUser)
        System.assertEquals(testUser.Id, updatedCase1.OwnerId, 'Owner should remain the same for Case 1 as the user has the Benestar skill.');

        // Case 2: Should be reassigned to the Recaudacion queue
        System.assertEquals(recaudacionQueue.Id, updatedCase2.OwnerId, 'Owner should be reassigned to Recaudacion queue for Case 2.');
    }
}