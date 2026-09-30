import 'package:cloud_functions/cloud_functions.dart';

class GeneratedWebsite {
  const GeneratedWebsite({
    required this.projectId,
    required this.html,
  });

  final String projectId;
  final String html;

  factory GeneratedWebsite.fromMap(
    Map<String, dynamic> map,
  ) {
    final String projectId =
        map['projectId']?.toString().trim() ?? '';

    final String html =
        map['html']?.toString().trim() ?? '';

    if (projectId.isEmpty) {
      throw const AiWebsiteGenerationException(
        'Project ID was not returned by Firebase.',
      );
    }

    if (html.isEmpty) {
      throw const AiWebsiteGenerationException(
        'The generated website is empty.',
      );
    }

    return GeneratedWebsite(
      projectId: projectId,
      html: html,
    );
  }
}

class AiWebsiteGenerationService {
  AiWebsiteGenerationService({
    FirebaseFunctions? functions,
  }) : _functions = functions ??
            FirebaseFunctions.instanceFor(
              region: 'asia-south1',
            );

  final FirebaseFunctions _functions;

  Future<GeneratedWebsite> generate(
    Map<String, dynamic> requirements,
  ) async {
    if (requirements.isEmpty) {
      throw const AiWebsiteGenerationException(
        'Client requirements are required.',
      );
    }

    final HttpsCallable callable =
        _functions.httpsCallable(
      'generateStaticWebsite',
      options: HttpsCallableOptions(
        timeout: const Duration(minutes: 5),
      ),
    );

    try {
      final HttpsCallableResult<dynamic> response =
          await callable.call<Map<String, dynamic>>(
        requirements,
      );

      if (response.data is! Map) {
        throw const AiWebsiteGenerationException(
          'Invalid response from Firebase.',
        );
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      return GeneratedWebsite.fromMap(data);
    } on FirebaseFunctionsException catch (error) {
      throw AiWebsiteGenerationException(
        _getFirebaseErrorMessage(error),
      );
    } on AiWebsiteGenerationException {
      rethrow;
    } catch (error) {
      throw AiWebsiteGenerationException(
        'Unable to generate website: $error',
      );
    }
  }

  String _getFirebaseErrorMessage(
    FirebaseFunctionsException error,
  ) {
    switch (error.code) {
      case 'unauthenticated':
        return 'Please sign in before generating a website.';

      case 'invalid-argument':
        return error.message ??
            'Please provide valid client requirements.';

      case 'deadline-exceeded':
        return 'Website generation took too long. Please retry.';

      case 'resource-exhausted':
        return 'Website generation limit reached.';

      case 'unavailable':
        return 'Website generation service is temporarily unavailable.';

      case 'internal':
        return error.message ??
            'An internal server error occurred.';

      default:
        return error.message ??
            'Website generation failed.';
    }
  }
}

class AiWebsiteGenerationException implements Exception {
  const AiWebsiteGenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}