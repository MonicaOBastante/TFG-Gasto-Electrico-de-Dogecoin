=begin
Codigo auxiliar para ordenar csv mediante el algoritmo quickshort

autor: Mónica Ocaña Bastante
version: 1.0.1
actualizacion: 2022/02/26

=end

def quickshort (maxIzquierda,maxDerecha,contenido)
    izquierda = maxIzquierda
    derecha = maxDerecha
    pivote = contenido[((izquierda+derecha)/2)].split(";")[0]
    puts "Ciclo nuevo #{Time.new}"
    while (izquierda<=derecha)

        #buscamos elemento desorndenado por la izquierda
        while ((izquierda<=maxDerecha) && ((contenido[izquierda].split(";")[0]<=>pivote)==-1))
            izquierda =izquierda + 1
            #puts "izquierda"
        end

        #buscamos elemento desordenado por la derecha
        while ((derecha>=maxIzquierda) && ((contenido[derecha].split(";")[0]<=>pivote)==+1))
            derecha = derecha - 1
            #puts "derecha"
        end

        #si hay 2 elementos desordenados, los intercambiamos
        #puts "comparar"
        if(izquierda<=derecha)
            auxiliar = contenido[izquierda]
            contenido[izquierda] = contenido[derecha]
            contenido[derecha] = auxiliar
            izquierda = izquierda + 1
            derecha = derecha - 1
        end
    end
    puts "dividiendo"
    if(maxIzquierda<derecha)
        quickshort(maxIzquierda,derecha,contenido)
    end

    if(maxDerecha>izquierda)
        quickshort(izquierda,maxDerecha,contenido)
    end
end

destino ="./segundoIntento/Ordenado/Pool/Mineros2MesesOrdenadoPool.csv"
fichero = "./segundoIntento/Mineros/MinerosConPool/Mineros2mesesReves2Pools.csv"
#lineas = 627733

ordenado = false
auxiliar = ""
csv = File.new(destino,"a")
#leemos contenido del fichero
contenido = File.read(fichero)
puts "fichero leido"

#dividimos el contenido en lineas
contenido = contenido.split("\n")
lineas = contenido.length()

# -1 o es mas pequeño, 0 son iguales, 1 u es mas pequeño (A mas pequeño que


inicio = Time.new
puts "comenzando a ordenar"
puts inicio
coso= lineas-1
#ordenar el fichero
quickshort(0,coso,contenido)

ordenar = Time.new
puts "escribiendo fichero"
puts ordenar
#Escribimos los datos ya ordenados
for i in (0..(lineas-1))

    csv.write(contenido[i]+"\n")

end

fin = Time.new
#impresion tiempos
puts "Inicio #{inicio}"
puts "Fin ordenar #{ordenar}"
puts "Fin de programa #{fin}"
