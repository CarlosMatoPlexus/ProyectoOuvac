public with sharing class RouteCasesBasedOnSkills {

    private static Id getSkillId(String skillName) {
        Skill skill = [SELECT Id FROM Skill WHERE MasterLabel = :skillName LIMIT 1];
        return (skill != null) ? skill.Id : null;
    }

    public static void RouteCasesBasedOnSkills(List<Case> casesObj) {
        
        List<ServiceChannel> servChannelList = [SELECT Id, DeveloperName FROM ServiceChannel WHERE DeveloperName = 'caseChannel'];
        Id serviceChannelId = servChannelList[0].Id;
        
        Map<String, Id> skillMap = new Map<String, Id>();
        for (Skill skillObj : [SELECT Id, MasterLabel FROM Skill]) {
            skillMap.put(skillObj.MasterLabel, skillObj.Id);
        }
        
        for (Case cs : casesObj) {
            
            if (cs.Origin == 'Presencial' || cs.Origin == 'Phone' || cs.Origin == 'Chat') {
                continue;
            }
            
            System.debug('Case Origin: ' + cs.Origin);
            
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
                if (skillMap.containsKey('Otras')) {
                    skillNeededList.add(skillMap.get('Otras'));
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
                } else if (cs.ambitos__c == 'Otras' && skillMap.containsKey('Otras')) {
                    skillNeededList.add(skillMap.get('Otras'));
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
        
        Id benestarQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Benestar' LIMIT 1].Id;
        Id recaudacionQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Recaudacion' LIMIT 1].Id;
        Id asesoriaJuridicaQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Asesoria_Juridica' LIMIT 1].Id;
        Id contratacionQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Contratacion' LIMIT 1].Id;
        Id culturaYdeportesQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Cultura_y_Deportes' LIMIT 1].Id;
        Id infraestructurasQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Infraestructuras' LIMIT 1].Id;
        Id intervencionQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Intervencion' LIMIT 1].Id;
        Id medioAmbienteQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Medio_Ambiente' LIMIT 1].Id;
        Id otrasQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Otras' LIMIT 1].Id;
        Id rrhhQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'RRHH' LIMIT 1].Id;
        Id tramitacionElectronicaQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Tramitacion_Electronica' LIMIT 1].Id;
        Id transparenciaQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Transparencia' LIMIT 1].Id;
        Id turismoQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Turismo' LIMIT 1].Id;
        
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
        ambitoToSkillMap.put('Otras', getSkillId('Otras'));
        
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
                        if (newCase.ambitos__c == 'Benestar') {
                            ownerIdToAssign = benestarQueueId;
                        } else if (newCase.ambitos__c == 'Recaudación') {
                            ownerIdToAssign = recaudacionQueueId;
                        } else if (newCase.ambitos__c == 'Asesoría Jurídica (legal)') {
                            ownerIdToAssign = asesoriaJuridicaQueueId;
                        } else if (newCase.ambitos__c == 'Contratación') {
                            ownerIdToAssign = contratacionQueueId;
                        } else if (newCase.ambitos__c == 'Cultura y Deportes') {
                            ownerIdToAssign = culturaYdeportesQueueId;
                        } else if (newCase.ambitos__c == 'Infraestructuras (Vías y Obras)') {
                            ownerIdToAssign = infraestructurasQueueId;
                        } else if (newCase.ambitos__c == 'Intervención') {
                            ownerIdToAssign = intervencionQueueId;
                        } else if (newCase.ambitos__c == 'Medio Ambiente') {
                            ownerIdToAssign = medioAmbienteQueueId;
                        } else if (newCase.ambitos__c == 'Otras') {
                            ownerIdToAssign = otrasQueueId;
                        } else if (newCase.ambitos__c == 'RRHH (Ofertas de empleo)') {
                            ownerIdToAssign = rrhhQueueId;
                        } else if (newCase.ambitos__c == 'Tramitación electrónica') {
                            ownerIdToAssign = tramitacionElectronicaQueueId;
                        } else if (newCase.ambitos__c == 'Tramitación electrónica') {
                            ownerIdToAssign = tramitacionElectronicaQueueId;
                        } else if (newCase.ambitos__c == 'Transparencia') {
                            ownerIdToAssign = transparenciaQueueId;
                        } else if (newCase.ambitos__c == 'Turismo') {
                            ownerIdToAssign = turismoQueueId;
                        }
                    }
                    
                    if (canAssign && newCase.Status != 'Finalizado') {
                        Case caseToUpdate = new Case(Id = newCase.Id);
                        caseToUpdate.OwnerId = ownerIdToAssign;
                        if (oldCase.Status == 'En Progreso') {
                            caseToUpdate.Status = 'Pendiente';
                        }
                        casesToUpdate.add(caseToUpdate);
                    }
                }
            }
        }
        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
    
    @InvocableMethod(label='Handle Ambitos Change' description='Reasigna el caso si el propietario no tiene el skill para el ámbito.')
    public static void handleAmbitosNotChange(List<Case> cases) {
        
        // Las IDs de las colas para los distintos ámbitos
        Id benestarQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Benestar' LIMIT 1].Id;
        Id recaudacionQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Recaudacion' LIMIT 1].Id;
        Id asesoriaJuridicaQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Asesoria_Juridica' LIMIT 1].Id;
        Id contratacionQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Contratacion' LIMIT 1].Id;
        Id culturaYdeportesQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Cultura_y_Deportes' LIMIT 1].Id;
        Id infraestructurasQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Infraestructuras' LIMIT 1].Id;
        Id intervencionQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Intervencion' LIMIT 1].Id;
        Id medioAmbienteQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Medio_Ambiente' LIMIT 1].Id;
        Id otrasQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Otras' LIMIT 1].Id;
        Id rrhhQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'RRHH' LIMIT 1].Id;
        Id tramitacionElectronicaQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Tramitacion_Electronica' LIMIT 1].Id;
        Id transparenciaQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Transparencia' LIMIT 1].Id;
        Id turismoQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Turismo' LIMIT 1].Id;
        
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
        ambitoToSkillMap.put('Otras', getSkillId('Otras'));
        
        List<Case> casesToUpdate = new List<Case>();
        
        for (Case caseRecord : cases) {
            Id ownerId = caseRecord.OwnerId;
            Id ambitoSkillId = ambitoToSkillMap.get(caseRecord.ambitos__c);
            
            if (ambitoSkillId != null) {
                Set<Id> ownerSkills = new Set<Id>();
                
                for (ServiceResource sr : [SELECT Id, RelatedRecordId, (SELECT SkillId FROM ServiceResourceSkills) FROM ServiceResource WHERE RelatedRecordId = :ownerId]) {
                    for (ServiceResourceSkill srs : sr.ServiceResourceSkills) {
                        ownerSkills.add(srs.SkillId);
                    }
                }
                
                if (!ownerSkills.contains(ambitoSkillId)) {
                    Id ownerIdToAssign;
                    
                    if (caseRecord.ambitos__c == 'Benestar') {
                        ownerIdToAssign = benestarQueueId;
                    } else if (caseRecord.ambitos__c == 'Recaudación') {
                        ownerIdToAssign = recaudacionQueueId;
                    } else if (caseRecord.ambitos__c == 'Asesoría Jurídica (legal)') {
                        ownerIdToAssign = asesoriaJuridicaQueueId;
                    } else if (caseRecord.ambitos__c == 'Contratación') {
                        ownerIdToAssign = contratacionQueueId;
                    } else if (caseRecord.ambitos__c == 'Cultura y Deportes') {
                        ownerIdToAssign = culturaYdeportesQueueId;
                    } else if (caseRecord.ambitos__c == 'Infraestructuras (Vías y Obras)') {
                        ownerIdToAssign = infraestructurasQueueId;
                    } else if (caseRecord.ambitos__c == 'Intervención') {
                        ownerIdToAssign = intervencionQueueId;
                    } else if (caseRecord.ambitos__c == 'Medio Ambiente') {
                        ownerIdToAssign = medioAmbienteQueueId;
                    } else if (caseRecord.ambitos__c == 'Otras') {
                        ownerIdToAssign = otrasQueueId;
                    } else if (caseRecord.ambitos__c == 'RRHH (Ofertas de empleo)') {
                        ownerIdToAssign = rrhhQueueId;
                    } else if (caseRecord.ambitos__c == 'Tramitación electrónica') {
                        ownerIdToAssign = tramitacionElectronicaQueueId;
                    } else if (caseRecord.ambitos__c == 'Transparencia') {
                        ownerIdToAssign = transparenciaQueueId;
                    } else if (caseRecord.ambitos__c == 'Turismo') {
                        ownerIdToAssign = turismoQueueId;
                    }
                    
                    caseRecord.OwnerId = ownerIdToAssign;
                    if (caseRecord.Status == 'En Progreso') {
                        caseRecord.Status = 'Pendiente';
                    }
                    casesToUpdate.add(caseRecord);
                }
            }
        }
        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }

    public static void handleCaseStatusChange(Map<Id, Case> oldMap, Map<Id, Case> newMap) {
        List<Case> casesToUpdate = new List<Case>();
    
        for (Id caseId : newMap.keySet()) {
            Case oldCase = oldMap.get(caseId);
            Case newCase = newMap.get(caseId);
    
            if (oldCase.Status != newCase.Status) {
                if (newCase.Status == 'Finalizado' || newCase.Status == 'Cerrado') {
                    Case caseToUpdate = new Case(Id = newCase.Id);
                    caseToUpdate.OwnerId = UserInfo.getUserId();
                    casesToUpdate.add(caseToUpdate);
                }
            }
        }
    
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
}

