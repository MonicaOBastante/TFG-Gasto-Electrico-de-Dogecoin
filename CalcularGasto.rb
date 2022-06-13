require 'net/http'

class Dogecoin
    ASICgrandeH=3.03055556
    ASICgrandeW=2522.7777778
    ASICpequeñoH=517.1111111
    ASICpequeñoW=833.88888889

    def compararGasto(gasto)
        fichero = File.read("./electricidadPequeña.csv")
        fichero=fichero.split("\n")

        comparado = ""
        menor = 0.0
        mayor = 0.0
        pais = ""
        paisMenor=""
        paisMayor=""
        for i in(0..(fichero.length()-1))
            comparado=fichero[i].split(";")[1]
            pais=fichero[i].split(";")[0]
            if(comparado.to_f<=gasto)
                if(comparado.to_f>menor)#menor<comparado<gasto
                    menor=comparado.to_f
                    paisMenor=pais
                end
            else
                if(comparado.to_f>gasto)
                    if(i>0)
                        if(comparado.to_f<mayor)#menor<comparado<gasto
                            mayor=comparado.to_f
                            paisMayor=pais
                        end
                    else
                        mayor=comparado.to_f
                        paisMayor=pais
                    end
                end
            end
        end

        puts "Gasta más que "+paisMenor+", que consume "+menor.to_s+"tWh/año"
        puts "Gasta menos que "+paisMayor+", que consume "+mayor.to_s+"tWh/año"
    end
    def calcularTasa()
        ##########################################
        #               VARIABLES               #
        ########################################
        previo=Time.new
        #urls
        url = "https://dogechain.info/api/v1/block/" #permite obtener informacion de un bloque
        urlDificultadUltimoBloque="https://dogechain.info/chain/Dogecoin/q/getdifficulty"  #permite obtener dificultad actual

        #parametros
        bloquesEsperados=1440 #bloques se espera se minen en 24 horas
        tiempoBloque=60 #tiempo tarda en minarse un bloque
        combinaciones=(2**32) #cantidad posible de hashes
        segundosDia=86400
        unidad=10**12 #divisor para pasar a THs
        bloqueActual=Net::HTTP.get(URI("https://dogechain.info/chain/Dogecoin/q/getblockcount")) #ultimo bloque minado
        bloqueFinal=(bloqueActual.to_i) #bloque termina el bucle
        diferencia=0 #diferencia de tiempo entre dos bloques
        tiempoBloqueActual=0 #momento se mino el bloque actual
        tiempoBloqueFinal=0 #momento se mino el bloque queremos ver si es el primero
        contador=2 #numero bloques recorridos
        suma=0.0 #todas las dificultados del dia sumadas para hacer la media con contador

        ##########################################
        #           OBTECION PARAMETROS         #
        ########################################
        #obtener datos iniciales de tiempo y dificultad
        html = ""
        html = html.concat(url)
        html = html.concat(bloqueActual.to_s)
        urlCompleta = URI(html)
        auxiliar=Net::HTTP.get(urlCompleta)

        auxiliar=auxiliar.split("[")
        auxiliar=auxiliar[0].split(",")

        #obtener fecha se mino el bloque actual
        tiempo=auxiliar[6].split(":")
        tiempoBloqueActual=tiempo[1].gsub(" ","")

        #obtener dificultad bloque actual
        dificultadBloque=auxiliar[5].split(":")
        suma=dificultadBloque[1].to_f
        dificultadActual=dificultadBloque[1].to_f
        puts tiempoBloqueActual
        puts suma

        ##########################################
        #BUSQUEDA PRIMER BLOQUE ULTIMAS 24 HORAS#
        ########################################
        encontrado=false #tengo el primer bloque de las ultimas 24 horas
        inicio=Time.new
        puts "Previo "+previo.to_s #tiempo de control para depurado
        puts "Empieza bucle "+inicio.to_s
        while !encontrado
            bloqueFinal=bloqueFinal-1
            html = ""
            html = html.concat(url)
            html = html.concat(bloqueFinal.to_s)
            urlCompleta = URI(html)
            conectado = false
            extraido = false
            retrocedido = false
            while !extraido
                #evitar codigo pete por una mala conexion o demasiado tiempo esperando
                while !conectado
                    #obtener datos del bloque
                    begin
                        auxiliar=Net::HTTP.get(urlCompleta)
                        conectado=true
                    rescue
                        puts "Fallo en la conexion. Saltando uno."+Time.new.to_s
                        if !retrocedido
                          bloqueFinal=bloqueFinal-1
                          retrocedido = true
                          html = ""
                          html = html.concat(url)
                          html = html.concat(bloqueFinal.to_s)
                          urlCompleta = URI(html)
                        end

                        conectado=false
                    end
                end
                #si lo que ha devuelto es un codigo de error, aqui peta,
                #asi que tenemos que repetirlo
                begin
                    auxiliar = auxiliar.split("[")
                    auxiliar = auxiliar[0].split(",")

                    #obtener tiempo
                    tiempo = auxiliar[6].split(":")
                    tiempoBloqueFinal = tiempo[1]

                    #obtener dificultad
                    dificultadBloque = auxiliar[5].split(":")
                    suma = suma+dificultadBloque[1].to_f
                    contador = contador+1
                    extraido = true
                rescue
                    puts "Fallo al extraer. Conectando de nuevo."
                    extraido= false
                end
            end
            #comprobar si hemos llegado a ultimo bloque
            diferencia=(tiempoBloqueActual.to_i)-(tiempoBloqueFinal.to_i)
            if(diferencia>=segundosDia)
                encontrado=true
                puts "Bloque encontrado. Bloque: "+bloqueFinal.to_s
            end
            puts bloqueFinal
        end
        fin=Time.new
        ##########################################
        #               CALCULOS                #
        ########################################
        aux=bloqueActual
        html = ""
        html = html.concat(url)
        html = html.concat(bloqueActual)
        urlCompleta = URI(html)
        auxiliar=Net::HTTP.get(urlCompleta)

        dificultadBloque=auxiliar.split("[")
        dificultadBloque=dificultadBloque[0].split(",")
        dificultadBloque=dificultadBloque[5].split(":")
        dificultadActual=dificultadBloque[1].to_f
        contador=contador+1

        #calcular variables para formula de tasa
        bloquesMinados=bloqueActual.to_i-bloqueFinal
        dificultadMedia=(suma.to_f)/(contador).to_f
        proporcion= bloquesMinados.to_f/bloquesEsperados.to_f

        puts "Dificultad Media: "+dificultadMedia.to_s
        puts "Bloques Minados: "+bloquesMinados.to_s
        puts "Proporcion: "+proporcion.to_s
        puts "Dificultad Actual: "+dificultadActual.to_s

        tasa=((bloquesMinados.to_f/bloquesEsperados.to_f)*(dificultadMedia)*combinaciones/tiempoBloque)/unidad
        puts "Tasa calculada: "+tasa.to_s+"Ths"
        puts "El codigo empezo a: "+inicio.to_s
        puts "El codigo acabo a: "+fin.to_s

        ##########################################
        #         CALCULOS ELECTRICIDDAD        #
        ########################################
        gigas = 10**3
        megas = 10**6

        gastoGrande=((tasa*gigas/ASICgrandeH)*ASICgrandeW)/megas
        gastoAñoGrande=gastoGrande*24*365/megas
        gastoPequeño=((tasa*megas/ASICpequeñoH)*ASICpequeñoW)/megas
        gastoAñoPequeño=gastoPequeño*24*365/megas
        gastoMedio=((gastoGrande+gastoPequeño)/2)
        gastoAñoMedio=gastoMedio*24*365/megas
        gastoAika = 61.05047917
        potenciaAika = 40.606
        gastoProporcional= (tasa*gigas*gastoAika/potenciaAika)/gigas
        gastoProporcionalAño=gastoProporcional*24*365/megas

        puts "Gasto de la red con ASIC grandes: "+gastoGrande.to_s+"mWh"
        puts "Gasto de la red con ASIC grandes al año: "+gastoAñoGrande.to_s+"tWh/año"
        compararGasto(gastoAñoGrande)
        puts "\n"
        puts "Gasto de la red con ASIC pequeños: "+gastoPequeño.to_s+"mWh"
        puts "Gasto de la red con ASIC pequeños al año: "+gastoAñoPequeño.to_s+"tWh/año"
        compararGasto(gastoAñoPequeño)
        puts "\n"
        puts "Gasto de la red con ASIC medios: "+gastoMedio.to_s+"mWh"
        puts "Gasto de la red con ASIC medios al año: "+gastoAñoMedio.to_s+"tWh/año"
        compararGasto(gastoAñoMedio)
        puts "\n"
        puts "Gasto de la red usando Aikapool de referencia: "+gastoProporcional.to_s+"mWh"
        puts "Gasto al año de la red usando Aikapool de referencia: "+gastoProporcionalAño.to_s+"tWh/año"
        compararGasto(gastoProporcionalAño)

        fichero =File.new("Potencia.csv","a")
        fichero.write(tasa.to_s+";"+gastoAñoGrande.to_s+";"+gastoAñoPequeño.to_s+";"+gastoAñoMedio.to_s+";"+gastoProporcionalAño.to_s+";"+bloqueActual.to_s+"\n")
        fichero.close
    end

end

#Main
doge=Dogecoin.new()
pruebas = 100#pruebas queremos realizar seguidas

for i in (0..pruebas)
    doge.calcularTasa()
end
