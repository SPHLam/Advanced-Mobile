import 'dart:io';

import 'package:dio/dio.dart';
import 'package:project_ai_chat/models/response/api_response.dart';
import 'package:project_ai_chat/utils/dio/dio_knowledge_base.dart';

class KnowledgebaseService {
  final dioKB = DioKnowledgeBase().dio;

  Future<ApiResponse> getAllKnowledgeBases(
      String query, int? offset, int? limit) async {
    try {
      final response = await dioKB.get(
        '/knowledge',
        queryParameters: {
          'q': query,
          'limit': limit,
          'offset': offset,
        },
      );
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: response.data,
          message: 'Lấy thông tin KB thành công',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Lấy thông tin KB thất bại',
          statusCode: response.statusCode ?? 400,
        );
      }
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: 'Create new knowledge base successfully',
          data: response.data,
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Fail to create new knowledge base: ${response.data}',
          statusCode: response.statusCode ?? 400,
        );
      }
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: 'Edit knowledge base successfully',
          data: response.data,
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Fail to edit new knowledge base: ${response.data}',
          statusCode: response.statusCode ?? 400,
        );
      }
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: 'Delete knowledge base successfully',
          data: response.data,
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Fail to Delete new knowledge base: ${response.data}',
          statusCode: response.statusCode ?? 400,
        );
      }
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

  Future<ApiResponse> uploadLocalFile(
      File selectedFile, String knowledgeId) async {
    try {
      print('Đường dẫn file: ${selectedFile.path}');
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          selectedFile.path,
          filename: selectedFile.path.split('/').last,
          contentType: DioMediaType('application', 'pdf'),
        )
      });
      final response = await dioKB.post(
        '/knowledge/$knowledgeId/local-file',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data' // Chỉ áp dụng cho request này
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: 'Upload local file successfully',
          data: response.data,
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Fail to upload local file: ${response.data}',
          statusCode: response.statusCode ?? 400,
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Fail to upload local file';
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

  Future<ApiResponse> getUnitsOfKnowledge(
      String knowledgeId, int? offset, int? limit) async {
    try {
      final response = await dioKB.get(
        '/knowledge/$knowledgeId/units',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: response.data,
          message: 'Lấy thông tin units KB thành công',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Lấy thông tin units KB thất bại',
          statusCode: response.statusCode ?? 400,
        );
      }
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
          await dioKB.delete('/knowledge/$knowledgeId/units/$unitId');
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: response,
          message: 'Delete units thành công',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Delete units thất bại',
          statusCode: response.statusCode ?? 400,
        );
      }
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

  Future<ApiResponse> updateStatusUnit(String unitId, bool isActived) async {
    try {
      final response = await dioKB.patch(
        '/knowledge/units/$unitId/status',
        data: {
          "status": isActived,
        },
      );
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: response,
          message: 'Update units thành công',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Update units thất bại',
          statusCode: response.statusCode ?? 400,
        );
      }
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
      final response = await dioKB.post(
        '/knowledge/$knowledgeId/web',
        data: {
          "unitName": webName,
          "webUrl": webUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: 'Upload web url successfully',
          data: response.data,
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Fail to upload web url: ${response.data}',
          statusCode: response.statusCode ?? 400,
        );
      }
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
      String knowledgeId, String slackName, String slackWorkspace, String slackBotToken) async {
    try {
      final response = await dioKB.post(
        '/knowledge/$knowledgeId/slack',
        data: {
          "unitName": slackName,
          "slackWorkspace": slackWorkspace,
          "slackBotToken": slackBotToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: 'Upload slack successfully',
          data: response.data,
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Fail to upload slack: ${response.data}',
          statusCode: response.statusCode ?? 400,
        );
      }
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
      String knowledgeId, String confluenceName, String wikiPageUrl, String username, String accessToken) async {
    try {
      final response = await dioKB.post(
        '/knowledge/$knowledgeId/confluence',
        data: {
          "unitName": confluenceName,
          "wikiPageUrl": wikiPageUrl,
          "confluenceUsername": username,
          "confluenceAccessToken": accessToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: 'Upload confluence successfully',
          data: response.data,
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Fail to upload confluence: ${response.data}',
          statusCode: response.statusCode ?? 400,
        );
      }
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
