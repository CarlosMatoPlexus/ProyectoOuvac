@isTest
public class ConvocatoriaServiceTest {
    @isTest
    static void testProcesarConvocatoria() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetConvocatoriasMock());
        // Ejecutar el método
        Test.startTest();
        List<String> detallesJson = new List<String>();
        List<String>  scope = new List<String>();
        scope.add('321902');
        String token = 'mockToken123';
        detallesJson = APIGetConvocatorias.obtenerDetallesConvocatorias(scope, token);
        ConvocatoriaService.procesarConvocatoria(detallesJson);
        Test.stopTest();
        // Verificar si se insertaron 2 registros de Knowledge__kav
        List<Knowledge__kav> knowledgeList = [SELECT Id, code_bdns__c, Descripcion__c, RecordTypeId, Language FROM Knowledge__kav WHERE code_bdns__c = '321902'];
        System.assertEquals(2, knowledgeList.size(), 'Se deben haber insertado 2 registros de Knowledge__kav');
        // Verificar si uno de los registros está en español y otro en español mexicano
        Knowledge__kav knowCastellano = null;
        Knowledge__kav knowOtraLengua = null;
        for (Knowledge__kav know : knowledgeList) {
            if (know.RecordTypeId == Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Convocatoria').getRecordTypeId()) {
                if (know.Language == 'es') {
                    knowCastellano = know;
                } else if (know.Language == 'es_MX') {
                    knowOtraLengua = know;
                }
            }
        }
        System.assertEquals('es', knowCastellano.Language, 'El registro en español debe existir en Salesforce.');
        System.assertEquals('es_MX', knowOtraLengua.Language, 'El registro en galego debe existir en Salesforce.');
    }
    
    // Mock class para simular las respuestas de las llamadas HTTP
    private class APIGetConvocatoriasMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            // Simulación de la respuesta de login
            if (req.getEndpoint().contains('/login_check')) {
                res.setBody('{"token": "mockToken123", "refresh_token": "mockRefreshToken123", "refresh_token_expiration": 1729701726}');
            }
            // Simulación de la respuesta JSON de la API para convocatorias
            else if (req.getEndpoint().contains('/convocatorias/321902')) {
                // Usar DateTime.now() para simular la fecha actual y asegurar la actualización
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('{'+
                    '    "code_bdns": "321902",'+
                    '    "fecha_recepcion": "2016-11-08T01:00:00+01:00",'+
                    '    "descripcion": "Acuerdo de Junta de Gobierno de 29/09/2016 por el que se convocan subvenciones a deportistas orensanos cualificados en modalidades deportivas individuales del año 2016",'+
                    '    "importe_total": 25000,'+
                    '    "fondo_ue": false,'+
                    '    "tema": "/api/temas/008",'+
                    '    "version_json": null,'+
                    '    "activo": true,'+
                    '    "fecha_creacion": "2024-07-11T14:29:00+02:00",'+
                        '"fecha_modificacion": "' + fechaActual + '",' +
                    '    "data_json": {'+
                    '        "DatosGeneralesCov": {'+
                    '            "IdConvocatoria": "321902",'+
                    '            "FechaRecepcion": "2016-11-08",'+
                    '            "Estado": "V",'+
                    '            "Propietario": {'+
                    '                "OrganoGestor": "L02000032",'+
                    '                "DescripcionOrgano": "DIPUTACIÓN PROVINCIAL DE OURENSE"'+
                    '            },'+
                    '            "ReferenciaExterna": "10/2017",'+
                    '            "DescripcionCov": "Acuerdo de Junta de Gobierno de 29/09/2016 por el que se convocan subvenciones a deportistas orensanos cualificados en modalidades deportivas individuales del año 2016",'+
                    '            "DocumentoCastellano": {'+
                    '                "Nombre": "Bases deportivas cualificados 2016.pdf",'+
                    '                "Fichero": "",'+
                    '                "TipoDocumento": "5"'+
                    '            },'+
                    '            "DocumentoOtraLengua": {'+
                    '                "Nombre": "Acordo bases deportistas cualificados 2016. 29.09.2016.pdf",'+
                    '                "Fichero": "",'+
                    '                "TipoDocumento": "6"'+
                    '            }'+
                    '        },'+
                    '        "DatosBaseReguladora": {'+
                    '            "Nomenclatura": "10/2017",'+
                    '            "DiarioOficialBR": {'+
                    '                "codigo": "50",'+
                    '                "nombre": "B.O.P. DE OURENSE"'+
                    '            },'+
                    '            "DescripcionBR": "Bases reguladoras del concurso de subvenciones a deportistas orensanos cualificados en modalidades deportivas individuales del año 2016",'+
                    '            "URLEspBR": "http://www.depourense.es/index.php/seccion-de-subvencions/negociadoconcursos",'+
                    '            "URLengBR": "http://www.depourense.es/index.php/seccion-de-subvencions/negociadoconcursos"'+
                    '        },'+
                    '        "DatosSolicitudJustificacionFinanciacion": {'+
                    '            "Solicitud": {'+
                    '                "Abierto": "0",'+
                    '                "InicioSolicitud": "Publicación en el BOP",'+
                    '                "FechaFinSolicitud": "2016-12-20"'+
                    '            },'+
                    '            "Justificacion": {'+
                    '                "codigo": "PRE",'+
                    '                "nombre": "JUSTIFICACIÓN PREVIA (AL ÚNICO O AL ÚLTIMO PAGO)"'+
                    '            },'+
                    '            "TiposFinanciacion": ['+
                    '                {'+
                    '                    "TipoFinanciacion": {'+
                    '                        "codigo": "PEL",'+
                    '                        "nombre": "Presupuestos Generales de las Entidades Locales"'+
                    '                    },'+
                    '                    "ImporteFinanciacion": "25000"'+
                    '                }'+
                    '            ]'+
                    '        },'+
                    '        "OtrosDatos": {'+
                    '            "Sectores": ['+
                    '                {'+
                    '                    "codigo": "93.1",'+
                    '                    "nombre": "Actividades deportivas"'+
                    '                }'+
                    '            ],'+
                    '            "Regiones": ['+
                    '                {'+
                    '                    "codigo": "ES113",'+
                    '                    "nombre": "Ourense"'+
                    '                }'+
                    '            ],'+
                    '            "Instrumentos": ['+
                    '                {'+
                    '                    "codigo": "SUBV",'+
                    '                    "nombre": "SUBVENCIÓN y ENTREGA DINERARIA SIN CONTRAPRESTACIÓN"'+
                    '                }'+
                    '            ],'+
                    '            "TiposBeneficiario": ['+
                    '                {'+
                    '                    "codigo": "FSA",'+
                    '                    "nombre": "PERSONAS FÍSICAS QUE NO DESARROLLAN ACTIVIDAD ECONÓMICA"'+
                    '                }'+
                    '            ],'+
                    '            "Finalidad": {'+
                    '                "codigo": "4",'+
                    '                "nombre": "Otras Prestaciones económicas"'+
                    '            },'+
                    '            "ImpactoGenero": {'+
                    '                "codigo": "2",'+
                    '                "nombre": "Nulo. Cuando no existiendo desigualdades de partida en relación a la igualdad de oportunidades y de trato entre mujeres y hombres, no se prevea modificación alguna de esta situación"'+
                    '            },'+
                    '            "ConcesionPublicable": "1",'+
                    '            "SubvencionNominativa": "0",'+
                    '            "TipoConvocatoria": "1",'+
                    '            "ProcedimientoConcesion": "2",'+
                    '            "Contribucion": "0",'+
                    '            "Desierta": "0",'+
                    '            "Regularizar": "0",'+
                    '            "Anulada": "0"'+
                    '        },'+
                    '        "OtrosDocumentos": ['+
                    '            {'+
                    '                "DescripcionOtro": "Ordenanza general de subvenciones de la Diputación Provincial de Ourense",'+
                    '                "Nombre": "Ordenanza general de subvenciones.pdf",'+
                    '                "Fichero": "",'+
                    '                "TipoDocumento": {'+
                    '                    "codigo": "9",'+
                    '                    "nombre": "Otros"'+
                    '                }'+
                    '            },'+
                    '            {'+
                    '                "DescripcionOtro": "Anexos bases",'+
                    '                "Nombre": "Anexos bases deportistas cualificados 2016.pdf",'+
                    '                "Fichero": "",'+
                    '                "TipoDocumento": {'+
                    '                    "codigo": "9",'+
                    '                    "nombre": "Otros"'+
                    '                }'+
                    '            }'+
                    '        ],'+
                    '        "Extractos": ['+
                    '            {'+
                    '                "DiarioOficial": "50",'+
                    '                "ExtractoCastellano": {'+
                    '                    "TituloExtracto": "Extracto de la convocatoria del procedimiento de concurrencia competitiva para concesión de subvenciones  a deportistas orensanos cualificados en modalidades deportivas individuales del año 2016",'+
                    '                    "TextoExtractoCastellano": {'+
                    '                        "p": ['+
                    '                            "De conformidad con lo previsto en los artículos 17.3.b y 20.8.a de la Ley 38/2003, de 17 de noviembre, General de Subvenciones, se publica el extracto de la convocatoria del “procedimiento de concurrencia competitiva para concesión de subvenciones  a deportistas orensanos cualificados en modalidades deportivas individuales del año 2016”, cuyo texto completo puede consultarse en la Base de Datos Nacional de Subvenciones (http://www.pap.minhap.gob.es/bdnstrans/index):",'+
                    '                            "BDNS: 321902",'+
                    '                            "Primero. Beneficiarios:",'+
                    '                            "Podrán ser beneficiarios de esta subvención las personas físicas que sean deportistas federados, de categorías de base hasta absoluta, y exclusivamente de modalidades deportivas individuales (excluyéndose, por tanto, los practicantes de deportes de equipo) de nacionalidad española o residentes legales en España, que cumplan alguno de los requisitos establecidos en las bases.",'+
                    '                            "Segundo. Objeto:",'+
                    '                            "La finalidad de esta subvención es fomentar la práctica deportiva e incentivar a los deportistas orensanos cualificados mediante el reconocimiento de su trayectoria y rendimiento deportivo.",'+
                    '                            "Tercero. Bases reguladoras:",'+
                    '                            "Acuerdo de Junta de Gobierno de 29 de septiembre de 2016 por la que se establecen las bases reguladoras y se anuncia la convocatoria de subvenciones a deportistas orensanos cualificados en modalidades deportivas individuales del año 2016.",'+
                    '                            "Cuarto. Importe:",'+
                    '                            "El importe de la consignación prevista asciende a un total de 25.000 euros, con cargo a la aplicación 341.11/482.00 de los presupuestos de la Diputación Provincial de Ourense para el ejercicio 2017",'+
                    '                            "Quinto. Plazo de presentación de solicitudes:",'+
                    '                            "El plazo de solicitud se iniciará a partir del día siguiente al de la publicación del presente extracto de convocatoria en el BOP de Ourense, y finalizará el 20 de diciembre de 2016"'+
                    '                        ]'+
                    '                    },'+
                    '                    "PieFirmaExtracto": {'+
                    '                        "FechaFirma": "2016-11-09",'+
                    '                        "LugarFirma": "Ourense",'+
                    '                        "Firmante": "José Manuel Baltar Blanco"'+
                    '                    }'+
                    '                },'+
                    '                "ExtractoOtraLengua": {'+
                    '                    "TituloExtracto": "Extracto da convocatoria do procedemento de concorrencia competitiva para a concesión de subvencións a deportistas ourensáns cualificados en modalidades deportivas individuais do ano 2016",'+
                    '                    "TextoExtractoOtraLengua": {'+
                    '                        "p": ['+
                    '                            "BDNS: 321902",'+
                    '                            "De conformidade co previsto nos artigos 17.3.b e 20.8.a da Lei 38/2003, do 17 de novembro, xeral de subvencións, publícase o extracto da convocatoria do “procedemento de concorrencia competitiva para concesión de subvencións a deportistas ourensáns cualificados en modalidades deportivas individuais do ano 2016”, cuxo texto completo pode consultarse na Base de Datos Nacional de Subvencións (http://www.pap.minhap.gob.es/bdnstrans/index):",'+
                    '                            "Primeiro. Beneficiarios:",'+
                    '                            "Poderán ser beneficiarios desta subvención as persoas físicas que sexan deportistas federados, de categorías de base até absoluta, e exclusivamente de modalidades deportivas individuais (excluíndose, por tanto, os practicantes de deportes de equipo) de nacionalidade española ou residentes legais en España, que cumpran algún dos requisitos establecidos nas bases.",'+
                    '                            "Segundo. Obxecto:",'+
                    '                            "A finalidade desta subvención é fomentar a práctica deportiva e incentivar aos deportistas ourensáns cualificados mediante o recoñecemento da súa traxectoria e rendemento deportivo.",'+
                    '                            "Terceiro. Bases reguladoras:",'+
                    '                            "Acordo da Xunta de Goberno do 29 de setembro de 2016 polo que se establecen as bases reguladoras e se anuncia a convocatoria de subvencións a deportistas ourensáns cualificados en modalidades deportivas individuais do ano 2016.",'+
                    '                            "Cuarto. Importe:",'+
                    '                            "O importe da consignación prevista ascende a un total de 25.000 euros, con cargo á aplicación 341.11/482.00 dos orzamentos da Deputación Provincial de Ourense para o exercicio 2017.",'+
                    '                            "Quinto. Prazo de presentación de solicitudes:",'+
                    '                            "O prazo de solicitude iniciarase a partir do día seguinte ao da publicación do presente extracto de convocatoria no BOP de Ourense, e finalizará o 20 de decembro de 2016."'+
                    '                        ]'+
                    '                    },'+
                    '                    "PieFirmaExtracto": {'+
                    '                        "FechaFirma": "2016-11-09",'+
                    '                        "LugarFirma": "Ourense",'+
                    '                        "Firmante": "José Manuel Baltar Blanco"'+
                    '                    }'+
                    '                },'+
                    '                "FechaEnvio": "2016-11-10",'+
                    '                "Publicacion": {'+
                    '                    "IdExtractoDiarioOficial": "BOP Ourense nº 264",'+
                    '                    "EstadoPublicacion": {'+
                    '                        "Publicado": {'+
                    '                            "FechaPublicacion": "2016-11-17",'+
                    '                            "URL": "https://bop.depourense.es/portal/cambioBoletin.do"'+
                    '                        }'+
                    '                    }'+
                    '                }'+
                    '            }'+
                    '        ]'+
                    '    }'+
                    '}');
            }
            return res;
        }
    }
}