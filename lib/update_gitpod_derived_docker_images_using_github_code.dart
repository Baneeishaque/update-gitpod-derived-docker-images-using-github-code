import 'dart:convert';
import 'dart:io';

import 'package:docker2/docker2.dart' as docker2;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

// import 'package:git_clone/git_clone.dart' as git_clone;
// import 'package:docker_client/api.dart';
import 'package:update_gitpod_derived_docker_images_using_github_code/GithubApiSearchCodeRequestResponse.dart';

int apiRequestCount = 1;

Future<GitHubApiSearchCodeRequestResponse> searchForGitHubCode(
    String searchQuery) async {
  if (searchQuery.isEmpty) {
    print('Invalid Search Query...');
    throw Exception('Error : Invalid Search Query');
  }

  String encodeSearchQuery = Uri.encodeFull(searchQuery);
  Uri url =
      Uri.parse('https://api.github.com/search/code?q=$encodeSearchQuery');
  http.Response response = await http.get(url);

  if (response.statusCode == 200) {
    return GitHubApiSearchCodeRequestResponse.fromJson(
        jsonDecode(response.body));
  } else {
    throw Exception(
        'Error : Status Code - ${response.statusCode}, Response Body - ${response.body}');
  }
}

Future<void> searchForGitpodDerivedImagesSkeleton(
    String imageName, String gitHubUsername) async {
  if (imageName.isEmpty) {
    print('Invalid Image Name...');
    return;
  }

  if ((apiRequestCount > 10) && ((apiRequestCount % 10) == 1)) {
    print('Waiting to bypass GitHub API request limit restrictions');
    sleep(Duration(minutes: 1));
  }

  print('$apiRequestCount : $imageName - Clone, Build, Push & Remove Image');
  await repositoryCloneBuildPushAndRemoveImage(imageName);

  GitHubApiSearchCodeRequestResponse gitHubApiSearchCodeRequestResponse =
      await searchForGitHubCode(
          '$imageName in:file user:$gitHubUsername path:/ language:Dockerfile filename:.gitpod fork:true');
  apiRequestCount++;

  if (gitHubApiSearchCodeRequestResponse.incompleteResults) {
    print('Incomplete results...');
  } else {
    for (var i = 0; i < gitHubApiSearchCodeRequestResponse.totalCount; ++i) {
      Items item = gitHubApiSearchCodeRequestResponse.items[i];
      Repository repository = item.repository;

      if (repository.fork) {
        print('It\'s a fork, Want to continue : ');
      } else {
        String derivedImage =
            '$gitHubUsername/${repository.htmlUrl.replaceFirst('https://github.com/${intl.toBeginningOfSentenceCase(gitHubUsername)}/', '')}';
        if ((derivedImage.contains('gitpod')) ||
            (derivedImage.contains('gp'))) {
          await searchForGitpodDerivedImagesSkeleton(
              derivedImage, gitHubUsername);
        }
      }
    }
    print('Safely Remove Image : $imageName');
  }
}

Future<void> repositoryCloneBuildPushAndRemoveImage(String imageName) async {
  // await git_clone.fastClone(
  //     platform: git_clone.Platform.github,
  //     ownerAndRepo: 'docker/getting-started',
  //     callback: (ProcessResult processResult) async {
  //       if (processResult.exitCode == 0) {
  //         print(processResult.stdout);
  //       } else {
  //         print("Error : ${processResult.stderr}");
  //       }
  //     });
  // await ImageApi().imageBuild(
  //     remote: 'https://github.com/docker/getting-started.git',
  //     dockerfile: 'Dockerfile',
  //     t: 'docker/getting-started');
  docker2.dockerRun(
      'build', '--file .gitpod.Dockerfile --tag $imageName:latest https://github.com/$imageName.git',
      terminal: true);
}

Future<void> searchForGitpodDerivedImages(String baseImageName) async {
  await searchForGitpodDerivedImagesSkeleton(baseImageName, 'baneeishaque');
}
