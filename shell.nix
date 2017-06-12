with import <nixpkgs> {};

let
  jdk = openjdk;
  node = nodejs-8_x;
  sdk = androidenv.androidsdk {
    platformVersions = [ "23" ];
    abiVersions = [ "x86" ];
    useGoogleAPIs = true;
    useExtraSupportLibs = false;
    useGooglePlayServices = false;
  };
  unpatched-sdk =
    let version = "3859397";
    in stdenv.mkDerivation {
      name = "unpatched-sdk";
      src = fetchzip {
        url = "https://dl.google.com/android/repository/sdk-tools-linux-${version}.zip";
        sha256 = "03vh2w1i7sjgsh91bpw40ryhwmz46rv8b9mp7xzg89zs18021plr";
      };
      installPhase = ''
        mkdir -p $out
        cp -r * $out/
      '';
      dontPatchELF = true;
    };
  run-android = pkgs.buildFHSUserEnv {
    name = "run-android";
    targetPkgs = (pkgs: [
      node
    ]);
    profile = ''
      export JAVA_HOME=${jdk.home}
      export ANDROID_HOME=$PWD/.android
      export PATH=$PWD/node_modules/.bin:$PATH
    '';
    runScript = "react-native run-android";
  };
in
  stdenv.mkDerivation {
    name = "react-native-android";
    nativeBuildInputs = [
      run-android
    ];
    buildInputs = [
      coreutils
      node
      sdk
      unpatched-sdk
    ];
    shellHook = ''
      export JAVA_HOME=${jdk}
      export ANDROID_HOME=$PWD/.android/sdk
      export PATH="$ANDROID_HOME/bin:$PWD/node_modules/.bin:$PATH"

      if ! test -d .android ; then
        echo doing hacky setup stuff:

        echo "=> pull the sdk out of the nix store and into a writeable directory"
        mkdir -p .android/sdk
        cp -r ${unpatched-sdk}/* .android/sdk/

        echo "=> don't track the sdk directory"
        echo .android/ >> .gitignore

        echo "=> get react-native-cli in here"
        npm install --no-save react-native-cli

        echo "=> set up react-native plugins... need an FHS env for... reasons."
        cd .android/sdk
          $PWD/bin/sdkmanager --update
          echo "=> installing platform stuff (you'll need to accept a license in a second)..."
          $PWD/bin/sdkmanager "platforms;android-23" "build-tools;23.0.1" "add-ons;addon-google_apis-google-23"
        cd ../../
      fi;
    '';
  }
