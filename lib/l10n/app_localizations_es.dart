// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcome => 'Bienvenido a Mental Gym';

  @override
  String get start => 'Comenzar';

  @override
  String get back => 'Regresar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get appName => 'Bulk Mind';

  @override
  String get red => 'Rojo';

  @override
  String get blue => 'Azul';

  @override
  String get green => 'Verde';

  @override
  String get yellow => 'Amarillo';

  @override
  String get orange => 'Naranja';

  @override
  String get purple => 'Morado';

  @override
  String get pink => 'Rosa';

  @override
  String get grey => 'Gris';

  @override
  String get brown => 'Marrón';

  @override
  String get white => 'Blanco';

  @override
  String get correct => '¡Correcto!';

  @override
  String get youCanContinue => 'Ya puedes seguir...';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get goToLogin => 'Ir a Login';

  @override
  String get logic => 'Lógica';

  @override
  String get intuition => 'Intuición';

  @override
  String get memory => 'Memoria';

  @override
  String get patterns => 'Patrones';

  @override
  String get spatial => 'Espacial';

  @override
  String get youAreALooser => 'Eres un perdedor';

  @override
  String get newRecord => 'Nuevo Record';

  @override
  String get maxLevel => 'Nivel Máximo';

  @override
  String get newBestTime => 'Nuevo mejor tiempo';

  @override
  String get bestTime => 'Mejor tiempo';

  @override
  String get yourScore => 'Tu puntuación';

  @override
  String get timeTaken => 'Tiempo';

  @override
  String get levels => 'Niveles';

  @override
  String get level => 'Nivel';

  @override
  String get time => 'Tiempo';

  @override
  String get incorrect => 'Incorrecto';

  @override
  String get signUp => 'Crear Cuenta';

  @override
  String get signIn => 'Iniciar Sesión';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordInvalid =>
      'La contraseña debe tener al menos 9 caracteres e incluir mayúsculas, minúsculas, un número y un carácter especial.';

  @override
  String get goToHome => 'Ir al Home';

  @override
  String get loginWithGoogle => 'Iniciar sesión con Google';

  @override
  String get fullName => 'Nombre Completo';

  @override
  String get age => 'Edad';

  @override
  String get birthday => 'Fecha de nacimiento';

  @override
  String get profile => 'Perfil';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get continueWithOutSignIn => 'Continuar sin iniciar sesión';

  @override
  String get getAllGamesTitle => 'Obtener todos los juegos';

  @override
  String annualSubscriptionPrice(Object price) {
    return 'Precio de suscripción anual: $price';
  }

  @override
  String get discountCodeLabel => 'Código de descuento';

  @override
  String get apply => 'Aplicar';

  @override
  String finalPrice(Object price) {
    return 'Precio final: $price';
  }

  @override
  String finalPriceWithOriginal(Object finalPrice, Object originalPrice) {
    return 'Precio final: $finalPrice (antes $originalPrice)';
  }

  @override
  String appliedCode(Object code) {
    return 'Código aplicado: $code';
  }

  @override
  String get priceUnavailable => 'Precio no disponible';

  @override
  String get failedToLoadPrice => 'No se pudo cargar el precio';

  @override
  String get discountApplied => 'Código de descuento aplicado';

  @override
  String get invalidOrExpiredCode => 'Código inválido o expirado';

  @override
  String get couldNotApplyCode => 'No se pudo aplicar el código';

  @override
  String get purchaseAnnualSubscription => 'Comprar suscripción anual';

  @override
  String get purchaseFlowStub => 'Aquí iniciaría el flujo de compra (Stripe)';
}
