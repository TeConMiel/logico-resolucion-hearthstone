/*
% jugadores
jugador(Nombre, PuntosVida, PuntosMana, CartasMazo, CartasMano, CartasCampo)

% cartas
criatura(Nombre, PuntosDaño, PuntosVida, CostoMana)
hechizo(Nombre, FunctorEfecto, CostoMana)

% efectos
daño(CantidadDaño)
cura(CantidadCura)
*/

nombre(jugador(Nombre,_,_,_,_,_), Nombre).
nombre(criatura(Nombre,_,_,_), Nombre).
nombre(hechizo(Nombre,_,_), Nombre).

vida(jugador(_,Vida,_,_,_,_), Vida).
vida(criatura(_,_,Vida,_), Vida).
vida(hechizo(_,curar(Vida),_), Vida).

danio(criatura(_,Danio,_, _), Danio).
danio(hechizo(_,danio(Danio),_), Danio).

mana(jugador(_,_,Mana,_,_,_), Mana).
mana(criatura(_,_,_,Mana), Mana).
mana(hechizo(_,_,Mana), Mana).

cartasMazo(jugador(_,_,_,Cartas,_,_), Cartas).
cartasMano(jugador(_,_,_,_,Cartas,_), Cartas).
cartasCampo(jugador(_,_,_,_,_,Cartas), Cartas).



jugador(jugador(franco, 200, 280, [criatura(nombre, 10, 10, 2)], [criatura(otroNombre, 10, 10, 2)], [])).
jugador(jugador(mati, 500, 180, [hechizo(nombre, danio(42), 10)], [], [])).

/* 1 ------------------------------------------
Relacionar un jugador con una carta que tiene. La carta podría estar en su mano,
en el campo o en el mazo.
*/

% version 1
tiene(Jugador, Carta):-
    cartasCampo(Jugador, Campo),
    member(Carta, Campo).
tiene(Jugador, Carta):-
    cartasMano(Jugador, Mano),
    member(Carta, Mano).
tiene(Jugador, Carta):-
    cartasMazo(Jugador, Mazo),
    member(Carta, Mazo).
    

% version 2
tiene2(Jugador, Carta):-
    tiene(Jugador, cartasMazo, Carta).
tiene2(Jugador, Carta):-
    tiene(Jugador, cartasMano, Carta).
tiene2(Jugador, Carta):-
    tiene(Jugador, cartasCampo, Carta).

% tiene/3
tiene(Jugador, Predicado, Carta):-
    jugador(Jugador),
    call(Predicado, Jugador, Cartas),
    member(Carta, Cartas).
    
% version 3
tiene3(Jugador, Carta):-
    jugador(Jugador),
    member(Predicado, [cartasMazo, cartasMano, cartasCampo]),
    call(Predicado, Jugador, Cartas),
    member(Carta, Cartas).

% version 4
lugarDeCartas(cartasCampo).
lugarDeCartas(cartasMano).
lugarDeCartas(cartasMazo).

tiene4(Jugador, Carta):-
    jugador(Jugador),
    lugarDeCartas(Lugar),
    call(Lugar, Jugador, Cartas),
    member(Carta, Cartas).

/* 2 ------------------------------------------
Saber si un jugador es un guerrero. Es guerrero cuando todas las cartas que tiene,
ya sea en el mazo, la mano o el campo, son criaturas.
*/
esCriatura(criatura(_, _, _, _)).

esGuerrero(Jugador):- 
    jugador(Jugador),
    forall(tiene(Jugador,Carta), esCriatura(Carta)).




/* 3 ------------------------------------------
Relacionar un jugador consigo mismo después de empezar el turno. Al empezar el turno,
la primer carta del mazo pasa a estar en la mano y el jugador gana un punto de maná.
*/

empezarTurno(jugador(Nombre, Vida, PuntosMana, [PrimeraMazo | Mazo], Mano, Campo),
             jugador(Nombre, Vida, PuntosManaDespues, Mazo, [PrimeraMazo | Mano], Campo)):- 
             jugador(jugador(Nombre, Vida, PuntosMana, [PrimeraMazo | Mazo], Mano, Campo)),
                PuntosManaDespues is PuntosMana + 1.

