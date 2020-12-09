# Pigeon

![pigeon](assets/pigeon.png#pigeon)
_TP Grupal - IASC 2C2020_

## Contexto

Nos acaban de contratar para desarrollar una nueva app de mensajería que destrone a WhatsApp y Telegram.

Para esta primera versión, vamos a querer enfocarnos en el core de nuestro producto, que es la posibilidad de enviar y recibir mensajes entre distintos usuarios. Es por eso que en este momento no nos va a interesar desarrollar las interfaces gráficas para los clientes, y nos conformaremos con tener clientes por interfaz de línea de comandos (o CLI).

## Requerimientos

Nuestra arquitectura va a tener que soportar los siguientes requerimientos:

- Chats 1 a 1 de texto, donde los usuarios deben poder:
  - enviar mensajes
  - modificar y eliminar los mensajes que enviaron previamente
  - recibir notificaciones cuando otros usuarios les envían un nuevo mensaje
- Chats de grupo, que soporten las mismas operaciones mencionadas anteriormente, además de tener un usuario administrador, que va a poder:
  - agregar y sacar gente del grupo
  - borrar cualquier mensaje
  - darle privilegios de administrador a otros usuarios
- Hay que pensar también que en algún momento nuestro sistema puede tener una gran cantidad de usuarios en estos grupos, y esto no debería afectar la performance normal del sistema
- Historial de chats persistente: un usuario debería poder seguir accediendo a sus mensajes, por más que deje de usar un cliente y pase de usar otro

La aplicación, a su vez, debe manejar los siguientes requerimientos no funcionales:

- debe soportar acceso concurrente de múltiples usuarios;
- debe poder escalar horizontalmente de forma automática;
- debe ser tolerante a fallos tanto de red como de implementación;
- debe maximizar la disponibilidad de los datos y su velocidad de acceso;
- toda la operatoria del servicio debe ocurrir en memoria y no se debe nunca persistir a disco, por cuestiones legales y de performance.
- es deseable que el despliegue se haga mediante contenedores Docker.

En esta primera versión no se tendrán en cuenta cuestiones de seguridad; se asumirá que todos los clientes y servidores están dentro de una red segura. Tampoco nos interesa en este momento tener un sistema complejo de manejo de usuarios y permisos; sólo nos importa poder distinguir a un usuario de otro.

## Tecnologías

Se podrá utilizar cualquier tecnología que aplique alguno de los siguientes conceptos vistos en la cursada:

- Paso de mensajes basado en actores
- Continuaciones explícitas (CPS)
- Promises
- Memoria transaccional
- Corrutinas

Obviamente, lo más simple es basarse en Elixir/OTP, Haskell, o Node.js, que son las tecnologías principales que vimos en la materia.

Otras opciones son tecnologías basadas en Scala/Akka, Go, Clojure y Rust, pero ahí les podremos dar menos soporte.

## Formato de entrega y evaluación

El trabajo práctico tendrá tres hitos:

- Un pre-checkpoint, para validar las problemáticas que identificaron, las primeras ideas de arquitectura y la tecnología a utilizar.

- Un checkpoint, donde deberán presentar el avance de la implementación hasta ese momento, junto con la propuesta de arquitectura del sistema completo a alto nivel, considerando los requerimientos funcionales y no funcionales (no hace falta entregar una implementación de esto último, alcanza con tener diagramas que permitan entender la propuesta).

- Una entrega final con el sistema terminado (tanto el servidor como los clientes de prueba). No es obligatoria la construcción de casos de prueba automatizados, pero constituye un gran plus. Además, la entrega debe contar con un documento que describa la arquitectura de la resolución propuesta, el cual se deberá entregar junto con la implementación.

Se evaluará que:

- El sistema cumpla con los requerimientos planteados
- Haga un uso adecuado de la tecnología y los conceptos explicados en la materia
- La arquitectura sea distribuida
