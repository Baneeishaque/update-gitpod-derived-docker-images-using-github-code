import 'package:update_gitpod_derived_docker_images_using_github_code/update_gitpod_derived_docker_images_using_github_code.dart'
    as update_gitpod_derived_docker_images_using_github_code;

Future<void> main(List<String> arguments) async {
  await update_gitpod_derived_docker_images_using_github_code.searchForGitpodDerivedImages(
      'baneeishaque/gitpod-workspace-full-vnc-1366x768-tint2-pcmanfm-zsh-android-studio-gh-chrome');
}
