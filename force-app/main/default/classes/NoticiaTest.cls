@isTest
public class NoticiaTest {
    @isTest
    public static void testNoticiaDeserialization() {
        // JSON de ejemplo
        String jsonDet = '{' +
            '   "id": 102,' +
            '   "titulo": "Campaña informativa \\"INFOCONSUMO\\" en Amoeiro",' +
            '   "descripcion": "Prueba Json Noticia",' +
            '   "institucion": {' +
            '       "code": "002",' +
            '       "name": "Amoeiro"' +
            '   },' +
            '   "tema": {' +
            '       "code": "012",' +
            '       "name": "Otras"' +
            '   },' +
            '   "activo": true,' +
            '   "fecha_creacion": "2024-08-06T19:53:37+02:00",' +
            '   "fecha_modificacion": "2024-10-17T11:32:10+02:00",' +
            '   "ambito": {' +
            '       "code": "002",' +
            '       "name": "Amoeiro"' +
            '   },' +
            '   "data_es_json": null,' +
            '   "data_gl_json": {' +
            '       "titulo": "Campaña informativa \\"INFOCONSUMO\\" en Amoeiro",' +
            '       "url": "https://www.amoeiro.gal/arquivos/3673",' +
            '       "date": "2023-09-30T00:00:00+02:00",' +
            '       "contenido": "Prueba Json Noticia data_gl_json",' +
            '       "categorias": [' +
            '           "consumo",' +
            '           "dereitos",' +
            '           "información",' +
            '           "charlas",' +
            '           "Escola Galega de consumo"' +
            '       ],' +
            '       "imagenes": [' +
            '           {' +
            '               "url": "https://static.xx.fbcdn.net/images/emoji.php/v9/t40/1/16/25b6.png",' +
            '               "titulo": "Img 1"' +
            '           },' +
            '           {' +
            '               "url": "https://static.xx.fbcdn.net/images/emoji.php/v9/t40/1/16/25b6.png",' +
            '               "titulo": "Img 2"' +
            '           },' +
            '           {' +
            '               "url": "https://static.xx.fbcdn.net/images/emoji.php/v9/t40/1/16/25b6.png",' +
            '               "titulo": "Img 3"' +
            '           },' +
            '           {' +
            '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/banca-300x216.png",' +
            '               "titulo": "Img 4"' +
            '           },' +
            '           {' +
            '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/compra-300x216.png",' +
            '               "titulo": "Img 5"' +
            '           },' +
            '           {' +
            '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/consumo-300x216.png",' +
            '               "titulo": "Img 6"' +
            '           },' +
            '           {' +
            '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/luz-e-gas-300x217.png",' +
            '               "titulo": "Img 7"' +
            '           }' +
            '       ]' +
            '   }' +
            '}';
        // Deserializa el JSON en una instancia de la clase Noticia
        Noticia noticia = Noticia.fromJson(jsonDet);
        // Realiza algunas verificaciones para asegurarte de que los datos se han deserializado correctamente
        System.assertEquals(102, noticia.id);
        System.assertEquals('Campaña informativa "INFOCONSUMO" en Amoeiro', noticia.titulo);
        System.assertEquals('2024-08-06T19:53:37+02:00', noticia.fecha_creacion);
        System.assertEquals('Amoeiro', noticia.ambito.name);
        System.assertEquals('Otras', noticia.tema.name);
        System.assert(noticia.activo);
        System.assertEquals('https://www.amoeiro.gal/arquivos/3673', noticia.data_gl_json.url);
    }
}