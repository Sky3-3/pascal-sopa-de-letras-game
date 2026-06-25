unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btn_nuevo: TButton;
    btn_jugar: TButton;
    lbl_puntajeTI: TLabel;
    lbl_titulo: TLabel;
    grid_sopa: TStringGrid;
    lbl_puntaje: TLabel;
    procedure btn_jugarClick(Sender: TObject);
    procedure btn_nuevoClick(Sender: TObject);
  private

  public

  end;

const
  TamSopa = 18;
  CantBase = 20; // Cantidad de palabras que hay en la lista/archivo

var
  Form1: TForm1;
  sopa: array[0..TamSopa-1, 0..TamSopa-1] of char;

  // Guardamos las 4 palabras que logramos meter en la sopa actual
  palabras_escondidas: array[0..3] of string;

  // LA MATRIZ DE BASE DE DATOS: columna 0 guarda la palabra (string), columna 1 el estado ('0' o '1')
  base_palabras: array[0..CantBase-1, 0..1] of string;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btn_nuevoClick(Sender: TObject);
var
   f, c, p, fila_actual, largo_palabra, elegida: integer;
   palabra: string;
begin
     randomize;

     // 1. SIMULAMOS LA CARGA DE LA BASE DE MOODLE (Puntapié inicial)
     base_palabras[0,0]:='ALEGRIA';   base_palabras[1,0]:='AMISTAD';
     base_palabras[2,0]:='AMOR';      base_palabras[3,0]:='ARBOL';
     base_palabras[4,0]:='AUTOMOVIL'; base_palabras[5,0]:='BELLEZA';
     base_palabras[6,0]:='BICICLETA'; base_palabras[7,0]:='BONDAD';
     base_palabras[8,0]:='CASA';      base_palabras[9,0]:='ESPEJO';
     base_palabras[10,0]:='FLOR';     base_palabras[11,0]:='IMAGINACION';
     base_palabras[12,0]:='JUSTICIA'; base_palabras[13,0]:='LIMPIEZA';
     base_palabras[14,0]:='MESA';     base_palabras[15,0]:='MOCHILA';
     base_palabras[16,0]:='RELOJ';    base_palabras[17,0]:='SABIDURIA';
     base_palabras[18,0]:='SILLA';    base_palabras[19,0]:='VERDAD';

     // Ponemos todas las marcas de selección en '0' (ninguna elegida todavía)
     for f := 0 to CantBase - 1 do
          base_palabras[f, 1] := '0';

     // 2. SELECCIÓN ALEATORIA DE 4 PALABRAS SIN REPETIR
     for p := 0 to 3 do
     begin
          repeat
               elegida := random(CantBase); // Sorteamos un índice de la base
          until base_palabras[elegida, 1] = '0'; // Si da '1', repite hasta encontrar una libre

          // La marcamos como elegida metiéndole un '1'
          base_palabras[elegida, 1] := '1';
          // La guardamos en nuestro vector de la partida
          palabras_escondidas[p] := base_palabras[elegida, 0];
     end;

     // 3. LLENAMOS LA SOPA CON MAYÚSCULAS AL AZAR (Fondo)
     for f := 0 to TamSopa - 1 do
     begin
          for c := 0 to TamSopa - 1 do
          begin
               sopa[f, c] := chr(random(26) + 65); // Letras 'A' a 'Z'
          end;
     end;

     // 4. INCRUSTAMOS LAS 4 PALABRAS AL COMIENZO DE LAS FILAS SELECCIONADAS
     for p := 0 to 3 do
     begin
          fila_actual := 1 + (p * 2); // Filas 1, 3, 5 y 7 (fila por medio)
          palabra := palabras_escondidas[p];
          largo_palabra := length(palabra);

          // Reemplazamos los casilleros del comienzo de la fila con las letras de la palabra
          for c := 0 to largo_palabra - 1 do
          begin
               sopa[fila_actual, c] := palabra[c + 1];
          end;
     end;

     // 5. VOLCAMOS LA MATRIZ DE CARACTERES A LA GRILLA VISUAL
     grid_sopa.RowCount := TamSopa;
     grid_sopa.ColCount := TamSopa;
     for f := 0 to TamSopa - 1 do
     begin
          for c := 0 to TamSopa - 1 do
          begin
               grid_sopa.cells[c, f] := sopa[f, c];
          end;
     end;

     showmessage('¡Nueva sopa de letras generada con éxito!');

     // Habilitamos JUGAR y actualizamos la interfaz
     btn_jugar.enabled := true;
     lbl_puntaje.Caption := '-'; // Reseteamos el cartel de puntaje
end;

procedure TForm1.btn_jugarClick(Sender: TObject);
var
   intento, p: integer;
   ingreso: string;
   puntaje_total: integer;
   encontrada: boolean;
begin
     // Arrancamos el puntaje de la partida en cero
     puntaje_total := 0;

     // El enunciado dice que se brinda la posibilidad de ingresar las 4 palabras
     for intento := 1 to 4 do
     begin
          // Abrimos la ventana emergente para que el alumno arriesgue una palabra
          ingreso := inputbox('Jugando - Intento ' + inttostr(intento) + ' de 4',
                             '¿Qué palabra encontraste en la sopa?:', '');

          // Pasamos lo que ingresó a MAYÚSCULAS para que coincida si escribe en minúsculas
          ingreso := uppercase(trim(ingreso));

          // 1. REGLA CONDICIONAL: ¿Dejó el cuadro vacío?
          if ingreso = '' then
          begin
               puntaje_total := puntaje_total - 50; // Palabra vacía resta 50
          end
          else
          begin
               // Si escribió algo, revisamos si está en nuestra lista de escondidas
               encontrada := false;

               for p := 0 to 3 do
               begin
                    if ingreso = palabras_escondidas[p] then
                    begin
                         encontrada := true;
                         break; // Si ya coincidió, salimos del bucle de revisión
                    end;
               end;

               // 2. REGLA CONDICIONAL: ¿Acertó o le erró?
               if encontrada then
                    puntaje_total := puntaje_total + 100 // Correcta suma 100
               else
                    puntaje_total := puntaje_total - 100; // Incorrecta resta 100
          end;
     end;

     // 3. FINALIZACIÓN DEL JUEGO: Mostramos el puntaje final en el TLabel de la pantalla
     lbl_puntaje.Caption := inttostr(puntaje_total);

     showmessage('¡Juego terminado! Revisá tu puntaje en la pantalla.');

     // 4. CONTROL DE INTERFAZ: Bloqueamos este botón y liberamos Nuevo Juego
     btn_jugar.enabled := false;
     btn_nuevo.enabled := true;
end;

end.

