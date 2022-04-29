import 'package:update_gitpod_derived_docker_images_using_github_code/update_gitpod_derived_docker_images_using_github_code.dart'
    as update_gitpod_derived_docker_images_using_github_code;
import 'dart:io';

Future<void> main(List<String> arguments) async {
  // print(arguments.length);
  // exit(0);
  if (arguments.length == 0) {
    print(
        'Error: Missing Base Image Name - Please supply the Base Image Name as program argument...');
  } else {
    if (arguments.contains('--dry-run')) {
      await update_gitpod_derived_docker_images_using_github_code
          .searchForGitpodDerivedImages(arguments[0], isDryRun: true);
    } else {
      await update_gitpod_derived_docker_images_using_github_code
          .searchForGitpodDerivedImages(arguments[0]);
    }
  }
}
