@isTest
public class BopedictoTest {
    @isTest
    public static void testBopedictoDeserialization(){
        // JSON de ejemplo
        String json='{'+
        '        "id": 60992,'+
        '        "id_bop_edicto_externo": 3141,'+
        '        "bop": {'+
        '            "id": 7918,'+
        '            "id_bop_externo": 581'+
        '        },'+
        '        "sumario": "Exposición pública del padrón anual del impuesto de bienes inmuebles de naturaleza urbana del ejercicio de 2009.",'+
        '        "institucion": {'+
        '            "code": "036",'+
        '            "name": "Laza"'+
        '        },'+
        '        "tema": {'+
        '            "code": "012",'+
        '            "name": "Otras"'+
        '        },'+
        '        "activo": true,'+
        '        "fecha_creacion": "2024-11-29T13:31:44+01:00",'+
        '        "fecha_modificacion": "2024-11-29T13:31:44+01:00",'+
        '        "ambito": {'+
        '            "code": "036",'+
        '            "name": "Laza"'+
        '        },'+
        '        "data_es_json": {'+
        '            "id_bop_edicto_externo": 3141,'+
        '            "fecha_entrada": "2009-04-23T00:00:00+02:00",'+
        '            "numero_pagina": 23,'+
        '            "tema": "Otras",'+
        '            "entidad_nombre": "CONCELLO DE LAZA",'+
        '            "entidad_nif": "P3204000H",'+
        '            "sumario": "Exposición pública del padrón anual del impuesto de bienes inmuebles de naturaleza urbana del ejercicio de 2009.",'+
        '            "texto": "ex.publica padron IBI urbana-09",'+
        '            "url_texto": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
        '            "url_pdf": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
        '            "url_html": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
        '            "url_epub": "https://bop.depourense.es/portal/consulta?fecha=20090429"'+
        '        },'+
        '        "data_gl_json": {'+
        '            "id_bop_edicto_externo": 3141,'+
        '            "fecha_entrada": "2009-04-23T00:00:00+02:00",'+
        '            "numero_pagina": 23,'+
        '            "tema": "Otras",'+
        '            "entidad_nombre": "CONCELLO DE LAZA",'+
        '            "entidad_nif": "P3204000H",'+
        '            "sumario": "Exposición pública do padrón anual do imposto de bens inmobles de natureza urbana do exercicio de 2009.",'+
        '            "texto": "ex.publica padron IBI urbana-09",'+
        '            "url_texto": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
        '            "url_pdf": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
        '            "url_html": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
        '            "url_epub": "https://bop.depourense.es/portal/consulta?fecha=20090429"'+
        '        }'+
        '    }';
        // Deserializa el JSON en una instancia de la clase Bopedicto
        Bopedicto bopedicto = Bopedicto.fromJson(json);
        // Realiza algunas verificaciones para asegurarte de que los datos se han deserializado correctamente
        System.assertEquals(60992, bopedicto.id);
        System.assertEquals('Exposición pública del padrón anual del impuesto de bienes inmuebles de naturaleza urbana del ejercicio de 2009.', bopedicto.sumario);
        System.assertEquals('2024-11-29T13:31:44+01:00', bopedicto.fecha_creacion);
        System.assertEquals('Laza', bopedicto.ambito.name);
        System.assertEquals('Otras', bopedicto.tema.name);
        System.assert(bopedicto.activo);
        System.assertEquals('https://bop.depourense.es/portal/consulta?fecha=20090429', bopedicto.data_gl_json.url_texto);
    }
}