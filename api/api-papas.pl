:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_cors)).

:- use_module(motor).
:- use_module(options).

:- encoding(utf8).
:- set_setting(http:cors, [*]).
% Rutas del API

:- http_handler('/', handle_home, []).

:- http_handler('/send', handle_post, []).

:- http_handler('/solution', handle_solution, []).

:- http_handler('/clear', handle_clear, []).

:- http_handler('/trait-options', handle_trait_options, []).



get_solution(Resp) :-
    solution(ResDict),
    Resp = ResDict,
    clearFacts(_);
    Resp = _{error: 1, msg: "Con los parametros ingresados, no es posible obtener un resultado."}.

perform_clear(ResDict) :-
    clearFacts(Result),
    (Result == true),
    ResDict =
    _{
        msg: "Limpieza correcta.",
        error: 0
    };
    ResDict = _{
        msg: "Limpieza correcta.",
        error: 0
    }.


% Servidor HTTP Prolog
% Maneja la respuesta a la raiz "/"
handle_home(_) :-
    cors_enable,
    Ver is 1.0,
    reply_json_dict(
        _{
            msg: "Api del Sistema Experto",
            ver: Ver
        }
    ).

% Maneja la peticion GET a "/solution".
handle_solution(_) :-
    cors_enable,
    get_solution(Result),
    reply_json_dict(Result).

% Maneja la peticion POST a "/send"
handle_post(Request) :-
    option(method(options), Request), !,
    cors_enable(Request,
                [ methods([get,post,delete])
                  ]),
    reply_json_dict(_{error: 0, msg: "peticion OPTIONS"});
    % Por POST
    option(method(post), Request), !,
    cors_enable(Request,
                [ methods([get,post,delete])
                  ]),
    http_read_json_dict(Request, Query),
    createFacts(Query),
    Result = _{error: 0, msg: "Recibido."},
    reply_json_dict(Result).

% Retorna las opciones de caracteristicas.
handle_trait_options(_) :-
   cors_enable,
   get_options(ResList),
   reply_json(ResList).

% Maneja la peticion GET a "/clear"
handle_clear(_) :-
    perform_clear(Resp),
    reply_json_dict(Resp).


server(Port) :-
    http_server(http_dispatch, [port(Port)]).

:- initialization(server(8081)).
% Fin Servidor


















