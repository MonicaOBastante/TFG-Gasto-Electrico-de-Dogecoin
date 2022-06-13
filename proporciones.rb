#ficheros
origen="./segundoIntento/Ordenado/Pool/Mineros2MesesOrdenadoPool.csv"
destino="./segundoIntento/proporciones/pool/proporciones2MesesPool.csv"

#auxiliares
address=""
total=100.00
contador=1.0
proporcion=0.9999 #porcentaje minado. Numero entre 0 y 100


csv =File.new(destino, "a")
csv.write("address;bloques;porcentaje\n")
contenido = File.read(origen)
contenido=contenido.split("\n")
total=(contenido.length())-1
inicio=Time.new

address=contenido[1].split(";")[0]
for i in (2..(total-1))
    if(address==contenido[i].split(";")[0])
        contador=contador+1
    else
        proporcion= ((contador)/total)*100
        csv.write(address+";"+(contador.to_i).to_s+";"+proporcion.to_s+"\n")
        address=contenido[i].split(";")[0]
        contador=1.0
    end

end
fin=Time.new
puts("El programa comenzó a las "+inicio.to_s)
puts("El programa acabó a las "+fin.to_s)
