:- encoding(utf8).

/*
Alumno: Franco damian romagnoli
Legajo: 173.112-9
*/

jugador(jugador(franco, 100, 100, [hechizo(pedro,xD,50)], [prueba2], [prueba3])).

nombre(jugador(Nombre,_,_,_,_,_), Nombre).
nombre(criatura(Nombre,_,_,_), Nombre).
nombre(hechizo(Nombre,_,_), Nombre).

vida(jugador(_,Vida,_,_,_,_), Vida).
vida(criatura(_,_,Vida,_), Vida).
vida(hechizo(_,curar(Vida),_), Vida).

danio(criatura(_,Danio,_), Danio).
danio(hechizo(_,danio(Danio),_), Danio).

mana(jugador(_,_,Mana,_,_,_), Mana).
mana(criatura(_,_,_,Mana), Mana).
mana(hechizo(_,_,Mana), Mana).

cartasMazo(jugador(_,_,_,Cartas,_,_), Cartas).
cartasMano(jugador(_,_,_,_,Cartas,_), Cartas).
cartasCampo(jugador(_,_,_,_,_,Cartas), Cartas).

%-------[PUNTO 1]--------%

tieneCarta(Jugador, Carta) :-
    jugador(Jugador),
    cartasPoseidas(Jugador, CartasPoseidas),
    member(Carta, CartasPoseidas).

cartasPoseidas(Jugador, Cartas) :-
    cartasMazo(Jugador, Cartas).

cartasPoseidas(Jugador, Cartas) :-
    cartasMano(Jugador, Cartas).

cartasPoseidas(Jugador, Cartas) :-
    cartasCampo(Jugador, Cartas).

%-------[PUNTO 2]--------%

esGuerrero(Jugador) :-
    jugador(Jugador),
    not(tieneCarta(Jugador,hechizo(_,_,_))).

%-------[PUNTO 3]--------%

empiezaTurno(jugador(Nombre, Vida, Mana, [Carta | RestoMazo], Mano, Campo), jugador(Nombre, Vida, ManaActualizado, RestoMazo, [Carta|Mano], Campo)) :-
    jugador(jugador(Nombre, Vida, Mana, [Carta | RestoMazo], Mano, Campo)),
    ManaActualizado is Mana + 1.


%-------[PUNTO 4A]--------%

puedeUtilizar(jugador(Nombre,Vida,Mana,Mazo,Mano,Campo), Carta) :-
    tieneCarta(jugador(Nombre,Vida,Mana,Mazo,Mano,Campo),Carta),
    costoMana(Carta,Costo),
    Mana >= Costo.

costoMana(hechizo(_,_,Costo), Costo).
costoMana(criatura(_,_,_,Costo), Costo).

%-------[PUNTO 4B]--------%

