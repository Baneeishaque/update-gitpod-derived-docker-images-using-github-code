import 'dart:convert';
import 'dart:io';

import 'package:docker2/docker2.dart' as docker2;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

import 'package:update_gitpod_derived_docker_images_using_github_code/GithubApiSearchCodeRequestResponse.dart';

int apiRequestCount = 1;
bool isLoggedIn = false;
List<String> builtImages = List.empty(growable: true);
List<String> pushedImages = List.empty(growable: true);
File builtImagesFile = File('builtImages.txt');
var pushedImagesFile = File('pushedImages.txt');

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
    removeImage(imageName);
  }
}

void removeImage(String imageName) {
  // var a = docker2.dockerRun('images', '\'$imageName\' -a -q');
  // print(a);
  docker2.dockerRun('rmi',
      '--force ${(docker2.dockerRun('images', '\'$imageName\' -a -q'))[0]}',
      terminal: true);
}

void removePushedImages() {
  pushedImages.forEach((pushedImage) {
    removeImage(pushedImage);
    // pushedImages.remove(pushedImage);
  });
}

Future<void> repositoryCloneBuildPushAndRemoveImage(String imageName) async {
  //built images
  if (builtImages.contains(imageName)) {
    print('Image $imageName is already built. So, skipping now...');
  } else {
    //check disk space
    ProcessResult dfResult = await Process.run('df', ['-h', '--total']);
    String dfResultFileName = 'dfResult.txt';
    File(dfResultFileName).writeAsStringSync(dfResult.stdout.toString());
    ProcessResult grepResult =
        await Process.run('grep', ['total', dfResultFileName]);
    String processedGrepResultString =
        grepResult.stdout.toString().substring(16);
    int percentageSymbolIndex = processedGrepResultString.indexOf('%');
    int diskUsagePercentage = int.parse(processedGrepResultString.substring(
        percentageSymbolIndex - 2, percentageSymbolIndex));
    if (diskUsagePercentage >=
        int.parse(Platform.environment['MAXIMUM_DISK_USAGE_PERCENTAGE'])) {
      //Stop Containers
      // List<String> containerIds = docker2.dockerRun('ps', '-a -q');
      // print(containerIds);
      // containerIds.forEach((containerId) {
      //   docker2.dockerRun('rm', containerId, terminal: true);
      // });
      if (pushedImages.isNotEmpty) {
        removePushedImages();
        repositoryCloneBuildPushAndRemoveImage(imageName);
      } else {
        print('Error : out of storage...');
        exit(0);
      }
    }
    String dockerBuildArgs =
        '--file .gitpod.Dockerfile --tag $imageName:latest';
    print('Building https://github.com/$imageName.git');
    print(
        'Docker raw command for local repo. : docker build $dockerBuildArgs .');
    dockerBuildArgs = '$dockerBuildArgs https://github.com/$imageName.git';
    print('Docker raw command : docker build $dockerBuildArgs');
    docker2.dockerRun('build', dockerBuildArgs, terminal: true);
    builtImagesFile.writeAsStringSync('$imageName\n', mode: FileMode.append);
  }
  // //pushed images
  if (pushedImages.contains(imageName)) {
    print('Image $imageName is already pushed. So, skipping now...');
  } else {
    if (isLoggedIn) {
      pushImage(imageName);
    } else {
      var loginResult = docker2.dockerRun('login',
          '--username ${Platform.environment['DOCKER_HUB_USERNAME']} --password ${Platform.environment['DOCKER_HUB_PASSWORD']}');
      // print(loginResult);
      // print(loginResult.last);
      if (loginResult.last == 'Login Succeeded') {
        isLoggedIn = true;
        // exit(0);
        pushImage(imageName);
      } else {
        print('login Error : $loginResult');
        exit(0);
      }
    }
  }
}

void pushImage(String imageName) {
  String dockerPushArgs = '$imageName:latest';
  print('Pushing $dockerPushArgs');
  docker2.dockerRun('push', '$dockerPushArgs', terminal: true);
  print('Docker raw command : docker push $dockerPushArgs');
  pushedImagesFile.writeAsStringSync('$imageName\n', mode: FileMode.append);
}

Future<void> searchForGitpodDerivedImages(String baseImageName) async {
  if (builtImagesFile.existsSync()) {
    builtImages = builtImagesFile.readAsLinesSync();
  }
  if (pushedImagesFile.existsSync()) {
    pushedImages = pushedImagesFile.readAsLinesSync();
  }
  await searchForGitpodDerivedImagesSkeleton(baseImageName, 'baneeishaque');
}
