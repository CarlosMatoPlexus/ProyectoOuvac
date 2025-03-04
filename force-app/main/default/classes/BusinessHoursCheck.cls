public with sharing class BusinessHoursCheck {
    @InvocableMethod(label='Check Business Hours' description='Returns true if the message is outside business hours or on a holiday')
    public static List<Boolean> isOutsideBusinessHours(List<Datetime> messageTimestamps) {
        List<Boolean> results = new List<Boolean>();
        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1].Id;
        Set<Date> holidays = new Set<Date>();

        for (Holiday h : [SELECT ActivityDate FROM Holiday WHERE ActivityDate != NULL]) {
            holidays.add(h.ActivityDate);
        }

        for (Datetime dt : messageTimestamps) {
            Date messageDate = dt.date();
            Boolean isHoliday = holidays.contains(messageDate);
            Boolean isWithinBusinessHours = BusinessHours.isWithin(businessHoursId, dt);
            results.add(isHoliday || !isWithinBusinessHours);
        }
        return results;
    }
}