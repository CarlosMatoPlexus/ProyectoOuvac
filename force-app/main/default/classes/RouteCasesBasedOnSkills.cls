public with sharing class RouteCasesBasedOnSkills {
    public static void RouteCasesBasedOnSkills(List<Case> casesObj) {

        List<ServiceChannel> servChannelList = [SELECT Id, DeveloperName FROM ServiceChannel WHERE DeveloperName = 'caseChannel'];
        Id serviceChannelId = servChannelList[0].Id;
    
        Map<String, Id> skillMap = new Map<String, Id>();
        for (Skill skillObj : [SELECT Id, MasterLabel FROM Skill]) {
            skillMap.put(skillObj.MasterLabel, skillObj.Id);
        }
    
        for (Case cs : casesObj) {
            PendingServiceRouting psr = new PendingServiceRouting();
            psr.WorkItemId = cs.Id;
            psr.ServiceChannelId = serviceChannelId;
            psr.RoutingType = 'SkillsBased';
            psr.RoutingPriority = 1;
            psr.CapacityWeight = 1;
            psr.RoutingModel = 'MostAvailable';
            psr.IsReadyForRouting = false;
            insert psr;
    
            List<Id> skillNeededList = new List<Id>();
    
            if (String.isBlank(cs.ambitos__c)) {
                if (skillMap.containsKey('General')) {
                    skillNeededList.add(skillMap.get('General'));
                }
            } else {
                if (cs.ambitos__c == 'Benestar' && skillMap.containsKey('Benestar')) {
                    skillNeededList.add(skillMap.get('Benestar'));
                } else if (cs.ambitos__c == 'Asesoría Jurídica (legal)' && skillMap.containsKey('Asesoría Jurídica')) {
                    skillNeededList.add(skillMap.get('Asesoría Jurídica'));
                } else if (cs.ambitos__c == 'Contratación' && skillMap.containsKey('Contratación')) {
                    skillNeededList.add(skillMap.get('Contratación'));
                } else if (cs.ambitos__c == 'Cultura y Deportes' && skillMap.containsKey('Cultura y Deportes')) {
                    skillNeededList.add(skillMap.get('Cultura y Deportes'));
                } else if (cs.ambitos__c == 'Infraestructuras (Vías y Obras)' && skillMap.containsKey('Infraestructuras (Vías y Obras)')) {
                    skillNeededList.add(skillMap.get('Infraestructuras (Vías y Obras)'));
                } else if (cs.ambitos__c == 'Intervención' && skillMap.containsKey('Intervención')) {
                    skillNeededList.add(skillMap.get('Intervención'));
                } else if (cs.ambitos__c == 'Medio Ambiente' && skillMap.containsKey('Medio Ambiente')) {
                    skillNeededList.add(skillMap.get('Medio Ambiente'));
                } else if (cs.ambitos__c == 'RRHH (Ofertas de empleo)' && skillMap.containsKey('RRHH')) {
                    skillNeededList.add(skillMap.get('RRHH'));
                } else if (cs.ambitos__c == 'Recaudación' && skillMap.containsKey('Recaudación')) {
                    skillNeededList.add(skillMap.get('Recaudación'));
                } else if (cs.ambitos__c == 'Tramitación electrónica' && skillMap.containsKey('Tramitación electrónica')) {
                    skillNeededList.add(skillMap.get('Tramitación electrónica'));
                } else if (cs.ambitos__c == 'Transparencia' && skillMap.containsKey('Transparencia')) {
                    skillNeededList.add(skillMap.get('Transparencia'));
                } else if (cs.ambitos__c == 'Turismo' && skillMap.containsKey('Turismo')) {
                    skillNeededList.add(skillMap.get('Turismo'));
                } else if (cs.ambitos__c == 'Otras' && skillMap.containsKey('General')) {
                    skillNeededList.add(skillMap.get('General'));
                }
            }
    
            List<SkillRequirement> lstSkillReq = new List<SkillRequirement>();
            for (Id skillNeeded : skillNeededList) {
                SkillRequirement skillreq = new SkillRequirement();
                skillreq.SkillId = skillNeeded;
                skillreq.RelatedRecordId = psr.Id;
                skillreq.skilllevel = 5;
                lstSkillReq.add(skillreq);
            }
            insert lstSkillReq;
    
            psr.IsReadyForRouting = true;
            update psr;
        }
    }
    public static void handleAmbitosChange(Map<Id, Case> oldMap, Map<Id, Case> newMap) {
        
        Id benestarQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Benestar_cases' LIMIT 1].Id;
        Id generalQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'General' LIMIT 1].Id;
    
        Map<String, Id> ambitoToSkillMap = new Map<String, Id>();
        ambitoToSkillMap.put('Benestar', getSkillId('Benestar'));
        ambitoToSkillMap.put('Asesoría Jurídica (legal)', getSkillId('Asesoría Jurídica'));
        ambitoToSkillMap.put('Contratación', getSkillId('Contratación'));
        ambitoToSkillMap.put('Cultura y Deportes', getSkillId('Cultura y Deportes'));
        ambitoToSkillMap.put('Infraestructuras (Vías y Obras)', getSkillId('Infraestructuras (Vías y Obras)'));
        ambitoToSkillMap.put('Intervención', getSkillId('Intervención'));
        ambitoToSkillMap.put('Medio Ambiente', getSkillId('Medio Ambiente'));
        ambitoToSkillMap.put('RRHH (Ofertas de empleo)', getSkillId('RRHH'));
        ambitoToSkillMap.put('Recaudación', getSkillId('Recaudación'));
        ambitoToSkillMap.put('Tramitación electrónica', getSkillId('Tramitación electrónica'));
        ambitoToSkillMap.put('Transparencia', getSkillId('Transparencia'));
        ambitoToSkillMap.put('Turismo', getSkillId('Turismo'));
        ambitoToSkillMap.put('Otras', getSkillId('General'));
    
        Set<Id> ownerIds = new Set<Id>();
        for (Case c : oldMap.values()) {
            ownerIds.add(c.OwnerId);
        }
    
        Map<Id, Set<Id>> userSkillsMap = new Map<Id, Set<Id>>();
        for (ServiceResource sr : [SELECT Id, RelatedRecordId, Name, (SELECT SkillId FROM ServiceResourceSkills) FROM ServiceResource WHERE RelatedRecordId IN :ownerIds]) {
            if (!userSkillsMap.containsKey(sr.RelatedRecordId)) {
                userSkillsMap.put(sr.RelatedRecordId, new Set<Id>());
            }
            for (ServiceResourceSkill srs : sr.ServiceResourceSkills) {
                userSkillsMap.get(sr.RelatedRecordId).add(srs.SkillId);
            }
        }
    
        List<Case> casesToUpdate = new List<Case>();
    
        for (Id caseId : newMap.keySet()) {
            Case oldCase = oldMap.get(caseId);
            Case newCase = newMap.get(caseId);
    
            if (oldCase.ambitos__c != newCase.ambitos__c) {
                Id newSkillId = ambitoToSkillMap.get(newCase.ambitos__c);
                if (newSkillId != null) {
                    Boolean canAssign = true;
                    Id ownerIdToAssign = oldCase.OwnerId;
    
                    Set<Id> ownerSkills = userSkillsMap.get(oldCase.OwnerId);
                    if (ownerSkills != null && ownerSkills.contains(newSkillId)) {
                        canAssign = false;
                    } else {
                        ownerIdToAssign = (newCase.ambitos__c == 'Benestar') ? benestarQueueId : generalQueueId;
                    }
    
                    if (canAssign) {
                        Case caseToUpdate = new Case(Id = newCase.Id);
                        caseToUpdate.OwnerId = ownerIdToAssign;
                        casesToUpdate.add(caseToUpdate);
                    }
                }
            }
        }
    
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
    
    private static Id getSkillId(String skillName) {
        Skill skill = [SELECT Id FROM Skill WHERE MasterLabel = :skillName LIMIT 1];
        return (skill != null) ? skill.Id : null;
    }
}