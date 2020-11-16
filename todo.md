## Pendiente

- Chats 1 a 1 de texto, donde los usuarios deben poder:
  - enviar mensajes
  - modificar y eliminar los mensajes que enviaron previamente
  - recibir notificaciones cuando otros usuarios les envían un nuevo mensaje

- Chats 1 a 1 seguros, donde se asegura que los mensajes se borrarán después de cierto tiempo, especificado por el emisor

- Chats de grupo, que soporten las mismas operaciones mencionadas anteriormente, además de tener un usuario administrador, que va a poder:
  - agregar y sacar gente del grupo
  - borrar cualquier mensaje
  - darle privilegios de administrador a otros usuarios

- Hay que pensar también que en algún momento nuestro sistema puede tener una gran cantidad de usuarios en estos grupos, y esto no debería afectar la performance normal del sistema

- Historial de chats persistente: un usuario debería poder seguir accediendo a sus mensajes, por más que deje de usar un cliente y pase de usar otro

## Investigar

- Como distribuir dinamicamente en BEAM
  - debe poder escalar horizontalmente de forma automática;
  - debe ser tolerante a fallos tanto de red como de implementación;

- Como implementar estado distribuido en elixir
  - toda la operatoria del servicio debe ocurrir en memoria y no se debe nunca persistir a disco, por cuestiones legales y de performance.

- Como distribuir BEAM en Docker
  - es deseable que el despliegue se haga mediante contenedores Docker.

- Chequear que elixir nos da esto
  - debe soportar acceso concurrente de múltiples usuarios;
  - debe maximizar la disponibilidad de los datos y su velocidad de acceso;

## Entrega Final

- Implementación.
- Documento que describa la arquitectura
- Prueba automatizados
