@isTest
public class TramiteTest {
    @isTest
    public static void testTramiteDeserialization() {
        // JSON de ejemplo
        String jsonDet='{'+
            '    "id": 514,'+
            '    "codigo": "001/2666943",'+
            '    "titulo": "Abastecimiento de Aguas (Baja)",'+
            '    "descripcion": "Permite tramitar expedientes relativos a la baja en el servicio público de abastecimiento y saneamiento de agua.",'+
            '    "institucion": {'+
            '        "code": "001",'+
            '        "name": "Allariz"'+
            '    },'+
            '    "tema": {'+
            '        "code": "011",'+
            '        "name": "Tramitación electrónica"'+
            '    },'+
            '    "activo": true,'+
            '    "fecha_creacion": "2024-08-06T12:52:19+02:00",'+
            '    "fecha_modificacion": "2024-08-21T20:57:16+02:00",'+
            '    "data_es_json": {'+
            '        "codigo": "2666943",'+
            '        "titulo": "Abastecimiento de Aguas (Baja)",'+
            '        "descripcion": "Permite tramitar expedientes relativos a la baja en el servicio público de abastecimiento y saneamiento de agua.",'+
            '        "finalidad": "",'+
            '        "requisitos": "Según la normativa aplicable la iniciación de este procedimiento podrá ser tanto de oficio como a instancia de parte.",'+
            '        "plazoPresentacion": "Continuo",'+
            '        "presentacion": "",'+
            '        "presentarPor": "",'+
            '        "organoGestor": "",'+
            '        "plazoResolucion": "Según normativa aplicable",'+
            '        "efectoSilencioAdministrativo": "Según normativa aplicable",'+
            '        "recursos": "",'+
            '        "normativaBasica": "",'+
            '        "coleccionNormativas": ['+
            '            {'+
            '                "titulo": "Ley 39/2015, de 1 de octubre, del Procedimiento Administrativo Común de las Administraciones Públicas.",'+
            '                "url": "https://www.boe.es/legislacion"'+
            '            },'+
            '            {'+
            '                "titulo": "Ley 7/1985, de 2 de abril, reguladora de las Bases del Régimen Local.",'+
            '                "url": "https://www.boe.es/legislacion"'+
            '            }'+
            '        ],'+
            '        "informacionAdicional": "",'+
            '        "nivelIdentificacionSolicitante": "",'+
            '        "coleccionDocumentos": [],'+
            '        "urlInicioTramitacion": "https://allariz.sedelectronica.gal/catalog/tw/27666b59-7238-4f55-9968-d45406f433f9",'+
            '        "urlDescargaInstancia": "?x=ezozc-EQNg7eJccPZ9FOYjFy9U4CxBq6Hoa0ysvF18RF2jpGNmnzfG4-TZyuKEEtQX2r1qgcSemr0xdsTTjchw",'+
            '        "urlDetalleTramite": ""'+
            '    },'+
            '    "data_gl_json": {'+
            '        "codigo": "2666943",'+
            '        "titulo": "Abastecemento de Augas (Baixa)",'+
            '        "descripcion": "Permite tramitar expedientes relativos á baixa no servizo público de abastecemento e saneamento de auga.",'+
            '        "finalidad": "",'+
            '        "requisitos": "Segundo a normativa aplicable a iniciación deste procedemento poderá ser tanto de oficio como a instancia de parte.",'+
            '        "plazoPresentacion": "Continuo",'+
            '        "presentacion": "",'+
            '        "presentarPor": "",'+
            '        "organoGestor": "",'+
            '        "plazoResolucion": "Segundo normativa aplicable",'+
            '        "efectoSilencioAdministrativo": "Segundo normativa aplicable",'+
            '        "recursos": "",'+
            '        "normativaBasica": "",'+
            '        "coleccionNormativas": ['+
            '            {'+
            '                "titulo": "Ley 39/2015, de 1 de octubre, del Procedimiento Administrativo Común de las Administraciones Públicas.",'+
            '                "url": "https://www.boe.es/legislacion"'+
            '            },'+
            '            {'+
            '                "titulo": "Ley 7/1985, de 2 de abril, reguladora de las Bases del Régimen Local.",'+
            '                "url": "https://www.boe.es/legislacion"'+
            '            }'+
            '        ],'+
            '        "informacionAdicional": "",'+
            '        "nivelIdentificacionSolicitante": "",'+
            '        "coleccionDocumentos": [],'+
            '        "urlInicioTramitacion": "https://allariz.sedelectronica.gal/catalog/tw/27666b59-7238-4f55-9968-d45406f433f9",'+
            '        "urlDescargaInstancia": "?x=ezozc-EQNg7eJccPZ9FOYjFy9U4CxBq6Hoa0ysvF18RF2jpGNmnzfKxGq45DXbG2tG*ZPeBfuLw-8P8UCHX1nQ",'+
            '        "urlDetalleTramite": ""'+
            '    }'+
            '}';
        // Deserializa el JSON en una instancia de la clase Tramite
        Tramite tramite = (Tramite) JSON.deserialize(jsonDet, Tramite.class);
        // Realiza algunas verificaciones para asegurarte de que los datos se han deserializado correctamente
        System.assertEquals(514, tramite.id);
        System.assertEquals('001/2666943', tramite.codigo);
        System.assertEquals('Abastecimiento de Aguas (Baja)', tramite.titulo);
        System.assertEquals('Allariz', tramite.institucion.name);
        System.assertEquals('Tramitación electrónica', tramite.tema.name);
        System.assert(tramite.activo);
        System.assertEquals('2666943', tramite.data_es_json.codigo);
        System.assertEquals('Ley 39/2015, de 1 de octubre, del Procedimiento Administrativo Común de las Administraciones Públicas.', tramite.data_es_json.coleccionNormativas[0].titulo);
        System.assertEquals('https://www.boe.es/legislacion', tramite.data_es_json.coleccionNormativas[0].url);
        System.assertEquals('Ley 7/1985, de 2 de abril, reguladora de las Bases del Régimen Local.', tramite.data_es_json.coleccionNormativas[1].titulo);
    }
}