import 'github_api_file_type.dart';
import 'github_api_links.dart';

class GithubApiFileInfo {
  final String name;
  final Uri path;
  final String sha;
  final int size;
  final Uri url;
  final Uri htmlUrl;
  final Uri gitUrl;
  final Uri? downloadUrl;
  final GithubApiFileType type;
  final GithubApiLinks links;

  const GithubApiFileInfo({
    required this.name,
    required this.path,
    required this.sha,
    required this.size,
    required this.url,
    required this.htmlUrl,
    required this.gitUrl,
    required this.downloadUrl,
    required this.type,
    required this.links,
  });

  factory GithubApiFileInfo.fromJson(Map<String, dynamic> json) {
    return GithubApiFileInfo(
      name: json['name'],
      path: Uri.parse(json['path']),
      sha: json['sha'],
      size: json['size'],
      url: Uri.parse(json['url']),
      htmlUrl: Uri.parse(json['html_url']),
      gitUrl: Uri.parse(json['git_url']),
      downloadUrl:
          json['download_url'] != null ? Uri.parse(json['download_url']) : null,
      type: GithubApiFileType.fromJson(json['type']),
      links: GithubApiLinks.fromJson(json['_links']),
    );
  }

  @override
  String toString() {
    return 'GithubFileInfo{name: $name,\n  path: $path,\n  sha: $sha,\n  size: $size,\n  url: $url,\n  htmlUrl: $htmlUrl,\n  gitUrl: $gitUrl,\n  downloadUrl: $downloadUrl,\n  type: $type,\n  links: $links}';
  }

  List<String> get pathFragments => path.pathSegments;
}
