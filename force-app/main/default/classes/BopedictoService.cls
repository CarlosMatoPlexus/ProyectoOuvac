public class BopedictoService {
    public static void procesarBopedicto(List<String> detallesJson){
        for (String jsonDetalle : detallesJson){
            try {
                //Declaracion de variables
                Knowledge__kav knowCastellano = new Knowledge__kav();
                Knowledge__kav knowOtraLengua = new Knowledge__kav();
                List<Knowledge__kav> lstKnowledge = new List<Knowledge__kav>();
                String bopedictoId; //Convert to String
                String id_bop_edicto_externo; //Convert to String
                String sumario;
                Boolean activo;
                String fecha_creacion;
                String fecha_modificacion;
                String bop_id; //Convert to String


                
            } catch (Exception ex) {
                System.debug('Ocurrió un error al procesar el bopedicto: ' + ex.getMessage());
            }
        }
    }
    private static Datetime convertFechasJson (String fecha) {
        Datetime fechaModificada = null;
        if(fecha != null){
            String fechaModificacionSinOffset = fecha.substring(0, 19);
            String offSetModificacion = fecha.substring(19, 22);
            Integer horasOffsetModificacion = Integer.valueOf(offSetModificacion);
            fechaModificacionSinOffset = fechaModificacionSinOffset.replace('T', ' ');
            fechaModificada = DateTime.valueOf(fechaModificacionSinOffset);
            fechaModificada = fechaModificada.addHours(horasOffsetModificacion);
        }
        return fechaModificada;
    }
}