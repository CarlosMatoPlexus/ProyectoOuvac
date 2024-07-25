@isTest
public class RouteCasesBasedOnSkillsTest {

    @testSetup
    static void setupTestData() {
        // Ensure ServiceChannel exists
        List<ServiceChannel> serviceChannels = [SELECT Id, DeveloperName FROM ServiceChannel WHERE DeveloperName = 'caseChannel'];
        if (serviceChannels.isEmpty()) {
            System.assert(false, 'ServiceChannel with DeveloperName "caseChannel" does not exist. Ensure it exists before running tests.');
        }

        // Ensure Skills exist
        List<String> skillNames = new List<String>{'General', 'Benestar', 'Asesoría Jurídica', 'Contratación', 'Cultura y Deportes', 'Infraestructuras (Vías y Obras)', 
                                                    'Intervención', 'Medio Ambiente', 'RRHH', 'Recaudación', 'Tramitación electrónica', 'Transparencia', 'Turismo'};
        List<Skill> skills = [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel IN :skillNames];
        Set<String> existingSkillNames = new Set<String>();
        for (Skill skill : skills) {
            existingSkillNames.add(skill.MasterLabel);
        }

        if (existingSkillNames.size() != skillNames.size()) {
            System.assert(false, 'Not all required Skills exist. Ensure all required Skills are created before running tests.');
        }
        // Create User
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuserdeputacion@example.com'
        );
        insert testUser;
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
            new Case(Subject = 'Case 13', ambitos__c = 'Turismo')
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
        System.assertEquals(13, psrs.size(), 'There should be 3 PendingServiceRouting records.');

        List<SkillRequirement> skillRequirements = [SELECT Id, SkillId, RelatedRecordId FROM SkillRequirement WHERE RelatedRecordId IN :psrs];
        System.assertEquals(13, skillRequirements.size(), 'There should be 3 SkillRequirement records.');

        // Verify that PendingServiceRouting records are ready for routing
        for (PendingServiceRouting psr : psrs) {
            System.assertEquals(true, psr.IsReadyForRouting, 'PendingServiceRouting should be ready for routing.');
        }
    }
    @isTest
    static void testOwnerDoesNotChangeIfHasSkill() {
        // Get the test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'testuser' LIMIT 1];

        // Assign the skill 'Benestar' to the test user
        Skill benestarSkill = [SELECT Id FROM Skill WHERE MasterLabel = 'Benestar' LIMIT 1];
        ServiceResource sr = new ServiceResource(RelatedRecordId = testUser.Id, ResourceType = 'A',Name = 'Test2', IsActive = true);
        insert sr;
        ServiceResourceSkill srs = new ServiceResourceSkill(ServiceResourceId = sr.Id, SkillId = benestarSkill.Id, effectiveStartDate = Date.today());
        insert srs;

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
}

