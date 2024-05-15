/// Esta función ejecuta la función `op` si es que el objeto no es nulo, además retorna lo que retorne la función op.
///
/// Modo de uso:
///
/// ```dart
/// num? numeroPosiblementeNulo = 5;
/// num? resultado = let(numeroPosiblementeNulo, (numero) => numero*2);
/// print(resultado); // 10
/// ```
///
/// Ahora, si el objeto es nulo, la función retornará null.
///
/// Además puedes especificar los tipos de datos para ayudar a los IDEs a inferir el tipo de dato de retorno.
/// Ejemplo:
///
/// ```dart
/// String? fechaPosiblementeNula = "2021-10-10";
/// DateTime? fecha = let<String, DateTime?>(fechaPosiblementeNula, (fecha) => DateTime.tryParse(fecha));
/// print(fecha); // 2021-10-10 00:00:00.000
/// ```
V? let<K,V>(K? object, V Function(K) op) => object != null ? op(object) : null;