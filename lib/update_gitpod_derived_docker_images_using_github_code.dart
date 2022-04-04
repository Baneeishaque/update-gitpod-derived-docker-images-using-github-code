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

  print('$apiRequestCount : $imageName - Build, Push & Safely Remove Image');
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
  print('Removing image $imageName...');
  List<String> imageIdList =
      docker2.dockerRun('images', '\'$imageName\' -a -q');
  // print(imageIdList);
  if (imageIdList.isNotEmpty) {
    try {
      docker2.dockerRun('rmi', '--force ${imageIdList[0]}', terminal: true);
    } catch (exception) {
      print('Error : ${exception.toString()}');
    }
  }
}

void removeImageUsingImageId(String imageId) {
  print('Removing image $imageId...');
  try {
    docker2.dockerRun('rmi', '--force $imageId', terminal: true);
  } catch (exception) {
    print('Error : ${exception.toString()}');
  }
}

void removePushedImages() {
  print('Removing Pushed Images...');
  print('Pushed Images : $pushedImages');
  pushedImages.reversed.forEach((pushedImage) {
    removeImage(pushedImage);
  });
  pushedImages = List.empty(growable: true);
}

bool deleteAllImages(){
  print('Removing all images...');
  List<String> imagesIdList =
      docker2.dockerRun('images', '-a -q');
  print('All Images : $imagesIdList');
  if (imagesIdList.isNotEmpty) {
    imagesIdList.forEach((imageId){
      removeImageUsingImageId(imageId);
    });
    return true;
  }else{
    return false;
  }
}

Future<void> repositoryCloneBuildPushAndRemoveImage(String imageName,
    {bool afterCleanUp = false}) async {
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
    int allowedMaximumDiskUsage =
        int.parse(Platform.environment['MAXIMUM_DISK_USAGE_PERCENTAGE']);
    print(
        'disk Usage % : $diskUsagePercentage, allowed Disk Usage % : $allowedMaximumDiskUsage');
    if (diskUsagePercentage >= allowedMaximumDiskUsage) {
      //Stop Containers
      // List<String> containerIds = docker2.dockerRun('ps', '-a -q');
      // print(containerIds);
      // containerIds.forEach((containerId) {
      //   docker2.dockerRun('rm', containerId, terminal: true);
      // });
      if (pushedImages.isNotEmpty) {
        removePushedImages();
        repositoryCloneBuildPushAndRemoveImage(imageName, afterCleanUp: true);
      } else {
        //delete all images
        if(deleteAllImages()){
          repositoryCloneBuildPushAndRemoveImage(imageName, afterCleanUp: true);
        }else{
          print('Error : out of storage...');
          exit(0);
        }
      }
    }else{
      String dockerBuildArgs =
          '--file .gitpod.Dockerfile --tag $imageName:latest';
      print('Building https://github.com/$imageName.git');
      print(
          'Docker raw command for local repo. : docker build $dockerBuildArgs .');
      dockerBuildArgs = '$dockerBuildArgs https://github.com/$imageName.git';
      print('Docker raw command : docker build $dockerBuildArgs');
      docker2.dockerRun('build', dockerBuildArgs, terminal: true);
      if (!builtImages.contains(imageName)) {
        builtImagesFile.writeAsStringSync('$imageName\n', mode: FileMode.append);
      }
    }
  }
  //pushed images
  if (afterCleanUp) {
    pushedImages = pushedImagesFile.readAsLinesSync();
  }
  // print('Pushed Images : $pushedImages');
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
  if (!pushedImages.contains(imageName)) {
    pushedImagesFile.writeAsStringSync('$imageName\n', mode: FileMode.append);
  }
  print('Pushed Images : $pushedImages');
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
