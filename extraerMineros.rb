=begin
Codigo auxiliar para obtener bloques de la blockchain usando la API de la
blockchain de dogecoin:
https://dogechain.info/api/blockchain_api

autor: Mónica Ocaña Bastante
version: 1.0.8
actualizacion: 2022/03/13

=end

#bibliotecas usadas
require 'net/http'

####################################################################
#                           VARIABLES                              #
####################################################################

#variables referentes a las urls usadas
url = "https://dogechain.info/api/v1/block/" #da un bloque y toda su informacion
url2 =  "https://dogechain.info/api/v1/transaction/" #informacion de una transacciontransaccion
html = ""


#variables de control del bucle
diferencia = 100000
max = Net::HTTP.get(URI("https://dogechain.info/chain/Dogecoin/q/getblockcount")) #altura del ultimo bloque agregado a la blockchain
min = (max.to_i)-diferencia
min = 4141693
max = 4198784
fichero = "./Mineros2meses.csv" #donde guardamos los datos obtenidos
conseguido = false #si ha logrado conectarse a la red
extraido = false #si ha logrado extraer el bloque
#variables auxiliares para guardar datos temporales
cifrado = ""  #guarda el hash de la primera transaccion del bloque
auxiliar = "" #guarda el resultado de la pagina
auxiliar2 = ""
addres = "" #guarda el addres extraido de una transaccion
contador = 0 # contar veces hemos fallado tratando de establecer conexion
fallo = false #false se ha logrado conectar al bloque, true no se ha logrado
inicio = Time.new

#este bucle va desde el bloque min hasta el bloque actual (se quiere ir desde el 2020 hasta la fecha actual)
for bloque in(min..max.to_i)
    #OBTENER PRIMERA TRANSACCION DEL BLOQUE (la del minero)
    puts bloque
    min = bloque
    #generar url
    html = ""
    html = html.concat(url)
    html = html.concat(bloque.to_s)
    urlCompleta = URI(html)
    extraido = false
    fallo = false
    while !extraido
        #obtener informacion del bloque
        conseguido = false
        contador = 0
        while !conseguido && contador < 4 #si no lo consigo en 4 intentos, es que no se puede acceder a este bloque
            begin
                puts "Intentando establecer conexion. #{Time.new}"
                auxiliar=Net::HTTP.get(urlCompleta)
                conseguido = true
            rescue
                puts "Ha habido un error en la conexion. Intentando otra vez. #{Time.new}"
                contador = contador + 1
                puts contador
            end
        end
        if(contador <4)
            puts "Conexion establecida"
            fallo = false
        else
            puts" Fallo al intentar extraer bloque. Saltando al siguiente"
            fallo = true
            extraido = true
        end
        contador = 0

        #LEER BLOQUE OBTENIDO PARA EXTRAER HASH MINERO
        #vamos poco a poco cortando el bloque hasta obtener lo que queremos
        if !fallo
            begin
                cifrado = auxiliar.split("[")
                cifrado = cifrado[1].split("]")
                cifrado = cifrado[0].split(",")
                cifrado = cifrado[0].gsub(" ","")
                cifrado = cifrado.gsub("\"","")
                cifrado = cifrado.gsub("\n","")
                extraido = true
            rescue
                puts "Ha habido un error al extraer. Intentando de nuevo. #{Time.new}"
                extraido = false
            end
        end

    end

    if !fallo
        puts "Extraido con exito bloque #{bloque}"

        #OBTENER ADDRESS DEL MINERO
        #generar url
        html = ""
        html = html.concat(url2)
        html = html.concat(cifrado)
        urlCompleta = URI(html)

        #obtener addres
        extraido = false
        while !extraido
            conseguido = false
            while !conseguido
                begin
                    puts "Intentando establecer conexion 2"
                    auxiliar2=Net::HTTP.get(urlCompleta)
                    conseguido = true
               rescue
                puts "Hay problemas en la conexion. Intentando otra vez. #{Time.new}"
                end
            end
            puts "Conexion 2 establecida. #{Time.new} "
            begin
              #LEER TRANSACCION PARA SACAR EL ADDRESS
                addres= auxiliar2.split("[")
                addres = addres[2].split("]")
                addres = addres[0].split(",")
                addres = addres[3].split(":")
                addres = addres[1].gsub(" ","")
                addres = addres.gsub("}","")
                addres = addres.gsub("\"","")
                extraido = true
                #quitar saltos de linea para ayudar en la escritura
                addres = addres.gsub("\n","")
            rescue
                puts "Fallo en segunda extracion. Intentando de nuevo"
                puts "Bloque: #{bloque}"
                extraido = false
            end
        end
        puts "Escribiendo bloque"
        #GUARDAR MINERO EN FICHERO Y EL NUMERO DE BLOQUE QUE MINO
        File.open(fichero, "a") do |file|
            file.write("#{addres};#{bloque}\n")
        end
    end


end
puts cifrado
puts addres
fin = Time.new


puts ("El codigo comenzo a: #{inicio}")
puts ("El codigo termino a: #{fin}")
