class GithubApiLinks {
  final Uri self;
  final Uri git;
  final Uri html;

  const GithubApiLinks({
    required this.self,
    required this.git,
    required this.html,
  });

  factory GithubApiLinks.fromJson(Map<String, dynamic> json) {
    return GithubApiLinks(
      self: Uri.parse(json['self']),
      git: Uri.parse(json['git']),
      html: Uri.parse(json['html']),
    );
  }

  @override
  String toString() {
    return 'GithubLinks{self: $self, git: $git, html: $html}';
  }
}