empezarTurno2(Jugador, jugador(Nombre, Vida, PuntosManaDespues, Mazo, [PrimeraMazo | Mano], Campo)):-
    jugador(Jugador),
    nombre(Jugador, Nombre),
    vida(Jugador, Vida),
    mana(Jugador, PuntosMana),
    cartasMazo(Jugador, [PrimeraMazo | Mazo]),
    cartasMano(Jugador, Mano),
    cartasCampo(Jugador, Campo),
    PuntosManaDespues is PuntosMana + 1.


/* 4 ------------------------------------------
Cada jugador, en su turno, puede jugar cartas.

a) Saber si un jugador tiene la capacidad de jugar una carta, esto es verdadero cuando
el jugador tiene igual o más maná que el costo de maná de la carta.
Este predicado no tiene que ser inversible 
*/

puedeJugar(Jugador, Carta):-
    mana(Jugador, ManaJugador),
    mana(Carta, ManaCarta),
    ManaJugador >= ManaCarta.



/*
b) Relacionar un jugador y las cartas que va a poder jugar en el próximo turno,
una carta se puede jugar en el próximo turno si al empezar ese turno está en la mano y
además se cumplen las condiciones del punto 4.a.
*/

puedeJugarEnElProximoTurno(Jugador, Cartas):-
    puedeJugarEnElProximoTurno(Jugador, Cartas, _).

puedeJugarEnElProximoTurno(Jugador, Cartas, JugadorDespues):-
    empezarTurno(Jugador, JugadorDespues),
    cartasMano(JugadorDespues, Mano),
    findall(Carta, 
        (member(Carta, Mano), puedeJugar(JugadorDespues, Carta)), 
        Cartas).





/* 5 ------------------------------------------
Conocer, de un jugador, todas las posibles jugadas que puede hacer en el próximo turno,
esto es, el conjunto de cartas que podrá jugar al mismo tiempo sin que su maná quede
negativo.
Nota: Se puede asumir que existe el predicado jugar/3 como se indica en el punto 7.b.
No hace falta implementarlo para resolver este punto. Importante: También hay formas
de esolver este punto sin usar jugar/3.
Tip: Pensar en explosión combinatoria.
*/

carta(criatura(_,_,_,_)).
carta(hechizo(_,_,_)).

% Jugada = [Carta]
posibleJugada(Jugador, Cartas):-
    puedeJugarEnElProximoTurno(Jugador, CartasJugables, JugadorDespues),
    mana(JugadorDespues, ManaDespues),
    subconjunto(Cartas, CartasJugables),
    manaTotal(CartasJugables, ManaTotal),
    ManaDespues >= ManaTotal.

subconjunto(Subconjunto, Conjunto):-
    select(_, Conjunto, Resto),
    subconjunto(Subconjunto, Resto).
subconjunto([Elemento | Subconjunto], Conjunto):-
    select(Elemento, Conjunto, Resto),
    subconjunto(Subconjunto, Resto).
subconjunto([], []).

manaTotal(Cartas, Total):-
    maplist(mana, Cartas, Manas),
    sum_list(Manas, Total).
    







/* 6 ------------------------------------------
Relacionar a un jugador con el nombre de su carta más dañina.
*/

masDañina(Jugador, Carta):-
    tiene(Jugador, Carta),
    danio(Carta, Danio),
    not((tiene(Jugador, OtraCarta), danio(OtraCarta, OtroDanio), OtroDanio > Danio)).

masDañina2(Jugador, Carta):-
    tiene(Jugador, Carta),
    danio(Carta, Danio),
    forall(tiene(Jugador, OtraCarta), (danio(OtraCarta, OtroDanio), Danio >= OtroDanio)).



/* 7.a) ------------------------------------------
Cuando un jugador juega una carta, él mismo y/o su rival son afectados de alguna forma:
jugarContra/3. Modela la acción de jugar una carta contra un jugador. Relaciona a la
carta, el jugador antes de que le jueguen la carta y el jugador después de que le
jueguen la carta. Considerar que únicamente afectan al jugador las cartas de hechizo de
daño.
Este predicado no necesita ser inversible para la carta ni para el jugador antes de que
e jueguen la carta.
*/

/* 7.b) ------------------------------------------
BONUS: jugar/3. Modela la acción de parte de un jugador de jugar una carta. Relaciona a
la carta, el jugador que puede jugarla antes de hacerlo y el mismo jugador después de
jugarla. En caso de ser un hechizo de cura, se aplicará al jugador y no a sus criaturas.
No involucra al jugador rival (para eso está el punto a).
*/