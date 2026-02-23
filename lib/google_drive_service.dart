// lib/google_drive_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'models.dart';

const _backupFileName = 'investimentos_backup.json';

/// Cliente HTTP auxiliar para adicionar cabeçalhos de autenticação a cada solicitação.
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope], // Escopo para a pasta de dados do aplicativo
  );

  /// Tenta fazer login e retorna um cliente HTTP autenticado.
  Future<http.Client?> _getHttpClient() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        debugPrint("Usuário cancelou o login.");
        return null;
      }
      final authHeaders = await account.authHeaders;
      return _GoogleAuthClient(authHeaders);
    } catch (e) {
      debugPrint("Erro durante o login: $e");
      return null;
    }
  }

  /// Encontra o ID do nosso arquivo de backup na pasta de dados do aplicativo.
  Future<String?> _findBackupFileId(drive.DriveApi driveApi) async {
    try {
      final fileList = await driveApi.files.list(
        q: "name='$_backupFileName'",
        spaces: 'appDataFolder', // Usar a pasta de dados do aplicativo
        $fields: 'files(id, name)',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }
    } catch (e) {
      debugPrint("Não foi possível encontrar o arquivo de backup: $e");
    }
    return null;
  }

  /// Faz o backup da lista de fundos fornecida para o Google Drive.
  Future<bool> backup(List<InvestmentFund> funds) async {
    final client = await _getHttpClient();
    if (client == null) return false;

    final driveApi = drive.DriveApi(client);

    try {
      final fileId = await _findBackupFileId(driveApi);

      final List<Map<String, dynamic>> jsonList = funds.map((f) => f.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      final media = drive.Media(
        Stream.value(utf8.encode(jsonString)),
        utf8.encode(jsonString).length,
        contentType: 'application/json',
      );

      if (fileId == null) {
        final fileMetadata = drive.File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'];
        await driveApi.files.create(fileMetadata, uploadMedia: media);
      } else {
        await driveApi.files.update(drive.File(), fileId, uploadMedia: media);
      }
      debugPrint("Backup bem-sucedido.");
      return true;
    } catch (e) {
      debugPrint('Erro durante o backup: $e');
      return false;
    } finally {
      client.close();
    }
  }

  /// Restaura a lista de fundos do Google Drive.
  Future<List<InvestmentFund>?> restore() async {
    final client = await _getHttpClient();
    if (client == null) return null;

    final driveApi = drive.DriveApi(client);

    try {
      final fileId = await _findBackupFileId(driveApi);
      if (fileId == null) {
        debugPrint("Nenhum arquivo de backup encontrado.");
        return null;
      }

      final media = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      final jsonString = await utf8.decodeStream(media.stream);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final funds = jsonList.map((json) => InvestmentFund.fromJson(json as Map<String, dynamic>)).toList();
      debugPrint("Restauração bem-sucedida.");
      return funds;
    } catch (e) {
      debugPrint('Erro durante a restauração: $e');
      return null;
    } finally {
      client.close();
    }
  }
}