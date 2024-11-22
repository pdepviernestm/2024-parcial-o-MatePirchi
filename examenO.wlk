class Persona {
    const property emociones = [] //todas las emociones de una persona
    var edad
    var property intensidadElevada = 60
    method esAdolescente() = edad.between(12, 19)

    method cumplirAnios(){
        edad += 1
    }

    method nuevaEmocion(emocion){
        emociones.add(emocion)
    }
    method estaPorExplotar(){
        emociones.all({emocion => emociones.sePuedeLiberar()})
    }

    method vivirEvento(evento){
        evento.aplicarEvento(self)
    }

    method cambiarIntensElev(nuevaIntensidad){
        intensidadElevada = nuevaIntensidad
    }
}

class Eventos{
    const impacto
    const descripcion

    method sucederA(personas){
        personas.forEach({persona => persona.vivirEvento(self)})
    }
    
    method aplicarEvento(persona){
        persona.emociones().forEach({emocion => 
            emocion.sufrirEvento(impacto, persona)
            emocion.restringirLiberacion(false)
            })
    }
}

object insultado inherits Eventos(impacto = 50, descripcion = "Te metes a una pelea y te insultan"){}

object tropezarse inherits Eventos(impacto = 10, descripcion = "te tropezaste en la calle y quedaste como un tonto"){}

object pelearseConFamilia inherits Eventos(impacto = 70, descripcion = "Quedas Peleado con tu familia"){
    override method aplicarEvento(persona){
        persona.emociones().forEach({emocion => 
            emocion.aplicarEventoLiberador(impacto, persona)
            emocion.restringirLiberacion(true)
            })
    }
}


class Emociones{
    var intensidad
    var property eventosVividos = 0
    var noSePuedeLiberar = false

    method sufrirEvento(impacto, persona){
        self.cambiarIntensidad((impacto/2).round())
        self.AumentarEventosVividos()
    }
    method aplicarEventoLiberador(impacto, persona){
        if(self.sePuedeLiberar(persona)){
            self.liberarse(impacto)
        }
        self.AumentarEventosVividos()
    }
    method restringirLiberacion(bool){
        noSePuedeLiberar = bool
    }
    method AumentarEventosVividos(){
        eventosVividos += 1
    }

    method liberarse(impacto){
        intensidad -= impacto
    }
    method cambiarIntensidad(cambio){
        intensidad += cambio
    }

    method condAdicLiberar(persona)

    method sePuedeLiberar(persona) = noSePuedeLiberar && intensidad > persona.intensidadElevada() && self.condAdicLiberar(persona)

}
class Furia inherits Emociones(intensidad = 100){
    const palabrotas = []

    override method sufrirEvento(impacto, persona){
        if( impacto > 20){
            self.aprenderPalabrota("No Se Insultos (mentira)")
        }else{
            self.aprenderPalabrota("bobo")
        }
        super(impacto, persona)
    }

    method aprenderPalabrota(palabrota){
        palabrotas.add(palabrota)
    }
    method olvidarPalabrota(palabrota){
        palabrotas.remove(palabrota)
    }
    override method condAdicLiberar(persona) = palabrotas.any({palabrota => palabrota.size() > 7})

    override method liberarse(impacto){
        super(impacto)
        palabrotas.remove(palabrotas.first())
    }
}

class Alegria inherits Emociones{
    override method liberarse(impacto){
        super(impacto)
        intensidad *= intensidad.max(-1).min(1)
        
    }
    override method condAdicLiberar(persona) = persona.eventosVividos().even()
    
}

class Tristeza inherits Emociones{
    var causa = "melancolia"
    override method condAdicLiberar(persona) = (causa != "melancolia")
    method cambiarCausa(nuevaCausa){
        causa = nuevaCausa
    }

    override method sufrirEvento(impacto, persona){
        if( impacto > 30){
            self.cambiarCausa(["Traicion","Abandono","Perdio Boquita"].anyOne())
        }
        super(impacto, persona)
    }

}

class Desagrado inherits Emociones{
    override method condAdicLiberar(persona) = (persona.eventosVividos() > intensidad)
}
class Temor inherits Emociones{
    override method condAdicLiberar(persona) = (persona.eventosVividos() > intensidad)
}

// INTENSAMENTE 2
class Ansiedad inherits Emociones{
    var property hizoMeditacion = false
    override method condAdicLiberar(persona) = !hizoMeditacion
    method hacerMeditacion(){
        hizoMeditacion = true
    }
    method seOlvidoDeMeditar(){
        hizoMeditacion = false
    }

    override method sufrirEvento(impacto, persona){
        var impactoReducido = impacto
        if(hizoMeditacion){ //Si antes de sufrir un evento estaba meditando, dejara de hacerlo y le afectara menos lo sucedido
            hizoMeditacion = false
            impactoReducido = impacto/2.round()
        }else{ 
            hizoMeditacion = true //Empezara a meditar si no lo estaba haciendo antes
        }
        super(impactoReducido, persona)
    }
}

/* 
    Si bien no utilice mucho polimorfismo en ansiedad, si utilice herencia, me fue util porque el concepto me ayudo a tener en cuenta las partes de codigo que 
    se repetian en todas las diferentes emociones, y como podria simplificarlo. A raiz de esto es que cree la clase abstracta "Emociones", que contiene todo 
    este codigo y me ayuda a evitar redundancias. Por ejemplo el metodo liberarse() y la variable intensidad. Que no solo se usaron aca si no en todo el resto 
    de las emociones. 
    
    Si bien no utilice polimorfismo en Ansiedad en si, se utiliza en el resto del codigo, fue util para simplificar el codigo significativamente ya que no tengo
    que identificar individualmente a cada emocion o evento para poder enviarles el mismo mensaje, un ejemplo de esto es que todas la emociones comparten el 
    mismo metodo "sufrirEvento" lo que me ayuda a poder hacer las distintas acciones en los distintos partes del codigo llamando a todos de la misma manera. 
    Codigo como el metodo aplicarEvento(persona) de la clase Eventos seria mucho mas complejo si todas las emociones no entendieran el mensaje "sufrirEvento"

*/