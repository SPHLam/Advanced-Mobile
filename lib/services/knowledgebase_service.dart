import 'dart:io';

import 'package:dio/dio.dart';
import 'package:project_ai_chat/models/response/api_response.dart';
import 'package:project_ai_chat/utils/dio/dio_knowledge_base.dart';
import 'package:mime/mime.dart';

class KnowledgebaseService {
  final dioKB = DioKnowledgeBase().dio;

  Future<ApiResponse> getAllKnowledgeBases(int? offset, int? limit, String query) async {
    try {
      final response = await dioKB.get(
        '/knowledge',
        queryParameters: {
          'offset': offset,
          'limit': limit,
          'q': query,
        },
      );

      return ApiResponse(
        success: true,
        data: response.data,
        message: 'Lấy thông tin KB thành công',
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = '';
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Unauthorized, Please Login again';
        } else if (e.response!.statusCode == 500) {
          errorMessage = 'Internal Server Error';
        }

        final errorData = e.response!.data;
        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }

      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ApiResponse> createKnowledge(
      String knowledgeName, String description) async {
    try {
      final response = await dioKB.post(
        '/knowledge',
        data: {"knowledgeName": knowledgeName, "description": description},
      );


      return ApiResponse(
        success: true,
        message: 'Create new knowledge base successfully',
        data: response.data,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = 'Fail to create new knowledge base';
      if (e.response != null) {
        final errorData = e.response!.data;

        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }
      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response!.statusCode ?? 400,
      );
    }
  }

  Future<ApiResponse> editKnowledge(
      String id, String knowledgeName, String description) async {
    try {
      final response = await dioKB.patch(
        '/knowledge/$id',
        data: {
          "knowledgeName": knowledgeName,
          "description": description,
        },
      );


      return ApiResponse(
        success: true,
        message: 'Edit knowledge base successfully',
        data: response.data,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = 'Fail to edit knowledge base';
      if (e.response != null) {
        final errorData = e.response!.data;

        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }
      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response!.statusCode ?? 400,
      );
    }
  }

  Future<ApiResponse> deleteKnowledge(String id) async {
    try {
      final response = await dioKB.delete('/knowledge/$id');

      return ApiResponse(
        success: true,
        message: 'Delete knowledge base successfully',
        data: response.data,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = 'Fail to Delete knowledge base';
      if (e.response != null) {
        final errorData = e.response!.data;

        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }
      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response!.statusCode ?? 400,
      );
    }
  }

  Future<ApiResponse> uploadLocalFiles(List<File> selectedFiles, String knowledgeId) async {
    try {
      // Step 1: Upload all files to get identifiers
      final formData = FormData.fromMap({
        'files': await Future.wait(
          selectedFiles.asMap().entries.map((entry) async {
            final file = entry.value;
            final fileName = file.path.split('/').last;
            final binaryData = await file.readAsBytes();
            return MultipartFile.fromBytes(
              binaryData,
              filename: fileName,
              contentType: DioMediaType.parse(lookupMimeType(fileName) ?? 'application/octet-stream'),
            );
          }).toList(),
        ),
      });

      final uploadResponse = await dioKB.post(
        '/knowledge/files',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final fileIds = (uploadResponse.data['files'] as List<dynamic>)
          .map((file) => file['id'])
          .toList();

      // Step 2: Send the JSON payload with the files' metadata
      final payload = {
        'datasources': selectedFiles.asMap().entries.map((entry) {
          final index = entry.key;
          final file = entry.value;
          return {
            'type': 'local_file',
            'name': file.path.split('/').last,
            'credentials': {
              'file': fileIds[index],
            },
          };
        }).toList(),
      };

      final response = await dioKB.post(
        '/knowledge/$knowledgeId/datasources',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return ApiResponse(
        success: true,
        message: 'Upload local files successfully',
        data: response.data,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = 'Failed to upload local files';
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }
      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response?.statusCode ?? 400,
      );
    }
  }

  Future<ApiResponse> getUnitsOfKnowledge(
      String knowledgeId, int? offset, int? limit, String query) async {
    try {
      final response = await dioKB.get(
        '/knowledge/$knowledgeId/datasources',
        queryParameters: {
          'offset': offset,
          'limit': limit,
          'q': query,
        },
      );

      return ApiResponse(
        success: true,
        data: response.data,
        message: 'Lấy thông tin units KB thành công',
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = 'Internal Server Error';
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Unauthorized, Please Login again';
        } else if (e.response!.statusCode == 500) {
          errorMessage = 'Internal Server Error';
        }

        final errorData = e.response!.data;
        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }

      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ApiResponse> deleteUnit(String unitId, String knowledgeId) async {
    try {
      final response =
          await dioKB.delete('/knowledge/$knowledgeId/datasources/$unitId');

      return ApiResponse(
        success: true,
        data: response,
        message: 'Delete units successful',
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = 'Internal Server Error';
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Unauthorized, Please Login again';
        } else if (e.response!.statusCode == 500) {
          errorMessage = 'Internal Server Error';
        }

        final errorData = e.response!.data;
        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }

      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ApiResponse> updateStatusUnit(String knowledgeId, String unitId, bool isActived) async {
    try {
      final response = await dioKB.patch(
        '/knowledge/$knowledgeId/datasources/$unitId',
        data: {
          "status": isActived,
        },
      );

      return ApiResponse(
        success: true,
        data: response,
        message: 'Update units thành công',
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = 'Internal Server Error';
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Unauthorized, Please Login again';
        } else if (e.response!.statusCode == 500) {
          errorMessage = 'Internal Server Error';
        }

        final errorData = e.response!.data;
        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }

      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ApiResponse> uploadWebUrl(
      String knowledgeId, String webName, String webUrl) async {
    try {
      final payload = {
        'datasources': [{
          'type': 'web',
          'name': webName,
          'credentials': {
            'url': webUrl,
          },
        }],
      };
      final response = await dioKB.post(
        '/knowledge/$knowledgeId/datasources',
        data: payload,
      );

      return ApiResponse(
        success: true,
        message: 'Upload web url successfully',
        data: response.data,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = 'Fail to upload web url';
      if (e.response != null) {
        final errorData = e.response!.data;

        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }
      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response!.statusCode ?? 400,
      );
    }
  }

  Future<ApiResponse> uploadSlack(
      String knowledgeId, String slackName, String slackBotToken) async {
    try {
      final payload = {
        'datasources': [{
          'type': 'slack',
          'name': slackName,
          'credentials': {
            'token': slackBotToken,
          },
        }],
      };

      final response = await dioKB.post(
        '/knowledge/$knowledgeId/datasources',
        data: payload,
      );

      return ApiResponse(
        success: true,
        message: 'Upload slack successfully',
        data: response.data,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = 'Fail to upload slack';
      if (e.response != null) {
        final errorData = e.response!.data;

        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }
      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response!.statusCode ?? 400,
      );
    }
  }

  Future<ApiResponse> uploadConfluence(
      String knowledgeId, String confluenceName, String wikiPageUrl, String confluenceEmail, String confluenceToken) async {
    try {
      final payload = {
        'datasources': [{
          'type': 'confluence',
          'name': confluenceName,
          'credentials': {
            'token': confluenceToken,
            'url': wikiPageUrl,
            'username': confluenceEmail,
          },
        }],
      };

      final response = await dioKB.post(
        '/knowledge/$knowledgeId/datasources',
        data: payload,
      );

      return ApiResponse(
        success: true,
        message: 'Upload confluence successfully',
        data: response.data,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = 'Fail to upload confluence';
      if (e.response != null) {
        final errorData = e.response!.data;

        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }
      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response!.statusCode ?? 400,
      );
    }
  }
}