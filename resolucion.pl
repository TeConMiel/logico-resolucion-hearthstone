:- encoding(utf8).

/*
Alumno: Franco damian romagnoli
Legajo: 173.112-9
*/

jugador(jugador(franco, 100, 100, [hechizo(lluviaMeteoro,danio(50),100), hechizo(tormentaArena,danio(6),40)], [criatura(martin2, 100, 100, 100)], [criatura(martin, 100, 101, 100)])).

nombre(jugador(Nombre,_,_,_,_,_), Nombre).
nombre(criatura(Nombre,_,_,_), Nombre).
nombre(hechizo(Nombre,_,_), Nombre).

vida(jugador(_,Vida,_,_,_,_), Vida).
vida(criatura(_,_,Vida,_), Vida).
vida(hechizo(_,curar(Vida),_), Vida).

danio(criatura(_,Danio,_,_), Danio).
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

puedeUtilizar(Jugador, Carta) :-
    mana(Jugador, Mana),
    mana(Carta, CostoMana),
    Mana >= CostoMana.

%-------[PUNTO 4B]--------%

puedeJugarEnElProximoTurno(Jugador, Cartas) :-
    jugador(Jugador),
    empiezaTurno(Jugador, JugadorActualizado),
    cartasMano(JugadorActualizado, Mano),
    findall( Carta, (member(Carta, Mano), puedeUtilizar(JugadorActualizado, Carta)) , Cartas ).

%-------[PUNTO 5]--------%

posiblesJugadas(Jugador, PosiblesJugadas) :-
    jugador(Jugador),
    puedeJugarEnElProximoTurno(Jugador, Cartas),
    mana(Jugador, Mana),
    jugadasPosibles(Cartas, Mana, PosiblesJugadas).

jugadasPosibles([], _ , []).

jugadasPosibles([Carta| RestoCartas], Mana, [Carta| CartasPosibles]) :-
    mana(Carta, Costo),
    Mana >= Costo,
    NuevoMana is Mana - Costo,
    jugadasPosibles(RestoCartas, NuevoMana, CartasPosibles).

jugadasPosibles([_|RestoCartas], Mana, CartasPosibles) :-
    jugadasPosibles(RestoCartas, Mana, CartasPosibles).

%-------[PUNTO 6]--------%

masDanina(Jugador, NombreCarta) :-
    tieneCarta(Jugador, Carta),
    nombre(Carta,NombreCarta),
    danio(Carta, Danio),
    not( ((tieneCarta(Jugador,OtraCarta), danio(OtraCarta,OtroDanio)) , OtroDanio > Danio  )).

 
%-------[PUNTO 7A]--------%

jugarContra(Carta, jugador(Nombre,Vida,Mana,Mazo,Mano,Campo), jugador(Nombre, NuevaVida, Mana, Mazo, Mano, Campo)) :-
    danio(Carta,Danio),
    NuevaVida is Vida - Danio.

