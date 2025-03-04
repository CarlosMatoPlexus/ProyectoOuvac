@isTest
private class BusinessHoursCheckTest {
    
    @testSetup
    static void setupTestData() {
        
        if ([SELECT COUNT() FROM BusinessHours WHERE IsDefault = true] == 0) {
            System.debug('No default BusinessHours found. Please ensure one exists in the org.');
        }

        Holiday holiday = new Holiday(
            Name = 'Test Holiday',
            ActivityDate = Date.today().addDays(1),
            IsAllDay = true
        );
        insert holiday;
    }

    @isTest
    static void testWithinBusinessHours() {
        
        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1].Id;
        Datetime businessTime = BusinessHours.nextStartDate(businessHoursId, Datetime.now());
        List<Boolean> results = BusinessHoursCheck.isOutsideBusinessHours(new List<Datetime>{businessTime});
        System.assertEquals(true, results[0], 'El mensaje debería estar dentro del horario laboral');
    }

    @isTest
    static void testOutsideBusinessHours() {
        
        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1].Id;
        Datetime afterHours = BusinessHours.nextStartDate(businessHoursId, Datetime.now()).addHours(-10);
        List<Boolean> results = BusinessHoursCheck.isOutsideBusinessHours(new List<Datetime>{afterHours});
        System.assertEquals(true, results[0], 'El mensaje debería estar fuera del horario laboral');
    }
}