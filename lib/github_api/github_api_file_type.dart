enum GithubApiFileType {
  file,
  dir,
  symlink;

  factory GithubApiFileType.fromJson(String json) {
    switch (json) {
      case 'file':
        return GithubApiFileType.file;
      case 'dir':
        return GithubApiFileType.dir;
      case 'symlink':
        return GithubApiFileType.symlink;
      default:
        throw Exception('Invalid GithubApiFileType: $json');
    }
  }

  bool get isFile => this == GithubApiFileType.file;
  bool get isDir => this == GithubApiFileType.dir;
}