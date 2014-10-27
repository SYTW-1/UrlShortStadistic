# Sistemas y Tecnologías Web:
[![Build Status](https://travis-ci.org/SYTW-1/shortened_urls.svg?branch=master)](https://travis-ci.org/SYTW-1/shortened_urls)
##Práctica: Estadísticas de Visitas al Acortador de URLs

**Autor:** Eliezer Cruz Suárez: alu0100611298
**Autor:** Nestor Alvarez Díaz: alu0100594973

En esta práctica extendemos la anterior 40.9 con información estadística acerca de las visitas. Se pide que se presenten gráficos estadísticos (barras, etc.) del número de visitas por día, por país, etc.

La información de las visitas se guardará en una tabla Visit.

Cada objeto Visit representará una visita a la URL corta y contendrá información acerca de la visita:

la fecha de la visita y
la procedencia de la misma.

[Repositorio](https://github.com/SYTW-1/UrlShortStadistic)

[Heroku](http://shortedstadistic.herokuapp.com/)

[gh-pages](http://sytw-1.github.io/UrlShortStadistic)

##Funcionamiento

Hay dos maneras de ejecutar la aplicacion

1. Accediendo a Heroku

	[Heroku](http://shortedstadistic.herokuapp.com/)

2. Ejecucion el local

	* Clonamos la aplicacion el local
		`git clone git@github.com:SYTW-1/UrlShortStadistic.git`
	* Instalamos las gemas
		`bundle install`
	* Modificamos el archivo config.yml con nuestras claves
	* Arrancamos el servidor
		`rake server`

## Problemas con las gemas postgree

Siga los siguientes pasos desde la consola:

* sudo apt-get install libpq-dev
* gem install pg
* sudo apt-get install postgresql
* sudo apt-get install postgresql-server-dev-9.3
* https://www.heroku.com/postgres
